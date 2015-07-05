{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            Oscillograph - AIMP3 plugin
                  Version: 2.0
              Copyright (c) Lyuter
           Mail : pro100lyuter@mail.ru

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
unit OscillographPlugin;

interface

uses  Windows, SysUtils,
      OscillographGDIP,
      OscillographSettings,
      AIMPCustomPlugin,
      apiWrappers, apiVisuals, apiCore,
      apiObjects, apiPlugin, apiMessages;

const
    PLUGIN_NAME              = 'Oscillograph';
    PLUGIN_AUTHOR            = 'Author: Lyuter';
    PLUGIN_SHORT_DESCRIPTION = 'DEV BUILD';
    PLUGIN_FULL_DESCRIPTION  = '';
    //
    OSCILLOGRAPH_CAPTION     = 'AIMP Oscillograph';

type

  TOMessageHook = class(TInterfacedObject, IAIMPMessageHook)
  public
    procedure CoreMessage(Message: DWORD; Param1: Integer; Param2: Pointer;
                                                  var Result: HRESULT); stdcall;
  end;

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
  end;

  TOPlugin = class(TAIMPCustomPlugin)
  private
    OMessageHook: IAIMPMessageHook;
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
{--------------------------------------------------------------------
Initialize}
function TOPlugin.Initialize(Core: IAIMPCore): HRESULT;
var
  ServiceMessageDispatcher: IAIMPServiceMessageDispatcher;
begin
  Result := inherited Initialize(Core);
  if Succeeded(Result)
  then
    Result := Core.RegisterExtension(IID_IAIMPServiceVisualizations, TOVisualization.Create);

  if Succeeded(Result)
  then
    begin
      try
        OMessageHook := TOMessageHook.Create;
        Core.QueryInterface(IID_IAIMPServiceMessageDispatcher, ServiceMessageDispatcher);
        CheckResult(ServiceMessageDispatcher.Hook(OMessageHook));
      except
        Result := E_UNEXPECTED;
      end;
    end;
end;
{--------------------------------------------------------------------
Finalize}
procedure TOPlugin.Finalize;
var
  ServiceMessageDispatcher: IAIMPServiceMessageDispatcher;
begin
 try
  // Removing the message hook
  CheckResult(CoreIntf.QueryInterface(IID_IAIMPServiceMessageDispatcher,
                                                ServiceMessageDispatcher));
  CheckResult(ServiceMessageDispatcher.Unhook(OMessageHook));
 except
  ShowErrorMessage('"Plugin.Finalize" failure!');
 end;
  inherited;
end;

{=========================================================================)
                              TMessageHook
(=========================================================================}
procedure TOMessageHook.CoreMessage(Message: DWORD; Param1: Integer;
  Param2: Pointer; var Result: HRESULT);
begin
try
  case Message  of
    AIMP_MSG_EVENT_LANGUAGE:
      begin
       //
      end;
  end;
except
  ShowErrorMessage('"MessageHook.CoreMessage" failure!');
end;
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
      AntiAlias := True;
      IsTwoLines := True;
      CustomColors := False;
      Color := OSC_COLOR_DEFAULT; 
      LineColor := OSC_COLOR_DEFAULT_LINE; 
      MarkColor := OSC_COLOR_DEFAULT_MARK;
      BackColor := OSC_COLOR_DEFAULT_BACK;      
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

procedure TOVisualization.Draw(DC: HDC; Data: PAIMPVisualData);
begin
  ODrawer.Draw(DC, Data);
end;

{=========================================================================)
                                  THE END
(=========================================================================}

end.
