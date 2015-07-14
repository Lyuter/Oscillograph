unit OscillographSettings;

interface

uses
  Windows, SysUtils,
  apiVisuals, apiObjects, apiCore,
  apiWrappers, apiMessages;

const
    PLUGIN_NAME              = 'Oscillograph';
    PLUGIN_AUTHOR            = 'Author: Lyuter';
    PLUGIN_SHORT_DESCRIPTION = 'DEV BUILD';
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
    OSC_CELLSIZE   = 30;    //  Размер сетки в пикселях
    OSC_MARKERSIZE = 6;     //  Расстояние между маркерами
    //
    OSC_CONFIG_KEYPATH_PARENT   = 'Oscillograph\';
    OSC_CONFIG_KEYPATH_ACTIVE   = 'Oscillograph\Active';

type

  TOSettings = record
    AntiAliasing,
    DrawGrid: Boolean;
    LineMode: Integer; // 0 - both, 1 - right, 2 - left
    ColorLine,
    ColorGrid,
    ColorBackground   : Cardinal;
  end;

  IOscillographDrawer = interface(IUnknown)
  ['{0E6815FA-BC17-47AC-95A2-2F42DE84EB3D}']
    function Initialize(Settings: TOSettings; Width, Height: Integer): HRESULT;
    function GetMaxDisplaySize(out Width, Height: Integer): HRESULT;
    procedure Click(X, Y, Button: Integer);
    procedure Draw(DC: HDC; Data: PAIMPVisualData);
    procedure UpdateSettings(NewSettings: TOSettings);
    procedure Resize(NewWidth, NewHeight: Integer);
  end;

  function ReadActiveSettings(out ActiveSettings: TOSettings): HRESULT;
  function WriteActiveSettings(ActiveSettings: TOSettings): HRESULT;
  function GetDefaultSettings: TOSettings;

implementation

{--------------------------------------------------------------------}
function GetDefaultSettings: TOSettings;
begin
  with Result
  do
    begin
      AntiAliasing := OSC_DEFAULT_ANTIALIASING;
      LineMode := OSC_DEFAULT_LINEMODE;
      ColorLine := OSC_DEFAULT_COLOR_LINE;
      ColorGrid := OSC_DEFAULT_COLOR_GRID;
      ColorBackground := OSC_DEFAULT_COLOR_BACK;
    end;
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
function ReadActiveSettings(out ActiveSettings: TOSettings): HRESULT;
var
  ServiceConfig: IAIMPServiceConfig;
  ConfigString: IAIMPString;
begin
 try
  Result := CoreIntf.QueryInterface(IID_IAIMPServiceConfig, ServiceConfig);
  if not Succeeded(Result)
  then exit;
  Result := ServiceConfig.GetValueAsString(MakeString(OSC_CONFIG_KEYPATH_ACTIVE), ConfigString);
  if Succeeded(Result)
  then
    ActiveSettings :=  AIMPStringToSettings(ConfigString)
  else
    ActiveSettings := GetDefaultSettings;
  Result := S_OK;
 except
  Result := E_UNEXPECTED;
 end;
end;
{--------------------------------------------------------------------}
function WriteActiveSettings(ActiveSettings: TOSettings): HRESULT;
var
  ServiceConfig: IAIMPServiceConfig;
  ConfigString: IAIMPString;
begin
 try
  Result := CoreIntf.QueryInterface(IID_IAIMPServiceConfig, ServiceConfig);
  if Succeeded(Result)
  then
    Result := ServiceConfig.SetValueAsString(MakeString(OSC_CONFIG_KEYPATH_ACTIVE),
                                           SettingsToAIMPString(ActiveSettings));
 except
  Result := E_UNEXPECTED;
 end;
end;

end.
