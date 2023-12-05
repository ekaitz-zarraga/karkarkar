# EXTRA:
# rust-winres or binutils' windres to add an icon in the .exe

# define name of installer
OutFile "installer.exe"

# define installation directory
InstallDir "$DESKTOP"

# For removing Start Menu shortcut in Windows 7
RequestExecutionLevel user

InstType "Full" IT_FULL
InstType "Minimal" IT_MIN

PageEx license
    LicenseText "You have to accept the GPL license of this program"
    LicenseData "../LICENSE.txt"
PageExEnd

PageEx license
    LicenseText "You have to accept the GPL of the AhoTTS library"
    LicenseData "../LICENSE.txt"
PageExEnd

PageEx license
    LicenseText "You have to accept the CC-BY-3 license AhoTTS dictionaries \
    and voices"
    LicenseData "../windows/data/AhoTTS/LICENSE_VOICES.txt"
PageExEnd

Page components
Page instfiles

UninstPage uninstConfirm
UninstPage instfiles

Section "Karkarkar executable"
    SectionInstType ${IT_FULL} ${IT_MIN}
    SetOutPath "$INSTDIR\karkarkar"
    WriteUninstaller "$INSTDIR\uninstall.exe"
    CreateShortcut "$SMPROGRAMS\Uninstall.lnk" "$INSTDIR\uninstall.exe"
    File "../zig-out/bin/karkarkar.exe"
    CreateShortcut "$SMPROGRAMS\karkarkar.lnk" "$INSTDIR\karkarkar.exe"
SectionEnd

Section "Karkarkar sources"
    SectionInstType ${IT_FULL}
    SetOutPath "$INSTDIR\karkarkar\sources"
    File /r "../src"
    File /r "../build.zig"
    File /r "../LICENSE.txt"
    File /r "../ahotts_c"
SectionEnd

Section "AhoTTS library"
    SectionInstType ${IT_FULL} ${IT_MIN}
    SetOutPath "$INSTDIR\karkarkar"
    File "../windows/lib/htts.dll*"
SectionEnd

Section "AhoTTS dictionaries and voices"
    SectionInstType ${IT_FULL} ${IT_MIN}
    SetOutPath "$LOCALAPPDATA\AhoTTS"
    File /r "../windows/data/AhoTTS/"
SectionEnd

Section "OpenAL-soft library (optional)"
    SectionInstType ${IT_FULL}
    SetOutPath "$INSTDIR\karkarkar"
    File "../windows/lib/libOpenAL32.dll.a"
    File /r "../windows/lib/OpenAL32*"
SectionEnd

# uninstaller section start
Section "Uninstall"
    # Remove the link from the start menu
    Delete "$SMPROGRAMS\Uninstall.lnk"
    Delete "$INSTDIR\uninstall.exe"

    # Delete the uninstaller
    RMDir /r "$INSTDIR\karkarkar"
    RMDir /r "$INSTDIR\AhoTTS"
    RMDir /r "$INSTDIR\OpenAL"
    RMDir /r "$LOCALAPPDATA\AhoTTS"
# uninstaller section end
SectionEnd
