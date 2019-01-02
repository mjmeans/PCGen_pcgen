; Begin Script ----------------------------------------------------------------------------
; Include the externally defined constants
!include "project.nsh"
!define INCLUDES_DIR "${PROJECT_BUILD_DIR}\..\installers\win-installer\includes"
!include ${INCLUDES_DIR}\constants.nsh
;File association
!include ${INCLUDES_DIR}\FileAssociation.nsh
;Windows 32 or 64 bit version
!include "x64.nsh"
;Used for installation size calculation
!include "FileFunc.nsh"

; Define constants
!define APPNAME "PCGen"
!define APPNAMEANDVERSION "${APPNAME} ${LONGVER}"
!define APPDIR "${LONGVER}"
!define TargetVer "1.10"
!define OverVer "1.11"
!define OutName "pcgen-${LONGVER}_win_install"

;Change the icons
!include "MUI2.nsh"

!define MUI_ICON "${PROJECT_BUILD_DIR}\..\installers\win-installer\Local\pcgen.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "${PROJECT_BUILD_DIR}\..\installers\win-installer\Local\splash.bmp"
!define MUI_HEADERIMAGE_RIGHT
;Uncomment when a better images is available.
;!define MUI_WELCOMEFINISHPAGE_BITMAP "${PROJECT_BUILD_DIR}\..\installers\win-installer\Local\splash.bmp" 

; Main Install settings
Name "${APPNAMEANDVERSION}"
InstallDir "$LOCALAPPDATA\${APPNAME}\${APPDIR}"
InstallDirRegKey HKLM "Software\${APPNAME}\${APPDIR}" ""
OutFile "${OutDir}\${OutName}.exe"
;This will save a little less than 1mb, it should be left enabled -Ed
SetCompressor lzma
;This will force the installer to do a CRC check prior to install,
;it is safer, so should be left on. -Ed
CRCCheck on

; Install Type Settings
InstType "Full Install"
InstType "Average Install"
InstType "Average All SRD"
InstType "Min - SRD"
InstType "Min - SRD 3.5"
InstType "Min - MSRD"

;	Look and style
ShowInstDetails show
InstallColors FF8080 000030
XPStyle on
Icon "${SrcDir}\Local\PCGen2.ico"

; Modern interface settings
!include "MUI.nsh"

; if/then/else etc
!include 'LogicLib.nsh'

!define MUI_ABORTWARNING
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${SrcDir}\PCGen_${SIMPVER}_base\docs\acknowledgments\PCGenLicense.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

!define ARP "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPDIR}"

!macro VerifyUserIsAdmin
UserInfo::GetAccountType
pop $0
${If} $0 != "admin" ;Require admin rights on NT4+
        messageBox mb_iconstop "Administrator rights required!"
        setErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
        quit
${EndIf}
!macroend

; Installer properties
VIProductVersion "${INSTALLER_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${APPNAMEANDVERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" "${APPNAME} Release"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${APPNAME} Open Source Project"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "${APPNAME} Open Source Project, Bryan McRoberts and the PCGen Board of Directors"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "© ${APPNAME} Open Source Project"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${APPNAME} Windows OS Supported File"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${INSTALLER_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${LONGVER}"

Section "PCGen" Section1

	SectionIn RO

	; Set Section properties
	SetOverwrite ifnewer

	; Set Section Files and Shortcuts
	SetOutPath "$INSTDIR"
	File /r "${SrcDir}\PCGen_${SIMPVER}_base\*.*"



	; Set the common files
	SetOutPath "$INSTDIR\data"
	File /r "${SrcDir}\..\..\data\_images"
	File /r "${SrcDir}\..\..\data\_universal"
	File /r "${SrcDir}\..\..\data\publisher_logos"

SectionEnd

SubSection /e "Data" Section2

# Run the perl script gendatalist.pl to generate the file below.
!include ${INCLUDES_DIR}\data.nsh

SubSectionEnd

SubSection /e "PlugIns" Section3

	Section "Skins"

	SectionIn 1 2 3
	SetOutPath "$INSTDIR\libs"
	File /r "${SrcDir}\PCGen_${SIMPVER}_opt\plugin\skin\libs\*.*"

	SectionEnd

	Section "PDF"

	SectionIn 1 2 3
	SetOutPath "$INSTDIR\libs"
	File /r "${SrcDir}\PCGen_${SIMPVER}_opt\plugin\pdf\libs\*.*"
	SetOutPath "$INSTDIR\outputsheets"
	File /r "${SrcDir}\PCGen_${SIMPVER}_opt\plugin\pdf\outputsheets\*.*"

	SectionEnd

	Section "GMGen Plugins"

	SectionIn 1 2 3
	SetOutPath "$INSTDIR\plugins"
	File /r "${SrcDir}\PCGen_${SIMPVER}_opt\plugin\gmgen\plugins\*.*"

	SectionEnd

SubSectionEnd

Section "-Local" Section4

	; Set Section properties
	SetOverwrite ifnewer

	; Set Section Files and Shortcuts
	SetOutPath "$INSTDIR\Local\"
	File /r "${SrcDir}\Local\*.*"

	; Create Shortcuts
	SetOutPath "$INSTDIR\"
	CreateDirectory "$SMPROGRAMS\PCGen\${APPDIR}"
	CreateShortCut "$DESKTOP\${APPNAMEANDVERSION}.lnk" "$INSTDIR\pcgen.exe" "" \
				"$INSTDIR\Local\PCGen2.ico" 0 SW_SHOWMINIMIZED
# We no longer provide the .bat file.
#	CreateShortCut "$SMPROGRAMS\PCGen\${APPDIR}\${APPDIR}-Low.lnk" "$INSTDIR\pcgen_low_mem.bat" "" \
#				"$INSTDIR\Local\PCGen.ico" 0 SW_SHOWMINIMIZED
        CreateShortCut "$SMPROGRAMS\${APPNAMEANDVERSION}\pcgen-Bat.lnk" "$INSTDIR\pcgen.bat" "" \
				"$INSTDIR\Local\PCGen.ico" 0 SW_SHOWMINIMIZED
	CreateShortCut "$SMPROGRAMS\${APPNAMEANDVERSION}\${APPNAMEANDVERSION}.lnk" "$INSTDIR\pcgen.exe" "" \
				"$INSTDIR\Local\pcgen2.ico" 0 SW_SHOWMINIMIZED
        CreateShortCut "$SMPROGRAMS\${APPNAMEANDVERSION}\Convert Data.lnk" "$INSTDIR\jre\bin\javaw.exe" \ 
                                "-Xmx256M -jar pcgen-batch-convert.jar" \
				"$INSTDIR\Local\convert.ico"
	CreateShortCut "$SMPROGRAMS\${APPNAMEANDVERSION}\Release Notes.lnk" \ 
                                "$INSTDIR\pcgen-release-notes-${SIMPVER}.html" "" \ 
                                "$INSTDIR\Local\knight.ico"
	CreateShortCut "$SMPROGRAMS\${APPNAMEANDVERSION}\News.lnk" "http://pcgen.sourceforge.net/02_news.php" "" \ 
                                "$INSTDIR\Local\queen.ico"
	CreateShortCut "$SMPROGRAMS\${APPNAMEANDVERSION}\uninstall.lnk" \ 
                                "$INSTDIR\uninstall.exe"
	CreateShortCut "$SMPROGRAMS\${APPNAMEANDVERSION}\Manual.lnk" "$INSTDIR\docs\index.html" "" \ 
                                "$INSTDIR\Local\castle.ico"
        ;Add file extension registration
        ;File association. See: http://nsis.sourceforge.net/FileAssoc
        !insertmacro APP_ASSOCIATE "pcg" "PCGen.File" "PCGen Character file" \
                 "$INSTDIR\pcgen.exe,0" "Open with PCGen" "$INSTDIR\pcgen.exe $\"%1$\""
        System::Call 'Shell32::SHChangeNotify(i ${SHCNE_ASSOCCHANGED}, i 0, i 0, i 0)'

SectionEnd

Section "Java 64 Bit" Section5
        SectionIn RO

        ;Use the right java version
        DetailPrint "Java extraction..."
        SetOutPath "$INSTDIR\jre"
        File /r "${SrcDir}\..\..\jre\jre_x64\*.*"
	File /r "${SrcDir}\..\..\code\pcgen_JREx64.bat"
        DetailPrint "Java extraction complete!"
SectionEnd

Section "Java 32 Bit" Section6
        SectionIn RO

        ;Use the right java version
        DetailPrint "Java extraction..."
        SetOutPath "$INSTDIR\jre"
        File /r "${SrcDir}\..\..\jre\jre_x32\*.*"
	File /r "${SrcDir}\..\..\code\pcgen_JREx32.bat"
        DetailPrint "Java extraction complete!"
SectionEnd

Section -FinishSection

	WriteRegStr HKLM "Software\${APPNAME}\${APPDIR}" "" "$INSTDIR"
	WriteRegStr HKLM "${ARP}" "DisplayName" "${APPNAMEANDVERSION}"
	WriteRegStr HKLM "${ARP}" "UninstallString" "$INSTDIR\uninstall.exe"
	WriteUninstaller "$INSTDIR\uninstall.exe"

	DetailPrint "Calculating installation size..."
	${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
 	IntFmt $0 "0x%08X" $0
 	WriteRegDWORD HKLM "${ARP}" "EstimatedSize" "$0"
	DetailPrint "Done!"

SectionEnd

; Modern install component descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
	!insertmacro MUI_DESCRIPTION_TEXT ${Section1} "This is the PCGen Core"
	!insertmacro MUI_DESCRIPTION_TEXT ${Section2} "This section installs the data sets you need"
	!insertmacro MUI_DESCRIPTION_TEXT ${Section3} "This section installs the plug ins you may need"
	!insertmacro MUI_DESCRIPTION_TEXT ${Section4} "This is for icons and such"
        !insertmacro MUI_DESCRIPTION_TEXT ${Section5} "This is the embedded JRE used by PCGen"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

Section Uninstall

	; Delete Desktop Shortcut
	Delete "$DESKTOP\${APPNAMEANDVERSION}.lnk"
	; Delete Shortcut Directory
	RMDir /r "$SMPROGRAMS\${APPNAMEANDVERSION}"
        ;Delete file extension registration
        !insertmacro APP_UNASSOCIATE "pcg" "PCGen.File"

	MessageBox MB_YESNO "Do you wish to save, your characters, custom sources etc? $\nAnswering no will delete ${APPDIR}." IDYES Save IDNO NoSave

	Save:
!define SAVEDIR "$LOCALAPPDATA\${APPNAME}\${APPDIR}_Save"
	CreateDirectory "${SAVEDIR}"
	CreateDirectory "${SAVEDIR}\characters"
	CreateDirectory "${SAVEDIR}\customsources"
	CreateDirectory "${SAVEDIR}\settings"
	CreateDirectory "${SAVEDIR}\GMGen"
	CopyFiles /SILENT "$INSTDIR\characters\*.*" "${SAVEDIR}\characters\"
	CopyFiles /SILENT "$INSTDIR\data\customsources\*.*" "${SAVEDIR}\customsources\"
	CopyFiles /SILENT "$INSTDIR\*.ini" "${SAVEDIR}\"
	CopyFiles /SILENT "$INSTDIR\settings\*.*" "${SAVEDIR}\settings\"
	;Ed- This has not been tested, Please test.
	CopyFiles /SILENT "$INSTDIR\plugins\Notes\*.*" "${SAVEDIR}\GMGen\"
	MessageBox MB_ICONINFORMATION|MB_OK "A shortcut will be created on your desktop to the saved files."
	CreateShortCut "$DESKTOP\${APPNAMEANDVERSION}_Save.lnk" "${SAVEDIR}"

	NoSave:
	; Clean up PCGen program directory by deleting folders.
	;Ed- This method is used, as a safer alternative
	RMDir /r "$INSTDIR\characters"
	RMDir /r "$INSTDIR\data"
	RMDir /r "$INSTDIR\docs"
	RMDir /r "$INSTDIR\libs"

        ;Remove local JRE
        RMDir /r "$INSTDIR\jre"
	RMDir /r "$INSTDIR\Local"
	RMDir /r "$INSTDIR\outputsheets"
	RMDir /r "$INSTDIR\plugins"
	RMDir /r "$INSTDIR\preview"
	RMDir /r "$INSTDIR\system"
	RMDir /r "$INSTDIR\settings"
	;Ed- below would be the removal of all files in the PCGen root directory, on a file by file basis.
	Delete /REBOOTOK "$INSTDIR\pcgen.jar"
	Delete /REBOOTOK "$INSTDIR\pcgen-release-notes-${SIMPVER}.html"
	Delete /REBOOTOK "$INSTDIR\pcgen.exe"
	Delete /REBOOTOK "$INSTDIR\pcgen.sh"
#	Delete /REBOOTOK "$INSTDIR\pcgen_low_mem.bat"
	Delete /REBOOTOK "$INSTDIR\pcgen.bat"
	Delete /REBOOTOK "$INSTDIR\pcgen_JREx32.bat"
	Delete /REBOOTOK "$INSTDIR\pcgen_JREx64.bat"
	Delete /REBOOTOK "$INSTDIR\pcgen-batch-convert.jar"
	Delete /REBOOTOK "$INSTDIR\filepaths.ini"
	Delete /REBOOTOK "$INSTDIR\config.ini"
	Delete /REBOOTOK "$INSTDIR\logging.properties"
	Delete /REBOOTOK "$INSTDIR\pcgen.log"
	
	RMDir "$INSTDIR"

	# Always delete uninstaller as the last action
	Delete /REBOOTOK "$INSTDIR\uninstall.exe"

	# Try to remove the install directory - this will only happen if it is empty
	rmDir $INSTDIR

	; Remove from registry...
	DeleteRegKey HKLM "${ARP}"
	DeleteRegKey HKLM "Software\${APPNAME}\${APPDIR}"
	DeleteRegKey HKLM "${ARP}_alpha"

	;Run the uninstaller
  	ClearErrors
  	ExecWait '$R0 _?=$INSTDIR' ;Do not copy the uninstaller to a temp file
 
  	IfErrors no_remove_uninstaller done
    	;You can either use Delete /REBOOTOK in the uninstaller or add some code
    	;here to remove the uninstaller. Use a registry key to check
    	;whether the user has chosen to uninstall. If you are using an uninstaller
    	;components page, make sure all sections are uninstalled.
  	
	no_remove_uninstaller:

	done:
SectionEnd

Function .onInit
	ReadRegStr $R0 HKLM \
  	"Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPDIR}" \
  	"UninstallString"
  	StrCmp $R0 "" done
 
  	MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
  	"${APPNAME} is already installed. $\n$\nClick `OK` to remove the \
  	previous version or `Cancel` to cancel this upgrade." \
  	IDOK uninst
  	Abort

	;Run the uninstaller
	uninst:
  		ClearErrors
  		ExecWait '$R0 _?=$INSTDIR' ;Do not copy the uninstaller to a temp file
 
  		IfErrors no_remove_uninstaller done
    		;You can either use Delete /REBOOTOK in the uninstaller or add some code
    		;here to remove the uninstaller. Use a registry key to check
    		;whether the user has chosen to uninstall. If you are using an uninstaller
    		;components page, make sure all sections are uninstalled.
  	no_remove_uninstaller:

	done:

	#Determine the bitness of the OS and enable the correct section
  	IntOp $0 ${SF_SELECTED} | ${SF_RO}
  	${If} ${RunningX64}
    		SectionSetFlags ${Section5} $0
    		SectionSetFlags ${Section6} ${SECTION_OFF}
  	${Else}
    		SectionSetFlags ${Section5} ${SECTION_OFF} 
    		SectionSetFlags ${Section6} $0
  	${EndIf}
FunctionEnd

; eof
