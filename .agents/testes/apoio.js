.pragma library

// Apoio dos testes das bibliotecas puras da shell (F6-T18, P-82). É o que todos os `*.test.js` desta pasta usam: `test`, `equal`,
// `near`, `check`, `skip` e `result`. Rodam no motor de JavaScript do Qt, o mesmo da shell, sem janela:
//   .agents/scripts/testar.sh [nome ...]
//
// Cada arquivo de teste importa este com `.import "apoio.js" as T` e roda os casos no próprio corpo, quando o runner o importa.
// O runner (runner.qml) lê `result()` depois e escreve o resultado no log, onde o `testar.sh` o lê.
//
// É `.pragma library` de propósito: o estado (quantos passaram, quais falharam) é um só por processo, e cada rodada do
// `testar.sh` tem o próprio processo, com um arquivo de teste só.

var passed = 0;
var failures = [];
var skipped = [];

// O valor como texto estável: as chaves dos objetos em ordem alfabética, para `{ x, y }` e `{ y, x }` serem o mesmo valor, e
// `undefined` e `NaN` aparecendo escritos (o JSON.stringify os apaga, ou os troca por null, e o caso passaria sem dever).
function show(value) {
  if (value === undefined)
    return "undefined";
  if (typeof value === "number" && !isFinite(value))
    return String(value);
  if (value === null || typeof value !== "object")
    return JSON.stringify(value);
  if (Array.isArray(value))
    return "[" + value.map(show).join(",") + "]";
  return "{" + Object.keys(value).sort().map(function (key) {
    return JSON.stringify(key) + ":" + show(value[key]);
  }).join(",") + "}";
}

// O valor que veio é igual ao esperado (comparação profunda, pelo texto de `show`).
function equal(actual, expected, message) {
  var a = show(actual);
  var e = show(expected);
  if (a !== e)
    throw new Error((message ? message + ": " : "") + "esperava " + e + " e veio " + a);
}

// O número que veio está a no máximo `tolerance` do esperado.
function near(actual, expected, tolerance, message) {
  if (typeof actual !== "number" || !(Math.abs(actual - expected) <= tolerance))
    throw new Error((message ? message + ": " : "") + "esperava " + expected + " (a menos de " + tolerance + ") e veio " + show(actual));
}

function check(condition, message) {
  if (!condition)
    throw new Error(message || "condição falsa");
}

// Um caso. Falhou = lançou. O nome é o que aparece na linha da falha.
function test(name, fn) {
  try {
    fn();
    passed++;
  } catch (error) {
    failures.push(name + ": " + error.message);
  }
}

// Um caso que a ficha pede e que a biblioteca de hoje não cumpre (falha conhecida). Fica fora da contagem e o `testar.sh` o lista
// à parte, com o motivo. Rodo o corpo mesmo assim, só para dizer se ainda falha ou se já passa (aí o aviso é para tirar o `skip`).
// `fn` pode faltar: o caso é só uma nota.
function skip(name, reason, fn) {
  var state = "sem corpo";
  if (fn) {
    try {
      fn();
      state = "passa agora: tire o skip";
    } catch (error) {
      state = "ainda falha: " + error.message;
    }
  }
  skipped.push({ name: name, reason: reason, state: state });
}

function result() {
  return { passed: passed, failures: failures, skipped: skipped };
}
