.pragma library

// Menu "Ações" do launcher (ficha 14, F5-T05; P-13). Biblioteca pura: recebe a linha que estava selecionada na lista e
// devolve as linhas de ação dela, no mesmo formato das linhas de resultado, para o Panel.qml desenhar com a ResultRow de
// sempre. Quem faz o que cada ação diz é o State.qml; aqui só fica a conta (quais ações cada tipo de item tem, em que ordem,
// e como são os workspaces da segunda camada). Os testes exercitam estas funções com dados fictícios.
//
// Uma linha de ação tem { title, detail, kind: "Action", icon, danger } e mais:
//   act     o que o State faz: "workspaces" (troca a lista pela dos workspaces), "remove-recent", "show-folder" ou
//           "pick-workspace". Sem `act`, a ação vale o que a linha original valeria: o Enter nela.
//   target  nas ações "Open" e "Run", o alvo da linha original: `activate` as trata como o Enter na linha, e a confirmação do
//           comando perigoso (`armedKey`) reconhece a linha pelo alvo.
//   copy    nas ações de copiar, o texto que vai para a área de transferência: `activate` copia e fecha, como na linha do cálculo.

function action(title, icon, extra) {
  return Object.assign({ title: title, detail: "", kind: "Action", icon: icon, danger: false }, extra || {});
}

// Os tipos de item que têm menu: "app", "file", "setting", "command" e "calc" (a linha do cálculo, que traz `copy`).
// Linha sem alvo e sem texto para copiar (as ações do "sem resultado") não tem menu: devolve "".
function itemType(row) {
  if (!row)
    return "";
  if (row.copy !== undefined)
    return "calc";
  return row.target && row.target.type ? row.target.type : "";
}

// O que aparece no cabeçalho da página: o nome do item, ou a expressão, no cálculo (o que o cartão mostra).
function itemTitle(row, calculation) {
  if (itemType(row) === "calc" && calculation)
    return calculation.expression;
  return row ? String(row.title || "") : "";
}

// As ações do item, na ordem da tabela da P-13. `recentIds` diz se o app está nos recentes ("Remove from recent" só
// aparece então); `calculation` é a do State (`{ result, hex }`), de onde saem os dois textos do cálculo, e o
// hexadecimal só existe quando o resultado é inteiro e não negativo.
function rowsFor(row, recentIds, calculation) {
  const type = itemType(row);
  if (type === "app") {
    const list = [
      action("Open", "arrow-up-right", { target: row.target }),
      action("Open on workspace…", "layout-grid", { act: "workspaces" })
    ];
    if ((recentIds || []).indexOf(row.target.id) >= 0)
      list.push(action("Remove from recent", "trash-2", { act: "remove-recent" }));
    return list;
  }
  if (type === "file") {
    return [
      action("Open", "arrow-up-right", { target: row.target }),
      action("Show in folder", "folder", { act: "show-folder" }),
      action("Copy path", "copy", { copy: row.target.path })
    ];
  }
  if (type === "setting")
    return [action("Open", "arrow-up-right", { target: row.target })];
  if (type === "command")
    return [action("Run", "play", { target: row.target, danger: !!row.danger })];
  if (type === "calc" && calculation) {
    const list = [action("Copy result", "copy", { copy: calculation.result })];
    if (calculation.hex)
      list.push(action("Copy hexadecimal", "hash", { copy: calculation.hex }));
    return list;
  }
  return [];
}

// A pasta onde o arquivo está: o caminho sem o último componente. Um item direto na raiz ("/arquivo") fica em "/".
function parentDirectory(path) {
  const text = String(path || "");
  const slash = text.lastIndexOf("/");
  return slash <= 0 ? "/" : text.substring(0, slash);
}

// O número que o organizador mostra para a linha: o `sidebarWorkspaceNumber`, e, na linha de criação ainda sem número, a
// posição dela no monitor (a mesma conta de `NiriMsg.openLauncher`, que dá a etiqueta "On workspace N").
function workspaceNumber(entry) {
  return Number(entry.sidebarWorkspaceNumber) || (Number(entry.sidebarRowOrdinal) || 0) + 1;
}

// A segunda camada de "Open on workspace…": uma linha por workspace do monitor, na ordem do organizador. `entries` é a cópia
// de `NiriMsg.workspaceRows` (listas simples com outputName, workspaceId, sidebarWorkspaceNumber e sidebarRowOrdinal).
function workspaceRows(entries, outputName) {
  const rows = [];
  (entries || []).forEach(entry => {
    if (entry.outputName !== outputName)
      return;
    rows.push(action("Workspace " + workspaceNumber(entry), "layout-grid", {
      act: "pick-workspace",
      workspaceId: entry.workspaceId
    }));
  });
  return rows;
}
