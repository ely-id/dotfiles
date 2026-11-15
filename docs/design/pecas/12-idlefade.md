# 12 · IdleFade

**Nova?** não  
**Board:** `13:14610`  
**PNG:** `referencias/armitage/05-popups-cartoes-osds-chiba.png` (trecho IdleFade)  
**QML da Pond:** `shell/IdleFade.qml` (spec §3.26)

## Comportamento (herdar)

Depois do tempo de “desligar a tela” (Ajustes → Bloqueio e suspensão) sem uso:

1. 0 s — tempo esgotado, véu preto ainda em 0.
2. 2,5 s — véu a 50%.
3. 5 s — véu a 100% (preto) e os monitores desligam (`power-off-monitors`).

Qualquer movimento, tecla ou toque **cancela** e o véu some.

O Figma mostra três quadros (216×136) só como explicação. Não há curva nova documentada: use a da Pond em `IdleFade.qml` (ida a preto em 5 s). Se o código atual não for linear e você precisar reproduzir os três instantes exatos do Figma, meça no QML — não invente outra curva.

## Conferido na F3 (2026-11-15, S07)

O `IdleFade.qml` já reproduz os três quadros: a `ColorAnimation` vai de transparente a preto em 5000 ms com curva linear (50% aos 2,5 s), e o `Timer` que chama `niri msg action power-off-monitors` usa os mesmos 5 s. Não mudei o comportamento; só escrevi o comentário em português e deixei a curva linear explícita. A vitrine (aba F3) mostra os três quadros de 216×136 com a opacidade do véu em 0, 50% e 100%. O tempo de tela esgotado vem de `System.Idle.current.display` (Ajustes, na F4).
