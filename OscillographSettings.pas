unit OscillographSettings;

interface

uses
  Windows, apiVisuals;

const

    OSC_COLOR_DEFAULT           = $FF00FF00;
    OSC_COLOR_DEFAULT_BACK      = $55002000;
    OSC_COLOR_DEFAULT_LINE      = $FF00ee00;
    OSC_COLOR_DEFAULT_MARK      = $3200aa00;
    //
    OSC_CELLSIZE   = 30;    //  Размер сетки в пикселях
    OSC_MARKERSIZE = 6;     //  Расстояние между маркерами

type

  TOSettings = record
    AntiAlias: Boolean;
    IsTwoLines: Boolean;
    CustomColors: Boolean;
    Color,
    LineColor,
    MarkColor,
    BackColor   : Cardinal;
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

implementation

end.
