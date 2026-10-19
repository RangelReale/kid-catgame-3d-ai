# Arquitetura

## Ideia geral

O jogo é 2.5D: tudo é 3D, mas o gato, os monstrinhos e a bandeira ficam no
plano onde z é 0. O gato anda para os lados (x) e sobe e desce (y), como no
jogo 2D. A profundidade (z) serve só para a aparência: caixas com volume,
colinas ao fundo e sombras.

## Pastas

```
project.godot          configuração: tela, ações de entrada, renderizador
scenes/
  main.tscn            a cena que o jogo abre; tem a lista de fases e os botões
  hud/                 botões de toque (2D, copiados do jogo 2D)
  camera/              a câmera que segue o gato
  level/               peças de fase: bloco, plataforma móvel de mão única,
                       luz e céu, céu distante, balanço, pintura
  levels/              uma cena por fase
  player/              o gato
  monster/             o monstrinho
  goal/                a bandeira de chegada
  sun/, cloud/         o sol e as nuvens do céu
assets/                ícone e sons
tools/tests/           teste automático e passeio automático para gravar quadros
docs/                  estes documentos (o Godot ignora a pasta)
```

## Medidas

Uma unidade do 3D vale 32 pixels do jogo 2D. O chão fica em y = 0, e y
cresce para cima (no 2D, y cresce para baixo). Para passar uma posição do 2D
para o 3D:

- x 3D = x 2D ÷ 32
- y 3D = (238 − y 2D) ÷ 32, porque o chão do 2D ficava em y = 238

Os números do gato são os do 2D divididos por 32:

| Valor | 2D (pixels) | 3D (unidades) |
| --- | --- | --- |
| Velocidade | 120 | 3,75 |
| Pulo | 300 | 9,375 |
| Gravidade | 900 | 28,125 |
| Batida de asa | 250 | 7,8125 |
| Quique no monstrinho | 220 | 6,875 |
| Nado (sereia e voo) | 130 | 4,0625 |
| Monstrinho: velocidade, distância | 25, 60 | 0,78125, 1,875 |

O pulo sobe 1,64 unidades, que são 52,5 pixels, igual ao jogo 2D.

## Peças de fase

- **Bloco** (`scenes/level/block.gd`): uma caixa sólida. A posição é o meio
  da caixa. Tem tamanho, cor e duas opções: `show_mesh` (desligada nas paredes
  invisíveis) e `one_way` (plataforma que o gato atravessa de baixo para
  cima). O Godot 3D não tem plataforma de mão única, então o bloco liga a
  colisão só quando os pés do gato estão em cima dele e o gato não está
  subindo.
- **Luz e céu** (`scenes/level/level_environment.gd`): a cor do céu, a luz
  ambiente, o sol com sombras e a névoa. No Retroid, `shadows` pode ser
  desligado se o jogo ficar lento.
- **Céu distante** (`scenes/level/sky.gd`): guarda o sol e as nuvens, longe
  do gato (z = −30). Ele acompanha a câmera um pouco mais devagar do que ela
  anda, para parecer bem longe.
- **Balanço** (`scenes/level/wobble.gd`): faz a água subir e descer e as algas
  balançarem.

## Câmera

A câmera (`scenes/camera/follow_camera.gd`) segue o gato com suavidade. Ela
fica um pouco acima (`pitch_degrees`, 8 graus) e um pouco à esquerda
(`yaw_degrees`, 6 graus), para mostrar o topo e o lado das caixas. Com os
dois em 0, a vista fica reta, como no 2D.

Cada fase define os limites da câmera no plano z = 0 (`limit_left`,
`limit_right`, `limit_bottom`, `limit_top`). Por causa da inclinação, a área
vista é um trapézio, e não um retângulo. A câmera usa o maior retângulo que
cabe dentro dele, então um pouco do lado de fora pode aparecer nos cantos. Por
isso o chão das fases é mais largo que a fase.

## Como passar uma fase do 2D para o 3D

1. Copie uma fase pronta, como `level_01.tscn`.
2. Converta cada posição e tamanho com as fórmulas de "Medidas". Blocos
   usam o meio da caixa, como os `StaticBody2D` do 2D.
3. O chão tem profundidade 10 e fica em z = −3, para ir de z = −8 até z = 2.
   Caixas e plataformas têm profundidade entre 1,5 e 2.
4. Coloque o sol e as nuvens dentro do nó `Sky`, em z = −30.
5. Coloque decoração ao fundo (z negativo) para dar profundidade.
6. Ponha a fase na lista `levels` de `scenes/main.tscn`.

## Testes

- `godot_console --headless --path . -s tools/tests/movement_test.gd` testa o
  pulo, as asas, o monstrinho, a bandeira, a plataforma de mão única e a
  sereia. `group_a_test.gd`, `group_b_test.gd` e `group_c_test.gd` testam as
  peças das fases 5 a 16: homem bravo, chefes, passarinhos, malas, avião,
  cama elástica, brinquedos que carregam o gato, princesas e peixes.
- `tools/tests/demo_drive.gd` joga sozinho por alguns segundos. Com o
  gravador de vídeo do Godot (`--write-movie`), ele grava quadros para ver o
  jogo sem jogar. O comando está no começo do arquivo.
