object frmLibView: TfrmLibView
  Left = 97
  Top = 103
  Width = 777
  Height = 493
  Caption = 'Информация о импортированных функциях'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object lstFun: TListBox
    Left = 10
    Top = 10
    Width = 316
    Height = 405
    ItemHeight = 16
    TabOrder = 0
    OnClick = lstFunClick
  end
  object grbFun: TGroupBox
    Left = 335
    Top = 10
    Width = 424
    Height = 237
    TabOrder = 1
    object memoFun: TMemo
      Left = 10
      Top = 20
      Width = 405
      Height = 208
      BorderStyle = bsNone
      Color = clSilver
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
    end
  end
  object Button1: TButton
    Left = 650
    Top = 423
    Width = 112
    Height = 31
    Caption = '&Закрыть'
    TabOrder = 2
    OnClick = Button1Click
  end
  object GroupBox1: TGroupBox
    Left = 335
    Top = 256
    Width = 424
    Height = 159
    Caption = 'Общяя информация :'
    TabOrder = 3
    object memoTotal: TMemo
      Left = 10
      Top = 30
      Width = 405
      Height = 109
      BorderStyle = bsNone
      Color = clSilver
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
    end
  end
end
