# Publicar uma versão

Uma versão é um release no GitHub com quatro arquivos:

- `catgame3d-<versão>-windows-setup.exe`: o instalador do Windows. Ele
  instala o jogo só para o usuário atual, sem pedir administrador, e cria
  atalhos no menu Iniciar e na área de trabalho.
- `catgame3d-<versão>-android.apk`: o jogo para o Retroid e celulares.
- `catgame3d-<versão>-quest.apk`: o jogo para o Meta Quest 3.
- `catgame3d-<versão>-web.zip`: o jogo para o navegador. Descompacte e
  ponha os arquivos em qualquer servidor web; o jogo abre pelo `index.html`.
  Ele não abre direto do disco (`file://`), só por um servidor.

## Como publicar

1. No GitHub, abra **Actions** > **Release** > **Run workflow**.
2. Digite a versão no formato `1.2.3` e clique em **Run workflow**.

O workflow (`.github/workflows/release.yml`) faz o resto:

- confere a versão e se a tag `v1.2.3` ainda não existe;
- põe a versão nas exportações. O número interno do Android é
  `maior × 10000 + menor × 100 + correção`, então 1.2.3 vira 10203. Por
  isso, o menor e a correção ficam abaixo de 100;
- exporta o Windows, o Android e a versão web, depois baixa o plugin do óculos e exporta
  o Quest;
- monta o instalador com o NSIS (`tools/installer/catgame3d.nsi`);
- cria a tag e o release, com as notas geradas pelo GitHub.

## A chave de assinatura

Os dois APKs são assinados com a mesma chave de release. O Android só
aceita uma atualização assinada pela mesma chave que instalou o jogo. **Se a
chave se perder, quem já instalou precisa desinstalar antes de instalar a
versão nova.**

- A chave fica nos secrets do repositório: `ANDROID_KEYSTORE_BASE64` (o
  arquivo em base64), `ANDROID_KEYSTORE_USER` (o alias, `catgame3d`) e
  `ANDROID_KEYSTORE_PASSWORD`.
- O pai guarda uma cópia do arquivo e da senha fora do Git.

Para exportar assinado no computador, defina antes as variáveis
`GODOT_ANDROID_KEYSTORE_RELEASE_PATH`, `GODOT_ANDROID_KEYSTORE_RELEASE_USER`
e `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD` e use `--export-release`.
