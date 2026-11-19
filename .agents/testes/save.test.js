// Testes das contas de salvar a captura de tela: wintermute-shell/screenshot/Save.js. Os casos saem da ficha 17, seção "Salvar e o aviso de
// salvo: conferido no Figma e como funciona" (F6-T03): o nome do arquivo no padrão do Niri, o caminho do aviso com a pasta pessoal como `~`
// "e só ela", e a conferência de "o arquivo já está dentro da pasta de capturas".
//   .agents/scripts/testar.sh save
.import "apoio.js" as T
.import "screenshot/Save.js" as S

const test = T.test, equal = T.equal, check = T.check;

// ---- o nome do arquivo ----

// A data é montada pelos campos locais (ano, mês de 0 a 11, dia, hora, minuto, segundo), e o nome usa a hora local: o teste não depende do fuso.
test("o nome é o do Niri: 'Screenshot from AAAA-MM-DD HH-MM-SS.png', na hora local", () => {
  equal(S.fileName(new Date(2026, 10, 19, 14, 32, 7), []), "Screenshot from 2026-11-19 14-32-07.png");
});

test("mês, dia, hora, minuto e segundo de um dígito ganham o zero", () => {
  equal(S.fileName(new Date(2026, 0, 5, 3, 4, 9), []), "Screenshot from 2026-01-05 03-04-09.png");
  equal(S.fileName(new Date(2026, 11, 31, 23, 59, 59), []), "Screenshot from 2026-12-31 23-59-59.png", "o fim do ano");
  equal(S.fileName(new Date(2026, 0, 1, 0, 0, 0), []), "Screenshot from 2026-01-01 00-00-00.png", "a meia-noite");
});

test("sem a lista de nomes já usados, o nome sai igual", () => {
  equal(S.fileName(new Date(2026, 10, 19, 14, 32, 7)), "Screenshot from 2026-11-19 14-32-07.png");
  equal(S.fileName(new Date(2026, 10, 19, 14, 32, 7), null), "Screenshot from 2026-11-19 14-32-07.png");
});

test("no mesmo segundo o nome ganha (2), (3) e assim por diante antes do .png", () => {
  const date = new Date(2026, 10, 19, 14, 32, 7);
  const first = "Screenshot from 2026-11-19 14-32-07.png";
  equal(S.fileName(date, [first]), "Screenshot from 2026-11-19 14-32-07 (2).png");
  equal(S.fileName(date, [first, "Screenshot from 2026-11-19 14-32-07 (2).png"]), "Screenshot from 2026-11-19 14-32-07 (3).png");
  equal(S.fileName(date, ["Screenshot from 2026-11-19 14-32-07 (2).png"]), first, "o (2) sozinho não ocupa o nome sem número");
});

test("um nome de outro segundo não conta como usado", () => {
  equal(S.fileName(new Date(2026, 10, 19, 14, 32, 8), ["Screenshot from 2026-11-19 14-32-07.png"]), "Screenshot from 2026-11-19 14-32-08.png");
});

test("o nome devolvido não leva pasta nenhuma", () => {
  check(S.fileName(new Date(2026, 10, 19, 14, 32, 7), []).indexOf("/") < 0);
});

// ---- o caminho que o aviso mostra ----

test("a pasta pessoal vira ~", () => {
  equal(S.displayPath("/home/case/Pictures/Screenshots/a.png", "/home/case"), "~/Pictures/Screenshots/a.png");
  equal(S.displayPath("/home/case/a.png", "/home/case/"), "~/a.png", "a pasta pessoal com / no fim");
  equal(S.displayPath("/home/case", "/home/case"), "~", "a própria pasta");
});

test("só a pasta pessoal: /home/case2 não é da pasta /home/case", () => {
  equal(S.displayPath("/home/case2/x.png", "/home/case"), "/home/case2/x.png");
  equal(S.displayPath("/home/cases", "/home/case"), "/home/cases");
});

test("um caminho fora da pasta pessoal aparece inteiro", () => {
  equal(S.displayPath("/tmp/x.png", "/home/case"), "/tmp/x.png");
  equal(S.displayPath("/run/user/1000/wintermute-shell/capture-1.png", "/home/case"), "/run/user/1000/wintermute-shell/capture-1.png");
});

test("sem pasta pessoal conhecida, ou sem caminho, o caminho fica como está", () => {
  equal(S.displayPath("/home/case/a.png", ""), "/home/case/a.png");
  equal(S.displayPath("/home/case/a.png", undefined), "/home/case/a.png");
  equal(S.displayPath("/home/case/a.png", "/"), "/home/case/a.png", "a raiz como pasta pessoal não vira ~");
  equal(S.displayPath("", "/home/case"), "");
  equal(S.displayPath(undefined, "/home/case"), "");
  equal(S.displayPath(null, "/home/case"), "");
});

// ---- "este arquivo já está na pasta de capturas" ----

const DIR = "/home/case/Pictures/Screenshots";

test("o arquivo está dentro da pasta, em qualquer profundidade", () => {
  check(S.isInside(DIR + "/a.png", DIR), "direto");
  check(S.isInside(DIR + "/2026/11/a.png", DIR), "numa subpasta");
  check(S.isInside(DIR + "/a.png", DIR + "/"), "a pasta com / no fim");
});

test("compara por pedaços inteiros: Screenshots2 não está em Screenshots", () => {
  check(!S.isInside("/home/case/Pictures/Screenshots2/a.png", DIR));
  check(!S.isInside("/home/case/Pictures/Screenshots-old/a.png", DIR));
  check(!S.isInside("/home/case/Pictures/a.png", DIR));
});

test("a própria pasta, ou só a pasta com / no fim, não é arquivo dentro dela", () => {
  check(!S.isInside(DIR, DIR));
  check(!S.isInside(DIR + "/", DIR));
});

test("o arquivo temporário da captura, fora da pasta, não está dentro dela", () => {
  check(!S.isInside("/run/user/1000/wintermute-shell/capture-1.png", DIR));
});

test("sem caminho ou sem pasta, não está dentro", () => {
  check(!S.isInside("", DIR));
  check(!S.isInside(undefined, DIR));
  check(!S.isInside(DIR + "/a.png", ""));
  check(!S.isInside(DIR + "/a.png", undefined));
});
