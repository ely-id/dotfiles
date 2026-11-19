# 0017 — A captura de tela recorta o quadro congelado, em vez de chamar a captura do Niri

- **Data:** 2026-11-19
- **Estado:** Aceita

## Contexto

A captura de tela da shell (ficha 17) precisa virar uma imagem em três casos: uma área que eu seleciono, uma janela que eu escolho e um monitor inteiro. Quando cheguei à `F6-T13`, a janela de captura já mostrava um quadro congelado de cada monitor, tirado pelo `ScreencopyView` do Quickshell no instante em que a captura abre, do mesmo jeito que a lupa do seletor de cor. Havia dois caminhos para a imagem final:

1. Recortar esse quadro congelado.
2. Fechar a interface e pedir a captura ao Niri (`niri msg action screenshot-window`, `screenshot-screen` e as outras), que já entrega o arquivo e avisa a shell pelo evento `ScreenshotCaptured`.

## Decisão

A imagem sai do quadro congelado, recortado em pixels do quadro (e não em pixels lógicos: num monitor com escala o quadro tem mais pixels). A área é o retângulo da seleção, a janela é o retângulo que o Niri informa para ela, cortado no que cabe no monitor, e a tela é o quadro inteiro.

Para o botão "mostrar o cursor" valer, a captura tira dois quadros por monitor quando abre, um sem o cursor e um com, e mostra e recorta o que corresponde ao botão.

O recorte é gravado como PNG num arquivo temporário, em `$XDG_RUNTIME_DIR/wintermute-shell/`, e cada captura apaga o arquivo da anterior. Daí ele vai para a área de transferência (`wl-copy`, pelo `screenshot/clipboard.py`) e para a prévia da barra.

Das três binds de captura, só a de região (Super+Shift+1) passa a abrir a captura da shell. As de tela (Super+Shift+2) e de janela (Super+Shift+3) continuam com as ações do Niri, que capturam na hora, sem interface, e cuja imagem já chega à prévia pelo evento do Niri.

## Motivo

**O quadro congelado, e não a captura do Niri,** porque o que eu vejo parado na tela é exatamente o que sai, nos três modos, com uma conta só. Pedindo ao Niri depois de fechar a interface, a tela já teria andado: um vídeo, um menu aberto, uma animação. E a área selecionada sobre o quadro congelado não teria como ser pedida ao Niri sem a interface dele.

**Dois quadros, e não um,** porque o cursor não pode ser acrescentado depois: ou ele está no quadro, ou não está. Tirar os dois na abertura custa uma captura a mais por monitor e deixa o botão valer a qualquer momento.

**As binds de tela e de janela continuam no Niri,** porque elas capturam na hora, sem eu escolher nada, e é assim que eu as uso. A captura da shell sempre abre a interface; pelo Espaço eu chego aos modos Window e Screen quando quero escolher.

**Arquivo temporário,** porque a prévia da origem já sabe receber um arquivo, e porque a pasta definitiva e o formato de salvar ainda são perguntas abertas (P-15 e P-16).

## Consequências

- A janela capturada é um recorte retangular: os cantos arredondados saem com o que estava atrás deles, e uma janela que passa da borda do monitor sai cortada. A captura do Niri pela bind (Super+Shift+3) continua dando a janela inteira.
- A posição da janela vem do `layout` do IPC do Niri; se a conta estiver errada, o recorte herda o erro. Só dá para conferir na sessão do Niri.
- Num monitor com escala fracionária, o PNG pode sair com 1 px a mais ou a menos que o recorte, por um limite do `grabToImage` do Qt. Com escala 1 e 2 ele sai exato.
- O atraso da captura (P-16), quando existir, muda o momento em que os quadros são tirados, e não o recorte.
- Salvar numa pasta definitiva (`F6-T03`) parte do mesmo arquivo temporário.
