// Testes da grade do mês do calendário: wintermute-shell/calendar/Dates.js. Os casos saem da ficha 09, "Calendário" (a semana começa na
// segunda, a grade tem sempre 6 linhas de 7 dias, os dias de outro mês completam a primeira e a última linha, o dia de hoje e a faixa da
// semana atual) e do comentário da biblioteca ("aritmética de calendário local, não de milissegundos, para continuar certa na troca
// de horário de verão"). Os dias da semana e as datas esperadas conferi à mão no calendário de 2026 a 2028 (1º de novembro de 2026 é um
// domingo; 1º de fevereiro de 2027 é uma segunda; 1º de fevereiro de 2028 é uma terça, num ano bissexto).
// Toda data é montada pelos campos locais (`new Date(ano, mês de 0 a 11, dia, hora)`), nunca por texto ISO: o teste passa em qualquer fuso.
//   .agents/scripts/testar.sh dates
.import "apoio.js" as T
.import "calendar/Dates.js" as D

const test = T.test, equal = T.equal, check = T.check;

// A data como [ano, mês de 1 a 12, dia], para as comparações ficarem legíveis.
const ymd = (date) => [date.getFullYear(), date.getMonth() + 1, date.getDate()];
const grid = (year, month) => D.monthDays(new Date(year, month - 1, 15, 12)).map(ymd);

// ---- o primeiro dia do mês e o deslocamento de mês ----

test("monthStart é o dia 1 do mês da data dada, seja qual for a hora", () => {
  equal(ymd(D.monthStart(new Date(2026, 10, 19, 23, 59))), [2026, 11, 1]);
  equal(ymd(D.monthStart(new Date(2026, 10, 1, 0, 0))), [2026, 11, 1], "já é o dia 1, à meia-noite");
  equal(ymd(D.monthStart(new Date(2026, 11, 31, 23, 59))), [2026, 12, 1], "último dia do ano");
});

test("shiftMonth anda de mês em mês e atravessa a virada do ano nos dois sentidos", () => {
  const nov = new Date(2026, 10, 19, 12);
  equal(ymd(D.shiftMonth(nov, 1)), [2026, 12, 1]);
  equal(ymd(D.shiftMonth(nov, 2)), [2027, 1, 1], "dezembro para janeiro");
  equal(ymd(D.shiftMonth(nov, -1)), [2026, 10, 1]);
  equal(ymd(D.shiftMonth(new Date(2026, 0, 10, 12), -1)), [2025, 12, 1], "janeiro para dezembro do ano anterior");
  equal(ymd(D.shiftMonth(nov, 0)), [2026, 11, 1]);
  equal(ymd(D.shiftMonth(nov, 12)), [2027, 11, 1]);
  equal(ymd(D.shiftMonth(nov, -23)), [2024, 12, 1]);
});

test("shiftMonth sai de um dia 31 sem pular mês: 31 de janeiro mais um mês é fevereiro, não março", () => {
  equal(ymd(D.shiftMonth(new Date(2027, 0, 31, 12), 1)), [2027, 2, 1]);
  equal(ymd(D.shiftMonth(new Date(2026, 2, 31, 12), -1)), [2026, 2, 1], "31 de março menos um mês");
  equal(ymd(D.shiftMonth(new Date(2028, 0, 30, 12), 1)), [2028, 2, 1], "ano bissexto");
});

test("monthStart e shiftMonth não mexem na data que receberam", () => {
  const date = new Date(2026, 10, 19, 12);
  const before = date.getTime();
  D.monthStart(date);
  D.shiftMonth(date, 3);
  D.monthDays(date);
  equal(date.getTime(), before);
});

// ---- comparar mês e dia ----

test("sameMonth: mesmo mês do mesmo ano, qualquer dia e hora", () => {
  check(D.sameMonth(new Date(2026, 10, 1, 0, 0), new Date(2026, 10, 30, 23, 59)));
  check(!D.sameMonth(new Date(2026, 10, 15, 12), new Date(2026, 9, 15, 12)), "mês diferente");
  check(!D.sameMonth(new Date(2026, 10, 15, 12), new Date(2027, 10, 15, 12)), "o mesmo mês de outro ano não é o mesmo mês");
  check(!D.sameMonth(new Date(2026, 11, 31, 12), new Date(2027, 0, 1, 12)), "a virada do ano");
});

test("sameDay: o mesmo dia do calendário, em qualquer hora", () => {
  check(D.sameDay(new Date(2026, 10, 19, 0, 0, 0), new Date(2026, 10, 19, 23, 59, 59)), "de uma ponta à outra do dia");
  check(!D.sameDay(new Date(2026, 10, 19, 23, 59), new Date(2026, 10, 20, 0, 1)), "dois minutos de distância, mas dias diferentes");
  check(!D.sameDay(new Date(2026, 10, 19, 12), new Date(2026, 9, 19, 12)), "o mesmo número em outro mês");
  check(!D.sameDay(new Date(2026, 10, 19, 12), new Date(2027, 10, 19, 12)), "o mesmo número no mesmo mês de outro ano");
});

// ---- a grade do mês ----

test("novembro de 2026 começa num domingo: a grade abre na segunda 26 de outubro e fecha no domingo 6 de dezembro", () => {
  const days = grid(2026, 11);
  equal(days.length, 42);
  equal(days[0], [2026, 10, 26], "a primeira linha tem 6 dias de outubro");
  equal(days[5], [2026, 10, 31]);
  equal(days[6], [2026, 11, 1], "o dia 1 é o domingo, a sétima célula");
  equal(days[35], [2026, 11, 30]);
  equal(days[36], [2026, 12, 1], "depois do dia 30 vêm os dias de dezembro");
  equal(days[41], [2026, 12, 6]);
});

test("um mês que começa na segunda não tem dia de fora antes do dia 1 (fevereiro de 2027)", () => {
  const days = grid(2027, 2);
  equal(days[0], [2027, 2, 1]);
  equal(days[27], [2027, 2, 28]);
  equal(days[28], [2027, 3, 1], "a quinta linha já é de março");
  equal(days[41], [2027, 3, 14]);
});

test("a grade atravessa a virada do ano: dezembro de 2026 abre em 30 de novembro e fecha em 10 de janeiro; janeiro de 2026 abre em 29 de dezembro de 2025", () => {
  const dec = grid(2026, 12);
  equal(dec[0], [2026, 11, 30]);
  equal(dec[1], [2026, 12, 1]);
  equal(dec[41], [2027, 1, 10]);
  const jan = grid(2026, 1);
  equal(jan[0], [2025, 12, 29]);
  equal(jan[3], [2026, 1, 1], "1º de janeiro de 2026 é uma quinta, a quarta célula");
});

test("fevereiro de um ano bissexto tem o dia 29 (2028)", () => {
  const days = grid(2028, 2);
  equal(days[0], [2028, 1, 31], "1º de fevereiro de 2028 é uma terça");
  equal(days[29], [2028, 2, 29]);
  equal(days[30], [2028, 3, 1]);
  const common = grid(2027, 2).filter((day) => day[1] === 2);
  equal(common.length, 28, "e 2027 não tem");
});

test("qualquer data do mês dá a mesma grade, e a hora não importa", () => {
  const base = grid(2026, 11);
  equal(D.monthDays(new Date(2026, 10, 1, 0, 0)).map(ymd), base, "o dia 1 à meia-noite");
  equal(D.monthDays(new Date(2026, 10, 30, 23, 59)).map(ymd), base, "o dia 30 à meia-noite menos um minuto");
  equal(D.monthDays(D.monthStart(new Date(2026, 10, 19, 8))).map(ymd), base, "pelo monthStart");
});

test("a grade tem sempre 6 linhas de 7, abre numa segunda, tem o dia 1 na primeira linha e cada dia do mês uma vez (84 meses, de 2024 a 2030)", () => {
  // A ficha 09: "a grade tem sempre 6 linhas, então o painel fica com 296 de altura" e "semana começa na segunda". O dia da semana vem do
  // getDay() do próprio motor (1 é segunda), e a contagem de dias do mês, de uma conta à parte, para eu não repetir a fórmula da biblioteca.
  const lengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  for (let year = 2024; year <= 2030; year++) {
    const leap = (year % 4 === 0 && year % 100 !== 0) || year % 400 === 0;
    for (let month = 1; month <= 12; month++) {
      const where = year + "-" + month;
      const days = D.monthDays(new Date(year, month - 1, 20, 12));
      equal(days.length, 42, where + ": 42 dias");
      equal(days[0].getDay(), 1, where + ": a primeira célula é uma segunda");
      const first = days.findIndex((day) => day.getDate() === 1 && day.getMonth() === month - 1);
      check(first >= 0 && first < 7, where + ": o dia 1 está na primeira linha (índice " + first + ")");
      const inMonth = days.filter((day) => D.sameMonth(day, new Date(year, month - 1, 1, 12)));
      equal(inMonth.map((day) => day.getDate()), Array.from({ length: lengths[month - 1] + (month === 2 && leap ? 1 : 0) }, (_, i) => i + 1), where + ": cada dia do mês uma vez, em ordem");
    }
  }
});

test("os dias da grade são consecutivos pelo calendário local, mesmo nos meses com troca de horário de verão", () => {
  // O comentário da biblioteca: aritmética de calendário, não de milissegundos, para continuar certa na troca de horário de verão.
  // Cada dia é o seguinte do anterior pelo calendário (o `new Date(a, m, d + 1)` do próprio motor), em todos os meses de 2026 e 2027.
  for (let year = 2026; year <= 2027; year++) {
    for (let month = 1; month <= 12; month++) {
      const days = D.monthDays(new Date(year, month - 1, 1, 12));
      for (let i = 1; i < days.length; i++) {
        const previous = days[i - 1];
        const expected = new Date(previous.getFullYear(), previous.getMonth(), previous.getDate() + 1, 12);
        equal(ymd(days[i]), ymd(expected), year + "-" + month + " célula " + i);
      }
    }
  }
});

// ---- a semana atual ----

test("currentWeekRow dá a linha do dia de hoje na grade (a faixa da semana atual)", () => {
  const days = D.monthDays(new Date(2026, 10, 1, 12));            // 26/10 a 06/12
  equal(D.currentWeekRow(days, new Date(2026, 10, 19, 9, 30)), 3, "quinta 19 de novembro: índice 24, linha 3");
  equal(D.currentWeekRow(days, new Date(2026, 9, 26, 0, 0)), 0, "a primeira célula, segunda 26 de outubro");
  equal(D.currentWeekRow(days, new Date(2026, 10, 1, 23, 59)), 0, "domingo 1º de novembro fecha a primeira linha");
  equal(D.currentWeekRow(days, new Date(2026, 10, 2, 0, 0)), 1, "segunda 2 de novembro abre a segunda linha");
  equal(D.currentWeekRow(days, new Date(2026, 10, 30, 12)), 5, "30 de novembro, na última linha");
  equal(D.currentWeekRow(days, new Date(2026, 11, 6, 12)), 5, "a última célula, domingo 6 de dezembro");
});

test("currentWeekRow dá -1 quando hoje não está na grade, e a faixa não aparece", () => {
  const days = D.monthDays(new Date(2026, 10, 1, 12));
  equal(D.currentWeekRow(days, new Date(2026, 9, 25, 12)), -1, "um dia antes da primeira célula");
  equal(D.currentWeekRow(days, new Date(2026, 11, 7, 12)), -1, "um dia depois da última");
  equal(D.currentWeekRow(days, new Date(2027, 10, 19, 12)), -1, "o mesmo dia e mês, em outro ano");
  equal(D.currentWeekRow(D.monthDays(new Date(2027, 1, 1, 12)), new Date(2026, 10, 19, 12)), -1, "outro mês navegado");
  equal(D.currentWeekRow([], new Date(2026, 10, 19, 12)), -1, "grade vazia");
});

test("hoje também está na grade de um mês vizinho quando cai num dia de fora: a faixa aparece na linha dele", () => {
  // Dezembro de 2026 abre em 30 de novembro (segunda): o dia 30 de novembro é a célula 0, linha 0.
  const dec = D.monthDays(new Date(2026, 11, 1, 12));
  equal(D.currentWeekRow(dec, new Date(2026, 10, 30, 12)), 0);
  equal(D.currentWeekRow(dec, new Date(2026, 11, 1, 12)), 0, "e o dia 1, a terça seguinte, na mesma linha");
  equal(D.currentWeekRow(dec, new Date(2026, 11, 7, 12)), 1, "segunda 7 de dezembro abre a segunda linha");
});
