{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            Oscillograph - AIMP3 plugin
                  Version: 2.0
              Copyright (c) Lyuter
           Mail : pro100lyuter@mail.ru

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
unit OscillographPlugin;

interface

uses
  Windows, SysUtils, Classes,
  OscillographGDIP,
  OscillographHelper,
  OscillographOptionsFrame,
  AIMPCustomPlugin,
  apiWrappers, apiVisuals, apiCore,
  apiObjects, apiPlugin, apiMessages,
  apiOptions, apiSkins;

type
  TOVisualization = class(TInterfacedObject, IAIMPExtensionEmbeddedVisualization)
    function GetFlags: Integer; stdcall;
    function GetMaxDisplaySize(out Width, Height: Integer): HRESULT; stdcall;
    function GetName(out S: IAIMPString): HRESULT; stdcall;
    function Initialize(Width, Height: Integer): HRESULT; stdcall;
    procedure Finalize; stdcall;
    procedure Click(X, Y: Integer; Button: Integer); stdcall;
    procedure Draw(DC: HDC; Data: PAIMPVisualData); stdcall;
    procedure Resize(NewWidth, NewHeight: Integer); stdcall;
  private
    ODrawer: IOscillographDrawer;
  public
    procedure UpdateSettings(NewSettings: TOSettings);
  end;

  TOOptionsCore = class(TInterfacedObject, IAIMPOptionsDialogFrame)
  private
    OOptionsFrame: TOOptionsFrame;
    FOnModified: TNotifyEvent;
  protected
    function GetName(out S: IAIMPString): HRESULT; stdcall;
    function CreateFrame(ParentWnd: HWND): HWND; stdcall;
    procedure DestroyFrame; stdcall;
    procedure Notification(ID: Integer); stdcall;
  public
    property OnModified: TNotifyEvent read FOnModified write FOnModified;
  end;

  TOPlugin = class(TAIMPCustomPlugin)
  private
    OVisualization: TOVisualization;
    OOptionsCore: TOOptionsCore;
    procedure OnSettingsModified(Sender: TObject);
  protected
    function InfoGet(Index: Integer): PWideChar; override; stdcall;
    function InfoGetCategories: Cardinal; override; stdcall;
    function Initialize(Core: IAIMPCore): HRESULT; override; stdcall;
    procedure Finalize; override; stdcall;
  end;

implementation

{=========================================================================)
                                 TPlugin
(=========================================================================}
function TOPlugin.InfoGet(Index: Integer): PWideChar;
begin
  case Index of
    AIMP_PLUGIN_INFO_NAME               : Result := PLUGIN_NAME;
    AIMP_PLUGIN_INFO_AUTHOR             : Result := PLUGIN_AUTHOR;
    AIMP_PLUGIN_INFO_FULL_DESCRIPTION   : Result := PLUGIN_FULL_DESCRIPTION;
    AIMP_PLUGIN_INFO_SHORT_DESCRIPTION  : Result := PLUGIN_SHORT_DESCRIPTION;
  else
    Result := nil;
  end;
end;

function TOPlugin.InfoGetCategories: Cardinal;
begin
  Result := AIMP_PLUGIN_CATEGORY_VISUALS;
end;

procedure TOPlugin.OnSettingsModified(Sender: TObject);
var
  AServiceOptions: IAIMPServiceOptionsDialog;
begin
 try
  if Supports(CoreIntf, IAIMPServiceOptionsDialog, AServiceOptions)
  then
    AServiceOptions.FrameModified(OOptionsCore);
  if Sender is TOOptionsFrame
  then
    OVisualization.UpdateSettings(TOOptionsFrame(Sender).Settings);
 except
  ShowErrorMessage('"Plugin.OnSettingsModified" failure!');
 end;
end;
{--------------------------------------------------------------------
Initialize}
function TOPlugin.Initialize(Core: IAIMPCore): HRESULT;
begin
 try
  Result := inherited Initialize(Core);
  if Succeeded(Result)
  then
    begin
      OVisualization := TOVisualization.Create;
      Result := Core.RegisterExtension(IID_IAIMPServiceVisualizations, OVisualization);
    end;
  if Succeeded(Result)
  then
    begin
      OOptionsCore := TOOptionsCore.Create;
      OOptionsCore.OnModified := OnSettingsModified;
      Result := Core.RegisterExtension(IID_IAIMPServiceOptionsDialog, OOptionsCore);
    end;
 except
  Result := E_UNEXPECTED;
  ShowErrorMessage('"Plugin.Initialize" failure!');
 end;
end;
{--------------------------------------------------------------------
Finalize}
procedure TOPlugin.Finalize;
begin
 try
//  FreeAndNil(OVisualization);
//  OOptionsDialogFrame.Free;
 except
  ShowErrorMessage('"Plugin.Finalize" failure!');
 end;
  inherited;
end;

{=========================================================================)
                              TOVisualization
(=========================================================================}
procedure TOVisualization.Click(X, Y, Button: Integer);
//var
//  Skin: IAIMPServiceSkinsManager;
//  SkinProperty: IAIMPPropertyList;
//  Name: IAIMPString;
var
  SP: TOPresetList;
begin
 try
  ODrawer.Click(X, Y, Button);
//  CheckResult(CoreIntf.QueryInterface(IID_IAIMPServiceSkinsManager, Skin));
//  CheckResult(Skin.QueryInterface(IID_IAIMPPropertyList, SkinProperty));
//  CheckResult(SkinProperty.GetValueAsObject(AIMP_SERVICE_SKINSMAN_PROPID_SKIN, IID_IAIMPString, Name));
//  ShowErrorMessage('"'+IAIMPStringToString(Name)+'"');
 except
  ShowErrorMessage('"Visualization.Click" failure!');
 end;
end;

procedure TOVisualization.Finalize;
begin
 try
  //
 except
  ShowErrorMessage('"Visualization.Finalize" failure!');
 end;
end;

function TOVisualization.GetFlags: Integer;
begin    
 try
  Result := AIMP_VISUAL_FLAGS_RQD_DATA_WAVE;
 except
  Result := 0;
  ShowErrorMessage('"Visualization.GetFlags" failure!');
 end;
end;

function TOVisualization.GetMaxDisplaySize(out Width, Height: Integer): HRESULT;
begin
  Result := E_FAIL;
end;

function TOVisualization.GetName(out S: IAIMPString): HRESULT;
begin
 try
  Result := CoreIntf.CreateObject(IID_IAIMPString, S);
  if Succeeded(Result)
  then
    Result := S.SetData(OSCILLOGRAPH_CAPTION, Length(OSCILLOGRAPH_CAPTION));
 except
  Result := E_UNEXPECTED;
 end;
end;

function TOVisualization.Initialize(Width, Height: Integer): HRESULT;
var
  Settings: TOSettings;
begin
 try
  ODrawer := TOscillographGDIP.Create;
  if not Succeeded(ReadPresetActive(Settings))
  then
    Settings := GetDefaultSettings;
  ODrawer.Initialize(Settings, Width, Height);
  Result := S_OK;
 except
  Result := E_UNEXPECTED;
  ShowErrorMessage('"Visualization.Initialize" failure!');
 end;
end;

procedure TOVisualization.Resize(NewWidth, NewHeight: Integer);
begin
 try
  if ODrawer <> nil
  then
    ODrawer.Resize(NewWidth, NewHeight);
 except
  ShowErrorMessage('"Visualization.Resize" failure!');
 end;
end;

procedure TOVisualization.UpdateSettings(NewSettings: TOSettings);
begin
 try
  if ODrawer <> nil
  then
    ODrawer.UpdateSettings(NewSettings);
 except
  ShowErrorMessage('"Visualization.UpdateSettings" failure!');
 end;
end;

procedure TOVisualization.Draw(DC: HDC; Data: PAIMPVisualData);
begin
 try
  ODrawer.Draw(DC, Data);
 except
  TextOut(DC, 0, 0, 'Draw failure!', Length('Draw failure!'));
 end;
end;

{=========================================================================)
                             TOOptionsDialogFrame
(=========================================================================}
function TOOptionsCore.CreateFrame(ParentWnd: HWND): HWND;
var
  R: Trect;
begin
  OOptionsFrame := TOOptionsFrame.CreateParented(ParentWnd);
  OOptionsFrame.OnModified := OnModified;
  GetWindowRect(ParentWnd, R);
  OffsetRect(R, -R.Left, -R.Top);
  OOptionsFrame.BoundsRect := R;
  OOptionsFrame.Visible := True;
  Result := OOptionsFrame.Handle;
end;

procedure TOOptionsCore.DestroyFrame;
begin
  FreeAndNil(OOptionsFrame);
end;

function TOOptionsCore.GetName(out S: IAIMPString): HRESULT;
begin
  try
    S := MakeString(OSCILLOGRAPH_CAPTION);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

procedure TOOptionsCore.Notification(ID: Integer);
begin
  if OOptionsFrame <> nil then
    case ID of
      AIMP_SERVICE_OPTIONSDIALOG_NOTIFICATION_LOCALIZATION:
                                            OOptionsFrame.ApplyLocalization;
      AIMP_SERVICE_OPTIONSDIALOG_NOTIFICATION_LOAD:
                                            OOptionsFrame.ConfigLoad;
      AIMP_SERVICE_OPTIONSDIALOG_NOTIFICATION_SAVE:
                                            OOptionsFrame.ConfigSave;
    end;
end;

{=========================================================================)
                                  THE END
(=========================================================================}

end.
