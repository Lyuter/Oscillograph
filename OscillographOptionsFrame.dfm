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
    Top = 224
    Width = 151
    Height = 17
    Caption = #1057#1075#1083#1072#1078#1080#1074#1072#1085#1080#1077
    TabOrder = 0
    OnClick = CheckBoxAntiAliasingClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 455
    Height = 194
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1094#1074#1077#1090#1072
    TabOrder = 1
    DesignSize = (
      455
      194)
    object PaintBoxColorPicker: TPaintBox
      Left = 193
      Top = 14
      Width = 252
      Height = 170
      Cursor = crCross
      Anchors = [akLeft, akTop, akRight, akBottom]
      Color = clLime
      ParentColor = False
      OnMouseDown = PaintBoxColorPickerMouseDown
      OnMouseMove = PaintBoxColorPickerMouseMove
      OnPaint = PaintBoxColorPickerPaint
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
    Top = 254
    Width = 151
    Height = 17
    Caption = #1054#1090#1086#1073#1088#1072#1078#1072#1090#1100' '#1089#1077#1090#1082#1091
    TabOrder = 2
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 208
    Width = 289
    Height = 215
    Caption = #1058#1077#1084#1099
    TabOrder = 3
    object ListBox1: TListBox
      Left = 144
      Top = 13
      Width = 136
      Height = 188
      ItemHeight = 13
      TabOrder = 0
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
  object RadioGroup1: TRadioGroup
    Left = 303
    Top = 287
    Width = 160
    Height = 98
    Caption = #1050#1072#1085#1072#1083#1099
    TabOrder = 4
  end
  object RadioButton1: TRadioButton
    Left = 325
    Top = 310
    Width = 113
    Height = 17
    Caption = #1054#1073#1072
    Checked = True
    TabOrder = 5
    TabStop = True
  end
  object RadioButton2: TRadioButton
    Left = 325
    Top = 333
    Width = 113
    Height = 17
    Caption = #1051#1077#1074#1099#1081
    TabOrder = 6
  end
  object RadioButton3: TRadioButton
    Left = 325
    Top = 356
    Width = 113
    Height = 17
    Caption = #1055#1088#1072#1074#1099#1081
    TabOrder = 7
  end
end
