# Vídeo de promoção

[English](README.md)

Estes arquivos refazem o vídeo de promoção de 46 segundos do jogo 3D, em
português (`build/promo/jogo_do_gato_promo.mp4`) e em inglês
(`build/promo/cat_game_promo.mp4`). Os dois usam a mesma jogada. Eles seguem
o vídeo de promoção do jogo 2D, em `../kid-catgame-ai/tools/promo/`: os
mesmos trechos, os mesmos títulos e a mesma música.

- `autopilot.gd`: pula a tela de início e joga sozinho. Ele mostra alguns
  segundos de várias fases, uma depois da outra. A lista `CLIPS` diz qual
  fase entra, por quanto tempo e onde o gato começa, em unidades. O gato
  anda para a direita, pula nos monstrinhos, nada como sereia, voa longe
  dos passarinhos e anda na roda-gigante e na montanha-russa. Quando um
  trecho começa, ele chama `snap()` na câmera da fase, e a câmera pula
  direto para o gato.
- `filter.txt`: o filtro do ffmpeg. Ele corta o vídeo em 46,5 segundos, põe
  os títulos em português e mistura a música com o som do jogo.
- `filter_en.txt`: o mesmo filtro, com os títulos em inglês.

As exportações para Windows, web e Quest deixam a pasta `tools/` de fora.
Assim, o script não entra nesses jogos exportados.

## Requisitos

- `godot` e `ffmpeg` no `PATH`.
- A fonte Comic Sans MS Bold. Ela vem no Windows e no Mac.

## Passos

Rode a partir da raiz do repositório. No Windows, use `godot_console` no
lugar de `godot`.

1. Teste o piloto automático sem gravar. A saída deve mostrar uma linha
   `clip` para cada trecho, um `POP` para cada monstrinho e um `ride` para
   cada brinquedo:

   ```sh
   godot --headless --path . --fixed-fps 60 -s tools/promo/autopilot.gd
   ```

2. Grave a jogada. O Godot abre uma janela e grava 46,5 segundos:

   ```sh
   mkdir -p build/promo
   godot --path . --write-movie build/promo/gameplay.avi --fixed-fps 30 -s tools/promo/autopilot.gd
   ```

   No PowerShell, troque `mkdir -p build/promo` por
   `New-Item -ItemType Directory -Force build/promo`.

3. Baixe a música e copie a fonte. Se o jogo 2D estiver na pasta ao lado e
   o vídeo dele já tiver sido feito, dá para copiar o
   `build/promo/music.wav` de lá em vez de baixar.

   ```sh
   curl -L -o build/promo/music.wav "https://opengameart.org/sites/default/files/Cat%20Song%201.2.wav"
   ```

   - Windows: `Copy-Item C:\Windows\Fonts\comicbd.ttf build\promo\font.ttf`
   - Mac: `cp "/System/Library/Fonts/Supplemental/Comic Sans MS Bold.ttf" build/promo/font.ttf`

4. Monte os vídeos a partir de `build/promo`. Os filtros procuram
   `font.ttf` na pasta atual. O primeiro comando faz o vídeo em português, e
   o segundo, o vídeo em inglês:

   ```sh
   cd build/promo
   ffmpeg -y -i gameplay.avi -stream_loop 1 -i music.wav -/filter_complex ../../tools/promo/filter.txt -map "[v]" -map "[a]" -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart jogo_do_gato_promo.mp4
   ffmpeg -y -i gameplay.avi -stream_loop 1 -i music.wav -/filter_complex ../../tools/promo/filter_en.txt -map "[v]" -map "[a]" -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart cat_game_promo.mp4
   cd ../..
   ```

## Quando o jogo mudar

Os títulos de `filter.txt` e de `filter_en.txt` aparecem em segundos fixos,
iguais nos dois arquivos. Cada título combina com um trecho de `CLIPS`: a
fase 1 até 9 s, a praia, a sereia, o ratão, o céu, o avião, as princesas, o
monstro gigante, a roda-gigante, a montanha-russa e o fim aos 42,5 s. Se
mudar a lista `CLIPS`, rode o passo 1. Depois, ajuste os tempos de
`enable='between(t,...)'` e os tempos do fim para os novos momentos da
saída, nos dois filtros.

## Música

"Cat Song", de Dan Knoflicek, está em
<https://opengameart.org/content/cat-song>. A licença é CC0, então não é
preciso pedir permissão. O autor pede o crédito, que já aparece no fim dos
dois vídeos. Ele também pede uma mensagem ou um link quando alguém usa a
música. A música tem 27 segundos. A opção `-stream_loop 1` toca a música
duas vezes seguidas, e o filtro abaixa o volume nos últimos 2 segundos.
