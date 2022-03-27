NSIS=""%ProgramFiles(x86)%\NSIS\makensis.exe""
UPDATEMGR="D:\Devel\Repositories\gUpdate\Publish\gUpdateMgr\gUpdateMgr.exe"
SCRIPT=Script.nsi
OUTPUT="..\Publish\SBCore.Configurator.Setup\SBCoreConfiguratorSetup.exe"
OUTPUTJSON="..\Publish\SBCore.Configurator.Setup\project.json"
DEPEND=..\Publish\SBCore.Configurator\SBCore.Configurator.dll \
..\Publish\SBCore.Configurator\CameraSharedWindows.dll \
..\Publish\SBCore.Configurator\SBShared.dll \
..\Publish\SBCore.Configurator\Shared.dll \
..\Publish\SBCore.Configurator\appsettings.json \
..\Publish\SBCore.Configurator\appsettings.Development.json \
..\Publish\SBCore.Configurator\NLog.config \
$(SCRIPT)

all: buildsetup buildjson

clean: cleansetup cleanjson

cleansetup:
	del /q $(OUTPUT)

cleanjson:
	del /q $(OUTPUTJSON)

buildsetup: $(OUTPUT)

buildjson:
	$(UPDATEMGR) -json ..\Publish\SBCore.Configurator\SBCore.Configurator.dll > $(OUTPUTJSON)

rebuild: clean buildsetup buildjson

$(OUTPUT): $(DEPEND)
	$(NSIS) $(SCRIPT)
