#!/usr/bin/env python3
"""Small JSON bridge for the Appearance panel's hardware and saved settings."""
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

CONFIG = Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))


def run(*args, timeout=12):
    result = subprocess.run(args, capture_output=True, text=True, timeout=timeout)
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or f"{args[0]} failed")
    return result.stdout


def describe_error(error):
    """Transformo o erro cru do brilho numa frase que diz o motivo e o que fazer."""
    text = str(error).strip()
    # `subprocess` levanta FileNotFoundError com o nome do programa que faltou; só o ddcutil
    # ausente tem frase própria, o resto (brightnessctl, /sys) cai no caso geral.
    if isinstance(error, FileNotFoundError) and error.filename == "ddcutil":
        return "Brightness for this display needs ddcutil, which is not installed."
    if isinstance(error, PermissionError) or re.search(r"permission denied|eacces", text, re.I):
        return "No permission to control this display. Add your user to the i2c group."
    first = next((line.strip() for line in text.splitlines() if line.strip()), "")
    # O texto do próprio control.py já é a frase inteira; não repito o prefixo por cima dele.
    if not first or first.startswith("Brightness control is unavailable for this display"):
        return first or "Brightness is unavailable for this display"
    return "Brightness is unavailable for this display: " + first


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


def brightness_device(output, cached=""):
    device = json.loads(cached) if cached else None
    # Match brightness control to the selected connector, not detection order.
    if not device and not output.startswith(("eDP", "LVDS", "DSI")):
        # The targeted brightness read below also checks DDC support.
        detected = run("ddcutil", "detect", "--brief", "--skip-ddc-checks")
        for block in re.split(r"(?=Display \d+)", detected):
            connector = re.search(r"DRM connector:\s+\S*card\d+-(\S+)", block)
            bus = re.search(r"I2C bus:\s+/dev/i2c-(\d+)", block)
            if connector and bus and connector[1] == output:
                device = {"kind": "ddc", "device": bus[1]}
                break
    elif not device:
        devices = sorted(Path("/sys/class/backlight").glob("*"))
        if devices:
            device = {"kind": "backlight", "device": devices[0].name}
    try:
        if device and device["kind"] == "ddc":
            value = run("ddcutil", "-b", device["device"], "getvcp", "10", "--brief",
                        *(["--skip-ddc-checks"] if cached else []))
            match = re.search(r"VCP 10 C (\d+) (\d+)", value)
            if match and int(match[2]) > 0:
                return dict(device, current=int(match[1]), max=int(match[2]))
        elif device:
            path = Path("/sys/class/backlight") / device["device"]
            return dict(device, current=int((path / "brightness").read_text()),
                        max=int((path / "max_brightness").read_text()))
    except (RuntimeError, OSError, subprocess.TimeoutExpired):
        if not cached:
            raise
    if cached:
        return brightness_device(output)
    raise RuntimeError("Brightness control is unavailable for this display")


def status(output, cached=""):
    outputs = json.loads(run("niri", "msg", "-j", "outputs"))
    monitor = outputs.get(output)
    result = {"output": output, "connected": bool(monitor and monitor.get("logical")),
              "brightness": None, "brightnessDevice": None, "brightnessError": ""}
    if result["connected"]:
        mode = monitor["modes"][monitor["current_mode"]]
        result.update(width=mode["width"], height=mode["height"], scale=monitor["logical"]["scale"])
        try:
            device = brightness_device(output, cached)
            result["brightness"] = device["current"] / device["max"]
            result["brightnessDevice"] = device
        except (RuntimeError, OSError, subprocess.TimeoutExpired) as error:
            result["brightnessError"] = describe_error(error)
    return result


def set_brightness(output, value, cached=""):
    value = max(0.01, min(1, float(value)))
    device = json.loads(cached) if cached else brightness_device(output)
    if device["kind"] == "ddc":
        run("ddcutil", "-b", device["device"], "--noverify", "--enable-dynamic-sleep",
            "--sleep-multiplier=0.05", "setvcp", "10", str(round(value * device["max"])))
    else:
        run("brightnessctl", "-d", device["device"], "set", f"{round(value * 100)}%")
    return {"brightness": value}


def step_brightness(output, delta):
    device = brightness_device(output)
    value = device["current"] / device["max"] + float(delta)
    return set_brightness(output, value, json.dumps(device))


def theme(name):
    if name not in ("chiba", "freeside", "sprawl"):
        raise ValueError("Unknown theme")
    atomic_write(CONFIG / "wintermute-shell/theme.json", json.dumps({"theme": name}) + "\n")
    return {"theme": name}


def main():
    action = ""
    try:
        action, *args = sys.argv[1:]
        commands = {"status": status, "brightness": set_brightness, "brightness-step": step_brightness,
                    "theme": theme}
        print(json.dumps(commands[action](*args)))
    except Exception as error:
        # Só os erros de leitura e escrita do brilho ganham a frase com o motivo; o resto
        # (tema, argumento inválido) segue com o texto que já tinha.
        known = isinstance(error, (RuntimeError, OSError, subprocess.TimeoutExpired))
        message = describe_error(error) if known and action in ("brightness", "brightness-step") else str(error)
        print(json.dumps({"error": message}))
        sys.exit(1)


if __name__ == "__main__":
    main()
