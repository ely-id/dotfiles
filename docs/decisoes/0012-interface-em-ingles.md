# 0012 — A interface da shell fala inglês

- **Data:** 2026-11-15
- **Estado:** Aceita

## Contexto

O código que copiei da origem escreve a interface em inglês ("Appearance", "Lock screen", "Update available"). As fichas de design descrevem as peças em português ("Aparência", "N atualizações disponíveis"), porque é a língua em que escrevo o projeto (decisão 0006), e nas fases F2 e F3 eu passei para o português parte dos textos das peças que redesenhei: o Bluetooth, os campos do Wi-Fi corporativo, o calendário (com locale pt-BR na ficha 09) e o contador da central de notificações. O resultado era uma interface misturada.

Ao responder a P-11, em 2026-11-15, defini: "usar sempre o idioma no inglês para a interface ou então seguir o idioma do sistema". As opções eram três: inglês fixo; seguir o idioma do sistema com uma camada de tradução (`qsTr` mais arquivos `.ts`/`.qm`, que o Quickshell não carrega sozinho); ou manter o português.

## Decisão

Todo texto que a shell mostra é escrito em inglês: rótulos, títulos, mensagens, nomes acessíveis e descrições de atalho. Datas e números seguem o locale do sistema (`Qt.locale()`), que nesta máquina é `en_US`.

Não monto agora a camada de tradução. Se um dia eu quiser a shell em português num sistema em português, isso entra como ajuste de escopo, com os textos já escritos em inglês como origem.

A regra vale para a interface. Não vale para o projeto: código comentado, documentação, fichas, painel e commits continuam em português (decisão 0006). As legendas da vitrine (`ComponentDemoPanel.qml`) são notas de conferência para mim, e não interface; ficam em português.

## Motivo

O sistema roda em inglês, então as duas formas que aceitei ("inglês" e "seguir o sistema") dão o mesmo resultado aqui. Escrever em inglês já cumpre as duas sem a camada de tradução, que exigiria carregar um `QTranslator` por fora do QML e manter um arquivo de tradução a cada texto novo. A origem já está em inglês, o que poupa reescrever as peças que ainda não redesenhei.

## Consequências

- As fichas continuam descrevendo os textos em português, como referência de sentido. Na implementação, cada texto vira o equivalente em inglês. Quando a ficha cita um texto literal (por exemplo, "N atualizações disponíveis"), a peça mostra a tradução ("N updates available").
- Os textos em português que deixei nas peças da F2 e da F3 passam para o inglês na `F4-T16`, junto com o locale do calendário, que deixa de ser fixo em pt-BR.
- As descrições dos atalhos no Niri (`hotkey-overlay-title`) e na lista do Manual também ficam em inglês.
