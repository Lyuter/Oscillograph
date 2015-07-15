{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

            Oscillograph - AIMP3 plugin
                  Version: 2.0
              Copyright (c) Lyuter
           Mail : pro100lyuter@mail.ru

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
unit OscillographOptionsFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  OscillographHelper;

type
  TOOptionsFrame = class(TForm)
    CheckBoxAntiAliasing: TCheckBox;
    GroupBoxColor: TGroupBox;
    CheckBoxGrid: TCheckBox;
    GroupBoxPresets: TGroupBox;
    ListBox1: TListBox;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox3: TCheckBox;
    PaintBoxColorPicker: TPaintBox;
    EditLine: TEdit;
    EditGrid: TEdit;
    EditBackground: TEdit;
    LabelLine: TLabel;
    LabelGrid: TLabel;
    LabelBackground: TLabel;
    PaintBoxLine: TPaintBox;
    PaintBoxGrid: TPaintBox;
    PaintBoxBackground: TPaintBox;
    CheckBoxFastConfig: TCheckBox;
    Button1: TButton;
    GroupBoxChannels: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton1: TRadioButton;
    procedure FormPaint(Sender: TObject);
    procedure PaintBoxColorPickerPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBoxColorPickerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxColorPickerMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure ColorBoxPaint(Sender: TObject);
    procedure ColorBoxClick(Sender: TObject);
    procedure CheckBoxFastConfigMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ColorEditChange(Sender: TObject);
    procedure ColorEditEnter(Sender: TObject);
    procedure ColorEditExit(Sender: TObject);
    procedure CheckBoxAntiAliasingClick(Sender: TObject);
    procedure CheckBoxGridClick(Sender: TObject);
  private
    FActiveSettings: TOSettings;
    FPaletteImage: TBitmap;
    FSelectedColorBox: TPaintBox;
    FOnModified: TNotifyEvent;
    function LineColorRead: Cardinal;
    procedure LineColorWrite(NewColor: Cardinal);
    function GridColorRead: Cardinal;
    procedure GridColorWrite(NewColor: Cardinal);
    function BackgroundColorRead: Cardinal;
    procedure BackgroundColorWrite(NewColor: Cardinal);
    function AntiAliasingRead: Boolean;
    procedure AntiAliasingWrite(NewValue: Boolean);
    function DrawGridRead: Boolean;
    procedure DrawGridWrite(NewValue: Boolean);
    procedure MakePalete;
    procedure DoModified;
  public
    property LineColor: Cardinal read LineColorRead write LineColorWrite;
    property GridColor: Cardinal read GridColorRead write GridColorWrite;
    property BackgroundColor: Cardinal read BackgroundColorRead write BackgroundColorWrite;
    property OnModified: TNotifyEvent read FOnModified write FOnModified;
    property Settings: TOSettings read FActiveSettings write FActiveSettings;
    property AntiAliasing: Boolean read AntiAliasingRead write AntiAliasingWrite;
    property DrawGrid: Boolean read DrawGridRead write DrawGridWrite;
    procedure ApplyLocalization;
    procedure ConfigLoad;
    procedure ConfigSave;
  end;

implementation

{$R *.dfm}
{$R CURSOR.res}

{--------------------------------------------------------------------
ColorToHtml}
function ColorToHtml(const Color: Cardinal): String;
const
  Hex = '0123456789ABCDEF';
var
  b, s: Byte;
begin
//  Result := '#';
  s := 0;
  repeat
    b := (Color shr s) and $FF;
    Result := Result + Hex[b div 16 + 1] + Hex[b mod 16 + 1];
    Inc(s, 8);
  until s = 24;
end;
{--------------------------------------------------------------------
HtmlToColor}
function HtmlToColor(const Html: String): Cardinal;
const
  Hex = '0123456789ABCDEF';
var
  p, s: Byte;
  HtmlFixed: String;
begin
  Result := 0;
  s := 0;
  p := 1;
  HtmlFixed := AnsiUpperCase(Html);

  if Length(HtmlFixed) = 0
  then
    begin
      Result := 0;
      exit;
    end;
  repeat
    Result := Result or (((Pos(HtmlFixed[p], Hex) - 1) * 16 +
      Pos(HtmlFixed[p + 1], Hex) - 1) shl s);
    Inc(p, 2);
    Inc(s, 8);
  until s = 24;
end;
{--------------------------------------------------------------------
DrawGradient}
procedure DrawGradient(ACanvas: TCanvas; Rect: TRect;
          Horizontal: Boolean; Colors: array of TColor);
type
   RGBArray = array[0..2] of Byte;
var
   x, y, z, stelle, mx, bis, faColorsh, mass: Integer;
   Faktor: double;
   A: RGBArray;
   B: array of RGBArray;
   merkw: integer;
   merks: TPenStyle;
   merkp: TColor;
begin
  mx := High(Colors);
   if mx > 0 then
   begin
     if Horizontal then
       mass := Rect.Right - Rect.Left
     else
       mass := Rect.Bottom - Rect.Top;
     SetLength(b, mx + 1);
     for x := 0 to mx do
     begin
       Colors[x] := ColorToRGB(Colors[x]);
       b[x][0] := GetRValue(Colors[x]);
       b[x][1] := GetGValue(Colors[x]);
       b[x][2] := GetBValue(Colors[x]);
     end;
     merkw := ACanvas.Pen.Width;
     merks := ACanvas.Pen.Style;
     merkp := ACanvas.Pen.Color;
     ACanvas.Pen.Width := 1;
     ACanvas.Pen.Style := psSolid;
     faColorsh := Round(mass / mx);
     for y := 0 to mx - 1 do
     begin
       if y = mx - 1 then
         bis := mass - y * faColorsh - 1
       else
         bis := faColorsh;
       for x := 0 to bis do
       begin
         Stelle := x + y * faColorsh;
         faktor := x / bis;
         for z := 0 to 3 do
           a[z] := Trunc(b[y][z] + ((b[y + 1][z] - b[y][z]) * Faktor));
         ACanvas.Pen.Color := RGB(a[0], a[1], a[2]);
         if Horizontal then
         begin
           ACanvas.MoveTo(Rect.Left + Stelle, Rect.Top);
           ACanvas.LineTo(Rect.Left + Stelle, Rect.Bottom);
         end
         else
         begin
           ACanvas.MoveTo(Rect.Left, Rect.Top + Stelle);
           ACanvas.LineTo(Rect.Right, Rect.Top + Stelle);
         end;
       end;
     end;
     b := nil;
     ACanvas.Pen.Width := merkw;
     ACanvas.Pen.Style := merks;
     ACanvas.Pen.Color := merkp;
   end;
 end;
{--------------------------------------------------------------------}
function RGBColorize(OldColor, NewColor: Cardinal): Cardinal;

  function BLimit(B: Integer): Byte;
  begin
    if B < 0
    then
      Result := 0
    else
      if B > 255
      then
        Result := 255
      else
        Result := B;
  end;

var
  RNew, GNew, BNew: Byte;
  ROld, GOld, BOld: Byte;
  Intensity: Double;
begin
  RNew := GetRValue(NewColor);
  GNew := GetGValue(NewColor);
  BNew := GetBValue(NewColor);

  ROld := GetRValue(OldColor);
  GOld := GetGValue(OldColor);
  BOld := GetBValue(OldColor);

  Intensity := (ROld + GOld + BOld) / 255;

  Result := RGB(BLimit(Round(RNew * Intensity)),
                 BLimit(Round(GNew * Intensity)),
                  BLimit(Round(BNew * Intensity)));
end;
{--------------------------------------------------------------------}
function TOOptionsFrame.LineColorRead: Cardinal;
begin
  Result := FActiveSettings.ColorLine;
end;

procedure TOOptionsFrame.LineColorWrite(NewColor: Cardinal);
begin
  FActiveSettings.ColorLine := NewColor;
  EditLine.Text := ColorToHtml(NewColor);
  DoModified;
end;

function TOOptionsFrame.GridColorRead: Cardinal;
begin
  Result := FActiveSettings.ColorGrid;
end;

procedure TOOptionsFrame.GridColorWrite(NewColor: Cardinal);
begin
  FActiveSettings.ColorGrid := NewColor;
  EditGrid.Text := ColorToHtml(NewColor);
  DoModified;
end;

function TOOptionsFrame.BackgroundColorRead: Cardinal;
begin
  Result := FActiveSettings.ColorBackground;
end;

procedure TOOptionsFrame.BackgroundColorWrite(NewColor: Cardinal);
begin
  FActiveSettings.ColorBackground := NewColor;
  EditBackground.Text := ColorToHtml(NewColor);
  DoModified;
end;

function TOOptionsFrame.AntiAliasingRead: Boolean;
begin
  Result := FActiveSettings.AntiAliasing;
end;

procedure TOOptionsFrame.AntiAliasingWrite(NewValue: Boolean);
begin
  FActiveSettings.AntiAliasing := NewValue;
  CheckBoxAntiAliasing.Checked := NewValue;
  DoModified;
end;

function TOOptionsFrame.DrawGridRead: Boolean;
begin
  Result := FActiveSettings.DrawGrid;
end;

procedure TOOptionsFrame.DrawGridWrite(NewValue: Boolean);
begin
  FActiveSettings.DrawGrid := NewValue;
  CheckBoxGrid.Checked := NewValue;
  DoModified;
end;
{--------------------------------------------------------------------}
procedure TOOptionsFrame.FormCreate(Sender: TObject);
begin
  FPaletteImage := TBitmap.Create;
  FPaletteImage.Height := PaintBoxColorPicker.Height;
  FPaletteImage.Width := PaintBoxColorPicker.Width;
  Screen.Cursors[crCross] := LoadCursor(HInstance, 'COLORPICKER');
  MakePalete;
end;

procedure TOOptionsFrame.FormDestroy(Sender: TObject);
begin
  ConfigLoad;
  FreeAndNil(FPaletteImage);
end;
{--------------------------------------------------------------------}
procedure TOOptionsFrame.FormPaint(Sender: TObject);
begin
  with Self.Canvas
  do
    begin
      DrawGradient(Self.Canvas, ClientRect, False,[$FeFeFe, $e3e3e3]);
    end;
end;

procedure TOOptionsFrame.PaintBoxColorPickerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if  Button = mbLeft
  then
    PaintBoxColorPickerMouseMove(Sender, Shift, X, Y);
end;

procedure TOOptionsFrame.PaintBoxColorPickerMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  Color: TColor;
  DC: HDC;
  CursorPos: TPoint;
begin
  if ssLeft in Shift
  then
    begin
//      if  X < 0
//      then  X := 0;
//      if  Y < 0
//      then  Y := 0;
//      if  X > PaintBoxColorPicker.Width - 1
//      then  X := PaintBoxColorPicker.Width - 1;
//      if  Y > PaintBoxColorPicker.Height - 1
//      then  Y := PaintBoxColorPicker.Height - 1;
      if PtInRect(PaintBoxColorPicker.ClientRect, Point(X, Y))
      then
        Color := PaintBoxColorPicker.Canvas.Pixels[X, Y]
      else
        begin
          DC := GetDC(0);
          GetCursorPos(CursorPos);
          Color := GetPixel(DC, CursorPos.X, CursorPos.Y);
          ReleaseDC(0, DC);
        end;

      if CheckBoxFastConfig.Checked
      then
        begin
          LineColor := RGBColorize(OSC_DEFAULT_COLOR_LINE, Color);
          GridColor := RGBColorize(OSC_DEFAULT_COLOR_GRID, Color);
          BackgroundColor := RGBColorize(OSC_DEFAULT_COLOR_BACK, Color);
        end;
      if FSelectedColorBox = PaintBoxLine
      then
        begin
          LineColor := Color;
        end;
      if FSelectedColorBox = PaintBoxGrid
      then
        begin
          GridColor := Color;
        end;
      if FSelectedColorBox = PaintBoxBackground
      then
        begin
          BackgroundColor := Color;
        end;
    end;
end;

procedure TOOptionsFrame.PaintBoxColorPickerPaint(Sender: TObject);
begin
  PaintBoxColorPicker.Canvas.Draw(0, 0, FPaletteImage);
end;

procedure TOOptionsFrame.CheckBoxAntiAliasingClick(Sender: TObject);
begin
  AntiAliasing := CheckBoxAntiAliasing.Checked;
end;

procedure TOOptionsFrame.CheckBoxFastConfigMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CheckBoxFastConfig.Checked := True;
end;

procedure TOOptionsFrame.CheckBoxGridClick(Sender: TObject);
begin
  DrawGrid := CheckBoxGrid.Checked;
end;

procedure TOOptionsFrame.ColorBoxClick(Sender: TObject);
begin
  if Sender is TPaintBox
  then
    begin
      FSelectedColorBox := TPaintBox(Sender);
      ColorBoxPaint(PaintBoxLine);
      ColorBoxPaint(PaintBoxGrid);
      ColorBoxPaint(PaintBoxBackground);
      CheckBoxFastConfig.Checked := False;
      if FSelectedColorBox = PaintBoxLine
      then
        EditLine.SetFocus;
      if FSelectedColorBox = PaintBoxGrid
      then
        EditGrid.SetFocus;
      if FSelectedColorBox = PaintBoxBackground
      then
        EditBackground.SetFocus;
    end;
end;

procedure TOOptionsFrame.ColorBoxPaint(Sender: TObject);
var
  Rect: TRect;
  Bitmap: TBitmap;
begin
  if not (Sender is TPaintBox)
  then
    exit;
  Bitmap := TBitmap.Create;
  Bitmap.Width := TPaintBox(Sender).Width;
  Bitmap.Height := TPaintBox(Sender).Height;
  with  Bitmap.Canvas
  do
    begin
      Brush.Color := Self.Color;
      Rect := TPaintBox(Sender).ClientRect;
      FillRect(Rect);
      if FSelectedColorBox = Sender
      then
        DrawFocusRect(Rect);
      if Sender = PaintBoxLine
      then
        Brush.Color := LineColor;
      if Sender = PaintBoxGrid
      then
        Brush.Color := GridColor;
      if Sender = PaintBoxBackground
      then
        Brush.Color := BackgroundColor;

      Rect.Left := 2;
      Rect.Top := 2;
      Rect.Right := Bitmap.Width - 2;
      Rect.Bottom := Bitmap.Height - 2;
      FillRect(Rect);
    end;
  TPaintBox(Sender).Canvas.Draw(0, 0, Bitmap);
  FreeAndNil(Bitmap);
end;

procedure TOOptionsFrame.ColorEditChange(Sender: TObject);
var
  Color: Cardinal;
begin
  if not (Sender is TEdit)
  then
    exit;
  if Sender = EditLine
  then
    try
      Color := HtmlToColor(EditLine.Text);
      FActiveSettings.ColorLine := Color;
      ColorBoxPaint(PaintBoxLine);
    except
    end;
  if Sender = EditGrid
  then
    try
      Color := HtmlToColor(EditGrid.Text);
      FActiveSettings.ColorGrid := Color;
      ColorBoxPaint(PaintBoxGrid);
    except
    end;
  if Sender = EditBackground
  then
    try
      Color := HtmlToColor(EditBackground.Text);
      FActiveSettings.ColorBackground := Color;
      ColorBoxPaint(PaintBoxBackground);
    except
    end;
  DoModified;
end;

procedure TOOptionsFrame.ColorEditEnter(Sender: TObject);
begin
  if not (Sender is TEdit)
  then
    exit;
  if Sender = EditLine
  then
    FSelectedColorBox := PaintBoxLine;
  if Sender = EditGrid
  then
    FSelectedColorBox := PaintBoxGrid;
  if Sender = EditBackground
  then
    FSelectedColorBox := PaintBoxBackground;

  CheckBoxFastConfig.Checked := False;
  ColorBoxPaint(PaintBoxLine);
  ColorBoxPaint(PaintBoxGrid);
  ColorBoxPaint(PaintBoxBackground);
end;

procedure TOOptionsFrame.ColorEditExit(Sender: TObject);
begin
  if not (Sender is TEdit)
  then
    exit;
  FSelectedColorBox := nil;
  if Sender = EditLine
  then
    begin
      EditLine.Text := ColorToHtml(LineColor);
      ColorBoxPaint(PaintBoxLine);
    end;
  if Sender = EditGrid
  then
    begin
      EditGrid.Text := ColorToHtml(GridColor);
      ColorBoxPaint(PaintBoxGrid);
    end;
  if Sender = EditBackground
  then
    begin
      EditBackground.Text := ColorToHtml(BackgroundColor);
      ColorBoxPaint(PaintBoxBackground);
    end;
end;

procedure TOOptionsFrame.DoModified;
begin
  if Assigned(OnModified)
  then
    OnModified(Self);
end;
{--------------------------------------------------------------------}
procedure TOOptionsFrame.ConfigLoad;
var
  NewSettings: TOSettings;
begin
  if not Succeeded(ReadSettingsActive(NewSettings))
  then
    NewSettings := GetDefaultSettings;
  LineColor := NewSettings.ColorLine;
  GridColor := NewSettings.ColorGrid;
  BackgroundColor := NewSettings.ColorBackground;
  AntiAliasing := NewSettings.AntiAliasing;
  DrawGrid := NewSettings.DrawGrid;
end;

procedure TOOptionsFrame.ConfigSave;
begin
  WriteSettingsActive(FActiveSettings);
end;
{--------------------------------------------------------------------}
procedure TOOptionsFrame.ApplyLocalization;
begin
  //
end;
{--------------------------------------------------------------------
MakePalete}
procedure TOOptionsFrame.MakePalete;
const
  PALETTE_GRAYLINE_WIDTH = 6;
var
  GradientLine: TBitmap;
  i: Integer;
  LineRect: TRect;
begin
  GradientLine := TBitmap.Create;
try
  GradientLine.Height := 1;
  GradientLine.Width := FPaletteImage.Width - PALETTE_GRAYLINE_WIDTH;

  LineRect.Top := 0;
  LineRect.Bottom := 1;
  LineRect.Left := 0;
  LineRect.Right := FPaletteImage.Width - PALETTE_GRAYLINE_WIDTH;
  DrawGradient(GradientLine.Canvas, LineRect, True,
        [$0000FF, $00FFFF, $00FF00, $FFFF00, $FF0000, $FF00FF, $0000FF]);

  FPaletteImage.Canvas.Lock;
  for i := 0 to LineRect.Right - 1
  do
    begin
      LineRect.Left := i;
      LineRect.Right := i + 1;
      LineRect.Top := 0;
      LineRect.Bottom := FPaletteImage.Height;

      DrawGradient(FPaletteImage.Canvas, LineRect, False,
                [$FFFFFF, GradientLine.Canvas.Pixels[i, 0], $000000]);
    end;

  LineRect.Left := FPaletteImage.Width - PALETTE_GRAYLINE_WIDTH;
  LineRect.Right := FPaletteImage.Width;
  LineRect.Top := 0;
  LineRect.Bottom := FPaletteImage.Height;
  DrawGradient(FPaletteImage.Canvas, LineRect, False, [$FFFFFF, $000000]);

  FPaletteImage.Canvas.Unlock;
finally
  FreeAndNil(GradientLine);
end;
end;

end.
