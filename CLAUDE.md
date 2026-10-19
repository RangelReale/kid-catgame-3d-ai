# Jogo do gato 3D

Um jogo de plataforma lateral em 3D (2.5D) com um gato, feito por um pai e
sua filha de 6 anos. É a nova versão do jogo 2D `rr-catgame-poc1`, que fica
na pasta ao lado. Os detalhes estão em [docs/](docs/README.md).

**Estado atual:** as fases 1 a 4 do jogo 2D estão prontas em 3D: gramado,
deserto, praia e fundo do mar. O gato arco-íris anda, pula com cambalhota,
bate as asas três vezes no ar e nada como sereia na fase 4. Os monstrinhos
somem num puf de estrelinhas quando o gato pula neles. A bandeira leva à
próxima fase, e depois da quarta o jogo volta à primeira. As teclas de 1 a 4
pulam direto para cada fase. Faltam as fases 5 a 16 (veja o
[roteiro](docs/03-roteiro.md)). Atualize esta seção a cada marco.

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

- Respostas, documentos e commits: português.
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
| Ver se abre sem erros | `godot --path . --quit-after 120 -- --level N` |
| Exportar para Android | `godot --headless --path . --export-debug "Android" build/android/catgame3d.apk` |

Para ver o jogo sem jogar, grave quadros com o passeio automático. O comando
está no começo de `tools/tests/demo_drive.gd`.

## Regras

- Nunca trabalhe em `master`. Crie um branch antes de qualquer mudança e faça
  commits nele. Faça o merge em `master` e o push só quando o pai pedir.
- Não edite a pasta `.godot/` nem os arquivos `.import`. O Godot os gera.
- Fases são dados: cada fase é um `.tscn`. Não monte fases por código.
- O gato, os monstrinhos e a bandeira ficam no plano z = 0. A profundidade é
  só para a aparência.
- 1 unidade vale 32 pixels do jogo 2D, e y cresce para cima. As fórmulas
  estão em [docs/02-arquitetura.md](docs/02-arquitetura.md).
- Use o bloco (`scenes/level/block.gd`) para chão, caixas, plataformas e
  paredes.
- Leia entradas por ações (`move_left`, `move_right`, `move_down`, `jump`),
  nunca por teclas.
- Mantenha a parte visual de cada cena em um nó `Visual` separado.
- Valores de ajuste ficam em variáveis `@export`.
- Depois de mudar o jogo, rode o teste do movimento e confirme que o jogo abre
  sem erros antes de dizer que terminou.
