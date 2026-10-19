# Realidade virtual no Meta Quest 3

O jogo tem uma versão para o óculos Meta Quest 3. A fase aparece como uma
maquete, uma caixa de madeira de 1 m de largura que flutua na sala de
verdade, na frente da criança. A versão já está pronta no computador, mas
**ainda não foi testada num óculos**.

![A fase 16 como maquete: uma caixa de madeira com o parque de diversões dentro e o céu pintado no fundo](images/diorama.png)

## Como funciona

- **Realidade misturada.** O óculos mostra a sala de verdade pelas câmeras
  (passthrough). Só a maquete é virtual.
- **A maquete fica parada; a fase desliza.** A caixa não se mexe na sala. A
  fase passa por dentro dela, e o gato fica perto do meio, como na câmera da
  tela. A criança não precisa andar nem virar a cabeça. Na fase 9, a fase
  desliza para cima e para baixo; na fase 11, a maquete segue o avião.
- **Tamanho.** 16 unidades do jogo valem 1 m. A janela da caixa tem 1 m por
  0,6 m. O gato tem uns 5 cm.
- **Lugar na sala.** Quando o jogo começa, a caixa aparece a 0,9 m da cabeça,
  com a base 0,45 m abaixo dos olhos, mais ou menos na altura de uma mesa
  para uma criança sentada. Segurar o botão de pegar (grip) de um controle
  por 1 segundo traz a caixa de volta para a frente da cabeça. O recentro do
  próprio Quest (segurar o botão Meta) faz o mesmo.
- **Controles.** O direcional de qualquer controle anda para os lados e
  nada para baixo. A, X ou um gatilho pulam. Eles apertam as mesmas ações
  do teclado, então nenhuma regra do jogo mudou.
- **Corte nas bordas.** O chão e as colinas das fases são mais largos que a
  caixa. Painéis invisíveis em volta da caixa apagam o que fica do lado de
  fora, e ali aparece a sala.
- **Céu.** O fundo da caixa é pintado com a cor do céu da fase, com o sol e
  as nuvens na frente.

## Ver no computador, sem óculos

`godot --path . -- --xr-preview` mostra a maquete na tela, vista de onde
estaria a cabeça. O cinza em volta faz o papel da sala. Funciona com
`--level N` e com as teclas de fase.

Com um runtime OpenXR no computador e um óculos ligado a ele (por exemplo,
Quest Link ou Virtual Desktop), `godot --path . --xr-mode on` roda a versão
do óculos direto do computador. Sem óculos, o jogo volta para a tela.

## Montar a versão do Quest

1. Baixe o plugin uma vez: `sh tools/install_xr_plugin.sh`. Ele fica em
   `addons/godotopenxrvendors/`, fora do Git, porque tem uns 80 MB.
2. Exporte:
   `godot --headless --path . --install-android-build-template --export-debug "Quest" build/quest/catgame3d-quest.apk`.
   A primeira vez demora, porque o Gradle baixa o que precisa.
3. Instale com o óculos ligado no cabo USB e com o modo de desenvolvedor
   ativo: `adb install -r build/quest/catgame3d-quest.apk`.

A predefinição "Quest" liga o recurso `quest`. Só com ele o OpenXR liga
(`xr/openxr/enabled.quest` em `project.godot`). O jogo de tela, o Retroid e
o iPad continuam sem OpenXR.

## O que falta testar no óculos

- Conforto: a velocidade com que a fase desliza, a distância e a altura da
  caixa.
- Se os painéis invisíveis apagam bem o que sai da caixa no passthrough de
  verdade. No computador, o teste deu certo.
- Velocidade: o Quest precisa de 72 quadros por segundo. Se ficar lento, o
  primeiro passo é desligar as sombras.
- O flash da foto das princesas (fase 14), que no óculos é uma bola branca
  em volta da cabeça.
- No Retroid, se o jogo de tela abre sem erro. A exportação "Android" não
  leva o plugin do óculos, mas a lista de extensões do Godot ainda cita o
  arquivo dele. O esperado é só uma mensagem de erro no começo, sem efeito.

## Cuidados para a criança

- A Meta recomenda o Quest para maiores de 10 anos. A filha tem 6. Os pais
  decidem se e quanto ela usa.
- Sessões curtas. A caixa fica parada na sala para não enjoar.
