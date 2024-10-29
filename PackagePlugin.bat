@echo off
REM SetupScript Juergen Riegel juergen.riegel@daimler.com
echo  [32mDeploy project.[0m

set hour=%time:~0,2%
if "%hour:~0,1%" == " " set hour=0%hour:~1,1%
set min=%time:~3,2%
if "%min:~0,1%" == " " set min=0%min:~1,1%
set secs=%time:~6,2%
if "%secs:~0,1%" == " " set secs=0%secs:~1,1%
set year=%date:~-4%
set month=%date:~3,2%
if "%month:~0,1%" == " " set month=0%month:~1,1%
set day=%date:~0,2%
if "%day:~0,1%" == " " set day=0%day:~1,1%

set BuildTime=%year%%month%%day%-%hour%%min%


FOR /F "tokens=2* skip=2" %%a in ('reg query "HKLM\Software\EpicGames\Unreal Engine\5.3" /v "InstalledDirectory"') do set UE_53_DIR=%%b



IF "%UE_53_DIR%"=="" (
    ECHO [91mERROR: UE_53_DIR environment variable not set!! [0m
    ECHO Install Unreal 5.3 via EpicGame launcher!
    pause
    exit 1
)


echo  [94mSearch for NSIS:[0m
WHERE makensis
IF %ERRORLEVEL% NEQ 0 (
    ECHO [91mERROR: makensis.exe whas not found in path! Download and install NSIS first! [0m
    ECHO See: https://nsis.sourceforge.io/Download on details for you system.
    pause
    exit 1
)


SET CURRENTDIR="%cd%"


call "%UE_53_DIR%/Engine/Build/BatchFiles/RunUAT.bat" BuildPlugin ^
                -plugin=%CURRENTDIR%\Plugins\MqttUtilities\MqttUtilities.uplugin ^
                -Package=%CURRENTDIR%\MqttPlugin_5.3 ^
				-TargetPlatforms=Win64
IF %ERRORLEVEL% NEQ 0 (
    ECHO [91mERROR: Building Plugin failed! [0m
    pause
    exit 1
)
copy Plugins\MqttUtilities\Source\ThirdParty\Win64\mosquitto\libraries\mosquitto.dll  MqttPlugin_5.3\Binaries\Win64
copy Plugins\MqttUtilities\Source\ThirdParty\Win64\mosquittopp\libraries\mosquittopp.dll  MqttPlugin_5.3\Binaries\Win64

copy Plugins\MqttUtilities\Source\ThirdParty\Win64\mosquitto\libraries\libcrypto-3-x64.dll  MqttPlugin_5.3\Binaries\Win64
copy Plugins\MqttUtilities\Source\ThirdParty\Win64\mosquitto\libraries\libssl-3-x64.dll  MqttPlugin_5.3\Binaries\Win64
copy Plugins\MqttUtilities\Source\ThirdParty\Win64\mosquitto\libraries\pthreadVC3.dll  MqttPlugin_5.3\Binaries\Win64


makensis.exe -V4 PluginInstaller.nsi
IF %ERRORLEVEL% NEQ 0 (
    ECHO [91mERROR: Building Installer failed! [0m
    pause
    exit 1
)

rem Remove build dir and rename with build time
rmdir /S / Q MqttPlugin_5.3
timeout 3 > NUL
ren MqttPluginInstaller_UE5.3.exe MqttPluginInstaller_UE5.3_%BuildTime%.exe