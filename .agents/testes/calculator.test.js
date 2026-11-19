// Testes do cálculo do launcher: wintermute-shell/launcher/Calculator.js. Os casos saem da ficha 14, seção "Cálculo: como funciona"
// (F5-T03, P-70 e P-71) e do estado "Cálculo" do board; as contas conferi à mão.
//   .agents/scripts/testar.sh calculator
.import "apoio.js" as T
.import "launcher/Calculator.js" as C

const test = T.test, equal = T.equal, check = T.check;

const value = (text) => { const a = C.analyze(text); return a ? a.value : null; };
const isCalc = (text) => C.analyze(text) !== null;

// ---- quando a busca vira cálculo ----

test("o exemplo do board: 128*3,5+12 dá 460", () => {
  equal(value("128*3,5+12"), 460);   // 128 × 3,5 = 448; 448 + 12 = 460
});

test("a multiplicação e a divisão vêm antes da soma e da subtração", () => {
  equal(value("2+3*4"), 14);
  equal(value("2*3+4"), 10);
  equal(value("10-6/3"), 8);
});

test("os parênteses mudam a ordem", () => {
  equal(value("(2+3)*4"), 20);
  equal(value("2*(3+4)"), 14);
  equal(value("((1+2))*3"), 9);
});

test("as operações do mesmo nível andam da esquerda para a direita", () => {
  equal(value("10-4-3"), 3);       // (10 - 4) - 3, e não 10 - (4 - 3)
  equal(value("100/10/5"), 2);     // (100 / 10) / 5
  equal(value("2*3/4"), 1.5);
});

test("o sinal na frente de um valor vale (2*-3)", () => {
  equal(value("2*-3"), -6);
  equal(value("-2+5"), 3);
  equal(value("+5+1"), 6);
  equal(value("2--3"), 5);
  equal(value("-(2+3)"), -5);
});

test("também aceito os símbolos que o cartão mostra: × ÷ −", () => {
  equal(value("6×7"), 42);
  equal(value("8÷2"), 4);
  equal(value("9−4"), 5);
  equal(value("6×7−2÷2"), 41);
});

test("vírgula e ponto valem como separador decimal", () => {
  equal(value("1,5+1,5"), 3);
  equal(value("1.5+1"), 2.5);
  equal(value("0,25*4"), 1);
});

test("espaços entre os termos não atrapalham", () => {
  equal(value("  1 +   2 "), 3);
  equal(value("128 * 3,5 + 12"), 460);
});

test("um número sozinho não é cálculo, nem entre parênteses", () => {
  check(!isCalc("42"), "42");
  check(!isCalc("-5"), "-5");
  check(!isCalc("+5"), "+5");
  check(!isCalc("3,14"), "3,14");
  check(!isCalc("(5)"), "(5)");
  check(!isCalc("-(5)"), "-(5)");
});

test("expressão incompleta, mal formada ou com texto não é cálculo", () => {
  ["2+", "+", "*3", "2*", "(2+3", "2+3)", "()", "2 3", "2++", "2**3", "abc", "2+a", "1e5+1", "2+3=", "", "   ", "1,2,3+1"].forEach((text) => {
    check(!isCalc(text), "'" + text + "' não devia ser cálculo");
  });
});

test("divisão por zero não vira cálculo", () => {
  check(!isCalc("1/0"), "1/0");
  check(!isCalc("5÷0"), "5÷0");
  check(!isCalc("1/(2-2)"), "1/(2-2)");
  check(!isCalc("4/0,0"), "4/0,0");
  equal(value("0/5"), 0, "zero dividido é cálculo");
});

test("a partir de 10²¹ em módulo não vira cálculo", () => {
  check(!isCalc("1000000000000*1000000000"), "10^21 exato");
  check(!isCalc("-1000000000000*1000000000"), "-10^21");
  check(isCalc("1000000000000*999999999"), "9,99…e20 ainda vale");
  check(!isCalc("99999999999*99999999999"), "uns 10^22");
});

test("o texto nunca vira código: nada de eval", () => {
  ["process.exit()", "2+2;alert(1)", "constructor", "(function(){})()", "1+__proto__", "`1+1`", "1+${2}"].forEach((text) => {
    check(!isCalc(text), "'" + text + "' não devia ser cálculo");
  });
});

test("o aninhamento fundo demais cai em 'não é cálculo', sem travar", () => {
  const depth = 3000;
  check(!isCalc("(".repeat(depth) + "1+1" + ")".repeat(depth)));
  equal(value("((((1+1))))"), 2, "o aninhamento normal continua valendo");
});

// ---- o resultado ----

test("o resultado sai com até 10 casas decimais e sem zeros no fim", () => {
  equal(C.describe("1/3", ".").result, "0.3333333333");
  equal(C.describe("10/4", ".").result, "2.5");
  equal(C.describe("2.5*2", ".").result, "5", "sem ponto sobrando");
  equal(C.describe("0.1+0.2", ".").result, "0.3", "o erro de ponto flutuante some");
  equal(C.describe("2/3", ".").result, "0.6666666667", "arredonda na 10ª casa");
});

test("o separador decimal é o que quem chama pede, no resultado", () => {
  equal(C.describe("10/4", ",").result, "2,5");
  equal(C.describe("1/3", ",").result, "0,3333333333");
  equal(C.describe("1.5+1", ".").result, "2.5");
});

test("sem separador de milhar", () => {
  equal(C.describe("1000*1000", ".").result, "1000000");
  equal(C.describe("1000*1000", ",").result, "1000000");
});

test("o resultado negativo leva o sinal, e menos zero vira zero", () => {
  equal(C.describe("1-5", ".").result, "-4");
  equal(C.describe("-1/3", ".").result, "-0.3333333333");
  equal(C.describe("0*-1", ".").result, "0");
  equal(C.describe("0,00000000001*-1", ".").result, "0", "o que sobra abaixo da 10ª casa também é zero");
});

// ---- o cartão: a expressão formatada ----

test("a expressão do cartão: um espaço de cada lado e × ÷ −", () => {
  equal(C.describe("128*3,5+12", ",").expression, "128 × 3,5 + 12");   // o exemplo da ficha
  equal(C.describe("8/2", ",").expression, "8 ÷ 2");
  equal(C.describe("9-4", ",").expression, "9 − 4");
  equal(C.describe("1+1", ",").expression, "1 + 1");
});

test("a expressão colada do cartão continua valendo e sai igual", () => {
  const colada = "128 × 3,5 + 12";
  equal(C.describe(colada, ",").expression, colada);
  equal(C.describe(colada, ",").result, "460");
});

test("o sinal na frente de um valor não leva espaço", () => {
  equal(C.describe("2*-3", ",").expression, "2 × −3");
  equal(C.describe("-5+10", ",").expression, "−5 + 10");
  equal(C.describe("+5+10", ",").expression, "+5 + 10");
});

test("os parênteses ficam e os números seguem o separador pedido, com as casas como digitei", () => {
  equal(C.describe("(1+2)*3", ",").expression, "(1 + 2) × 3");
  equal(C.describe("1,50+1", ".").expression, "1.50 + 1", "o zero que digitei fica");
  equal(C.describe("1.5+1", ",").expression, "1,5 + 1");
});

// ---- hexadecimal ----

test("o hexadecimal só aparece quando o resultado é inteiro e não negativo", () => {
  equal(C.describe("128*3,5+12", ",").hex, "0x1CC");   // 460 = 0x1CC, o exemplo da ficha
  equal(C.describe("255+0", ",").hex, "0xFF");
  equal(C.describe("0/5", ",").hex, "0x0");
  equal(C.describe("1-5", ",").hex, "", "negativo");
  equal(C.describe("1/2", ",").hex, "", "fracionário");
});

test("o hexadecimal vale para o que aparece: com 10 casas o erro de ponto flutuante já sumiu", () => {
  // 0,7 + 0,1 + 0,2 dá 0,9999999999999999 no ponto flutuante, e aparece como 1
  equal(C.describe("0.7+0.1+0.2", ".").result, "1");
  equal(C.describe("0.7+0.1+0.2", ".").hex, "0x1");
});

test("as linhas de ação: Copy result e, se houver, In hexadecimal", () => {
  const withHex = C.describe("128*3,5+12", ",");
  equal(withHex.rows, [
    { title: "Copy result", detail: "460", kind: "Action", icon: "copy", copy: "460" },
    { title: "In hexadecimal", detail: "0x1CC", kind: "Action", icon: "hash", copy: "0x1CC" }
  ]);
  const without = C.describe("1/2", ",");
  equal(without.rows, [{ title: "Copy result", detail: "0,5", kind: "Action", icon: "copy", copy: "0,5" }]);
});

test("o que o Enter copia é o texto que o cartão mostra, com o separador do locale", () => {
  const d = C.describe("5/2", ",");
  equal(d.result, "2,5");
  equal(d.rows[0].copy, d.result);
});

test("describe devolve null quando o texto não é cálculo", () => {
  equal(C.describe("42", ","), null);
  equal(C.describe("2+", ","), null);
  equal(C.describe("hello", ","), null);
  equal(C.describe("1/0", ","), null);
});
