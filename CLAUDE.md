# Jogo do gato 3D

Um jogo de plataforma lateral em 3D (2.5D) com um gato, feito por um pai e
sua filha de 6 anos. É a nova versão do jogo 2D `rr-catgame-poc1`, que fica
na pasta ao lado. Os detalhes estão em [docs-pt-br/](docs-pt-br/README.md) (em inglês, em [docs-en/](docs-en/README.md)).

**Estado atual:** as 16 fases do jogo 2D estão prontas em 3D. O gato
arco-íris anda, pula com cambalhota, bate as asas três vezes no ar, nada como
sereia (fase 4) e voa livre (fase 8). Os monstrinhos somem num puf de
estrelinhas. O homem bravo, os passarinhos e as malas fazem a fase recomeçar.
O ratão e o monstro gigante têm barra de vida e liberam a bandeira. A fase 11
é o voo do avião sem controles. As princesas pegam o gato no colo, e a fase 16
é o parque de diversões com roda-gigante, carrossel, camas elásticas,
montanha-russa, torre e pescaria. O jogo abre numa tela de início: "Jogo do
gato" sobre fases que jogam sozinhas, em sépia, com música de bipes; qualquer
botão (menos teclas especiais) começa a fase 1, e `--level N` pula essa tela.
Depois da última fase, a imagem fica sépia, aparecem "Você venceu!" e os
créditos, e um botão volta à tela de início. Os monstrinhos fazem "puf" ao
sumir; o ratão e o monstro gigante fazem "bonk" nos pulos antes do último. O jogo fala português e inglês: abre no idioma do aparelho, e duas
bandeiras na tela de início (ou a tecla L; no óculos, B ou Y) trocam o
idioma. As teclas de 1 a 9 e o 0 pulam para as fases 1 a 10; com Ctrl, para
as fases 11 a 20. Os próximos passos estão no [roteiro](docs-pt-br/03-roteiro.md).
Há também uma versão para o Meta Quest 3, em que a fase vira uma maquete na
sala ([docs-pt-br/04-realidade-virtual.md](docs-pt-br/04-realidade-virtual.md)); no óculos, as palavras
da tela de início e dos créditos aparecem em 3D na maquete. Ela já
abriu num Quest 3 de verdade. Atualize esta seção a cada marco.

## Quem pede as mudanças

Muitos pedidos vêm da criança, ditados por voz. O texto chega informal, com
erros de transcrição e sem detalhes.

- Escolha a interpretação mais simples e faça. Não faça perguntas técnicas.
- Faça uma mudança pequena e visível por vez.
- Depois de mudar, diga em uma ou duas frases curtas o que mudou e como ver
  isso no jogo. Use palavras que uma criança de 6 anos entende.
- Se o pedido for grande, faça a primeira parte jogável e diga o que falta.
- O conteúdo do jogo é para criança: sem violência e sem sustos. O jogador
  não pode precisar ler para jogar.

## Idioma

- Respostas e commits: português. Toda conversa com a IA neste repositório
  continua em português, mesmo com os documentos em dois idiomas, para que a
  filha possa continuar pedindo mudanças.
- Documentos: em português (`docs-pt-br/`, `README.pt-br.md`) e em inglês
  (`docs-en/`, `README.md`). Ao mudar um documento, mude também a versão no
  outro idioma. As imagens ficam só em `docs-en/images/`.
- Código, nomes de arquivos, nós e ações: inglês.

## Tecnologia

- Godot 4.7, com GDScript tipado e renderizador Compatibility.
- Plataformas, em ordem de prioridade: Windows, Android (Retroid Pocket 3+),
  Mac. O jogo também roda no iPad.
- O desenvolvimento acontece no Windows e no Mac. Verifique o sistema antes
  de rodar comandos.

## Comandos

Rode a partir da raiz do repositório. No Windows, use `godot_console` no
lugar de `godot` sempre que a saída importa.

| Tarefa | Comando |
| --- | --- |
| Abrir o editor | `godot -e --path .` |
| Rodar o jogo | `godot --path .` |
| Começar numa fase | `godot --path . -- --level 3` |
| Rodar com os botões de toque | `godot --path . -- --touch` |
| Importar recursos | `godot --headless --path . --import` |
| Testar o movimento | `godot --headless --path . -s tools/tests/movement_test.gd` |
| Testar as peças das fases | o mesmo comando com `group_a_test.gd`, `group_b_test.gd` e `group_c_test.gd` |
| Testar a tela de início e o final | o mesmo comando com `flow_test.gd` |
| Ver se abre sem erros | `godot --path . --quit-after 120 -- --level N` |
| Exportar para Android | `godot --headless --path . --export-debug "Android" build/android/catgame3d.apk` |
| Ver a maquete do óculos na tela | `godot --path . -- --xr-preview` |
| Testar a maquete do óculos | `godot --headless --path . -s tools/tests/xr_test.gd` |
| Baixar o plugin do óculos (uma vez) | `sh tools/install_xr_plugin.sh` |
| Exportar para o Quest 3 | `godot --headless --path . --install-android-build-template --export-debug "Quest" build/quest/catgame3d-quest.apk` |
| Exportar para Windows | `godot --headless --path . --export-release "Windows" build/windows/catgame3d.exe` |
| Exportar para a web | `godot --headless --path . --export-release "Web" build/web/index.html` |
| Publicar uma versão | no GitHub, Actions > Release > Run workflow ([docs-pt-br/05-versoes.md](docs-pt-br/05-versoes.md)) |

Para ver o jogo sem jogar, grave quadros com o passeio automático. O comando
está no começo de `tools/tests/demo_drive.gd`.

## Regras

- Neste repositório, não crie branches. Faça os commits direto em `master`.
  Faça o push só quando o pai pedir.
- Não edite a pasta `.godot/` nem os arquivos `.import`. O Godot os gera.
- Fases são dados: cada fase é um `.tscn`. Não monte fases por código.
- O gato, os monstrinhos e a bandeira ficam no plano z = 0. A profundidade é
  só para a aparência.
- 1 unidade vale 32 pixels do jogo 2D, e y cresce para cima. As fórmulas
  estão em [docs-pt-br/02-arquitetura.md](docs-pt-br/02-arquitetura.md).
- Não leia a câmera da tela nem o tamanho da tela no código do jogo. No
  óculos, a câmera é a cabeça. Use a câmera da fase só como dados (alvo e
  limites), como faz o rig em `scenes/xr/`.
- Use o bloco (`scenes/level/block.gd`) para chão, caixas, plataformas e
  paredes.
- Leia entradas por ações (`move_left`, `move_right`, `move_down`, `jump`),
  nunca por teclas.
- Mantenha a parte visual de cada cena em um nó `Visual` separado.
- Valores de ajuste ficam em variáveis `@export`.
- Depois de mudar o jogo, rode os testes de `tools/tests/` e confirme que o jogo abre
  sem erros antes de dizer que terminou.
