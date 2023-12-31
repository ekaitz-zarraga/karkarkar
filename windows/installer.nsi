# EXTRA:
# rust-winres or binutils' windres to add an icon in the .exe or add the icon
# to the .bat installed with the CreateShortcut
!include nsDialogs.nsh
!include LogicLib.nsh

Var Dialog
Var Label
Var Text
Var Text_State

# define name of installer
OutFile "installer.exe"

# define installation directory
InstallDir "$DESKTOP"
# InstallDir "$PROGRAMFILES" # TODO: Better this than desktop

# For removing Start Menu shortcut in Windows 7
RequestExecutionLevel user

PageEx license
    LicenseText "You have to accept the license of this program, and the \
    included AhoTTS"
    LicenseData "../LICENSE.txt"
PageExEnd

PageEx license
    LicenseText "You have to accept the CC-BY-3 license AhoTTS dictionaries \
    and voices"
    LicenseData "../AhoTTS/COPYRIGHT_and_LICENSE_voices.txt"
PageExEnd

PageEx license
    LicenseText "You have to accept the license of the OpenAL library"
    LicenseData "OPENAL_LICENSE.txt"
PageExEnd

DirText "Choose a directory"
Page directory

# Extra page to choose the user to follow
Page custom chooseUserEnter chooseUserLeave
Function .onInit
    StrCpy $Text_State ""
FunctionEnd
Function chooseUserEnter
    nsDialogs::Create 1018
    Pop $Dialog
    ${If} $Dialog == error
        Abort
    ${EndIf}
    ${NSD_CreateLabel} 0 0 100% 12u "Choose your Twitch username:"
    Pop $Label
    ${NSD_CreateText} 0 13u 100% 12u $Text_State
    Pop $Text
    nsDialogs::Show
FunctionEnd
Function chooseUserLeave
    ${NSD_GetText} $Text $Text_State
FunctionEnd

Page components
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

Section "Karkarkar executable"
    SetOutPath "$INSTDIR\karkarkar"
    File "../zig-out/bin/karkarkar.exe"
    File "../icons/icon.ico"

    # Uninstaller
    WriteUninstaller "$INSTDIR\karkarkar\uninstall.exe"

    # Make a runner in a .bat, with the user obtained during the installation
    # Maybe CreateShortcut has enough magic and we can avoid the .bat file?
    # https://nsis.sourceforge.io/Docs/Chapter4.html#createshortcut
    FileOpen $0 $INSTDIR\karkarkar\karkarkar.bat w
    FileWrite $0 "$INSTDIR\karkarkar\karkarkar.exe $Text_State$\r$\n"
    FileClose $0

    # Create shortcuts
    CreateDirectory "$SMPROGRAMS\karkarkar"
    CreateShortcut "$SMPROGRAMS\karkarkar\Uninstall.lnk" "$INSTDIR\karkarkar\uninstall.exe"
    CreateShortcut "$SMPROGRAMS\karkarkar\karkarkar.lnk" "$INSTDIR\karkarkar\karkarkar.bat" \
            "" "$INSTDIR\karkarkar\icon.ico" 0
SectionEnd

Section /o "Karkarkar sources"
    SetOutPath "$INSTDIR\karkarkar\sources"
    File /r "../src"
    File /r "../build.zig"
    File /r "../LICENSE.txt"
    File /r "../ahotts_c"
    File /r "../AhoTTS"
SectionEnd

Section "AhoTTS dictionaries and voices"
    SetOutPath "$LOCALAPPDATA\AhoTTS"
    File /r "../AhoTTS/data_tts"
SectionEnd

Section "OpenAL-soft library"
    SetOutPath "$INSTDIR\karkarkar"
    File "lib/libOpenAL32.dll.a"
    File "lib/OpenAL32.lib"
    File "lib/OpenAL32.dll"
    File "lib/OpenAL32.def"
SectionEnd

Section "Uninstall"
    # NOTE: installation directory is the place where the Uninstaller is
    # located, That's why we don't need the karkarkar\ prefix.

    # Remove the links from the start menu
    Delete "$SMPROGRAMS\karkarkar\Uninstall.lnk"
    Delete "$SMPROGRAMS\karkarkar\karkarkar.lnk"
    RMDir  "$SMPROGRAMS\karkarkar"

    # Karkarkar Sources
    RMDir /r "$INSTDIR\sources"

    # Karkarkar
    Delete "$INSTDIR\karkarkar.exe"
    Delete "$INSTDIR\karkarkar.bat"
    Delete "$INSTDIR\icon.ico"

    # AhoTTS dictionaries and voices
    RMDir /r "$LOCALAPPDATA\AhoTTS"

    # OpenAL
    Delete "$INSTDIR\OpenAL32.dll"
    Delete "$INSTDIR\OpenAL32.def"
    Delete "$INSTDIR\OpenAL32.lib"
    Delete "$INSTDIR\libOpenAL32.dll.a"

    # Delete uninstaller
    Delete "$INSTDIR\uninstall.exe"
    # Delete installation directory
    RMDir "$INSTDIR"
SectionEnd
