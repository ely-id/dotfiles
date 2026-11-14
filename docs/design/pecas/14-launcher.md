# 14 · Launcher

**Nova?** **sim** — a Pond não tem launcher próprio; o “+” abria o Vicinae (`PlusButton.qml`, spec §4.8).  
**Onde encaixar:** pasta nova `shell/launcher/` (janela, busca, resultados, cálculo). Abrir a partir de `minimap/PlusButton.qml`, de um atalho (Manual: Super+Espaço) e, se fizer sentido, de `Shortcuts.qml` / `config/niri/cfg/keybinds.kdl`.  
**Board:** `13:17120`  
**PNG:** `referencias/armitage/07-launcher-ferramentas-chiba.png`

Inspiração visual: Raycast, simples. Vidro Armitage, sempre escuro.

## Medidas comuns

- Largura **640**, raio **24**.
- Cabeçalho de busca altura **56**: ícone 20 em (18,18) (ou botão voltar 32 em (12,12) nas subpáginas); texto Geist Regular **17**, line-height 24, em x 52, y 16; cursor 1×24 `accentText`.
- Divisor y 56, largura 640.
- Seção: rótulo 11 `muted` em (20, y), altura 24.
- Resultado: linha 624×44 raio 12, x 8. Tile de app 28 raio 8 em (8,8). Título 13 Medium + detalhe 13 Regular (na selecionada o detalhe usa `text`, senão `muted`). Tipo 11 à direita. Selecionada: `accentSubtle` + tecla ↵.
- Rodapé **44**: ícone 16 + nome da ferramenta 11 `muted` à esquerda; ações (rótulo 11 + teclas) à direita, separadas por divisor 1×16.
- Placeholder da busca: `muted`. Sugestão fantasma (completar palavra): `muted` a 70%; Tab aceita.
- Tag de contexto (“No workspace 3”): altura 24 raio 12, `accentSubtle`+`accentRing`, texto 11 `accentText`, à direita do cabeçalho.

## Estados (aceite)

1. **Vazio** — altura 352. Recentes (3 apps) + seção Ferramentas com chips: Seletor de cor, Emoji, Captura de tela, Área de transf. Rodapé: Abrir ↵ · Ações Ctrl+K.
2. **Aberto pelo “+”** — o mesmo vazio, com a tag “No workspace N”. O app escolhido abre **nesse** workspace.
3. **Digitando** — altura 260. Fantasma completa a palavra. “Melhor resultado” no topo. Atualiza a cada tecla.
4. **Resultados agrupados** — altura 496. Grupos fixos nesta ordem: Aplicativos, Arquivos, Ajustes, Comandos. ↑↓ navegam, ↵ abre. Comandos perigosos (Desligar) usam ícone `dangerText`.
5. **Cálculo** — altura 360. Ícone `calculator` no cabeçalho. Cartão 624×128 raio 16: expressão Serif 28 `muted` | círculo “igual” | resultado Serif 40. Vírgula decimal **pt-BR**. ↵ copia o resultado; ações Copiar / Colar (Ctrl+↵). Também “Em hexadecimal”.
6. **Sem resultado** — altura 332. Ícone de busca vazia 48, título 15 centrado, dica `muted`, ações “Buscar na web” e “Buscar nos arquivos”.

## Comportamento

- Não reabrir o Vicinae.
- Esc fecha.
- Véu do desktop atrás: preto 20% (ficha 19).
- Posição no desktop de 1440×900 da prévia: launcher em (400, 160) — “terço de cima, centrado”. Em monitores reais, centre horizontalmente e ancore nessa proporção vertical; se a regra exata de multi-monitor faltar, **pergunte**.

## A CONFIRMAR

- Fontes da busca (apps, arquivos, ajustes, comandos): o Figma não escolhe o backend. Sugestão: desktop entries + local files + páginas dos Ajustes + sessão (desligar etc.). Confirme antes de amarrar um indexador pesado.
- Ctrl+K (“Ações”) aparece no rodapé, mas o menu de ações não tem board próprio. **A CONFIRMAR NO FIGMA (node 13:17120)** o conteúdo desse menu, ou implemente um menu mínimo e pergunte.
