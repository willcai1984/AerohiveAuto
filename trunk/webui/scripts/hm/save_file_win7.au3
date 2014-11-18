;~ AutoIt3.exe /ErrorStdOut save_file_win7.au3 C:\download_to\downloaded.zip
WinWait("[Class:IEFrame]");
WinActivate("[Class:IEFrame]");
 
;~ Save Prompt
ControlFocus("", "", "[CLASS:DirectUIHWND]");
WinActivate("[CLASS:DirectUIHWND]");
ControlFocus("", "", "[CLASS:DirectUIHWND]");
$p = ControlGetPos("", "", "[Class:DirectUIHWND]")
$x = $p[2] - 117;
$y = $p[3] - 25;
ControlClick("", "", "[Class:DirectUIHWND]", "primary", 1, $x, $y);
ControlSend("", "", "[Class:DirectUIHWND]", "{Down}", 0);
ControlSend("", "", "[Class:DirectUIHWND]", "a", 0);

;~ Save as dialog
WinWait("Save As");
WinActivate("Save As");
ControlSetText("Save As", "", "[Class:Edit]", $CmdLine[1]);
ControlClick("Save As", "", "[Class:Button]");
;~ WinWait("Confirm Save As");
;~ ControlFocus("Confirm Save As", "", "[Class:Button]");
;~ ControlClick("Confirm Save As", "", "[Class:Button]");

