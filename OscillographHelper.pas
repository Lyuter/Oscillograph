{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            Oscillograph - AIMP3 plugin
                  Version: 2.0
              Copyright (c) Lyuter
           Mail : pro100lyuter@mail.ru

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
unit OscillographHelper;

interface

uses
  Windows, SysUtils,
  apiVisuals, apiObjects, apiCore,
  apiWrappers, apiMessages;

const
    PLUGIN_NAME              = 'Oscillograph';
    PLUGIN_AUTHOR            = 'Author: Lyuter';
    PLUGIN_SHORT_DESCRIPTION = '! DEV BUILD !';
    PLUGIN_FULL_DESCRIPTION  = '';
    //
    OSCILLOGRAPH_CAPTION     = 'AIMP Oscillograph';
    //
    OSC_DEFAULT_COLOR_LINE      = $FF00ee00;
    OSC_DEFAULT_COLOR_GRID      = $3200aa00;
    OSC_DEFAULT_COLOR_BACK      = $55002000;
    OSC_DEFAULT_ANTIALIASING    = True;
    OSC_DEFAULT_DRAWGRID        = True;
    OSC_DEFAULT_LINEMODE        = 0;
    //
    OSC_CELLSIZE   = 30;
    OSC_MARKERSIZE = 6;
    //
    OSC_CONFIG_KEYPATH_PARENT       = 'Oscillograph\';
    OSC_CONFIG_KEYPATH_ACTIVE       = 'Oscillograph\Active';
    OSC_CONFIG_KEYPATH_PRESET_COUNT = 'Oscillograph\PresetCount';
    OSC_CONFIG_KEYPATH_PRESET       = 'Oscillograph\Preset';
    OSC_CONFIG_KEYPATH_SKINS        = 'Oscillograph\Skins';

type

  TOSettings = record
    AntiAliasing,
    DrawGrid: Boolean;
    LineMode: Integer; // 0 - both, 1 - right, 2 - left
    ColorLine,
    ColorGrid,
    ColorBackground   : Cardinal;
  end;

  TOPresetList = array of TOSettings;

  IOscillographDrawer = interface(IUnknown)
  ['{0E6815FA-BC17-47AC-95A2-2F42DE84EB3D}']
    function Initialize(Settings: TOSettings; Width, Height: Integer): HRESULT;
    function GetMaxDisplaySize(out Width, Height: Integer): HRESULT;
    procedure Click(X, Y, Button: Integer);
    procedure Draw(DC: HDC; Data: PAIMPVisualData);
    procedure UpdateSettings(NewSettings: TOSettings);
    procedure Resize(NewWidth, NewHeight: Integer);
  end;

  procedure ShowErrorMessage(ErrorMessage: String);

  function GetDefaultSettings: TOSettings;
  function DeletePresetByIndex(Index: Integer): HRESULT;

  function ReadPreset(KeyPath: String; out Settings: TOSettings): HRESULT;
  function ReadPresetActive(out ActiveSettings: TOSettings): HRESULT;
  function ReadPresetByIndex(Index: Integer; out Settings: TOSettings): HRESULT;
  function ReadPresetCount(out Count: Integer): HRESULT;

  function WritePreset(KeyPath: String; Settings: TOSettings): HRESULT;
  function WritePresetActive(ActiveSettings: TOSettings): HRESULT;
  function WritePresetByIndex(Index: Integer; Settings: TOSettings): HRESULT;
  function WritePresetCount(Count: Integer): HRESULT;

  function ReadPresetList(out PresetList: TOPresetList): HRESULT;
  function WritePresetList(PresetList: TOPresetList): HRESULT;

implementation

{--------------------------------------------------------------------}
procedure ShowErrorMessage(ErrorMessage: String);
var
  DLLName: array[0..MAX_PATH - 1] of Char;
  FullMessage: String;
begin
  FillChar(DLLName, MAX_PATH, #0);
  GetModuleFileName(HInstance, DLLName, MAX_PATH);
  FullMessage := 'Exception in module "' + DLLName + '".'#13#13 + ErrorMessage;
  MessageBox(0, PChar(FullMessage), OSCILLOGRAPH_CAPTION, MB_ICONERROR);
end;
{--------------------------------------------------------------------}
function SettingsToAIMPString(Settings: TOSettings): IAIMPString;
var
  Output: WideString;
begin
  with Settings do
    Output := Format('%d,%d,%d,%d,%d,%d',[ColorLine, ColorGrid, ColorBackground,
                                          LineMode, Integer(AntiAliasing),
                                          Integer(DrawGrid)]);
  Result := MakeString(Output);
end;
{--------------------------------------------------------------------}
function AIMPStringToSettings(AIMPString: IAIMPString): TOSettings;
var
  InputString: String;
  SplittedData: TArray<String>;
begin
  InputString := IAIMPStringToString(AIMPString);
  SplittedData := InputString.Split([',']);
  try
    Result.ColorLine := StrToInt(SplittedData[0]);
  except
    Result.ColorLine := OSC_DEFAULT_COLOR_LINE;
  end;
  try
    Result.ColorGrid := StrToInt(SplittedData[1]);
  except
    Result.ColorGrid := OSC_DEFAULT_COLOR_GRID;
  end;
  try
    Result.ColorBackground := StrToInt(SplittedData[2]);
  except
    Result.ColorBackground := OSC_DEFAULT_COLOR_BACK;
  end;
  try
    Result.LineMode := StrToInt(SplittedData[3]);
  except
    Result.LineMode := OSC_DEFAULT_LINEMODE;
  end;
  try
    Result.AntiAliasing := Boolean(StrToInt(SplittedData[4]));
  except
    Result.AntiAliasing := OSC_DEFAULT_ANTIALIASING;
  end;
    try
    Result.DrawGrid := Boolean(StrToInt(SplittedData[5]));
  except
    Result.DrawGrid := OSC_DEFAULT_DRAWGRID;
  end;
end;
{--------------------------------------------------------------------}
function GetDefaultSettings: TOSettings;
begin
  with Result
  do
    begin
      AntiAliasing := OSC_DEFAULT_ANTIALIASING;
      LineMode := OSC_DEFAULT_LINEMODE;
      DrawGrid := OSC_DEFAULT_DRAWGRID;
      ColorLine := OSC_DEFAULT_COLOR_LINE;
      ColorGrid := OSC_DEFAULT_COLOR_GRID;
      ColorBackground := OSC_DEFAULT_COLOR_BACK;
    end;
end;
{--------------------------------------------------------------------}
function ReadPreset(KeyPath: String; out Settings: TOSettings): HRESULT;
var
  ServiceConfig: IAIMPServiceConfig;
  ConfigString: IAIMPString;
begin
 try
  Result := CoreIntf.QueryInterface(IID_IAIMPServiceConfig, ServiceConfig);
  if not Succeeded(Result)
  then exit;
  Result := ServiceConfig.GetValueAsString(MakeString(KeyPath), ConfigString);
  if Succeeded(Result)
  then
    Settings := AIMPStringToSettings(ConfigString);
 except
  Result := E_UNEXPECTED;
 end;
end;
{--------------------------------------------------------------------}
function ReadPresetActive(out ActiveSettings: TOSettings): HRESULT;
begin
  Result := ReadPreset(OSC_CONFIG_KEYPATH_ACTIVE, ActiveSettings);
end;
{--------------------------------------------------------------------}
function ReadPresetByIndex(Index: Integer; out Settings: TOSettings): HRESULT;
begin
  Result := ReadPreset(OSC_CONFIG_KEYPATH_PRESET + IntToStr(Index), Settings);
end;
{--------------------------------------------------------------------}
function WritePreset(KeyPath: String; Settings: TOSettings): HRESULT;
var
  ServiceConfig: IAIMPServiceConfig;
begin
 try
  Result := CoreIntf.QueryInterface(IID_IAIMPServiceConfig, ServiceConfig);
  if Succeeded(Result)
  then
    Result := ServiceConfig.SetValueAsString(MakeString(KeyPath),
                                           SettingsToAIMPString(Settings));
 except
  Result := E_UNEXPECTED;
 end;
end;
{--------------------------------------------------------------------}
function WritePresetActive(ActiveSettings: TOSettings): HRESULT;
begin
  Result := WritePreset(OSC_CONFIG_KEYPATH_ACTIVE, ActiveSettings);
end;
{--------------------------------------------------------------------}
function WritePresetByIndex(Index: Integer; Settings: TOSettings): HRESULT;
begin
  Result := WritePreset(OSC_CONFIG_KEYPATH_PRESET + IntToStr(Index), Settings);
end;
{--------------------------------------------------------------------}
function ReadPresetCount(out Count: Integer): HRESULT;
var
  ServiceConfig: IAIMPServiceConfig;
begin
 try
  Result := CoreIntf.QueryInterface(IID_IAIMPServiceConfig, ServiceConfig);
  if not Succeeded(Result)
  then exit;
  Result := ServiceConfig.GetValueAsInt32(
                                    MakeString(OSC_CONFIG_KEYPATH_PRESET_COUNT),
                                      Count);
 except
  Result := E_UNEXPECTED;
 end;
end;
{--------------------------------------------------------------------}
function WritePresetCount(Count: Integer): HRESULT;
var
  ServiceConfig: IAIMPServiceConfig;
begin
 try
  Result := CoreIntf.QueryInterface(IID_IAIMPServiceConfig, ServiceConfig);
  if Succeeded(Result)
  then
    Result := ServiceConfig.SetValueAsInt32(
                                    MakeString(OSC_CONFIG_KEYPATH_PRESET_COUNT),
                                      Count);
 except
  Result := E_UNEXPECTED;
 end;
end;
{--------------------------------------------------------------------}
function DeletePresetByIndex(Index: Integer): HRESULT;
var
  ServiceConfig: IAIMPServiceConfig;
begin
 try
  Result := CoreIntf.QueryInterface(IID_IAIMPServiceConfig, ServiceConfig);
  if Succeeded(Result)
  then
    Result := ServiceConfig.Delete(
                      MakeString(OSC_CONFIG_KEYPATH_PRESET + IntToStr(Index)));
 except
  Result := E_UNEXPECTED;
 end;
end;
{--------------------------------------------------------------------}
function ReadPresetList(out PresetList: TOPresetList): HRESULT;
var
  i, PresetCount, PresetListLength: Integer;
  Settings: TOSettings;
begin
 try
  Result := ReadPresetCount(PresetCount);
  case  Result of
      S_OK: ;
      E_FAIL: begin
                SetLength(PresetList, 0);
                Result := S_OK;
                exit;
              end;
      else  exit;
  end;
  if (PresetCount < 0)
  then
    begin
      SetLength(PresetList, 0);
      Result := S_OK;
      exit;
    end;
  PresetListLength := 0;
  SetLength(PresetList, 0);
  for i := 0 to PresetCount - 1
  do
    if Succeeded(ReadPresetByIndex(i, Settings))
    then
      begin
        Inc(PresetListLength);
        SetLength(PresetList, PresetListLength);
        PresetList[PresetListLength - 1] := Settings;
      end;
  Result := S_OK;
 except
  Result := E_UNEXPECTED;
 end;
end;
{--------------------------------------------------------------------}
function WritePresetList(PresetList: TOPresetList): HRESULT;
var
  i, OldPresetCount, PresetListLength: Integer;
begin
 try
  if not Succeeded(ReadPresetCount(OldPresetCount))
  then
    OldPresetCount := 0;
  PresetListLength := Length(PresetList);
  if OldPresetCount > PresetListLength
  then
    for i := PresetListLength to OldPresetCount - 1
    do DeletePresetByIndex(i);
  for i := 0 to PresetListLength - 1
  do
    WritePresetByIndex(i, PresetList[i]);
  WritePresetCount(PresetListLength);
  Result := S_OK;
 except
  Result := E_UNEXPECTED;
 end;
end;
{--------------------------------------------------------------------}

end.
