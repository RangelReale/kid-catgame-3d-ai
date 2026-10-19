# Tecnologia

## Escolha

O jogo 3D usa o **Godot 4.7**, com GDScript tipado e o renderizador
**Compatibility** (OpenGL). É o mesmo motor do jogo 2D.

## Por que o Godot

- **Já está em uso.** O Godot 4.7.2 já está instalado. As ações de entrada,
  os botões de toque, o som e as predefinições de exportação do jogo 2D
  servem sem mudança.
- **Cenas em texto.** Cenas (`.tscn`) e scripts (`.gd`) são arquivos de
  texto. O Claude consegue ler e escrever uma fase inteira. Isso mantém a
  regra do jogo 2D: cada fase é um arquivo de dados.
- **Roda no Retroid.** O Retroid Pocket 3+ tem uma GPU Mali-G52, que é
  fraca. O renderizador Vulkan do Godot para celulares roda mal nessa GPU. O
  renderizador Compatibility é a escolha segura, e o jogo 2D já o usa. Formas
  simples com uma cor e uma luz só são leves nele.
- **Livre e gratuito.** A licença é MIT. Desde o Godot 4.6, a física 3D
  padrão é a Jolt, que é estável.

## Outras opções

| Motor | Por que não |
| --- | --- |
| Unity | Tem boas ferramentas para celular. Mas as cenas são difíceis de editar como texto, e a Unity exige conta e licença. Para um jogo deste tamanho, nada disso ajuda. |
| Unreal | É pesado demais para o Retroid. C++ e Blueprints não combinam com mudanças pequenas pedidas por voz. |
| Bevy | Não tem editor, e a exportação para celular ainda é imatura. |
| three.js | Não tem editor e foi feito para a web, sem exportação para Android ou iOS. |

## Fontes

- [Arm: otimizar cenas 3D no Godot em GPUs Arm](https://developer.arm.com/community/arm-community-blogs/b/mobile-graphics-and-gaming-blog/posts/optimizing-3d-scenes-in-godot-on-arm-gpus)
- [Como testar um jogo Godot em Android fraco](https://bugnet.io/blog/how-to-test-your-godot-game-on-low-end-android-phones)
- [Unity, Godot ou Unreal em 2026](https://oceanviewgames.co.uk/blog/posts/unity-vs-godot-vs-unreal-2026)
- [Motores de jogo de código aberto em 2026](https://app.cinevva.com/guides/open-source-game-engines-2026)
