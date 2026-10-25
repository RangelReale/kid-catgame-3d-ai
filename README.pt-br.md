# kid-catgame-3d-ai

[English](README.md) | **Português**

O jogo do gato em 3D. É uma nova versão do
[kid-catgame-ai](https://github.com/RangelReale/kid-catgame-ai), o jogo 2D de plataforma feito por um pai e
sua filha de 6 anos com a ajuda do Claude. O jogo usa o motor Godot 4.7 e roda em Windows,
Android, Mac e Meta Quest 3.

![O gato arco-íris em 3D em cima de uma caixa, com um monstrinho, colinas, o sol e as nuvens](docs-en/images/screenshot.png)

O gato continua andando só para os lados e para cima, como no jogo 2D. A
diferença é que tudo agora é feito de formas 3D, com luz e sombra, e a câmera
fica um pouco inclinada para mostrar a profundidade. As 16 fases
do jogo 2D estão prontas, do gramado até o parque de diversões. A lista das
ideias da filha para o jogo, na ordem em que ela pediu, está no
[README do jogo 2D](https://github.com/RangelReale/kid-catgame-ai/blob/master/README.pt-br.md#pedidos-da-filha).

Para jogar no navegador, abra
[https://rangelreale.github.io/kid-catgame-3d-ai/](https://rangelreale.github.io/kid-catgame-3d-ai/).
Para jogar no computador, rode `godot --path .` na raiz do repositório. Ande com as setas ou
com A e D, e pule com a barra de espaço. Aperte o pulo de novo no ar para
bater as asas. Um controle também funciona. Os detalhes estão no
[índice dos documentos](docs-pt-br/README.md).

## Meta Quest 3

No Meta Quest 3, a fase vira uma maquete em pé na sala: uma caixa de madeira
com a fase dentro e o céu pintado no fundo. A imagem mostra a maquete na tela
do computador, com `godot --path . -- --xr-preview`. Os detalhes estão em
[Realidade virtual](docs-pt-br/04-realidade-virtual.md).

![A fase 16 como maquete: uma caixa de madeira com o parque de diversões dentro e o céu pintado no fundo](docs-en/images/diorama.png)

## Idiomas e IA

Os documentos existem em português ([docs-pt-br](docs-pt-br/README.md)) e em
inglês ([docs-en](docs-en/README.md)). Ao mudar um, mude o outro.

Quem conversa com a IA neste repositório (Claude e outras) continua usando
português. Assim a filha pode continuar pedindo mudanças no jogo. As regras
para a IA estão em [CLAUDE.md](CLAUDE.md).
