unit OscillographOptionsFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TOOptionsFrame = class(TForm)
    CheckBox1: TCheckBox;
    GroupBox1: TGroupBox;
    Label4: TLabel;
    Edit4: TEdit;
    Panel4: TPanel;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit3: TEdit;
    Edit2: TEdit;
    Edit1: TEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    CheckBox2: TCheckBox;
    GroupBox3: TGroupBox;
    ListBox1: TListBox;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox3: TCheckBox;
    ColorDialog1: TColorDialog;
    Button1: TButton;
    PaintBox1: TPaintBox;
    procedure FormPaint(Sender: TObject);
    procedure Panel4Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
  private
    { Private declarations }
    PaletteImage: TBitmap;
    procedure MakePalete;
  public
    { Public declarations }
  end;

//var
//  OOptionsFrame: TOOptionsFrame;

implementation

{$R *.dfm}

procedure TOOptionsFrame.FormCreate(Sender: TObject);
begin
  PaletteImage := TBitmap.Create;
  PaletteImage.Height := PaintBox1.Height;
  PaletteImage.Width := PaintBox1.Width;
  MakePalete;
end;

procedure TOOptionsFrame.FormDestroy(Sender: TObject);
begin
  FreeAndNil(PaletteImage);
end;

procedure TOOptionsFrame.FormPaint(Sender: TObject);
begin
  with Self.Canvas
  do
    begin
      Brush.Color := $F0F0F0;
      DrawFocusRect(Self.ClientRect);
    end;
end;

procedure TOOptionsFrame.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if  Button = mbLeft
  then
    PaintBox1MouseMove(Sender, Shift, X, Y);
end;

procedure TOOptionsFrame.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if ssLeft in Shift
  then
    begin
      if  X < 0
      then  X := 0;
      if  Y < 0
      then  Y := 0;
      if  X > PaintBox1.Width - 1
      then  X := PaintBox1.Width - 1;
      if  Y > PaintBox1.Height - 1
      then  Y := PaintBox1.Height - 1;
      Panel4.Color := PaintBox1.Canvas.Pixels[X, Y];
    end;
end;

procedure TOOptionsFrame.PaintBox1Paint(Sender: TObject);
begin
  PaintBox1.Canvas.Draw(0, 0, PaletteImage);
end;

procedure TOOptionsFrame.Panel4Click(Sender: TObject);
begin
  ColorDialog1.Color := Panel4.Color;
  if ColorDialog1.Execute
  then
    begin
      Edit4.Text := Format('#%.02x%.02x%.02x',
      [GetRValue(ColorDialog1.Color), GetGValue(ColorDialog1.Color), GetBValue(ColorDialog1.Color)]);
      Panel4.Color := ColorDialog1.Color;
    end;
end;

{===========================================================================
DrawGradient}
procedure DrawGradient(ACanvas: TCanvas; Rect: TRect;
          Horicontal: Boolean; Colors: array of TColor);
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
     if Horicontal then
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
         if Horicontal then
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

{===========================================================================
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
  GradientLine.Width := PaletteImage.Width - PALETTE_GRAYLINE_WIDTH;

  LineRect.Top := 0;
  LineRect.Bottom := 1;
  LineRect.Left := 0;
  LineRect.Right := PaletteImage.Width - PALETTE_GRAYLINE_WIDTH;
  DrawGradient(GradientLine.Canvas, LineRect, True,
        [$0000FF, $00FFFF, $00FF00, $FFFF00, $FF0000, $FF00FF, $0000FF]);

  PaletteImage.Canvas.Lock;
  for i := 0 to LineRect.Right - 1
  do
    begin
      LineRect.Left := i;
      LineRect.Right := i + 1;
      LineRect.Top := 0;
      LineRect.Bottom := PaletteImage.Height;

      DrawGradient(PaletteImage.Canvas, LineRect, False,
                [$FFFFFF, GradientLine.Canvas.Pixels[i, 0], $000000]);
    end;

  LineRect.Left := PaletteImage.Width - PALETTE_GRAYLINE_WIDTH;
  LineRect.Right := PaletteImage.Width;
  LineRect.Top := 0;
  LineRect.Bottom := PaletteImage.Height;
  DrawGradient(PaletteImage.Canvas, LineRect, False, [$FFFFFF, $000000]);

  PaletteImage.Canvas.Unlock;
finally
  FreeAndNil(GradientLine);
end;
end;

end.
