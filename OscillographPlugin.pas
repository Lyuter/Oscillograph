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
  OscillographSettings,
  OscillographOptionsFrame,
  AIMPCustomPlugin,
  apiWrappers, apiVisuals, apiCore,
  apiObjects, apiPlugin, apiMessages,
  apiOptions;

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
begin
 try
  if Sender is TOOptionsFrame
  then
    OVisualization.UpdateSettings(TOOptionsFrame(Sender).Settings);
 except
  ShowErrorMessage('"SettingsModified" failure!');
 end;
end;
{--------------------------------------------------------------------
Initialize}
function TOPlugin.Initialize(Core: IAIMPCore): HRESULT;
begin
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
begin
 try
  ODrawer.Click(X, Y, Button);
 except
  ShowErrorMessage('"Visualization.Finalize" failure!');
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
  ShowErrorMessage('Drawer.GetFlags');
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
  DefaultSettings: TOSettings;
begin
 try
  ODrawer := TOscillographGDIP.Create;
  with DefaultSettings do
    begin
      AntiAliasing := True;
      LineMode := 0;
      ColorLine := OSC_COLOR_DEFAULT_LINE;
      ColorGrid := OSC_COLOR_DEFAULT_MARK;
      ColorBackground := OSC_COLOR_DEFAULT_BACK;
    end;    
  ODrawer.Initialize(DefaultSettings, Width, Height);
  Result := S_OK;
 except
  Result := E_UNEXPECTED;
 end;
end;

procedure TOVisualization.Resize(NewWidth, NewHeight: Integer);
begin
  ODrawer.Resize(NewWidth, NewHeight);
end;

procedure TOVisualization.UpdateSettings(NewSettings: TOSettings);
begin
  ODrawer.UpdateSettings(NewSettings);
end;

procedure TOVisualization.Draw(DC: HDC; Data: PAIMPVisualData);
begin
  ODrawer.Draw(DC, Data);
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
      AIMP_SERVICE_OPTIONSDIALOG_NOTIFICATION_LOCALIZATION: ;
//        OOptionsFrame.ApplyLocalization;
      AIMP_SERVICE_OPTIONSDIALOG_NOTIFICATION_LOAD: ;
//        OOptionsFrame.ConfigLoad;
      AIMP_SERVICE_OPTIONSDIALOG_NOTIFICATION_SAVE: ;
//        OOptionsFrame.ConfigSave;
    end;
end;

{=========================================================================)
                                  THE END
(=========================================================================}

end.
