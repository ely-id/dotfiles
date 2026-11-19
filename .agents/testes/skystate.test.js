// Testes do céu do papel de parede dinâmico: wintermute-shell/wallpaper/daylight/SkyState.js. Aqui a ficha não traz valor: a fonte dos casos é
// o comentário da própria biblioteca, que diz o que ela calcula. Por isso testo **propriedades**, e não números copiados
// da saída da biblioteca nem da tabela de cores da origem (que é a única fonte dos valores):
//   - "Map local time onto the palette cycle, keeping the value and rate of change continuous at midnight": o céu é contínuo, e a
//     passagem da meia-noite não tem salto nem quebra de ritmo; 0h e 24h são o mesmo instante;
//   - "Shape-preserving cubic interpolation avoids overshooting colors and band positions": entre duas âncoras nenhum canal passa do
//     que as duas âncoras têm;
//   - "Each time anchor defines six bands: zenith, upper sky, middle sky, haze, horizon, lower edge": seis faixas, da primeira (0) à
//     última (1) no mesmo sentido, em qualquer hora;
//   - os limites que `sanitize` impõe (`LIMITS`) e o padrão que ele usa (`DEFAULTS`), sem os valores de cada um escritos aqui;
//   - o nascer e o pôr do sol configuráveis: o céu no nascer é o mesmo, qualquer que seja a hora em que ele cai; o dia anda para a frente
//     e nunca volta;
//   - a noite é mais escura que o dia, e o meio-dia está no dia.
// Os pontos de referência de cor (preto, branco e o vermelho puro do sRGB no Oklab) são os do texto de Björn Ottosson, citado no comentário
// da conversão. As datas e as horas não entram: a hora é o número de horas decimais do relógio local, o que o Sky.qml passa.
//   .agents/scripts/testar.sh skystate
.import "apoio.js" as T
.import "wallpaper/daylight/SkyState.js" as K

const test = T.test, equal = T.equal, near = T.near, check = T.check;

// Todos os números de um estado do céu, em fila: posição e cor (L, a, b) de cada uma das seis faixas.
const flat = (state) => state.stops.reduce((all, stop) => all.concat([stop.position], stop.color), []);
const maxDiff = (a, b) => a.reduce((worst, value, i) => Math.max(worst, Math.abs(value - b[i])), 0);
const sky = (hour, settings) => K.skyState(hour, settings);
const lightness = (state) => state.stops.reduce((sum, stop) => sum + stop.color[0], 0) / state.stops.length;
// Todas as horas de 0 a 24, a cada quarto de hora (sem o 24).
const hours = Array.from({ length: 96 }, (_, i) => i / 4);

// ---- o relógio ----

test("wrap leva qualquer hora para o intervalo de 0 a 24", () => {
  equal(K.wrap(0), 0);
  equal(K.wrap(24), 0, "24 é a meia-noite do dia seguinte");
  equal(K.wrap(25.5), 1.5);
  equal(K.wrap(-1), 23);
  equal(K.wrap(-24), 0);
  equal(K.wrap(-0.5), 23.5);
  equal(K.wrap(48 + 6.5), 6.5);
});

test("o estado devolve a hora do relógio já dentro de 0 a 24", () => {
  equal(sky(13.25).hour, 13.25);
  equal(sky(24).hour, 0);
  equal(sky(-1).hour, 23);
  equal(sky(25).hour, 1);
});

// ---- os ajustes ----

test("sanitize: sem ajuste nenhum, ou com valor que não é número, vale o padrão", () => {
  equal(K.sanitize({}), K.DEFAULTS);
  equal(K.sanitize({ brightness: NaN, saturation: "0.5", warmth: null, horizon: undefined, twilight: Infinity }), K.DEFAULTS, "NaN, texto, nulo, ausente e infinito");
});

test("sanitize: cada ajuste é preso ao intervalo dele, e o que está dentro passa como veio", () => {
  Object.keys(K.LIMITS).forEach((key) => {
    const low = K.LIMITS[key][0], high = K.LIMITS[key][1];
    const middle = (low + high) / 2;
    const settings = {};
    settings[key] = low - 100;
    equal(K.sanitize(settings)[key], low, key + ": abaixo vai para o mínimo");
    settings[key] = high + 100;
    equal(K.sanitize(settings)[key], high, key + ": acima vai para o máximo");
    settings[key] = low;
    equal(K.sanitize(settings)[key], low, key + ": o mínimo passa");
    settings[key] = high;
    equal(K.sanitize(settings)[key], high, key + ": o máximo passa");
    settings[key] = middle;
    equal(K.sanitize(settings)[key], middle, key + ": o meio passa");
  });
});

test("o padrão cabe nos próprios intervalos, e os dois têm os mesmos ajustes", () => {
  equal(Object.keys(K.DEFAULTS).sort(), Object.keys(K.LIMITS).sort());
  Object.keys(K.DEFAULTS).forEach((key) => {
    check(K.DEFAULTS[key] >= K.LIMITS[key][0] && K.DEFAULTS[key] <= K.LIMITS[key][1], key + " fora do intervalo");
  });
  check(K.DEFAULTS.sunrise < K.DEFAULTS.sunset, "o dia nasce antes de se pôr");
  check(K.DEFAULTS.sunrise < 12 && K.DEFAULTS.sunset > 12, "o meio-dia cai no dia (a ficha 11 usa o sunrise e o sunset do padrão como a regra do tema escuro)");
});

test("sanitize não mexe no que recebeu e o padrão não muda", () => {
  const settings = { brightness: 99, saturation: 0.3 };
  const before = JSON.stringify(settings);
  const result = K.sanitize(settings);
  equal(JSON.stringify(settings), before);
  check(result !== K.DEFAULTS, "devolve um objeto novo");
  result.brightness = 0.5;
  equal(K.sanitize({}).brightness, K.DEFAULTS.brightness, "mudar o resultado não muda o padrão");
  check(Object.isFrozen(K.DEFAULTS), "o padrão é congelado");
});

test("o estado leva os ajustes já presos aos limites, e sem ajustes vale o padrão", () => {
  equal(sky(12, { brightness: 5, sunrise: 0 }).options.brightness, K.LIMITS.brightness[1]);
  equal(sky(12, { brightness: 5, sunrise: 0 }).options.sunrise, K.LIMITS.sunrise[0]);
  equal(sky(12).options, K.DEFAULTS);
  equal(sky(12, {}).options, K.DEFAULTS);
});

// ---- a conversão de cor ----

test("hexToLab: os pontos de referência do Oklab (preto, branco e o vermelho do sRGB)", () => {
  // Os valores do texto de Ottosson: preto (0, 0, 0), branco (1, 0, 0) e vermelho puro do sRGB (0,628, 0,2249, 0,1258).
  const black = K.hexToLab("000000"), white = K.hexToLab("ffffff"), red = K.hexToLab("ff0000");
  near(black[0], 0, 1e-6); near(black[1], 0, 1e-6); near(black[2], 0, 1e-6);
  near(white[0], 1, 1e-4); near(white[1], 0, 1e-4); near(white[2], 0, 1e-4);
  near(red[0], 0.628, 1e-3); near(red[1], 0.2249, 1e-3); near(red[2], 0.1258, 1e-3);
});

test("hexToLab: cinza não tem croma, e a luminosidade cresce com o cinza", () => {
  const dark = K.hexToLab("333333"), middle = K.hexToLab("808080"), light = K.hexToLab("cccccc");
  [dark, middle, light].forEach((lab) => { near(lab[1], 0, 1e-3); near(lab[2], 0, 1e-3); });
  check(dark[0] < middle[0] && middle[0] < light[0], "luminosidade em ordem");
  equal(K.hexToLab("FFFFFF").map((v) => Math.round(v * 1e6)), K.hexToLab("ffffff").map((v) => Math.round(v * 1e6)), "maiúsculas valem como minúsculas");
});

// ---- a forma do céu ----

test("o céu tem sempre seis faixas, da primeira em 0 à última em 1, em ordem, com cor de três números finitos", () => {
  hours.forEach((hour) => {
    const state = sky(hour);
    equal(state.stops.length, 6, hour + "h");
    near(state.stops[0].position, 0, 1e-9, hour + "h: a primeira faixa fica em 0");
    near(state.stops[5].position, 1, 1e-9, hour + "h: a última fica em 1");
    for (let i = 1; i < 6; i++)
      check(state.stops[i].position > state.stops[i - 1].position, hour + "h: faixa " + i + " depois da " + (i - 1));
    state.stops.forEach((stop) => {
      equal(stop.color.length, 3);
      check(isFinite(stop.position) && stop.color.every(isFinite), hour + "h: número que não é finito");
    });
  });
});

test("o ajuste do horizonte desloca só as faixas do meio: valor maior leva as posições para perto do 1 (a base), valor menor para perto do 0, e as pontas ficam", () => {
  [3, 12, 18.5].forEach((hour) => {
    const low = sky(hour, { horizon: K.LIMITS.horizon[0] }), high = sky(hour, { horizon: K.LIMITS.horizon[1] });
    near(low.stops[0].position, 0, 1e-9); near(high.stops[0].position, 0, 1e-9);
    near(low.stops[5].position, 1, 1e-9); near(high.stops[5].position, 1, 1e-9);
    for (let i = 1; i < 5; i++)
      check(high.stops[i].position > low.stops[i].position, hour + "h, faixa " + i + ": o horizonte alto deixa a faixa mais para baixo na tela");
    for (let i = 1; i < 6; i++) {
      check(low.stops[i].position > low.stops[i - 1].position && high.stops[i].position > high.stops[i - 1].position, hour + "h: a ordem se mantém");
    }
  });
});

test("o horizonte muda só as posições, nunca as cores, e os outros ajustes não mexem nas faixas", () => {
  const base = sky(9);
  const horizon = sky(9, { horizon: K.LIMITS.horizon[0] });
  equal(horizon.stops.map((stop) => stop.color), base.stops.map((stop) => stop.color));
  const others = sky(9, { brightness: 0.5, saturation: 0.2, warmth: -0.02 });
  equal(others.stops, base.stops, "brilho, saturação e calor são do shader, e as faixas ficam");
});

// ---- a continuidade ----

test("0h e 24h são o mesmo céu, e um dia a mais ou a menos também", () => {
  [0, 3.7, 6.5, 12, 18.5, 23.9].forEach((hour) => {
    check(maxDiff(flat(sky(hour)), flat(sky(hour + 24))) < 1e-9, hour + "h contra " + (hour + 24) + "h");
    check(maxDiff(flat(sky(hour)), flat(sky(hour - 24))) < 1e-9, hour + "h contra " + (hour - 24) + "h");
  });
  check(maxDiff(flat(sky(0)), flat(sky(24))) < 1e-9, "meia-noite");
  near(sky(0).solarHour, sky(24).solarHour, 1e-9);
});

test("o céu não dá salto em lugar nenhum do dia: o passo de um minuto cai pela metade quando o passo cai pela metade, também através da meia-noite", () => {
  // Numa função contínua o maior passo é proporcional ao tamanho do passo: com a metade do passo, a metade da diferença. Um salto (de uma
  // âncora para outra, ou na meia-noite) dá a mesma diferença seja qual for o passo, e a razão ficaria perto de 1. Percorro as 24 horas, o
  // último passo passando por 24 h, e o limite de 0,6 deixa folga sobre os 0,5 da conta.
  const worst = (step) => {
    let result = 0;
    for (let hour = 0; hour < 24; hour += step)
      result = Math.max(result, maxDiff(flat(sky(hour)), flat(sky(hour + step))));
    return result;
  };
  const coarse = worst(1 / 60), fine = worst(1 / 120);
  check(coarse > 0, "o céu muda ao longo do dia");
  check(fine < 0.6 * coarse, "passo de 1 min: " + coarse + "; de 30 s: " + fine + " (esperava cerca da metade)");
  const across = maxDiff(flat(sky(24 - 1 / 120)), flat(sky(24 + 1 / 120)));
  check(across <= coarse, "o passo de um minuto sobre a meia-noite (" + across + ") não passa do maior passo do dia");
});

test("o ritmo de mudança também é contínuo na meia-noite e nas âncoras: a inclinação antes e depois quase não difere", () => {
  // "keeping the value and rate of change continuous at midnight": a derivada dos dois lados do ponto é a mesma. Meço pela diferença
  // finita de 1e-3 h para cada lado, em cada canal, e comparo as duas inclinações. A meia-noite e as âncoras da tabela são os pontos onde
  // uma interpolação por trechos quebraria: as inclinações chegam a 0,14 por hora, e uma quebra de ritmo daria uma diferença dessa ordem. A
  // tolerância de 5e-3 é a do erro da diferença finita (a curvatura vezes 1e-3), com folga.
  const e = 1e-3;
  [0, 3, 4.8, 6.5, 8.5, 12, 15, 17.3, 18.5, 19.6, 21, 23].forEach((hour) => {
    const before = flat(sky(hour - e)), at = flat(sky(hour)), after = flat(sky(hour + e));
    const left = at.map((v, i) => (v - before[i]) / e), right = after.map((v, i) => (v - at[i]) / e);
    const gap = maxDiff(left, right);
    check(gap < 5e-3, hour + "h: as inclinações diferem em " + gap);
  });
});

test("o dia solar anda sempre para a frente: duas horas em ordem dão duas horas solares em ordem", () => {
  [K.DEFAULTS, { sunrise: 5, sunset: 20, twilight: 1 }, { sunrise: 8.5, sunset: 16, twilight: 2 }, { sunrise: 4, sunset: 22, twilight: 0.5 }].forEach((settings, which) => {
    const state = (h) => sky(h, settings).solarHour;
    for (let hour = 0; hour < 24; hour += 0.05) {
      const step = K.wrap(state(hour + 0.05) - state(hour));
      check(step > 0 && step < 12, "ajuste " + which + ", " + hour + "h: o passo solar foi " + step);
    }
  });
});

// ---- nascer e pôr do sol ----

test("com o padrão, o nascer e o pôr do sol caem nas âncoras da tabela, e o céu do nascer é o mesmo do pôr", () => {
  // O sunrise e o sunset do padrão são exatamente os dois pontos em que o mapa do dia solar toca as âncoras de 6,5 h e 18,5 h.
  const dawn = sky(K.DEFAULTS.sunrise), dusk = sky(K.DEFAULTS.sunset);
  near(dawn.solarHour, 6.5, 1e-9);
  near(dusk.solarHour, 18.5, 1e-9);
  check(maxDiff(flat(dawn), flat(dusk)) < 1e-9, "a tabela é espelhada em volta do meio-dia nesses dois pontos");
});

test("mudar o nascer e o pôr do sol desloca o dia inteiro: o céu da hora do nascer é sempre o do nascer", () => {
  const reference = flat(sky(K.DEFAULTS.sunrise));
  const referenceDusk = flat(sky(K.DEFAULTS.sunset));
  [{ sunrise: 5, sunset: 20 }, { sunrise: 8, sunset: 16 }, { sunrise: 4, sunset: 22 }, { sunrise: 9, sunset: 15 }].forEach((settings) => {
    check(maxDiff(flat(sky(settings.sunrise, settings)), reference) < 1e-9, "nascer às " + settings.sunrise);
    check(maxDiff(flat(sky(settings.sunset, settings)), referenceDusk) < 1e-9, "pôr às " + settings.sunset);
  });
});

test("o crepúsculo longo estica o amanhecer: uma hora depois do nascer o céu ainda está mais escuro que com o crepúsculo curto", () => {
  // O crepúsculo é o tempo que a tabela leva para ir da noite ao dia: com 2 h o amanhecer leva o dobro de 1 h, então no mesmo instante depois do
  // nascer o céu de 2 h está mais perto do nascer do que o de 1 h, ou seja, mais escuro.
  const short = { sunrise: 6.5, sunset: 18.5, twilight: 1 }, long = { sunrise: 6.5, sunset: 18.5, twilight: 2 };
  const hour = 7.5;
  check(sky(hour, long).solarHour < sky(hour, short).solarHour, "com crepúsculo longo a hora solar ainda está mais atrás");
  check(lightness(sky(hour, long)) < lightness(sky(hour, short)), "e o céu está mais escuro");
  near(sky(6.5, long).solarHour, sky(6.5, short).solarHour, 1e-9);
});

// ---- noite, dia, meia-noite e meio-dia ----

test("a meia-noite é mais escura que o meio-dia em todas as faixas", () => {
  const night = sky(0), noon = sky(12);
  for (let i = 0; i < 6; i++)
    check(night.stops[i].color[0] < noon.stops[i].color[0], "faixa " + i + ": luminosidade da meia-noite " + night.stops[i].color[0] + " e do meio-dia " + noon.stops[i].color[0]);
});

test("a luminosidade média sobe da noite até o dia e desce de volta: o ponto mais claro cai no dia e o mais escuro na noite", () => {
  let brightest = 0, darkest = 0;
  hours.forEach((hour) => {
    if (lightness(sky(hour)) > lightness(sky(brightest))) brightest = hour;
    if (lightness(sky(hour)) < lightness(sky(darkest))) darkest = hour;
  });
  check(brightest > K.DEFAULTS.sunrise && brightest < K.DEFAULTS.sunset, "o mais claro às " + brightest + "h deveria estar entre o nascer e o pôr");
  check(darkest < K.DEFAULTS.sunrise - 2 || darkest > K.DEFAULTS.sunset + 2, "o mais escuro às " + darkest + "h deveria estar bem fora do dia");
  check(lightness(sky(brightest)) > lightness(sky(darkest)), "e o dia é mais claro que a noite");
});

test("com qualquer nascer e pôr do sol, a meia-noite é mais escura que o meio-dia", () => {
  [{ sunrise: 5, sunset: 20 }, { sunrise: 8, sunset: 17 }, { sunrise: 7, sunset: 19, twilight: 1 }, { sunrise: 4, sunset: 22, twilight: 2 }].forEach((settings) => {
    check(lightness(sky(0, settings)) < lightness(sky(12, settings)), "nascer " + settings.sunrise + " e pôr " + settings.sunset);
  });
});

// ---- a interpolação não passa dos extremos ----

test("a interpolação não passa dos extremos: entre duas âncoras, cada número fica entre o das duas", () => {
  // `periodicSample` é a função que dá o céu da tabela para uma hora solar: nenhum canal pode passar do valor das âncoras do trecho
  // ("avoids overshooting colors and band positions"). A tolerância é só a do ponto flutuante.
  const anchors = K.ANCHORS;
  for (let i = 0; i < anchors.length; i++) {
    const a = anchors[i], b = anchors[(i + 1) % anchors.length];
    const start = a.hour, end = i + 1 < anchors.length ? b.hour : b.hour + 24;
    for (let step = 0; step <= 40; step++) {
      const sample = K.periodicSample(start + (end - start) * step / 40);
      for (let k = 0; k < sample.length; k++) {
        const low = Math.min(a.values[k], b.values[k]) - 1e-9, high = Math.max(a.values[k], b.values[k]) + 1e-9;
        check(sample[k] >= low && sample[k] <= high, "trecho " + i + ", passo " + step + ", número " + k + ": " + sample[k] + " fora de [" + low + ", " + high + "]");
      }
    }
  }
});

test("a interpolação passa exatamente pelas âncoras, e a tabela cobre o dia inteiro, de 0 h até antes de 24 h", () => {
  const anchors = K.ANCHORS;
  equal(anchors[0].hour, 0, "a tabela começa à meia-noite");
  check(anchors[anchors.length - 1].hour < 24, "e termina antes de 24 h");
  for (let i = 1; i < anchors.length; i++)
    check(anchors[i].hour > anchors[i - 1].hour, "as âncoras estão em ordem de hora");
  anchors.forEach((anchor) => {
    const sample = K.periodicSample(anchor.hour);
    check(maxDiff(sample, anchor.values) < 1e-9, "âncora de " + anchor.hour + "h");
  });
  anchors.forEach((anchor) => equal(anchor.values.length, 6 + 6 * 3, "seis posições e seis cores de três números"));
});

test("a inclinação que a interpolação usa não tem sinal onde os vizinhos não concordam (sem overshoot) e fica entre os dois lados onde concordam", () => {
  equal(K.slope(1, -1, 1, 1), 0, "um sobe e o outro desce: o ponto é um extremo, inclinação zero");
  equal(K.slope(0, 1, 1, 1), 0, "um dos lados reto");
  equal(K.slope(2, 2, 1, 1), 2, "iguais com trechos iguais: a mesma inclinação");
  const m = K.slope(1, 4, 1, 1);
  check(m >= 1 && m <= 4, "fica entre as duas: " + m);
  check(K.slope(-1, -4, 1, 2) < 0, "e vale para descidas");
});
