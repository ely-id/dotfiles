#!/usr/bin/env python3
"""Manage wallpaper discovery and saved selection through a JSON command interface."""
from concurrent.futures import ThreadPoolExecutor
import filecmp
import hashlib
import json
import os
from pathlib import Path
import random
import re
import shutil
import sys
import tempfile

from PyQt6.QtCore import QIODevice, QSaveFile, QSize, QStandardPaths
from PyQt6.QtGui import QImageReader

CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))
THUMBNAILS = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "pond-interface/wallpapers"
THUMBNAIL_WIDTH = 800
INCLUDED_WALLPAPERS = Path(__file__).resolve().parent / "included"
PORTAL = "org.freedesktop.portal.Desktop"
# Prefixo do arquivo temporário da cópia; a listagem ignora o que começa com ele.
COPYING_PREFIX = ".copying-"
IMAGE_PATTERNS = ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.bmp", "*.gif", "*.svg", "*.PNG", "*.JPG", "*.JPEG"]


def atomic_write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(mode="w", dir=path.parent, delete=False) as file:
        temporary = Path(file.name)
        file.write(text)
    try:
        if path.exists():
            temporary.chmod(path.stat().st_mode)
        os.replace(temporary, path)
    finally:
        temporary.unlink(missing_ok=True)


def wallpaper_folder():
    # Só a pasta em que o diálogo do portal abre; a lista de papéis de parede não lê mais daqui (P-66).
    return Path(QStandardPaths.writableLocation(QStandardPaths.StandardLocation.PicturesLocation)) / "Wallpapers"


def backgrounds_folder():
    """A pasta da shell onde moram as imagens que eu acrescento (P-59). Só é criada na primeira cópia."""
    data = os.environ.get("XDG_DATA_HOME") or Path.home() / ".local/share"
    return Path(data) / "wintermute-shell/backgrounds"


def wallpaper_state():
    try:
        saved = json.loads((CONFIG / "pond-interface/wallpaper.json").read_text())
    except FileNotFoundError:
        saved = {}
    state = {"mode": "dynamic", "path": "", "url": "", "imports": [], **saved}
    if not isinstance(state["imports"], list) or not all(isinstance(p, str) for p in state["imports"]):
        raise ValueError("Invalid wallpaper imports")
    return state


def wallpaper_entry(path, title=None, subtitle=None):
    try:
        image = Path(path).expanduser().resolve(strict=True)
        if not image.is_file() or not QImageReader(str(image)).canRead():
            return None
        folder = str(image.parent)
        if image.is_relative_to(Path.home()):
            folder = "~/" + str(image.parent.relative_to(Path.home()))
        return {"path": str(image), "url": f"{image.as_uri()}?{image.stat().st_mtime_ns}",
                "title": image.name if title is None else title,
                "subtitle": folder if subtitle is None else subtitle}
    except OSError:
        return None


def thumbnail(path):
    try:
        stat = os.stat(path)
        key = hashlib.sha256(f"{path}:{stat.st_mtime_ns}:{stat.st_size}".encode()).hexdigest()
        cached = THUMBNAILS / f"{key}.jpg"
        if cached.exists():
            return cached
        reader = QImageReader(path)
        reader.setAutoTransform(True)
        size = reader.size()
        if size.width() > THUMBNAIL_WIDTH:
            reader.setScaledSize(QSize(THUMBNAIL_WIDTH, round(size.height() * THUMBNAIL_WIDTH / size.width())))
        scaled = reader.read()
        if scaled.isNull():
            return None
        THUMBNAILS.mkdir(parents=True, exist_ok=True)
        output = QSaveFile(str(cached))
        if not output.open(QIODevice.OpenModeFlag.WriteOnly):
            return None
        if not scaled.save(output, "JPG", 90) or not output.commit():
            return None
        return cached
    except OSError:
        return None


def add_thumbnails(entries):
    with ThreadPoolExecutor() as pool:
        thumbnails = list(pool.map(thumbnail, [entry["path"] for entry in entries]))
    for entry, cached in zip(entries, thumbnails):
        entry["thumbnail"] = cached.as_uri() if cached else ""
    for stale in set(THUMBNAILS.glob("*.jpg")) - set(thumbnails):
        stale.unlink(missing_ok=True)


def included_entries():
    catalog_path = INCLUDED_WALLPAPERS.parent / "catalog.json"
    catalog = json.loads(catalog_path.read_text()) if catalog_path.exists() else []
    return [entry for item in catalog
            if (entry := wallpaper_entry(INCLUDED_WALLPAPERS / item["file"], item["title"], item["author"]))]


def file_time(path):
    try:
        return os.stat(path).st_mtime_ns
    except OSError:
        return 0


def background_entries(state):
    """As imagens legíveis da pasta da shell, na ordem de entrada.

    A ordem é a de state["imports"]. Uma imagem que está na pasta e não na lista (posta lá à mão) entra
    no fim, por data de modificação e depois por nome. O que a lista cita e não existe mais, ou aponta
    para fora da pasta, não entra.
    """
    folder = backgrounds_folder().resolve()
    found = {}
    try:
        children = list(folder.iterdir()) if folder.is_dir() else []
    except OSError:
        children = []
    for child in children:
        if child.name.startswith(COPYING_PREFIX):
            continue
        # O título e a autoria vazios: a acrescentada leva só o número (P-59).
        entry = wallpaper_entry(child, "", "")
        # O wallpaper_entry resolve links; um link que sai da pasta não é uma imagem da pasta.
        if entry and Path(entry["path"]).parent == folder:
            found[entry["path"]] = entry
    ordered = [path for path in dict.fromkeys(state["imports"]) if path in found]
    rest = sorted((path for path in found if path not in ordered),
                  key=lambda path: (file_time(path), Path(path).name.casefold()))
    return [found[path] for path in ordered + rest]


def wallpapers():
    state = wallpaper_state()
    original = json.dumps(state)
    included = included_entries()
    added = background_entries(state)
    # O número é a posição na ordem de entrada, sem buraco (P-65): se uma imagem some, as seguintes descem.
    for number, entry in enumerate(added, 1):
        entry["number"] = number
    state["imports"] = [entry["path"] for entry in added]
    if state["mode"] == "custom":
        selected = wallpaper_entry(state["path"])
        if selected:
            state.update(path=selected["path"], url=selected["url"])
        else:
            state.update(mode="dynamic", path="", url="")
    if json.dumps(state) != original:
        atomic_write(CONFIG / "pond-interface/wallpaper.json", json.dumps(state) + "\n")
    add_thumbnails(added + included)
    dynamic = {"dynamic": True, "title": "Dynamic"}
    return dict(state, wallpapers=[dynamic] + included + added)


def import_wallpaper(state, path):
    """Devolvo a entrada da imagem que vira o papel de parede personalizado, copiando-a para a pasta da shell.

    Papel de parede personalizado mora sempre na pasta da shell (P-59). Uma incluída e uma imagem que já
    está na pasta só são selecionadas. Se a pasta já tem um arquivo com o mesmo conteúdo, uso esse. Se tem
    outro arquivo com o mesmo nome, a cópia ganha -2, -3, ... antes da extensão. A cópia entra no fim de
    state["imports"].
    """
    source = wallpaper_entry(path)
    if not source:
        raise ValueError("Choose a readable image file")
    image = Path(source["path"])
    if source["path"] in {entry["path"] for entry in included_entries()}:
        return source
    folder = backgrounds_folder()
    resolved = folder.resolve()
    if image.parent == resolved:
        return source
    try:
        if folder.is_dir():
            size = image.stat().st_size
            for child in sorted(resolved.iterdir()):
                if (not child.name.startswith(COPYING_PREFIX) and child.is_file() and not child.is_symlink()
                        and child.stat().st_size == size and filecmp.cmp(child, image, shallow=False)
                        and (existing := wallpaper_entry(child, "", ""))):
                    return existing
        folder.mkdir(parents=True, exist_ok=True)
        resolved = folder.resolve()
        target = resolved / image.name
        copy = 2
        while target.exists() or target.is_symlink():
            target = resolved / f"{image.stem}-{copy}{image.suffix}"
            copy += 1
        # Copio para um temporário na mesma pasta e troco de nome, para a listagem nunca ver meia imagem.
        descriptor, temporary = tempfile.mkstemp(dir=resolved, prefix=COPYING_PREFIX)
        try:
            with os.fdopen(descriptor, "wb") as output, open(image, "rb") as origin:
                shutil.copyfileobj(origin, output)
            os.chmod(temporary, 0o644)
            os.replace(temporary, target)
        finally:
            Path(temporary).unlink(missing_ok=True)
    except OSError as error:
        reason = (error.strerror or str(error)).splitlines()
        raise ValueError("Could not save the image: " + (reason[0] if reason else "unknown error")) from None
    copied = wallpaper_entry(target, "", "")
    if not copied:
        raise ValueError("Choose a readable image file")
    state["imports"].append(copied["path"])
    return copied


def wallpaper(mode, path=""):
    state = wallpaper_state()
    if mode == "custom":
        selected = import_wallpaper(state, path)
        state.update(mode=mode, path=selected["path"], url=selected["url"])
    elif mode == "dynamic":
        state.update(mode=mode, path="", url="")
    else:
        raise ValueError("Unknown wallpaper mode")
    atomic_write(CONFIG / "pond-interface/wallpaper.json", json.dumps(state) + "\n")
    return wallpapers()


def portal_pick_file(title, filters, folder, failure):
    """Abro o seletor de arquivo do sistema pelo portal e devolvo o caminho escolhido.

    Devolvo None se eu cancelar e levanto RuntimeError(failure) nos demais casos.
    O primeiro filtro da lista é o que abre selecionado; folder pode ser None.
    O import do gi fica aqui dentro para o list e o set não pagarem por ele.
    """
    from gi.repository import Gio, GLib

    def first_line(error):
        # O strip_remote_error do Gio altera o GError in loco, e o PyGObject entrega uma cópia
        # dele; por isso tiro o prefixo "GDBus.Error:nome.do.erro: " eu mesmo.
        lines = re.sub(r"^GDBus\.Error:\S+:\s*", "", error.message.strip()).splitlines()
        return lines[0] if lines else ""

    def serialize(name, patterns):
        return (name, [(0, pattern) for pattern in patterns])

    try:
        bus = Gio.bus_get_sync(Gio.BusType.SESSION, None)
    except GLib.Error as error:
        raise RuntimeError(f"{failure}: {first_line(error)}") from None
    # O caminho do pedido é previsível pelo nome da minha conexão e pelo token.
    # Assino o Response antes de chamar, para a resposta não passar antes da assinatura.
    token = f"wintermute_{random.randrange(10**9, 10**10)}"
    expected = f"/org/freedesktop/portal/desktop/request/{bus.get_unique_name()[1:].replace('.', '_')}/{token}"
    outcome = {}
    loop = GLib.MainLoop()

    def on_response(connection, sender, path, interface, signal, parameters, data):
        outcome["response"], outcome["results"] = parameters.unpack()
        loop.quit()

    def on_vanished(connection, name):
        # Se o portal sumir com o diálogo aberto, ninguém mais vai responder.
        loop.quit()

    def subscribe(path):
        return bus.signal_subscribe(PORTAL, "org.freedesktop.portal.Request", "Response", path, None,
                                    Gio.DBusSignalFlags.NONE, on_response, None)

    subscription = subscribe(expected)
    watch = None
    try:
        options = {"handle_token": GLib.Variant("s", token),
                   "filters": GLib.Variant("a(sa(us))", [serialize(*item) for item in filters]),
                   "current_filter": GLib.Variant("(sa(us))", serialize(*filters[0]))}
        if folder is not None:
            options["current_folder"] = GLib.Variant("ay", os.fsencode(folder) + b"\0")
        try:
            reply = bus.call_sync(PORTAL, "/org/freedesktop/portal/desktop", "org.freedesktop.portal.FileChooser",
                                  "OpenFile", GLib.Variant("(ssa{sv})", ("", title, options)),
                                  GLib.VariantType("(o)"), Gio.DBusCallFlags.NONE, -1, None)
        except GLib.Error as error:
            raise RuntimeError(f"{failure}: {first_line(error)}") from None
        # Portais antigos devolvem outro caminho; nesse caso troco a assinatura (Request.xml).
        handle = reply.unpack()[0]
        if handle != expected:
            bus.signal_unsubscribe(subscription)
            subscription = subscribe(handle)
        watch = Gio.bus_watch_name_on_connection(bus, PORTAL, Gio.BusNameWatcherFlags.NONE, None, on_vanished)
        # Sem prazo: o diálogo fica aberto o tempo que eu quiser.
        loop.run()
    finally:
        bus.signal_unsubscribe(subscription)
        if watch is not None:
            Gio.bus_unwatch_name(watch)
    if outcome.get("response") == 1:
        return None
    uris = outcome.get("results", {}).get("uris") if outcome.get("response") == 0 else None
    path = Gio.File.new_for_uri(uris[0]).get_path() if uris else None
    if not path:
        raise RuntimeError(failure)
    return path


def pick_wallpaper():
    folder = wallpaper_folder()
    chosen = portal_pick_file("Choose a wallpaper", [("Images", IMAGE_PATTERNS), ("All files", ["*"])],
                              folder if folder.is_dir() else None, "Could not open the image picker")
    if chosen is None:
        return {"cancelled": True}
    return wallpaper("custom", chosen)


def main():
    try:
        action, *args = sys.argv[1:]
        commands = {"list": wallpapers, "set": wallpaper, "pick": pick_wallpaper}
        print(json.dumps(commands[action](*args)))
    except Exception as error:
        print(json.dumps({"error": str(error)}))
        sys.exit(1)


if __name__ == "__main__":
    main()
