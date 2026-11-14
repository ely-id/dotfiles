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
