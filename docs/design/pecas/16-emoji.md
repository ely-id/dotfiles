# 16 · Seletor de emoji

**Nova?** **sim** (dentro do launcher, ficha 14)  
**Onde encaixar:** `shell/launcher/`  
**Board:** `13:17120`  
**PNG:** `referencias/armitage/07-launcher-ferramentas-chiba.png`

## Medidas — launcher 640×436

- Cabeçalho com voltar + busca (“Buscar emoji”), Geist 17.
- Abas 36×36 raio 10 a cada 44 px, origem (20,64). Aba ativa: fundo `accentSubtle`, ícone `accentText`. Com busca, as abas ficam a 50% e nenhuma selecionada.
- Divisor y 108.
- Células **48×48** raio 12, passo **52**, origem x 36. Emoji 28, centrado.
- Hover: `hover`. Selecionada: `accentSubtle` + `accentRing`.
- Seções: “Recentes” (11 emojis na prévia) e categoria (grade 3×11 na prévia de Rostos e pessoas).
- Rodapé 44: prévia 20 + nome 11 à esquerda; ações Copiar ↵ · Tons de pele Ctrl+T.

## Estados

1. Grade (recentes + categorias).
2. Busca por nome em **português e inglês** (prévia: “gato”).
3. Tons de pele: segurar o clique ou Ctrl+T abre uma faixa 320×56 com os 6 tons; o escolhido vira o padrão.

## Fonte

No Figma usou-se Noto Color Emoji, mas a exportação saiu **monocromática**. No sistema real os emojis devem aparecer **coloridos**. Família sugerida: Noto Color Emoji (OFL) ou a fonte colorida do sistema.

## A CONFIRMAR

- Lista completa de categorias e o inventário de emojis (o Figma só mostra uma amostra). Pode usar um conjunto padrão (CLDR / Noto) e seguir o layout da ficha; não precisa copiar só os 33 rostos da prévia.
- Família exata no CachyOS se Noto Color Emoji não estiver instalado — pergunte antes de puxar outra fonte.
