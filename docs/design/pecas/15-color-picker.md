# 15 · Seletor de cor

**Nova?** **sim** (dentro do launcher, ficha 14)  
**Onde encaixar:** `shell/launcher/` (subpágina ou modo do launcher)  
**Board:** `13:17120`  
**PNG:** `referencias/armitage/07-launcher-ferramentas-chiba.png`

## Estado “pegando a cor”

- Tela do desktop visível. Lupa **112×112** raio 56, traço `knob` 2 px outside, sombra, conteúdo em grade 7×7 de pixels **16×16**. Pixel central marcado com traço `knob` 2.
- Valor sob o cursor, 112×28 raio 14, logo abaixo da lupa: amostra 12×12 + hex Geist Mono 11 (exemplo `#3FA9D9`, cor fictícia).
- Dica em pílula de vidro raio 20: Clique = pegar · Setas = mover 1 px · Esc = cancelar.

## Estado resultado — launcher 640×476

- Cabeçalho com voltar 32 + título “Seletor de cor” 17 Regular.
- Amostra 96×96 raio 16 em (20,76), borda `border`.
- Nome Serif 24; origem 13 Regular `muted`; botão “Pegar outra”.
- Três linhas de formato 600×44 raio 12, fundo `control`: rótulo Mono 11 `muted` (HEX / RGB / HSL) + valor Mono 13. Ao copiar: check `successText` + “Copiado” por **1,5 s**, botão ícone vira Selecionado.
- Histórico: as **12** últimas, swatches 32×32 raio 8 a cada 40 px, y 364. Hover mostra o valor numa dica (na prévia, a dica foi corrigida para x 32, y 328).
- Rodapé: Copiar HEX ↵ · Pegar outra P.

## Comportamento

- ↵ no resultado copia HEX por padrão.
- O histórico é só de cores deste seletor (não misturar com o clipboard, ficha 18), a menos que se confirme o contrário.
