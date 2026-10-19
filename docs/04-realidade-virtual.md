# Realidade virtual no Meta Quest 3 (futuro)

Este documento descreve um plano para o futuro: jogar o jogo do gato em 3D
dentro de um óculos de realidade virtual, o Meta Quest 3. Nada disto está
feito ainda. O trabalho começa depois que as 16 fases estiverem prontas em 3D
(veja o [roteiro](03-roteiro.md)).

## É possível?

Sim. O Godot 4 tem suporte a OpenXR, o padrão aberto de realidade virtual. O
Quest 3 roda jogos Godot direto no óculos, sem computador, como um app de
Android. O renderizador Compatibility, que o jogo já usa, é o que o Godot
recomenda para o Quest.

O que já serve sem mudança:

- O motor, as cenas e os modelos 3D.
- As fases e as regras do jogo. O gato continua andando no plano z = 0.
- As ações de entrada (`move_left`, `move_right`, `move_down`, `jump`). Os
  botões e o direcional dos controles do Quest podem ser ligados a elas.

## Como o jogo ficaria

A fase aparece flutuando na frente do jogador, como uma maquete em cima de
uma mesa. Jogos como Moss e Astro Bot usam essa ideia. O jogador vê o gato de
lado, como hoje, mas pode chegar perto e olhar as caixas e os monstrinhos de
outros ângulos.

## O que precisa mudar

- **Câmera.** Na realidade virtual, a cabeça do jogador é a câmera. A câmera
  que segue o gato (`scenes/camera/follow_camera.gd`) não pode mexer a vista
  sozinha, porque isso enjoa. A maquete fica parada, ou anda bem devagar para
  acompanhar o gato.
- **Céu.** O sol e as nuvens hoje acompanham a câmera. Na realidade virtual,
  eles ficam parados ao redor do jogador.
- **Botões de toque.** Ficam escondidos no Quest.
- **Exportação.** Uma nova predefinição em `export_presets.cfg` para o Quest,
  com o plugin "Godot OpenXR Vendors".
- **Desempenho.** O Quest precisa desenhar a cena duas vezes, uma para cada
  olho, a 72 quadros por segundo ou mais. As sombras e a névoa precisam de
  teste no óculos.

## Cuidados para a criança

- A Meta recomenda o Quest para maiores de 10 anos. A filha tem 6. Os pais
  decidem se e quanto ela usa.
- Sessões curtas, com a vista sempre parada, para não enjoar.

## Passos

1. Terminar as 16 fases em 3D.
2. Criar uma cena de realidade virtual com a câmera da cabeça, os dois
   controles e a fase como maquete.
3. Ligar os controles às ações do jogo.
4. Exportar para o Quest 3 e testar o conforto e a velocidade.
