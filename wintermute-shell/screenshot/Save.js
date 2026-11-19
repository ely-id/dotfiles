.pragma library

// As contas de salvar a captura de tela (ficha 17, F6-T03): o nome do arquivo, o caminho que o aviso mostra e a conferência de
// "este arquivo já está na pasta de capturas". Fica fora do QML para eu testar sem janela. Nenhum valor de desenho mora aqui.

function pad(value) {
  return (value < 10 ? "0" : "") + value;
}

// O nome do arquivo salvo, no padrão do Niri (`Screenshot from AAAA-MM-DD HH-MM-SS.png`, na hora local de `date`), para os arquivos da
// shell e os do Niri ficarem juntos e em ordem. `used` são os nomes que esta sessão já deu: no mesmo segundo o nome ganha ` (2)`,
// ` (3)` e assim por diante antes do `.png`. Devolvo só o nome, sem a pasta.
function fileName(date, used) {
  const stamp = date.getFullYear() + "-" + pad(date.getMonth() + 1) + "-" + pad(date.getDate())
      + " " + pad(date.getHours()) + "-" + pad(date.getMinutes()) + "-" + pad(date.getSeconds());
  const taken = used || [];
  let name = "Screenshot from " + stamp + ".png";
  for (let n = 2; taken.indexOf(name) >= 0; ++n)
    name = "Screenshot from " + stamp + " (" + n + ").png";
  return name;
}

// O caminho que o aviso mostra: a pasta pessoal `home` vira `~`, e só ela. `/home/case2/x.png` não é da pasta `/home/case`, e um
// caminho fora da pasta pessoal fica inteiro.
function displayPath(path, home) {
  const base = (home || "").replace(/\/+$/, "");
  if (!path || base === "")
    return path || "";
  if (path === base)
    return "~";
  if (path.indexOf(base + "/") === 0)
    return "~" + path.substring(base.length);
  return path;
}

// O arquivo `path` está dentro da pasta `dir` (em qualquer profundidade)? Compara por pedaços inteiros: `/a/Screenshots2/x.png` não está em `/a/Screenshots`.
function isInside(path, dir) {
  const base = (dir || "").replace(/\/+$/, "");
  if (!path || base === "")
    return false;
  return path.indexOf(base + "/") === 0 && path.length > base.length + 1;
}
