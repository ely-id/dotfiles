// Testes das contas dos aparelhos Bluetooth: wintermute-shell/bluetooth/Devices.js (o ícone e o rótulo por tipo, o aparelho de energia que
// corresponde a um endereço, a bateria em porcentagem). Os casos saem da ficha 06, "Bluetooth" (a bateria "aparece em qualquer dispositivo
// que a informe, conectado ou não", a linha de dispositivo com ícone e nome) e dos nomes de ícone que o BlueZ publica para cada classe de
// aparelho (`audio-headset`, `audio-headphones`, `input-keyboard`, `input-mouse`, `input-tablet`, `input-gaming`, `phone`, `audio-card`),
// que são os valores que a shell recebe em `device.icon`. A ficha não fixa o ícone por tipo (só o `bluetooth`, o ícone padrão): onde
// a biblioteca decide sozinha, e eu não tenho outra fonte, o caso diz "decisão da biblioteca" e serve de guarda contra mudança sem querer.
// Os nomes de ícone da resposta (headphones, keyboard, mouse, speaker, smartphone, gamepad-2, bluetooth) conferi à mão em wintermute-shell/icons/.
//   .agents/scripts/testar.sh devices
.import "apoio.js" as T
.import "bluetooth/Devices.js" as V

const test = T.test, equal = T.equal, check = T.check;

// ---- o ícone por tipo ----

test("cada classe de aparelho do BlueZ tem o ícone dela", () => {
  equal(V.classifier("audio-headset"), "headphones");
  equal(V.classifier("audio-headphones"), "headphones");
  equal(V.classifier("input-keyboard"), "keyboard");
  equal(V.classifier("input-mouse"), "mouse");
  equal(V.classifier("phone"), "smartphone");
  equal(V.classifier("input-gaming"), "gamepad-2");
  equal(V.classifier("audio-card"), "speaker");
});

test("decisão da biblioteca: a mesa digitalizadora e o touchpad usam o ícone do mouse, e o alto-falante o do speaker", () => {
  equal(V.classifier("input-tablet"), "mouse");
  equal(V.classifier("input-touchpad"), "mouse");
  equal(V.classifier("audio-speakers"), "speaker");
  equal(V.classifier("audio-output"), "speaker");
  equal(V.classifier("input-joystick"), "gamepad-2");
});

test("fones de ouvido são fones e não telefone, embora 'headphone' tenha 'phone' dentro", () => {
  equal(V.classifier("audio-headphones"), "headphones", "a palavra 'phone' não pode ganhar do 'headphone'");
  equal(V.classifier("headset"), "headphones");
  equal(V.classifier("phone"), "smartphone");
  equal(V.classifier("smartphone"), "smartphone");
});

test("sem tipo conhecido, ícone bluetooth: computador, vazio, ausente ou fora do formato", () => {
  equal(V.classifier("computer"), "bluetooth");
  equal(V.classifier("video-display"), "bluetooth");
  equal(V.classifier(""), "bluetooth");
  equal(V.classifier(undefined), "bluetooth");
  equal(V.classifier(null), "bluetooth");
  equal(V.classifier(0), "bluetooth");
  equal(V.classifier({}), "bluetooth");
});

test("a classificação não diferencia maiúsculas", () => {
  equal(V.classifier("Input-Keyboard"), "keyboard");
  equal(V.classifier("AUDIO-HEADSET"), "headphones");
});

// ---- o rótulo do tipo ----

test("o rótulo do tipo, em inglês, acompanha o ícone", () => {
  equal(V.typeLabel("audio-headset"), "Headphones");
  equal(V.typeLabel("input-keyboard"), "Keyboard");
  equal(V.typeLabel("input-mouse"), "Mouse");
  equal(V.typeLabel("audio-card"), "Speaker");
  equal(V.typeLabel("phone"), "Phone");
  equal(V.typeLabel("input-gaming"), "Controller");
  equal(V.typeLabel("computer"), "Bluetooth device");
  equal(V.typeLabel(undefined), "Bluetooth device");
});

test("o touchpad é 'Trackpad', e não 'Mouse', mesmo com o ícone do mouse", () => {
  equal(V.typeLabel("input-touchpad"), "Trackpad");
  equal(V.typeLabel("INPUT-TOUCHPAD"), "Trackpad", "sem diferenciar maiúsculas");
  equal(V.classifier("input-touchpad"), "mouse", "o ícone continua o do mouse");
  equal(V.typeLabel("input-tablet"), "Mouse", "a mesa digitalizadora não é touchpad");
});

// ---- o aparelho de energia de um endereço ----

const MAC = "AA:BB:CC:DD:EE:FF";
// Um aparelho do UPower: o `nativePath` do BlueZ escreve o endereço com sublinhado (`dev_AA_BB_CC_DD_EE_FF`).
const power = (path, extra) => Object.assign({ nativePath: path, ready: true, powerSupply: false, percentage: 0.5 }, extra || {});

test("o endereço acha o aparelho de energia cujo caminho o contém, sem diferenciar maiúsculas nem sublinhado", () => {
  const mine = power("/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF");
  const other = power("/org/bluez/hci0/dev_11_22_33_44_55_66");
  equal(V.powerDeviceFor(MAC, [other, mine]), mine);
  equal(V.powerDeviceFor(MAC.toLowerCase(), [other, mine]), mine, "endereço em minúsculas");
  equal(V.powerDeviceFor(MAC, [power("/org/bluez/hci0/dev_aa_bb_cc_dd_ee_ff")]) !== null, true, "caminho em minúsculas");
  equal(V.powerDeviceFor(MAC, [power("aa:bb:cc:dd:ee:ff")]) !== null, true, "caminho já com dois pontos");
});

test("sem aparelho que combine, ou fora da lista de endereços, a resposta é null", () => {
  const other = power("/org/bluez/hci0/dev_11_22_33_44_55_66");
  equal(V.powerDeviceFor(MAC, [other]), null);
  equal(V.powerDeviceFor(MAC, []), null);
  equal(V.powerDeviceFor(MAC, undefined), null);
  equal(V.powerDeviceFor(MAC, null), null);
  equal(V.powerDeviceFor(MAC, [{ ready: true, powerSupply: false }]), null, "sem nativePath");
});

test("só vale o aparelho pronto e que não seja fonte de energia (uma bateria de notebook, por exemplo)", () => {
  const path = "/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF";
  equal(V.powerDeviceFor(MAC, [power(path, { ready: false })]), null, "ainda não pronto");
  equal(V.powerDeviceFor(MAC, [power(path, { powerSupply: true })]), null, "fonte de energia");
  const good = power(path);
  equal(V.powerDeviceFor(MAC, [power(path, { ready: false }), power(path, { powerSupply: true }), good]), good, "o primeiro que serve");
});

test("endereço que não é um MAC não acha nada, e vazio ou ausente também não", () => {
  const list = [power("/org/bluez/hci0/dev_AA_BB_CC_DD_EE_FF")];
  equal(V.powerDeviceFor("AA:BB:CC:DD:EE", list), null, "curto");
  equal(V.powerDeviceFor("AA:BB:CC:DD:EE:FF:00", list), null, "comprido");
  equal(V.powerDeviceFor("AA-BB-CC-DD-EE-FF", list), null, "com hífen");
  equal(V.powerDeviceFor("AABBCCDDEEFF", list), null, "sem separador");
  equal(V.powerDeviceFor("GG:BB:CC:DD:EE:FF", list), null, "dígito que não é hexadecimal");
  equal(V.powerDeviceFor("", list), null);
  equal(V.powerDeviceFor(undefined, list), null);
  equal(V.powerDeviceFor(null, list), null);
});

// ---- a bateria em porcentagem ----

test("a bateria do aparelho vem de 0 a 1 e sai em porcentagem inteira", () => {
  equal(V.batteryPercent({ batteryAvailable: true, battery: 0.5 }, null), 50);
  equal(V.batteryPercent({ batteryAvailable: true, battery: 1 }, null), 100);
  equal(V.batteryPercent({ batteryAvailable: true, battery: 0 }, null), 0, "0% é um valor, e não 'sem bateria'");
  equal(V.batteryPercent({ batteryAvailable: true, battery: 0.754 }, null), 75, "75,4 arredonda para baixo");
  equal(V.batteryPercent({ batteryAvailable: true, battery: 0.756 }, null), 76, "75,6 arredonda para cima");
});

test("a bateria não passa de 100 nem fica abaixo de 0", () => {
  equal(V.batteryPercent({ batteryAvailable: true, battery: 1.2 }, null), 100);
  equal(V.batteryPercent({ batteryAvailable: true, battery: -0.2 }, null), 0);
});

test("sem bateria no aparelho, vale a do aparelho de energia, com a mesma conta", () => {
  equal(V.batteryPercent({ batteryAvailable: false, battery: 0.9 }, { percentage: 0.4 }), 40, "o aparelho diz que não tem");
  equal(V.batteryPercent({}, { percentage: 0.4 }), 40, "o aparelho nem informa");
  equal(V.batteryPercent(null, { percentage: 0.4 }), 40, "sem aparelho");
  equal(V.batteryPercent({ batteryAvailable: true, battery: NaN }, { percentage: 0.25 }), 25, "valor que não é número");
  equal(V.batteryPercent(undefined, { percentage: 3 }), 100, "o de energia também é limitado a 100");
  equal(V.batteryPercent(undefined, { percentage: 0 }), 0);
});

test("a bateria do próprio aparelho ganha da do aparelho de energia", () => {
  equal(V.batteryPercent({ batteryAvailable: true, battery: 0.8 }, { percentage: 0.1 }), 80);
});

test("sem nenhuma das duas, a resposta é -1 (a linha não mostra bateria)", () => {
  equal(V.batteryPercent(null, null), -1);
  equal(V.batteryPercent(undefined, undefined), -1);
  equal(V.batteryPercent({ batteryAvailable: false }, null), -1);
  equal(V.batteryPercent({ batteryAvailable: true, battery: NaN }, null), -1);
  equal(V.batteryPercent({ batteryAvailable: true, battery: Infinity }, { percentage: NaN }), -1, "nenhum valor que sirva");
  equal(V.batteryPercent({}, {}), -1);
});
