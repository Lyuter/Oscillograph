unit OscillographOptionsFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

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
    Button1: TButton;
    ListBox1: TListBox;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    CheckBox3: TCheckBox;
    ColorDialog1: TColorDialog;
    procedure FormPaint(Sender: TObject);
    procedure Panel4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  OOptionsFrame: TOOptionsFrame;

implementation

{$R *.dfm}

procedure TOOptionsFrame.FormPaint(Sender: TObject);
begin
  with Self.Canvas
  do
    begin
      Brush.Color := $F0F0F0;
      DrawFocusRect(Self.ClientRect);
    end;
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

end.
