# 13 · Ajustes e subpáginas

**Nova?** não (refino; as telas que faltavam na 1ª referência estão aqui)  
**Board:** `13:15787`  
**PNG:** `referencias/armitage/06-ajustes-chiba.png`  
**QML da Pond:** `settings/Window.qml`, `Modal.qml`, `CategoryButton.qml`, `SessionButton.qml`, `Tray.qml`, `Style.qml`, `Switcher.qml`, `Dropdown.qml`, `Field.qml`, `system/Panel.qml`, `Mouse.qml`, `Lock.qml`, `Idle.qml`, `Picker.qml`, `State.qml`, `display/Panel.qml`, `Arrange.qml`, `Monitor.qml`, `information/Panel.qml`, `Label.qml`, `Footer.qml`, `manual/Panel.qml`, `NavigationTutorial.qml`, `appearance/WallpaperPicker.qml`, `WallpaperTile.qml` (spec §3.20–3.25, §3.27)

## Tela inicial

- Tela cheia com véu `scrim` 80%. Composição **672×536** (cartões + sessão).
- Cartão de categoria **264×264** raio 16, passo **272** (Pond usava 274, fora da grade). Ícone em tile 48×48 raio 12 em (32,32); nome Geist Serif 32 em (32,184). Hover: vidro + `accentRing` e seta `arrow-up-right` `accentText` em (212,32).
- Quatro cartões: Aparência, Bluetooth, Sistema, Informações. (Wi-Fi e Som continuam pelos controles da barra; Bluetooth também tem cartão aqui.)
- Botão de sessão **128×128** raio 12, passo **136** (Pond 127). Círculo 80×80 raio 40 em (24,24), ícone 20 no centro. Hover de Desligar: o botão inteiro vira `danger` e o nome aparece à direita em Serif 32 `dangerText`, **60 ms depois**. Bloquear / Suspender / Reiniciar: o mesmo padrão com a cor de acento (não com perigo). Ponto `dangerText` 8×8 no Desligar em repouso.
- Bandeja no topo (ícones 16 em botões 36×36 raio 6, faixa 204×44 raio 8).
- Perfil de energia na borda direita: coluna 48×136 com três botões ícone 40 (Economia, Equilibrado selecionado, Desempenho). Ver *A CONFIRMAR* do ícone `zap` vs `rocket` na ficha 08.
- Selo de atualização embaixo: pílula `accentSubtle`, ícone + “N atualizações disponíveis” `accentText`. A contagem vem do estado do Cachy Update (decidido em 2026-11-14, P-32).
- Entrada: cada cartão 0,86→1 em ordem aleatória, **28 ms** entre eles, cada um em 32 ms (`settings/Window.qml:369-421`). Fechar 180 ms.

## Modal padrão

- Largura **580**, raio 32, título Geist Serif 32 em (30,20) caixa (w−80)×44. X pendurado em (w−20, 7).
- Linhas de ajuste 520×52 a cada **60** (Pond 51), x 30, a partir de y 84.

## Sistema — 580×348

Linhas com seta: Mouse e touchpad, Bloqueio e suspensão, Idioma do teclado, Fuso horário.

### Mouse e touchpad — 580×452

- Dois sliders de **480** (trilho 12 raio 6, 9 marcas a cada 60, alça 24 `knob`), rótulo 15 + valor `muted`.
- Chave “Aceleração do ponteiro”.
- Linha “Rolagem natural” com seletor Touchpad / Mouse.

### Bloqueio e suspensão — 580×420

- Seletor “Na tomada” / “Na bateria”.
- Valores: Bloquear a tela, Desligar a tela, Suspender. Chave “Pedir senha ao acordar”.

### Idioma do teclado / Fuso horário

- Fuso horário: a origem troca o fuso com uma regra de `sudo` sem senha. Procuro um caminho sem essa regra; se não houver um caminho limpo, a página de fuso sai e o relógio segue o horário do sistema (decidido em 2026-11-14, P-34).
- Modal com busca 520×44 (caret no acento) + lista 520×44. Escolhida: fundo `accentSubtle`, check `accentText`, código Mono 11 vira `text` (não `muted`).
- Altura máxima da lista: 460, com rolagem (Pond `Picker.qml`).
- Inclua “Inglês (EUA, internacional)” / `us · intl` — é o layout do escopo.

## Tela — 580×644

- Desenho dos monitores **520×280** (Pond 520×281; alinhado à grade) raio 16, fundo `cardHover`, em (30,84).
- Monitores com raio 8; o selecionado usa `accentSubtle` + `accentRing` 2. Botão “Organizar”.
- Linhas: Escala, Resolução, Taxa de atualização, Sincronia adaptativa (VRR). Só aparecem quando há opção (comportamento da Pond).

### Organizar monitores — 580×500

- Área de arraste 520×320. Guia de encaixe 1 px em `accentText`. Monitor arrastado com sombra. “Cancelar” / “Concluído”.

## Informações — 580×620

- 7 linhas, passo 48. Número em círculo 24 (Geist Mono 11). Rótulo 15 `muted`. Valor Geist Serif 17.
- Use **dados fictícios** (como na prévia: CachyOS · Linux 6.17, máquina “Wintermute”, etc.). Não leia hardware real para preencher prints de documentação; no runtime, a Pond já busca valores em `information/State.qml` — pode manter a leitura, mas nada de serial, MAC ou hostname pessoal em material compartilhado.
- Botão Manual 520×64. Rodapé “Wintermute Shell” Serif 17 + versão Mono 11 `muted`. Grade de “+” 7×3 que some aos poucos no hover dos contatos (opacidade 1 / 0,6 / 0,3) — herdar a graça da Pond, nas medidas do Figma (152×56 em (398,536)).

## Manual — 500×656, sem título no modal

- Seletor Teclado / Touchpad no topo.
- Tutorial 440×240 raio 16 (a Pond tinha 440×420 + um SVG grande que **não** está neste pacote). O Figma é a referência visual a seguir, não o SVG antigo.
- Lista de atalhos (teclas + texto `muted`): Super+Roda, Super+Shift+Roda, Super+Espaço (launcher), Print (captura), Super+V (clipboard), Super+B (recolher a barra). Posso trocar os binds depois, então eles ficam num único arquivo.
- Abre sozinho na primeira vez (`shell.qml:55-65`). Botão “Entendi” primário 440×40.

## Papel de parede — modal 624×608

- Grade 2×3 de miniaturas **276×156** raio 12 (Pond: 155 de uma das dimensões — refinado).
- Escolhida: anel `accent` 1 px com folga de 4 px + check 24 fundo `accent`.
- Hover: título e autor sobre degradê preto 0→80% na base.
- Tile “Escolher imagem” com traço tracejado `[4,4]`. “Dinâmico” pode permanecer (shader da Pond), visualmente como na prévia.
- As imagens da grade são as minhas, uma por variação (Chiba, Freeside, Sprawl), e moram no repositório. As fotos da origem não entram (decidido em 2026-11-14, P-31; o formato e a resolução que vão para o git são a P-37).

## A CONFIRMAR

- Ícone do perfil Desempenho na home: `zap` aqui vs `rocket` no pop-up da bateria (ficha 08).
- O tutorial do Manual da Pond era um SVG de 2,9 MB não baixado. Seguir o layout do Figma (440×240).
