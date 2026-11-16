pragma Singleton
import QtQuick
import ".." as Settings
import Quickshell
import Quickshell.Io

// Fatos da página Informações (ficha 13; Figma 13:16083), lidos pelo fastfetch quando a página abre.
// Os formatos seguem o Figma: "CachyOS · Linux 6.17", "Ryzen 7 · 8 cores", "Radeon · 16 GB",
// "32 GB" e "1 TB NVMe · 412 GB free". O tipo da memória (DDR5) do Figma fica de fora: o fastfetch só
// o lê pelo SMBIOS, que pede root. A origem atualizava memória e disco a cada 3 s; o Figma troca o uso
// pelo total, então leio uma vez por abertura.
Singleton {
  id: root
  property var facts: ({})
  readonly property bool active: Settings.State.opened && Settings.State.page === "information"
  onActiveChanged: if (active) refresh()

  Process {
    id: query
    command: ["fastfetch", "--config", "-", "--format", "json"]
    onStarted: {
      // driverSpecific: sem ele a VRAM da NVIDIA (driver proprietário) vem vazia.
      write(JSON.stringify({ modules: ["OS", "Kernel", "Title", "Board", "CPU", { type: "gpu", driverSpecific: true },
                                       "Memory", { type: "disk", folders: "/", useAvailable: true }] }));
      stdinEnabled = false;
    }
    stdout: StdioCollector {
      onStreamFinished: {
        try { root.updateFacts(text); }
        catch (e) { console.warn("Information: could not read system facts", e); }
      }
    }
  }

  // A raiz costuma ficar num LUKS em cima do NVMe (/dev/mapper/...); o lsblk -s sobe a cadeia até o disco.
  property var disk: null
  Process {
    id: transport
    stdout: StdioCollector {
      onStreamFinished: {
        if (/\bnvme\b/.test(text) && root.disk) {
          root.disk = Object.assign({}, root.disk, { nvme: true });
          root.facts = Object.assign({}, root.facts, { disk: root.diskText(root.disk) });
        }
      }
    }
  }
  function diskText(d) { return `${diskSize(d.total)}${d.nvme ? " NVMe" : ""} · ${diskSize(d.free)} free`; }

  function refresh() {
    if (query.running) return;
    query.stdinEnabled = true;
    query.running = true;
  }

  // Número curto: uma casa decimal, sem ",0" ("1 TB", "31.1 GB").
  function short(value) { return value.toFixed(1).replace(/\.0$/, ""); }
  // Disco em unidades decimais, como o tamanho que vem na caixa; memória e VRAM em binárias.
  function diskSize(bytes) { return bytes >= 1e12 ? short(bytes / 1e12) + " TB" : Math.round(bytes / 1e9) + " GB"; }
  function memorySize(bytes) { return short(bytes / 2 ** 30) + " GB"; }
  function cpuName(name) {
    return name.replace(/\((R|TM)\)|®|™/g, "").replace(/\s+w\/.*$/, "").replace(/\s*@.*$/, "")
        .replace(/\s+\d+-Core Processor$/, "").replace(/\s+(CPU|Processor)$/, "")
        .replace(/^(AMD|Intel)\s+/, "").replace(/\s+/g, " ").trim();
  }
  function gpuName(name) { return name.replace(/\((R|TM)\)|®|™/g, "").replace(/^(AMD|NVIDIA|Intel)\s+/, "").trim(); }

  function updateFacts(text) {
    const data = {};
    for (const item of JSON.parse(text)) data[item.type] = item.result;
    const next = {};

    const os = data.OS?.prettyName || data.OS?.name || "";
    const kernel = (data.Kernel?.release || "").match(/^\d+\.\d+/);
    next.os = os ? os + (kernel ? " · " + (data.Kernel.name || "Linux") + " " + kernel[0] : "") : "Unavailable";
    next.host = data.Title?.hostName || "Unavailable";
    next.board = data.Board?.name || "Unavailable";

    const cores = data.CPU?.cores?.physical;
    next.cpu = data.CPU?.cpu ? cpuName(data.CPU.cpu) + (cores ? ` · ${cores} ${cores === 1 ? "core" : "cores"}` : "") : "Unavailable";

    // A GPU dedicada primeiro; a VRAM só aparece nela (a integrada reserva memória do sistema).
    const gpus = (data.GPU || []).filter(gpu => gpu.name)
        .sort((a, b) => (b.type === "Discrete") - (a.type === "Discrete"));
    next.gpu = [...new Set(gpus.map(gpu => {
      const vram = gpu.type === "Discrete" ? gpu.memory?.dedicated?.total : 0;
      return gpuName(gpu.name) + (vram > 0 ? " · " + Math.round(vram / 2 ** 30) + " GB" : "");
    }))].join(", ") || "Unavailable";

    next.memory = data.Memory?.total > 0 ? memorySize(data.Memory.total) : "Unavailable";

    const found = data.Disk?.[0];
    const source = found?.mountFrom || "";
    disk = found?.bytes?.total > 0 ? { total: found.bytes.total, free: found.bytes.free, nvme: /^\/dev\/nvme/.test(source) } : null;
    next.disk = disk ? diskText(disk) : "Unavailable";

    facts = next;
    if (disk && !disk.nvme && source.startsWith("/dev/") && !transport.running) {
      transport.command = ["lsblk", "-nso", "TRAN", source];
      transport.running = true;
    }
  }
  function value(key) { return facts[key] || "…"; }
}
