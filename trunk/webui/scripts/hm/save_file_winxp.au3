;~ AutoIt3.exe /ErrorStdOut save_file_winxp.au3 C:\download_to\downloaded.zip
WinWait("File Download");
ControlFocus("File Download", "","[CLASS:Button; INSTANCE:2]");
WinActivate("File Download");
ControlClick("File Download", "","[CLASS:Button; INSTANCE:2]");
WinWait("Save As");
WinActivate("Save As");
ControlSetText("Save As", "", "[CLASS:Edit; INSTANCE:1]", $CmdLine[1])
ControlClick("Save As", "","[CLASS:Button; INSTANCE:2]");
WinWait("Download complete");
WinActivate("Download complete");
ControlClick("Download complete", "","[CLASS:Button; INSTANCE:4]");