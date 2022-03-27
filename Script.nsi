SetCompress auto
SetCompressor bzip2

; Build Unicode installer
Unicode True

!include "MUI2.nsh"
!include "x64.nsh"
!include "logiclib.nsh"

!system 'BinVersion.bat "..\Publish\SBCore.Configurator\SBCore.Configurator.exe "'
!include "Output\BinVersion.txt"

;--------------------------------
;General

!define PRODUCT "SBCore.Configurator"
!define VERSION "2.4"
;!define COMPANY "Геоис"

Name "${PRODUCT} ${VERSION}"
!define MUI_ICON ..\SBCore.Configurator\Resources\Icon.ico

!verbose push
!verbose 4
!echo "${PRODUCT} ${VERSION}"
!echo "${BinVersion}"
!verbose pop

!ifdef OUTFILE
  OutFile ${OUTFILE}
!else
  OutFile "..\Publish\SBCore.Configurator.Setup\SBCoreConfiguratorSetup.exe"
!endif

; Get installation folder from registry if available
InstallDir "$LocalAppData\SBCore.Configurator"
InstallDirRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "InstallLocation"

; Request application privileges for Windows Vista/7/8/10
RequestExecutionLevel user

Caption "Инструмент настройки сервиса интеграции паркочного оборудования производства Scheidt & Bachmann Gmbh с городскими информационными системами"
!define MUI_ABORTWARNING

!include "FileFunc.nsh"

; --------------------------------
; Pages

!define MUI_COMPONENTSPAGE_TEXT_COMPLIST "Build version:$\r$\n${BinVersion}$\r$\n $\r$\nВыберите компоненты программы для установки:"

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY

!insertmacro MUI_PAGE_INSTFILES

!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!define MUI_UNFINISHPAGE_NOAUTOCLOSE
!insertmacro MUI_UNPAGE_FINISH
  
; --------------------------------
; Languages
 
!insertmacro MUI_LANGUAGE "Russian"

;--------------------------------
;Reserve Files
  
;These files should be inserted before other files in the data block
;Keep these lines before any File command
;Only for solid compression (by default, solid compression is enabled for BZIP2 and LZMA)
  
!insertmacro MUI_RESERVEFILE_LANGDLL

;--------------------------------
;Installer Sections

Section !$(SecMain) SecMain
  SectionIn RO
  SetOutPath "$INSTDIR"

  SetOverwrite on
  File /r /x appsettings.Development.json /x appsettings.json /x NLog.config ..\Publish\SBCore.Configurator\*
  File /oname=appsettings.Development.json.dist "..\Publish\SBCore.Configurator\appsettings.Development.json"
  File /oname=appsettings.json.dist "..\Publish\SBCore.Configurator\appsettings.json"
  File /oname=NLog.config.dist "..\Publish\SBCore.Configurator\NLog.config"

  SetOverwrite off
  File "..\Publish\SBCore.Configurator\appsettings.Development.json"
  File "..\Publish\SBCore.Configurator\appsettings.json"
  File "..\Publish\SBCore.Configurator\NLog.config"

  ;Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "DisplayName" "${PRODUCT} ${VERSION} (Remove only)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "QuietUninstallString" "$\"$INSTDIR\Uninstall.exe$\" /S"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "DisplayVersion" "${VERSION}"
;  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "Publisher" "${COMPANY}"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT}" "InstallLocation" "$INSTDIR"

  ;Start Menu
  CreateDirectory "$SMPROGRAMS\${PRODUCT}"
  CreateShortCut "$SMPROGRAMS\${PRODUCT}\${PRODUCT}.lnk" "$INSTDIR\SBCore.Configurator.exe" "" "$INSTDIR\SBCore.Configurator.exe"
SectionEnd

LangString SecMain ${LANG_RUSSIAN} "SBCore.Configurator"
LangString SecMainDesc ${LANG_RUSSIAN} "Установится SBCore.Configurator, включая необходимые компоненты"

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecMain} $(SecMainDesc)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section

Section "Uninstall"
  ;Remove Start Menu launcher
  Delete "$SMPROGRAMS\${PRODUCT}\${PRODUCT}.lnk"
  ;Try to remove the Start Menu folder - this will only happen if it is empty
  rmDir "$SMPROGRAMS\${PRODUCT}"

  Delete "$INSTDIR\*.*"

  RMDir /r "$INSTDIR\hrtfs"
  RMDir /r "$INSTDIR\locale"
  RMDir /r "$INSTDIR\lua"
  RMDir /r "$INSTDIR\plugins"
  RMDir "$INSTDIR"
SectionEnd

;--------------------------------
;Installer Functions

Function .onInit
  System::Call 'kernel32::CreateMutexA(i 0, i 0, t "Global\\__SBCORE_SETUP_MTX") i .r1 ?e'
  Pop $R0
  StrCmp $R0 0 +3
    MessageBox MB_OK|MB_ICONEXCLAMATION "Установка уже запущена" /SD IDOK
    Abort
 
  ${If} ${RunningX64}
    ${If} $InstDir == "" ; Don't override setup.exe /D=c:\custom\dir
      StrCpy $InstDir "$PROGRAMFILES64\Geois\${PRODUCT}"
    ${EndIf}
  ${Else}
    MessageBox MB_OK|MB_ICONEXCLAMATION "Ошибка установки!$\n$\n\
    Программа предназначена для работы в 64-х битной версии Windows" /SD IDOK
    Abort
  ${EndIf}
FunctionEnd
