object OOptionsFrame: TOOptionsFrame
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'OOptionsFrame'
  ClientHeight = 430
  ClientWidth = 471
  Color = clBtnFace
  ParentFont = True
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object CheckBoxAntiAliasing: TCheckBox
    Left = 312
    Top = 220
    Width = 145
    Height = 17
    Caption = #1057#1075#1083#1072#1078#1080#1074#1072#1085#1080#1077
    Checked = True
    State = cbChecked
    TabOrder = 2
    OnClick = CheckBoxAntiAliasingClick
  end
  object GroupBoxColor: TGroupBox
    Left = 4
    Top = 4
    Width = 463
    Height = 194
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1094#1074#1077#1090#1072
    TabOrder = 0
    DesignSize = (
      463
      194)
    object PaintBoxColorPicker: TPaintBox
      Left = 193
      Top = 14
      Width = 260
      Height = 170
      Cursor = crCross
      Anchors = [akLeft, akTop, akRight, akBottom]
      Color = clLime
      ParentColor = False
      OnMouseDown = PaintBoxColorPickerMouseDown
      OnMouseMove = PaintBoxColorPickerMouseMove
      OnPaint = PaintBoxColorPickerPaint
      ExplicitWidth = 252
    end
    object LabelLine: TLabel
      Left = 28
      Top = 34
      Width = 46
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = #1051#1080#1085#1080#1103': #'
      ParentBiDiMode = False
    end
    object LabelGrid: TLabel
      Left = 28
      Top = 62
      Width = 46
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = #1057#1077#1090#1082#1072': #'
      ParentBiDiMode = False
    end
    object LabelBackground: TLabel
      Left = 39
      Top = 89
      Width = 35
      Height = 13
      Alignment = taRightJustify
      Caption = #1060#1086#1085': #'
    end
    object PaintBoxLine: TPaintBox
      Left = 136
      Top = 31
      Width = 49
      Height = 21
      Cursor = crHandPoint
      OnClick = ColorBoxClick
      OnPaint = ColorBoxPaint
    end
    object PaintBoxGrid: TPaintBox
      Left = 136
      Top = 58
      Width = 49
      Height = 21
      Cursor = crHandPoint
      OnClick = ColorBoxClick
      OnPaint = ColorBoxPaint
    end
    object PaintBoxBackground: TPaintBox
      Left = 136
      Top = 85
      Width = 49
      Height = 21
      Cursor = crHandPoint
      OnClick = ColorBoxClick
      OnPaint = ColorBoxPaint
    end
    object EditLine: TEdit
      Left = 79
      Top = 31
      Width = 50
      Height = 21
      TabOrder = 0
      Text = '094093'
      OnChange = ColorEditChange
      OnEnter = ColorEditEnter
      OnExit = ColorEditExit
    end
    object EditGrid: TEdit
      Left = 79
      Top = 58
      Width = 50
      Height = 21
      TabOrder = 1
      Text = '094093'
      OnChange = ColorEditChange
      OnEnter = ColorEditEnter
      OnExit = ColorEditExit
    end
    object EditBackground: TEdit
      Left = 79
      Top = 85
      Width = 50
      Height = 21
      TabOrder = 2
      Text = '094093'
      OnChange = ColorEditChange
      OnEnter = ColorEditEnter
      OnExit = ColorEditExit
    end
    object CheckBoxFastConfig: TCheckBox
      Left = 28
      Top = 144
      Width = 157
      Height = 17
      Caption = #1041#1099#1089#1090#1088#1072#1103' '#1085#1072#1089#1090#1088#1086#1081#1082#1072
      TabOrder = 3
      OnMouseUp = CheckBoxFastConfigMouseUp
    end
  end
  object CheckBoxGrid: TCheckBox
    Left = 312
    Top = 250
    Width = 137
    Height = 17
    Caption = #1054#1090#1086#1073#1088#1072#1078#1072#1090#1100' '#1089#1077#1090#1082#1091
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = CheckBoxGridClick
  end
  object GroupBoxPresets: TGroupBox
    Left = 4
    Top = 204
    Width = 293
    Height = 218
    Caption = #1058#1077#1084#1099
    TabOrder = 1
    object ListBoxPresetList: TListBox
      Left = 160
      Top = 16
      Width = 122
      Height = 192
      Style = lbOwnerDrawFixed
      ItemHeight = 13
      Items.Strings = (
        '1'
        '2'
        '3'
        '4')
      TabOrder = 0
      OnDrawItem = ListBoxPresetListDrawItem
    end
    object Button2: TButton
      Left = 14
      Top = 27
      Width = 113
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 1
    end
    object Button3: TButton
      Left = 14
      Top = 58
      Width = 113
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 2
    end
    object Button4: TButton
      Left = 14
      Top = 89
      Width = 113
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 3
    end
    object CheckBox3: TCheckBox
      Left = 14
      Top = 152
      Width = 113
      Height = 49
      Caption = #1055#1088#1080#1074#1103#1079#1072#1090#1100' '#1082' '#1072#1082#1090#1080#1074#1085#1086#1084#1091' '#1089#1082#1080#1085#1091
      TabOrder = 4
      WordWrap = True
    end
    object Button1: TButton
      Left = 14
      Top = 120
      Width = 113
      Height = 25
      Caption = #1053#1086#1074#1099#1081
      TabOrder = 5
    end
  end
  object GroupBoxChannels: TGroupBox
    Left = 303
    Top = 273
    Width = 164
    Height = 92
    Caption = #1050#1072#1085#1072#1083#1099
    TabOrder = 4
    object RadioButton3: TRadioButton
      Left = 31
      Top = 64
      Width = 113
      Height = 17
      Caption = #1055#1088#1072#1074#1099#1081
      TabOrder = 0
    end
    object RadioButton2: TRadioButton
      Left = 31
      Top = 41
      Width = 113
      Height = 17
      Caption = #1051#1077#1074#1099#1081
      TabOrder = 1
    end
    object RadioButton1: TRadioButton
      Left = 31
      Top = 18
      Width = 113
      Height = 17
      Caption = #1054#1073#1072
      Checked = True
      TabOrder = 2
      TabStop = True
    end
  end
end
