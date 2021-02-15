set JARPATH="C:\Users\biagi\Documents\Commodore Programs\kickassembler\KickAss.jar"
set WORK=C:\Users\biagi\git\killcovid
set SRCDIR=%WORK%\src
set INCDIR=%WORK%\sprites
set OUTDIR=%WORK%\bin

java.exe -jar %JARPATH% %SRCDIR%\killcovid.asm -libdir %INCDIR% -odir %OUTDIR%
