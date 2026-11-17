.pragma library

// Cálculo do launcher (ficha 14, estado "Cálculo"; pendências P-70 e P-71). Biblioteca pura: reconhece, calcula
// e formata a expressão que digitei na busca. O serviço de verdade (State.qml) e o fictício
// (demo/LauncherService.qml) usam esta mesma biblioteca, para o espécime medir o que a shell faz.
//
// Escrevi uma análise própria (descida recursiva) em vez de `eval` ou `Function`: o texto vem do teclado e
// nunca pode virar código.
//
// A busca vira cálculo quando o texto inteiro é uma expressão com pelo menos uma operação entre dois
// valores. Valem `+`, `-`, `*`, `/`, parênteses, o sinal de menos ou de mais na frente de um valor e números
// decimais com vírgula ou ponto, sem separador de milhar. Também aceito `×`, `÷` e `−`, que são os símbolos
// que o cartão mostra, para que a expressão colada de lá continue valendo.

var MAX_DECIMALS = 10;
// Acima disto o número já não tem casa decimal exata e o toFixed passaria a escrever em notação científica.
var MAX_ABSOLUTE = 1e21;

// Lista de { type: "num" | "op" | "paren", text }, ou null se houver caractere que não é da expressão.
function tokenize(text) {
  var tokens = [];
  var i = 0;
  var number = /^(\d+([.,]\d+)?|[.,]\d+)/;
  while (i < text.length) {
    var ch = text.charAt(i);
    if (/\s/.test(ch)) {
      i += 1;
      continue;
    }
    var match = number.exec(text.substring(i));
    if (match) {
      tokens.push({ type: "num", text: match[0] });
      i += match[0].length;
    } else if ("+-*/×÷−".indexOf(ch) >= 0) {
      tokens.push({ type: "op", text: ch, role: "" });
      i += 1;
    } else if (ch === "(" || ch === ")") {
      tokens.push({ type: "paren", text: ch });
      i += 1;
    } else {
      return null;
    }
  }
  return tokens;
}

function isAdditive(token) {
  return token.type === "op" && (token.text === "+" || token.text === "-" || token.text === "−");
}

function isMultiplicative(token) {
  return token.type === "op" && (token.text === "*" || token.text === "/" || token.text === "×" || token.text === "÷");
}

function isDivision(token) {
  return token.text === "/" || token.text === "÷";
}

function checked(value) {
  if (!isFinite(value))
    throw new Error("not finite");
  return value;
}

// expressão := termo (("+" | "-") termo)*
function parseExpression(state) {
  var left = parseTerm(state);
  while (state.pos < state.tokens.length && isAdditive(state.tokens[state.pos])) {
    var op = state.tokens[state.pos];
    op.role = "binary";
    state.pos += 1;
    state.binary += 1;
    var right = parseTerm(state);
    left = checked(op.text === "+" ? left + right : left - right);
  }
  return left;
}

// termo := unário (("*" | "/") unário)*
function parseTerm(state) {
  var left = parseUnary(state);
  while (state.pos < state.tokens.length && isMultiplicative(state.tokens[state.pos])) {
    var op = state.tokens[state.pos];
    op.role = "binary";
    state.pos += 1;
    state.binary += 1;
    var right = parseUnary(state);
    if (isDivision(op)) {
      if (right === 0)
        throw new Error("division by zero");
      left = checked(left / right);
    } else {
      left = checked(left * right);
    }
  }
  return left;
}

// unário := ("-" | "+") unário | primário
function parseUnary(state) {
  var token = state.tokens[state.pos];
  if (token && isAdditive(token)) {
    token.role = "unary";
    state.pos += 1;
    var value = parseUnary(state);
    return token.text === "+" ? value : -value;
  }
  return parsePrimary(state);
}

// primário := número | "(" expressão ")"
function parsePrimary(state) {
  var token = state.tokens[state.pos];
  if (!token)
    throw new Error("unexpected end");
  if (token.type === "num") {
    state.pos += 1;
    return parseFloat(token.text.replace(",", "."));
  }
  if (token.type === "paren" && token.text === "(") {
    state.pos += 1;
    var value = parseExpression(state);
    var close = state.tokens[state.pos];
    if (!close || close.type !== "paren" || close.text !== ")")
      throw new Error("missing )");
    state.pos += 1;
    return value;
  }
  throw new Error("unexpected token");
}

// { value, tokens } quando o texto inteiro é um cálculo; null quando não é (número sozinho, texto,
// expressão incompleta, divisão por zero, resultado grande demais).
function analyze(text) {
  try {
    var tokens = tokenize(String(text));
    if (!tokens || tokens.length === 0)
      return null;
    var state = { tokens: tokens, pos: 0, binary: 0 };
    var value = parseExpression(state);
    if (state.pos !== tokens.length || state.binary === 0)
      return null;
    if (!isFinite(value) || Math.abs(value) >= MAX_ABSOLUTE)
      return null;
    return { value: value, tokens: tokens };
  } catch (error) {
    // Expressão incompleta, divisão por zero ou aninhamento fundo demais: a busca segue normal.
    return null;
  }
}

function localize(digits, separator) {
  return digits.replace(/[.,]/, separator);
}

// Até 10 casas decimais, sem zeros no fim, com o separador decimal pedido e sem separador de milhar.
function formatNumber(value, separator) {
  var text = value.toFixed(MAX_DECIMALS);
  if (text.indexOf(".") >= 0)
    text = text.replace(/0+$/, "").replace(/\.$/, "");
  if (text === "-0")
    text = "0";
  return localize(text, separator);
}

// A expressão como o cartão mostra: operador com um espaço de cada lado, × ÷ −, e os números que digitei no
// separador do locale (as casas decimais ficam como digitei). O sinal na frente de um valor não leva espaço.
function formatExpression(tokens, separator) {
  var glyphs = { "*": "×", "×": "×", "/": "÷", "÷": "÷", "-": "−", "−": "−", "+": "+" };
  var out = "";
  tokens.forEach(function (token) {
    if (token.type === "num")
      out += localize(token.text, separator);
    else if (token.type === "op" && token.role === "binary")
      out += " " + glyphs[token.text] + " ";
    else if (token.type === "op")
      out += glyphs[token.text];
    else
      out += token.text;
  });
  return out;
}

// "0x1CC" quando o resultado (como aparece, com no máximo 10 casas) é inteiro, não negativo e cabe em
// inteiro exato; vazio nos outros casos.
function hexadecimal(value) {
  var shown = Number(value.toFixed(MAX_DECIMALS));
  if (!Number.isInteger(shown) || shown < 0 || shown > Number.MAX_SAFE_INTEGER)
    return "";
  return "0x" + shown.toString(16).toUpperCase();
}

// Tudo o que o launcher precisa do texto digitado, ou null quando o texto não é um cálculo:
//   expression  a expressão formatada para o cartão
//   result      o resultado formatado, o mesmo texto que o cartão mostra e que "Copy result" copia
//   hex         "0x…" ou ""
//   rows        as linhas de ação, no formato das linhas do launcher; `copy` é o texto que o Enter copia
function describe(text, separator) {
  var analysis = analyze(text);
  if (!analysis)
    return null;
  var result = formatNumber(analysis.value, separator);
  var hex = hexadecimal(analysis.value);
  var rows = [{ title: "Copy result", detail: result, kind: "Action", icon: "copy", copy: result }];
  if (hex !== "")
    rows.push({ title: "In hexadecimal", detail: hex, kind: "Action", icon: "hash", copy: hex });
  return {
    expression: formatExpression(analysis.tokens, separator),
    result: result,
    hex: hex,
    rows: rows
  };
}
