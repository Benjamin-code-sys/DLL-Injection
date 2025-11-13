@ECHO OFF

cl.exe /O2 /D_USRDLL /D_WINDLL /DNDEBUG /TcBenDLL.cpp /MT /link /DLL /OUT:mspaint2DLL.dll