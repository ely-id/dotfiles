# 0011 — As peças leem o estado por `service`, e a vitrine usa a peça real com dados fictícios

- **Data:** 2026-11-15
- **Estado:** Aceita

## Contexto

Na F1 e na F2 a vitrine (`ComponentDemoPanel.qml`) mostrava as peças com propriedades de amostra (`previewCount`, `previewReveal`, `visualState`) ou com réplicas desenhadas só para ela. Na F3 as peças dependem de serviços de verdade: NetworkManager, BlueZ, PipeWire, UPower e o servidor de notificações. O código que copiei da origem lê esses serviços direto, por singletons (`Wifi.State`, `Bluetooth.State`, `Audio.State`, `Battery.State`, `Notifications.State`). Isso criava três problemas:

- A vitrine mostraria as minhas redes, os meus dispositivos e as minhas notificações, e a regra do projeto é que nada real da máquina entra nos prints.
- Não dava para ver estados raros (senha incorreta, bateria em 9%, Bluetooth desligado) sem provocá-los de verdade.
- Para conferir o desenho eu precisava de uma sessão do Niri, porque nada abria fora dela.

As opções eram manter réplicas desenhadas na vitrine, injetar dados nos singletons só em modo de demonstração, ou fazer cada peça receber o estado por uma propriedade.

## Decisão

Cada painel e cartão da F3 tem uma propriedade `service`, com o singleton real como valor padrão (`property var service: Wifi.State`). As páginas de uma pilha leem `stackController.service`. Os estados fictícios ficam em `wintermute-shell/demo/` (`WifiService.qml`, `BluetoothService.qml`, `AudioService.qml`, `BatteryService.qml`, `NotificationService.qml`) com a mesma superfície do serviço real, e cada peça tem um espécime (`WifiSpecimen.qml` etc.) que instancia **a peça de verdade** com esse estado. A vitrine só instancia os espécimes. O mesmo vale para o que não é estado de serviço mas variava: o calendário recebe `today`, e o cartão da barra recebe `service` e `demoArrival`.

## Motivo

A vitrine passa a mostrar exatamente o código que roda na shell, em vez de uma réplica que poderia divergir, e os estados raros custam uma linha. Como os espécimes não dependem do `PanelWindow`, consigo renderizar as peças numa janela comum (`FloatingWindow`) fora do Niri e tirar prints para comparar com a referência, o que só era possível ao vivo antes. Injetar dados nos singletons deixaria o modo de demonstração dentro do código de produção.

## Consequências

- Peça nova que lê um serviço recebe `service` desde o começo, e quem a testa escreve um serviço fictício em `demo/` com a mesma superfície.
- O valor padrão `Wifi.State` e afins ainda é avaliado quando a peça é criada, então o singleton real é instanciado mesmo na vitrine. Nos testes em janela comum troquei `bluetooth/State.qml` e `notifications/State.qml` por um stub na cópia de teste, para não registrar o agente de pareamento nem disputar o nome de notificações no D-Bus da sessão.
- Um serviço fictício que fica para trás da superfície do real quebra em silêncio: a propriedade some e a peça mostra vazio. Ao mudar a superfície de um serviço, atualizo o fictício no mesmo commit.
- Ainda não vale para as peças das fases seguintes (Ajustes, launcher, captura). Cada uma adota a convenção quando for refeita.
