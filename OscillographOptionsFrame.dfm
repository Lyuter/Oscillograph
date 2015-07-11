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
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object CheckBox1: TCheckBox
    Left = 312
    Top = 24
    Width = 151
    Height = 17
    Caption = #1057#1075#1083#1072#1078#1080#1074#1072#1085#1080#1077
    TabOrder = 0
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 289
    Height = 194
    Caption = #1053#1072#1089#1090#1088#1086#1081#1082#1072' '#1094#1074#1077#1090#1072
    TabOrder = 1
    object Label4: TLabel
      Left = 23
      Top = 29
      Width = 30
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = #1062#1074#1077#1090':'
      ParentBiDiMode = False
    end
    object Edit4: TEdit
      Left = 63
      Top = 26
      Width = 57
      Height = 21
      TabOrder = 0
      Text = '#094093'
    end
    object Panel4: TPanel
      Left = 135
      Top = 26
      Width = 49
      Height = 21
      BevelOuter = bvLowered
      Caption = 'Panel0'
      Color = 8388863
      ParentBackground = False
      TabOrder = 1
      OnClick = Panel4Click
    end
    object GroupBox2: TGroupBox
      Left = 16
      Top = 61
      Width = 217
      Height = 116
      Caption = #1056#1072#1089#1096#1080#1088#1077#1085#1085#1072#1103' '#1085#1072#1089#1090#1088#1086#1081#1082#1072
      TabOrder = 2
      object Label1: TLabel
        Left = 22
        Top = 26
        Width = 35
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = #1051#1080#1085#1080#1103':'
        ParentBiDiMode = False
      end
      object Label2: TLabel
        Left = 22
        Top = 54
        Width = 35
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = #1057#1077#1090#1082#1072':'
        ParentBiDiMode = False
      end
      object Label3: TLabel
        Left = 33
        Top = 81
        Width = 24
        Height = 13
        Alignment = taRightJustify
        BiDiMode = bdLeftToRight
        Caption = #1060#1086#1085':'
        ParentBiDiMode = False
      end
      object Edit3: TEdit
        Left = 67
        Top = 77
        Width = 57
        Height = 21
        TabOrder = 0
        Text = '#094093'
      end
      object Edit2: TEdit
        Left = 67
        Top = 50
        Width = 57
        Height = 21
        TabOrder = 1
        Text = '#094093'
      end
      object Edit1: TEdit
        Left = 67
        Top = 23
        Width = 57
        Height = 21
        TabOrder = 2
        Text = '#094093'
      end
      object Panel1: TPanel
        Left = 139
        Top = 23
        Width = 49
        Height = 21
        BevelOuter = bvLowered
        Caption = 'Panel1'
        Color = clLime
        ParentBackground = False
        TabOrder = 3
      end
      object Panel2: TPanel
        Left = 139
        Top = 50
        Width = 49
        Height = 21
        BevelOuter = bvLowered
        Caption = 'Panel2'
        Color = clYellow
        ParentBackground = False
        TabOrder = 4
      end
      object Panel3: TPanel
        Left = 139
        Top = 77
        Width = 49
        Height = 21
        BevelOuter = bvLowered
        Caption = 'Panel3'
        Color = clGray
        ParentBackground = False
        TabOrder = 5
      end
    end
    object Button1: TButton
      Left = 190
      Top = 24
      Width = 75
      Height = 25
      Caption = #1057#1073#1088#1086#1089
      TabOrder = 3
    end
  end
  object CheckBox2: TCheckBox
    Left = 312
    Top = 61
    Width = 151
    Height = 17
    Caption = #1054#1090#1086#1073#1088#1072#1078#1072#1090#1100' '#1089#1077#1090#1082#1091
    TabOrder = 2
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 208
    Width = 455
    Height = 215
    Caption = #1058#1077#1084#1099
    TabOrder = 3
    object ListBox1: TListBox
      Left = 296
      Top = 16
      Width = 145
      Height = 185
      ItemHeight = 13
      TabOrder = 0
    end
    object Button2: TButton
      Left = 48
      Top = 33
      Width = 113
      Height = 25
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100
      TabOrder = 1
    end
    object Button3: TButton
      Left = 48
      Top = 64
      Width = 113
      Height = 25
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 2
    end
    object Button4: TButton
      Left = 48
      Top = 95
      Width = 113
      Height = 25
      Caption = #1059#1076#1072#1083#1080#1090#1100
      TabOrder = 3
    end
    object CheckBox3: TCheckBox
      Left = 16
      Top = 182
      Width = 196
      Height = 17
      Caption = #1055#1088#1080#1074#1103#1079#1072#1090#1100' '#1082' '#1072#1082#1090#1080#1074#1085#1086#1084#1091' '#1089#1082#1080#1085#1091
      TabOrder = 4
    end
  end
  object ColorDialog1: TColorDialog
    Options = [cdFullOpen]
    Left = 336
    Top = 117
  end
end
