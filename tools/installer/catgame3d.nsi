; Windows installer for the game, built with NSIS by the release workflow:
;   makensis -DVERSION=1.2.3 -DEXE=build/windows/catgame3d.exe \
;            -DOUTFILE=build/release/catgame3d-1.2.3-setup.exe tools/installer/catgame3d.nsi
; It installs for the current user only, so it does not ask for an administrator.

Unicode true
!define NAME "Jogo do gato 3D"
!define UNINSTALL_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\catgame3d"

Name "${NAME}"
OutFile "${OUTFILE}"
InstallDir "$LOCALAPPDATA\Programs\catgame3d"
RequestExecutionLevel user
SetCompressor /SOLID lzma

!include "MUI2.nsh"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN "$INSTDIR\catgame3d.exe"
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "PortugueseBR"

Section "Install"
	SetOutPath "$INSTDIR"
	File "/oname=catgame3d.exe" "${EXE}"
	WriteUninstaller "$INSTDIR\uninstall.exe"
	CreateShortcut "$SMPROGRAMS\${NAME}.lnk" "$INSTDIR\catgame3d.exe"
	CreateShortcut "$DESKTOP\${NAME}.lnk" "$INSTDIR\catgame3d.exe"
	WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayVersion" "${VERSION}"
	WriteRegStr HKCU "${UNINSTALL_KEY}" "Publisher" "Rangel Reale"
	WriteRegStr HKCU "${UNINSTALL_KEY}" "DisplayIcon" "$INSTDIR\catgame3d.exe"
	WriteRegStr HKCU "${UNINSTALL_KEY}" "UninstallString" '"$INSTDIR\uninstall.exe"'
	WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoModify" 1
	WriteRegDWORD HKCU "${UNINSTALL_KEY}" "NoRepair" 1
SectionEnd

Section "Uninstall"
	Delete "$INSTDIR\catgame3d.exe"
	Delete "$INSTDIR\uninstall.exe"
	RMDir "$INSTDIR"
	Delete "$SMPROGRAMS\${NAME}.lnk"
	Delete "$DESKTOP\${NAME}.lnk"
	DeleteRegKey HKCU "${UNINSTALL_KEY}"
SectionEnd
