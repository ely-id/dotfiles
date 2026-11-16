#!/usr/bin/env python3
import json
import os
from pathlib import Path
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from kdl import atomic_write, get_properties, set_properties

INPUT = Path(os.environ.get('XDG_CONFIG_HOME', Path.home() / '.config')) / 'niri/cfg/input.kdl'
# Velocidade do ponteiro em 9 passos (ficha 13): o passo 5 é o accel-speed 0 do Niri, e cada passo anda 0,25.
STEPS = 9


def run(*args, timeout=15):
    p = subprocess.run(args, capture_output=True, text=True, timeout=timeout)
    if p.returncode: raise RuntimeError(p.stderr.strip() or 'Could not change system settings')
    return p.stdout


def layouts():
    result = {}
    for rules in ('evdev.xml', 'evdev.extras.xml'):
        for layout in ET.parse(f'/usr/share/X11/xkb/rules/{rules}').iterfind('layoutList/layout'):
            name = layout.findtext('configItem/name')
            if name == 'custom': continue
            result.setdefault(name, {'id': name, 'label': layout.findtext('configItem/description'),
                                     'listed': rules == 'evdev.xml'})
            for variant in layout.iterfind('variantList/variant'):
                identifier = f"{name}({variant.findtext('configItem/name')})"
                result[identifier] = {'id': identifier, 'label': variant.findtext('configItem/description')}
    return list(result.values())


def languages(names=()):
    result = [item for item in layouts() if item.get('listed') or item['id'] == 'us(colemak_dh)' or item['label'] in names]
    return sorted(result, key=lambda item: item['label'].casefold())


def keyboard():
    return json.loads(run('niri', 'msg', '-j', 'keyboard-layouts'))


def step(speed):
    return max(1, min(STEPS, round((float(speed) + 1) * (STEPS - 1) / 2) + 1))


def speed(step):
    return round((int(step) - 1) * 2 / (STEPS - 1) - 1, 2)


def mouse():
    text = INPUT.read_text()
    pointer = get_properties(text, ('input', 'mouse'))
    touchpad = get_properties(text, ('input', 'touchpad'))
    return {'touchpadSpeed': step(touchpad.get('accel-speed', 0)), 'mouseSpeed': step(pointer.get('accel-speed', 0)),
            'acceleration': pointer.get('accel-profile') != 'flat',
            'naturalTouchpad': 'natural-scroll' in touchpad, 'naturalMouse': 'natural-scroll' in pointer}


def status():
    ids = {item['label']: item['id'] for item in layouts()}
    names = keyboard()['names']
    return {'selectedLanguages': [ids.get(name, name) for name in names], 'languageNames': names,
            'mouse': mouse()}


def load():
    result = status()
    return dict(result, languages=languages(result['languageNames']))


def apply_languages(text, names):
    atomic_write(INPUT, text)
    run('niri', 'msg', 'action', 'load-config-file')
    for _ in range(30):
        if keyboard()['names'] == names: return
        time.sleep(.1)
    raise RuntimeError('Niri did not apply the keyboard languages')


def toggle_language(identifier):
    catalog = layouts()
    labels = {item['id']: item['label'] for item in catalog}
    ids = {item['label']: item['id'] for item in catalog}
    current = keyboard()
    unknown = [name for name in current['names'] if name not in ids]
    if unknown: raise ValueError('Unknown keyboard language: ' + unknown[0])
    if identifier not in labels: raise ValueError('Unknown keyboard language')
    chosen = [ids[name] for name in current['names']]
    if identifier in chosen: chosen.remove(identifier)
    else: chosen.append(identifier)
    if not chosen: raise ValueError('Keep at least one keyboard language')
    names = [labels[value] for value in chosen]
    layout, variant = zip(*(value.rstrip(')').partition('(')[::2] for value in chosen))
    previous = INPUT.read_text()
    try: apply_languages(set_properties(previous, ('input', 'keyboard', 'xkb'),
                                        {'layout': ','.join(layout), 'variant': ','.join(variant)}), names)
    except Exception:
        apply_languages(previous, current['names'])
        raise
    active = current['names'][current['current_idx']]
    if active in names: run('niri', 'msg', 'action', 'switch-layout', str(names.index(active)))
    return status()


# Cada aparelho tem a própria velocidade e a própria rolagem natural; a aceleração vale para os dois.
# O scroll-factor não aparece mais na página (o Figma tirou), então não mexo nele.
def set_mouse(touchpad_speed, mouse_speed, acceleration, natural_touchpad, natural_mouse):
    text = INPUT.read_text()
    for device, value, natural in (('touchpad', touchpad_speed, natural_touchpad), ('mouse', mouse_speed, natural_mouse)):
        text = set_properties(text, ('input', device), {
            'accel-speed': speed(value),
            'accel-profile': 'adaptive' if acceleration == 'true' else 'flat',
            'natural-scroll': natural == 'true'})
    atomic_write(INPUT, text)
    run('niri', 'msg', 'action', 'load-config-file')
    return status()


if __name__ == '__main__':
    try:
        action, *args = sys.argv[1:]
        print(json.dumps({'load': load, 'keyboard': toggle_language, 'mouse': set_mouse}[action](*args)))
    except Exception as error:
        print(json.dumps({'error': str(error)}))
        sys.exit(1)
