# 0008 — O que a shell traz de fora da pasta `shell/` da origem

- **Data:** 2026-11-14
- **Estado:** Aceita

## Contexto

A decisão 0003 diz que a shell parte de uma cópia do código da interface da Pond. Ao preparar essa cópia, na fase F0, li o código de origem atrás de tudo o que ele usa e que não mora na pasta `shell/`, e encontrei mais do que eu esperava:

- quatro módulos QML instalados no sistema, que `shell.qml` importa pelo nome: a captura de tela, o papel de parede, o céu do papel de parede dinâmico e um plugin de sistema;
- dois plugins em C++, que precisam ser compilados com `cmake`;
- a tela de bloqueio, chamada pelos botões de sessão e pela suspensão;
- o gerenciador de pacotes da distribuição de origem, que alimenta o selo de atualização e o cartão de instalações;
- um launcher externo, chamado em quatro pontos;
- seis scripts Python, com dependências de pacotes e de comandos do sistema;
- quatro famílias de fonte que não são as do design Armitage;
- arquivos de configuração e de estado gravados em pastas com o nome da origem, e a própria configuração do Niri.

Sem decidir item a item, a shell nem abriria: faltariam os módulos e o plugin compilado. O levantamento completo, com arquivo e linha de cada ponto, está na nota da fase F0 no painel do projeto.

## Decisão

**A shell é autocontida.** Tudo o que ela precisa da origem mora dentro de `wintermute-shell/` e é importado por caminho relativo. Abrir a shell é apontar o Quickshell para a pasta (`qs -p wintermute-shell`), sem instalar módulo no sistema.

Item a item:

| Item | O que fiz | Quando volta ou muda |
|---|---|---|
| Captura de tela (`screenshot/`) | Entra, como `wintermute-shell/screenshot/` | Evolui na F6 |
| Papel de parede (`wallpaper/desktop`, `wallpaper/daylight`, `wallpaper/control.py`) | Entra o código, como `wintermute-shell/wallpaper/` | Seletor na F4 |
| Fotos de papel de parede e o catálogo delas | Não entram | Na F4 entram os meus papéis de parede, um por variação |
| Arte do manual da origem (SVG de 2,9 MB) | Não entra | A F4 segue o desenho do Figma |
| Plugin do arraste da captura (`screenshot/native/`) | O código entra, desligado | Compilado e religado na F6 |
| Plugin de sistema (segura a suspensão até a tela travar) | Sai de `shell.qml` | A F7 decide de onde parte a tela de bloqueio |
| Tela de bloqueio | Não entra na F0. "Bloquear" e "Suspender" ficam sem efeito | F7 |
| Gerenciador de pacotes da origem | Sai | O selo de atualização e o cartão de instalações passam a ler o Cachy Update, na F2 e na F4 |
| Launcher externo | Sai, nos quatro pontos | Marcador até a F5, que traz o launcher próprio |
| Scripts Python dos Ajustes, da sessão e do Bluetooth | Entram como estão | Pacotes vão para a lista da F10 |
| Fontes da origem | Saem | Geist, Geist Serif e Geist Mono, ainda na F0 |
| Pastas de configuração e de estado | Trocam para `wintermute-shell` | Tema na F0; o resto ao longo das fases |
| Tema GTK, cursor, configuração de outro terminal | Não entram | Fora do escopo |

**Aceito um passo de compilação na instalação.** Os dois plugins em C++ podem voltar, e o instalador da F10 pode compilar. Mas a shell precisa abrir sem eles: o que depende de plugin compilado é um recurso a mais, nunca uma condição para a barra aparecer.

**A shell pode escrever na configuração do Niri.** As páginas de mouse, teclado e tela dos Ajustes gravam em `~/.config/niri/cfg/`, e as fases podem acrescentar à configuração do Niri os atalhos, as regras de camada e os comandos de que a shell precisa. Tudo o que for acrescentado leva a marca `wintermute`.

## Motivo

**Autocontida, porque o projeto promete instalação fácil.** Na origem os módulos chegam ao sistema por um pacote da distribuição, que eu não tenho e não quero ter. Com tudo dentro de uma pasta, instalar a shell é copiar a pasta, e testar é apontar o Quickshell para o repositório. Também fica mais fácil cumprir a regra de uma pasta por peça.

**Copiar agora o plugin do arraste, mesmo desligado,** porque a decisão 0003 manda fazer a cópia uma única vez. Se eu deixasse para a F6, estaria voltando ao repositório de origem depois da cópia.

**Não trazer as fotos nem a arte do manual,** porque a decisão 0003 já exclui os recursos visuais da origem, e porque seriam 46 MB de imagens que não fazem parte do design Armitage.

**Tirar o plugin de sistema em vez de compilar já,** porque ele só existe para a tela de bloqueio, que é a fase F7, e porque o código dele mora na pasta da tela de bloqueio da origem, que a decisão 0003 não cobre. Trazer agora seria decidir a F7 pela porta dos fundos.

**Manter a recusa de suspender sem bloqueio.** O script de sessão da origem só suspende depois que a tela de bloqueio confirma que travou. Sem tela de bloqueio, ele não suspende. Prefiro um botão que não faz nada até a F7 a uma suspensão que acorda com a sessão aberta.

**Cachy Update no lugar do gerenciador da origem,** porque o sistema é o CachyOS e a ferramenta é da própria distribuição. Recriar o gerenciador de pacotes da Pond está fora do escopo.

**Manter os scripts Python,** porque reescrevê-los não melhora nada que eu vá ver na tela, e eles já resolvem leitura e escrita segura dos arquivos do Niri.

**Marcar com `wintermute` o que entra no Niri,** porque a configuração do Niri só é recolhida para o repositório na fase F8. Até lá ela muda a cada fase, e a marca é o que permite recolher depois sem adivinhar o que é da shell e o que é meu.

## Consequências

- `wintermute-shell/` tem três partes de origens diferentes: a raiz (a antiga `shell/`), `screenshot/` e `wallpaper/`. O README da pasta explica o mapa.
- Entre a F0 e a F7, "Bloquear" e "Suspender" não funcionam pela shell, nem o bloqueio por inatividade. Fechar a tampa suspende sem a shell travar a sessão. Enquanto o Niri for só a sessão de testes, isso é aceitável; a F7 não pode terminar sem resolver.
- Entre a F0 e a F6, a prévia da captura não pode ser arrastada para outro aplicativo. Copiar continua funcionando.
- O selo de atualização não aparece até a F4, e o cartão de instalações fica sem quem o alimente até a F2.
- O instalador da F10 precisa de: Quickshell, Python com PyQt6 e PyGObject, `brightnessctl`, `ddcutil`, `wl-clipboard`, `fastfetch`, NetworkManager, `iw`, o cliente do PulseAudio, `cachy-update`, as fontes Geist e, para os plugins, `cmake` e os cabeçalhos do Qt.
- A troca de fuso horário pelos Ajustes usa, na origem, uma regra de `sudo` sem senha. Procuro outro caminho na F4; se não houver um limpo, a página sai e o relógio segue o horário do sistema.
- Os Ajustes pressupõem a configuração do Niri dividida em `cfg/input.kdl` e `cfg/display.kdl`. A pasta `niri/` do repositório mantém essa divisão.
- Os nomes da origem que ainda estão no código (namespaces das camadas, pastas de estado, textos, símbolos de tema) saem ao longo das fases. A F11 confere que não sobrou nenhum.
