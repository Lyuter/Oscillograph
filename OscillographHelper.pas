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

  TOSettingsList = array of TOSettings;

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
  function DeleteSettingsByIndex(Index: Integer): HRESULT;

  function ReadSettings(KeyPath: String; out Settings: TOSettings): HRESULT;
  function ReadSettingsActive(out ActiveSettings: TOSettings): HRESULT;
  function ReadSettingsByIndex(Index: Integer; out Settings: TOSettings): HRESULT;

  function WriteSettings(KeyPath: String; Settings: TOSettings): HRESULT;
  function WriteSettingsActive(ActiveSettings: TOSettings): HRESULT;
  function WriteSettingsByIndex(Index: Integer; Settings: TOSettings): HRESULT;

  function ReadSettingsCount(out Count: Integer): HRESULT;
  function WriteSettingsCount(Count: Integer): HRESULT;

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
function ReadSettings(KeyPath: String; out Settings: TOSettings): HRESULT;
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
function ReadSettingsActive(out ActiveSettings: TOSettings): HRESULT;
begin
  Result := ReadSettings(OSC_CONFIG_KEYPATH_ACTIVE, ActiveSettings);
end;
{--------------------------------------------------------------------}
function ReadSettingsByIndex(Index: Integer; out Settings: TOSettings): HRESULT;
begin
  Result := ReadSettings(OSC_CONFIG_KEYPATH_PRESET + IntToStr(Index), Settings);
end;
{--------------------------------------------------------------------}
function WriteSettings(KeyPath: String; Settings: TOSettings): HRESULT;
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
function WriteSettingsActive(ActiveSettings: TOSettings): HRESULT;
begin
  Result := WriteSettings(OSC_CONFIG_KEYPATH_ACTIVE, ActiveSettings);
end;
{--------------------------------------------------------------------}
function WriteSettingsByIndex(Index: Integer; Settings: TOSettings): HRESULT;
begin
  Result := WriteSettings(OSC_CONFIG_KEYPATH_PRESET + IntToStr(Index), Settings);
end;
{--------------------------------------------------------------------}
function ReadSettingsCount(out Count: Integer): HRESULT;
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
function WriteSettingsCount(Count: Integer): HRESULT;
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
function DeleteSettingsByIndex(Index: Integer): HRESULT;
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

end.
