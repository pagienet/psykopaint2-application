@echo off

if "%WINDOWSKITS_BIN%" == "" (
	echo "An environment variable WINDOWSKITS_BIN needs to be created pointing to the bin folder of Windows Kits"
	echo "For example: C:\Program Files (x86)\Windows Kits\8.0\bin\x64"
) else (
	for /r %%f in (*.hlsl) do (
		"%WINDOWSKITS_BIN%\fxc" %%f /E "main" /T ps_3_0 /nologo /Fc %%~nf.asm /I includes
	)

    hlsl2agal *.asm -y
    move /Y *.asm asm
    move /Y *.agal agal-intermediate
    popd
)