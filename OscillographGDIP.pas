{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            Oscillograph - AIMP3 plugin
                  Version: 2.0
              Copyright (c) Lyuter
           Mail : pro100lyuter@mail.ru

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
unit OscillographGDIP;

interface

uses
  Windows, SysUtils, apiVisuals, GdiPlus, VCL.Graphics, Math,
  OscillographHelper;

type

  TOscillographGDIP = class(TInterfacedObject, IOscillographDrawer)
  private
    FSettings       : TOSettings;
    FClientRect     : TRect;
    FLinesBufer,
    FGridBuffer,
    FAssemblyBuffer : IGPBitmap;
    FLinesDrawer,
    FGridDrawer,
    FAssemblyDrawer,
    FPrimaryDrawer  :IGPGraphics;
    FCurentDC       : HDC;
    FPen            : IGPPen;
    FBrush          : IGPSolidBrush;
    FDisplayResized : Boolean;
    procedure RefreshTools(NewDC: HDC; NewWidth, NewHeight: Integer);
    procedure MakeGrid;
  public
    function Initialize(Settings: TOSettings; Width, Height: Integer): HRESULT;
    function GetMaxDisplaySize(out Width, Height: Integer): HRESULT;
    procedure Click(X, Y, Button: Integer);
    procedure Draw(DC: HDC; Data: PAIMPVisualData);
    procedure UpdateSettings(NewSettings: TOSettings);
    procedure Resize(NewWidth, NewHeight: Integer);
  end;

implementation

{--------------------------------------------------------------------}
function  RGBToARGB(RGBColor: Cardinal): Cardinal;
begin
  Result := (RGBColor and $00FF0000) shr 16 +
            (RGBColor and $0000FF00) +
            (RGBColor and $000000FF) shl 16;
end;
{--------------------------------------------------------------------}
procedure ConvertColors(out Settings: TOSettings);
begin
  Settings.ColorLine := RGBToARGB(Settings.ColorLine) or $FF000000;
  Settings.ColorGrid := RGBToARGB(Settings.ColorGrid) or $32000000;
  Settings.ColorBackground := RGBToARGB(Settings.ColorBackground) or $55000000;
end;
{--------------------------------------------------------------------}
function TOscillographGDIP.Initialize(Settings: TOSettings; Width, Height: Integer): HRESULT;
begin
  inherited;
 try
  Result := S_OK;
  FSettings := Settings;
  ConvertColors(FSettings);
  FBrush := TGPSolidBrush.Create(Settings.ColorBackground);
  FPen := TGPPen.Create(Settings.ColorBackground);
  FClientRect.Top := 0;
  FClientRect.Left := 0;
  FClientRect.Right := Width;
  FClientRect.Bottom := Height;
  FDisplayResized := False;
 except
  Result := E_UNEXPECTED;
{$IFDEF DEBUG}
  MessageBox(0, PChar('Exception: OscillographDraw.Initialize failed!'), '',  MB_ICONERROR);
{$ENDIF}
 end;
end;
{--------------------------------------------------------------------}
function TOscillographGDIP.GetMaxDisplaySize(out Width,
  Height: Integer): HRESULT;
begin
  Result := E_FAIL;
end;
{--------------------------------------------------------------------}
procedure TOscillographGDIP.Resize(NewWidth, NewHeight: Integer);
begin
 try
  FClientRect.Top := 0;
  FClientRect.Left := 0;
  FClientRect.Right := NewWidth;
  FClientRect.Bottom := NewHeight;
  FDisplayResized := True;
 except
{$IFDEF DEBUG}
  MessageBox(0, PChar('Exception: OscillographDraw.Resize failed!'), '',  MB_ICONERROR);
{$ENDIF}
 end;
end;
{--------------------------------------------------------------------}
procedure TOscillographGDIP.UpdateSettings(NewSettings: TOSettings);
begin
  FSettings := NewSettings;
  ConvertColors(FSettings);
  MakeGrid;
end;
{--------------------------------------------------------------------}
procedure TOscillographGDIP.Click(X, Y, Button: Integer);
begin
 try
  //
 except
{$IFDEF DEBUG}
  MessageBox(0, PChar('Exception: OscillographDraw.Click failed!'), '',  MB_ICONERROR);
{$ENDIF}
 end;
end;
{--------------------------------------------------------------------}
procedure TOscillographGDIP.Draw(DC: HDC; Data: PAIMPVisualData);
var
    i: Integer;
begin
 try
  if  (FCurentDC <> DC)
    or  FDisplayResized
  then
    begin
      RefreshTools(DC, FClientRect.Right, FClientRect.Bottom);
      FCurentDC := DC;
      FDisplayResized := False;
    end;

  // Рисуем лучи
  FBrush.SetColor(FSettings.ColorBackground);
  FLinesDrawer.FillRectangle(FBrush, 0, 0, FClientRect.Right, FClientRect.Bottom); // Очищаем
  FPen.SetColor(FSettings.ColorLine);

  if  (Data.Peaks[0] <> 0)
    and (Data.Peaks[1] <> 0)
  then
    begin
    for i := 1 to AIMP_VISUAL_WAVEFORM_MAX - 1
    do
      begin
        FLinesDrawer.DrawLine(FPen,
                          (i-1)*FClientRect.Right/AIMP_VISUAL_WAVEFORM_MAX,
                          (1/2+Data.WaveForm[0, i-1]/2)*FClientRect.Bottom/2,
                           i*FClientRect.Right/AIMP_VISUAL_WAVEFORM_MAX,
                          (1/2+Data.WaveForm[0, i]/2)*FClientRect.Bottom/2);

        FLinesDrawer.DrawLine(FPen,
                          (i-1)*FClientRect.Right/AIMP_VISUAL_WAVEFORM_MAX,
                          (3/2+Data.WaveForm[1, i-1]/2)*FClientRect.Bottom/2,
                           i*FClientRect.Right/AIMP_VISUAL_WAVEFORM_MAX,
                          (3/2+Data.WaveForm[1, i]/2)*FClientRect.Bottom/2);
      end;
    end
  else
    begin
      // Для уменьшения нагрузки просто рисуем прямые линии,
      // в случае отсутствия сигнала
      FLinesDrawer.DrawLine(FPen, 0,FClientRect.Bottom/4,
                      FClientRect.Right, FClientRect.Bottom/4);
      FLinesDrawer.DrawLine(FPen, 0,FClientRect.Bottom*3/4,
                      FClientRect.Right, FClientRect.Bottom*3/4);
    end;

  // Очищаем буфер сборки
  FAssemblyDrawer.Clear(FSettings.ColorBackground);
  // Выводим буфер лучей
  FAssemblyDrawer.DrawImage(FLinesBufer, 0, 0, 0, 0,
                        FClientRect.Right, FClientRect.Bottom, UnitPixel);
  // Выводим буфер сетки
  FAssemblyDrawer.DrawImage(FGridBuffer, 0, 0, 0, 0,
                        FClientRect.Right, FClientRect.Bottom, UnitPixel);
  // Выводим собранное изображение на дисплей
  FPrimaryDrawer.DrawImage(FAssemblyBuffer, 0, 0, 0, 0,
                        FClientRect.Right, FClientRect.Bottom, UnitPixel);
 except
{$IFDEF DEBUG}
  MessageBox(0, PChar('Exception: DisplayRender failed!'), '',  MB_ICONERROR);
{$ENDIF}
 end;
end;
{--------------------------------------------------------------------}
procedure TOscillographGDIP.RefreshTools(NewDC: HDC; NewWidth, NewHeight: Integer);
begin
 try
  FPrimaryDrawer := TGPGraphics.Create(NewDC);

  FLinesBufer := TGPBitmap.Create(NewWidth, NewHeight, FPrimaryDrawer);
  FLinesDrawer := TGPGraphics.Create(FLinesBufer);
  FLinesDrawer.SetCompositingQuality(CompositingQualityHighSpeed);
  if  FSettings.AntiAliasing
  then
    FLinesDrawer.SetSmoothingMode(SmoothingModeAntiAlias)
  else
    FLinesDrawer.SetSmoothingMode(SmoothingModeHighSpeed);
  FLinesDrawer.SetPageUnit(UnitPixel);

  FGridBuffer  :=  TGPBitmap.Create(NewWidth, NewHeight, FPrimaryDrawer);
  FGridDrawer  :=  TGPGraphics.Create(FGridBuffer);
  FGridDrawer.SetCompositingQuality(CompositingQualityHighSpeed);
  FGridDrawer.SetSmoothingMode(SmoothingModeHighSpeed);

  FAssemblyBuffer  :=  TGPBitmap.Create(NewWidth, NewHeight, FPrimaryDrawer);
  FAssemblyDrawer  :=  TGPGraphics.Create(FAssemblyBuffer);
  FAssemblyDrawer.SetCompositingQuality(CompositingQualityHighSpeed);
  FAssemblyDrawer.SetSmoothingMode(SmoothingModeHighSpeed);

  MakeGrid;
 except
{$IFDEF DEBUG}
  MessageBox(0, PChar('Exception: RefreshTools failed!'), '',  MB_ICONERROR);
{$ENDIF}
 end;
end;
{--------------------------------------------------------------------}
procedure TOscillographGDIP.MakeGrid;
var
    i: Integer;
    NewHeight, NewWidth : Integer;
begin
 try
  NewHeight := FClientRect.Bottom;
  NewWidth := FClientRect.Right;

  FGridDrawer.Clear($00000000);
  FPen.SetColor(FSettings.ColorGrid);

  for i := 0 to Round(Max(FClientRect.Bottom, FClientRect.Right)/2/OSC_CELLSIZE)
  do
    begin
      FGridDrawer.DrawLine(FPen, 0, NewHeight/2+i*OSC_CELLSIZE,
                      NewWidth, NewHeight/2+i*OSC_CELLSIZE);
      FGridDrawer.DrawLine(FPen, 0, NewHeight/2-i*OSC_CELLSIZE,
                      NewWidth, NewHeight/2-i*OSC_CELLSIZE);
      FGridDrawer.DrawLine(FPen, NewWidth/2-i*OSC_CELLSIZE, 0,
                      NewWidth/2-i*OSC_CELLSIZE, NewHeight);
      FGridDrawer.DrawLine(FPen, NewWidth/2+i*OSC_CELLSIZE, 0,
                      NewWidth/2+i*OSC_CELLSIZE, NewHeight);
    end;

  for i := 0 to Round(Max(FClientRect.Bottom, FClientRect.Right)/2/OSC_MARKERSIZE)
  do
    begin
      FGridDrawer.DrawLine(FPen, (NewWidth-OSC_MARKERSIZE)/2,
                      NewHeight/2+i*OSC_MARKERSIZE,
                      (NewWidth+OSC_MARKERSIZE)/2,
                      NewHeight/2+i*OSC_MARKERSIZE);

      FGridDrawer.DrawLine(FPen, (NewWidth-OSC_MARKERSIZE)/2,
                      NewHeight/2-i*OSC_MARKERSIZE,
                      (NewWidth+OSC_MARKERSIZE)/2,
                      NewHeight/2-i*OSC_MARKERSIZE);

      FGridDrawer.DrawLine(FPen, NewWidth/2-i*OSC_MARKERSIZE,
                      (NewHeight-OSC_MARKERSIZE)/2,
                      NewWidth/2-i*OSC_MARKERSIZE,
                      (NewHeight+OSC_MARKERSIZE)/2);
      FGridDrawer.DrawLine(FPen, NewWidth/2+i*OSC_MARKERSIZE,
                      (NewHeight-OSC_MARKERSIZE)/2,
                      NewWidth/2+i*OSC_MARKERSIZE,
                      (NewHeight+OSC_MARKERSIZE)/2);
    end;
 except
{$IFDEF DEBUG}
  MessageBox(0, PChar('Exception: MakeGrid failed!'), '',  MB_ICONERROR);
{$ENDIF}
 end;
end;

end.
