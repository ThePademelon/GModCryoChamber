SET GMALOCATION=%TEMP%\chamber.gma
E:\Steam\steamapps\common\GarrysMod\bin\gmad.exe create -folder "E:\Steam\steamapps\common\GarrysMod\garrysmod\addons\GModCryoChamber" -out %GMALOCATION% -warninvalid
SET /P CHANGES=Release message: || GOTO CLEANUP
E:\Steam\steamapps\common\GarrysMod\bin\gmpublish.exe update -id 850437362 -addon %GMALOCATION% -changes %CHANGES%

:CLEANUP
DEL %GMALOCATION%
PAUSE