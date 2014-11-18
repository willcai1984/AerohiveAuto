Option Explicit 
'On Error Resume Next
'------------------------------------------------------------
' Function Name : registryDo
' Arguments     : regKeyPath - the registry key path
'                 regValueName - the registry value name
'                 regValue - the value of the key
'                 keyType - one of : DWORD
'                                    STRING
'                                    BINARY
' Description   : add key for Registry
'------------------------------------------------------------
Public Function registryDo(regKeyPath, regValueName, regValue, keyType)
    Dim regPath
    Dim oShell
 	regPath = "HKEY_CURRENT_USER\" & regKeyPath & "\" & regValueName
    Set oShell = CreateObject("wscript.shell")
   
    Select Case keyType
        Case "DWORD"
            oShell.RegWrite regPath, regValue, "REG_DWORD"
        Case "STRING"
            oShell.RegWrite regPath, regValue, "REG_SZ"
        Case "BINARY"
            oShell.RegWrite regPath, regValue, "REG_BINARY"
    End Select
End Function

'------------------------------------------------------------
' Function Name : getIEVersion
' Arguments     : None
' Description   : Get ie version
'------------------------------------------------------------
Function getIEVersion()
    Dim regObj
    
    Set regObj = CreateObject("wscript.shell")
    getIEVersion = regObj.RegRead("HKLM\Software\Microsoft\Internet Explorer\Version")
End Function

'------------------------------------------------------------
' Function Name : setTabProcGrowth
' Arguments     : dwValue - one of:
'                           0 - Only show main IE process in task manager
'                           1 - Show all IE process in task manager
' Description   : Set IE process shown in task manager
'------------------------------------------------------------
Sub setTabProcGrowth(dwValue)
    Dim strKeyPath, strValueName
    
    strKeyPath = "Software\Microsoft\internet Explorer\Main"
    strValueName = "TabProcGrowth"
    
    registryDo strKeyPath, strValueName, dwValue, "DWORD"
End Sub

'------------------------------------------------------------
' Function Name : setIETrustUrl
' Arguments     : urls - The url list
' Description   : Add the url to IE trust list
'------------------------------------------------------------
Sub setIETrustUrl(url)
    Dim strValueName, dwValue, strKeyPath
    
    strKeyPath = "Software\Microsoft\Windows\CurrentVersion\Internet Settings\" _
        & "ZoneMap\Domains\" & url
    strValueName = "http"
    dwValue = 2
        
    registryDo strKeyPath, strValueName, dwValue, "DWORD"
End Sub

'------------------------------------------------------------
' Function Name : acrAction
' Arguments     : dwValue - one of:
'                           0 - Enable
'                           2 - Disable
' Description   : Enable or disable "Enable Automatic Crash Recovery"
'------------------------------------------------------------
Sub acrAction(dwValue)
    Dim strKeyPath, strValueName
    
    strKeyPath = "Software\Microsoft\Internet Settings\Recovery"
    strValueName = "AutoRecovery"
    
    registryDo strKeyPath, strValueName, dwValue, "DWORD"
End Sub

'------------------------------------------------------------
' Function Name : displayAcceleratorButton
' Arguments     : dwValue - one of:
'                           0 - Enable
'                           1 - Disable
' Description   : Enable or disable "Display Accelerator button on selection"
'------------------------------------------------------------
Sub displayAcceleratorButton(dwValue)
    Dim strKeyPath, strValueName
    
    strKeyPath = "Software\Microsoft\Internet Settings\Services"
    strValueName = "SelectionActivityButtonDisable"
    
    registryDo strKeyPath, strValueName, dwValue, "DWORD"
End Sub

'------------------------------------------------------------
' Function Name : popupBlockerMgr
' Arguments     : dwValue - one of:
'                           1 - Enable
'                           0 - Disable
'                 keyType - one of: DWORD
'                                   STRING
'                                   BINARY
' Description   : Enable or disable "Use Pop-up Blocker"
'------------------------------------------------------------
Sub popupBlockerMgr(dwValue, keyType)
    Dim strKeyPath, strValueName

    strKeyPath = "Software\Microsoft\Internet Explorer\New Windows\"
    strValueName = "PopupMgr"

    registryDo strKeyPath, strValueName, dwValue, keyType
End Sub

'------------------------------------------------------------
' Function Name : zonesLevelSetting
' Arguments     : strValueName - one of:
'                           1406 - "Access data source across domains"
'                           1400 - "Active scripting"
'                           2103 - "Allow status bar updates via script" _
'                                   Only two status: 0, 3
'                           1402 - "Scripting of Java applets"
'                           1209 - "Allow scriptlets"
'                           2104 - "Allow websites to open windows without address _
'                                   or status bar", only two status: 0, 3
'                           1201 - "Initialize and script ActiveX controls not marked _
'                                   as safe for scripting"
'							2500 - "Enable Protected Mode"
'
'                dwValue - one of:
'                           3 - Disable
'                           1 - Prompt
'                           0 - Enable
'                zoneType - one of:
'                           0 - My computer
'                           1 - Local intranet
'                           2 - Trust sites
'                           3 - Internet
'                           4 - Restricted sites

' Description   : Enable, disable or prompt the zones level settings
'------------------------------------------------------------
Sub zonesLevelSetting(strValueName, dwValue, zoneType)
    Dim strKeyPath
    			  
    strKeyPath = "Software\Microsoft\Windows\CurrentVersion\Internet Settings\" _
        & "Zones\" & zoneType

    registryDo strKeyPath, strValueName, dwValue, "DWORD"
End Sub
'------------------------------------------------------------
' Function Name : checkIfDefaultBrowser
' Description   : Enable, disable Check if ie is default browser.
'------------------------------------------------------------
Sub checkIfDefaultBrowser(dwValue)
    Dim strKeyPath, strValueName
                  
    strKeyPath = "Software\Microsoft\Internet Explorer\Main\"
    strValueName = "Check_Associations"

    registryDo strKeyPath, strValueName, dwValue, "STRING"
End Sub

'============================================================
'Main scripts
Dim ieVer, iePro, acrStatus, accBtnStatus, url, urls
Dim zoneEnable, zoneDisable, zone, zones, oneZone, allZones, popupMgrValue
Dim accDataScrAcrDom, actScript, statusBar, javaApplets
Dim unsafeScriptActX, sciptlets, noAddr, protectedMode

iePro = "0"
acrStatus = "2" '2 - disable
accBtnStatus = "1" '1 - disable
urls = "nestle.com;juniper.net;sigma-rt.com"
zoneEnable = "0"
zoneDisable = "3"
zones = "3;2"
allZones = "1;2;3;4"
popupMgrValue = "0" '0 - disable
accDataScrAcrDom = "1406"
actScript = "1400"
statusBar = "2103"
javaApplets = "1402"
unsafeScriptActX = "1201"
sciptlets = "1209"
noAddr = "2104"
protectedMode = "2500"

urls = Split(urls, ";")
zones = Split(zones, ";")
allZones = Split(allZones, ";")

'Config IE8's settings.
ieVer = getIEVersion
If Left(ieVer, 1) = "8" Then
'    setTabProcGrowth iePro
    acrAction acrStatus
    displayAcceleratorButton accBtnStatus
End If
If Left(ieVer, 1) = "6" Then
    'Disable "Use Pop-up Blocker"
    If popupMgrValue = "0" Then
        popupMgrValue = "no"
    Else
        popupMgrValue = "yes"
    End If
    popupBlockerMgr popupMgrValue, "STRING"
Else
    'Disable "Use Pop-up Blocker"
    popupBlockerMgr popupMgrValue, "DWORD"
End If

'Add url to IE trust List
For Each url In urls
    setIETrustUrl url
Next

'Zones Level configurations
For Each zone In zones
'    Enable "Access data source across domains"
    zonesLevelSetting accDataScrAcrDom, zoneEnable, zone
    
'    Enable "Active scripting"
    zonesLevelSetting actScript, zoneEnable, zone
    
'    Disable "Allow status bar updates via script"
    zonesLevelSetting statusBar, zoneDisable, zone
    
'    Enable "Scripting of Java applets"
    zonesLevelSetting javaApplets, zoneEnable, zone
    
'    Enable "Initialize and script ActiveX controls not marked
'        as safe for scripting" in "Trusted sites zone"
    If zone = "2" Then
        zonesLevelSetting unsafeScriptActX, zoneEnable, zone
    End If
    
'    Enable "Allow scriptlets"
    zonesLevelSetting sciptlets, zoneEnable, zone
    
'    Disable "Allow websites to open windows without address or status bar"
    zonesLevelSetting noAddr, zoneDisable, zone
    
Next
    
'Disable "Enable Protected Mode" for all zones
For Each oneZone In allZones

'	Disable "Enable Protected Mode"
	zonesLevelSetting protectedMode, zoneDisable, oneZone

Next

'Disable "Check Default browser"
checkIfDefaultBrowser "no"

WScript.Echo "Finished"