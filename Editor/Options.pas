unit Options;

interface

uses
 Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, checklst, ExtCtrls, Buttons, ColorGrd;
type
  TOptions = record
    Str        : TColor;
    Keyword    : TColor;
    BoolValue  : TColor;
    Rem        : TColor;
    Number     : TColor;
    Error      : TColor;
    BGColor    : TColor;
    NormalText : TColor;
  end;

  TfrmOptions = class(TForm)
    ListEditColor: TListBox;
    ColorGrid1: TColorGrid;
    TabControl1: TTabControl;
    ComboBox1: TComboBox;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Memo1: TMemo;
    Button3: TButton;
    Button4: TButton;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    OutText: TLabel;
    ComboBox2: TComboBox;
    Label2: TLabel;
    cbSel: TCheckBox;
    procedure ListEditColorClick(Sender: TObject);
    procedure ColorGrid1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BitBtn2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure GroupBox2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure BitBtn2Click(Sender: TObject);
    procedure ComboBox1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure cbSelClick(Sender: TObject);
    private
    public {home}
      tmpEditorOptions : TOptions;
    end;

Var
  iTypeBold     : Boolean;
  iTypeItalic   : Boolean;
  iTypeUnderLine: Boolean;

  frmOptions: TfrmOptions;
  F:textFile;
implementation

uses Editor;

{$R *.DFM}
function BGColor:TColor;
begin
  case frmOptions.ComboBox1.ItemIndex of
    0 : BGColor := clWhite;
    1 : BGColor := clBlue;
    2 : BGColor := clBlack;
    3 : BGCOlor := clAqua;
    else BGColor:= clMenu;
  end;
end;

function IndColor(SelColor:TColor):Byte;
begin
  case SelColor of
    clBlack  : IndColor:=0;
    clMaroon : IndColor:=1;
    clGreen  : IndColor:=2;
    clOlive  : IndColor:=3;
    clNavy   : IndColor:=4;
    clPurple : IndColor:=5;
    clTeal   : IndColor:=6;
    clGray   : IndColor:=7;
    clSilver : IndColor:=8;
    clRed    : IndColor:=9;
    clLime   : IndColor:=10;
    clYellow : IndColor:=11;
    clBlue   : IndColor:=12;
    clFuchsia: IndColor:=13;
    clAqua   : IndColor:=14;
  else IndColor:=0;
  end;
end;

procedure ReturnIndexColor;
begin
 case frmOptions.ListEditColor.ItemIndex of
   0: frmOptions.ColorGrid1.Foregroundindex:=IndColor(frmOptions.tmpEditorOptions.Str);
   1: frmOptions.ColorGrid1.Foregroundindex:=IndColor(frmOptions.tmpEditorOptions.Keyword);
   2: frmOptions.ColorGrid1.Foregroundindex:=IndColor(frmOptions.tmpEditorOptions.BoolValue);
   3: frmOptions.ColorGrid1.Foregroundindex:=IndColor(frmOptions.tmpEditorOptions.Rem);
   4: frmOptions.ColorGrid1.Foregroundindex:=IndColor(frmOptions.tmpEditorOptions.Number);
   5: frmOptions.ColorGrid1.Foregroundindex:=IndColor(frmOptions.tmpEditorOptions.Error);
   6: frmOptions.ColorGrid1.Foregroundindex:=IndColor(frmOptions.tmpEditorOptions.NormalText);
 end;
end;

function SelColor(Ind:byte):TColor;
begin
  case Ind of
    0:  SelColor:=clBlack;
    1:  SelColor:=clMaroon;
    2:  SelColor:=clGreen;
    3:  SelColor:=clOlive;
    4:  SelColor:=clNavy;
    5:  SelColor:=clPurple;
    6:  SelColor:=clTeal;
    7:  SelColor:=clGray;
    8:  SelColor:=clSilver;
    9:  SelColor:=clRed;
    10: SelColor:=clLime;
    11: SelColor:=clYellow;
    12: SelColor:=clBlue;
    13: SelColor:=clFuchsia;
    14: SelColor:=clAqua;
    else
     SelColor:=clWhite;
  end;
end;

procedure ShowColorPalette;
begin
 Case frmOptions.ListEditColor.itemIndex of
    0: frmOptions.OutText.Font.Color := frmOptions.tmpEditorOptions.Str;
    1: frmOptions.OutText.Font.Color := frmOptions.tmpEditorOptions.Keyword;
    2: frmOptions.OutText.Font.Color := frmOptions.tmpEditorOptions.BoolValue;
    3: frmOptions.OutText.Font.Color := frmOptions.tmpEditorOptions.Rem;
    4: frmOptions.OutText.Font.Color := frmOptions.tmpEditorOptions.Number;
    5: frmOptions.OutText.Font.Color := frmOptions.tmpEditorOptions.Error;
    6: frmOptions.OutText.Font.Color := frmOptions.tmpEditorOptions.NormalText;
 End;
end;

procedure TfrmOptions.ListEditColorClick(Sender: TObject);
begin
  ReturnIndexColor;
  ShowColorPalette;
end;

procedure TfrmOptions.ColorGrid1Click(Sender: TObject);
begin
  Case ListEditColor.itemIndex of
    0: tmpEditorOptions.Str       := SelColor(ColorGrid1.Foregroundindex);
    1: tmpEditorOptions.Keyword   := SelColor(ColorGrid1.Foregroundindex);
    2: tmpEditorOptions.BoolValue := SelColor(ColorGrid1.Foregroundindex);
    3: tmpEditorOptions.Rem       := SelColor(ColorGrid1.Foregroundindex);
    4: tmpEditorOptions.Number    := SelColor(ColorGrid1.Foregroundindex);
    5: tmpEditorOptions.Error     := SelColor(ColorGrid1.Foregroundindex);
    6: tmpEditorOptions.NormalText:= SelColor(ColorGrid1.Foregroundindex);
  end;
  ShowColorPalette;
end;

procedure TfrmOptions.Button1Click(Sender: TObject);
begin
  frmEditor.EditorOptions.Str        := tmpEditorOptions.Str;
  frmEditor.EditorOptions.Keyword    := tmpEditorOptions.Keyword;
  frmEditor.EditorOptions.BoolValue  := tmpEditorOptions.BoolValue;
  frmEditor.EditorOptions.Rem        := tmpEditorOptions.Rem;
  frmEditor.EditorOptions.Number     := tmpEditorOptions.Number;
  frmEditor.EditorOptions.Error      := tmpEditorOptions.Error;
  frmEditor.EditorOptions.NormalText := tmpEditorOptions.NormalText;

  {frmEditor.EditorOptions.KeyWord       := tmpEditorOptions.KeyWord;
  frmEditor.EditorOptions.NormalText    := tmpEditorOptions.NormalText;
  frmEditor.EditorOptions.Rem           := tmpEditorOptions.Rem;
  frmEditor.EditorOptions.Number        := tmpEditorOptions.Number;
  frmEditor.EditorOptions.Error         := tmpEditorOptions.Error;
  frmEditor.EditorOptions.Keyword := tmpEditorOptions.Identificator;}
  frmOptions.Hide;
  ProcessText;
end;

procedure TfrmOptions.BitBtn1Click(Sender: TObject);
var
  TextStyle : TFontStyles;
begin
  frmEditor.EditorOptions.Str        := tmpEditorOptions.Str;
  frmEditor.EditorOptions.Keyword    := tmpEditorOptions.Keyword;
  frmEditor.EditorOptions.BoolValue  := tmpEditorOptions.BoolValue;
  frmEditor.EditorOptions.Rem        := tmpEditorOptions.Rem;
  frmEditor.EditorOptions.Number     := tmpEditorOptions.Number;
  frmEditor.EditorOptions.Error      := tmpEditorOptions.Error;
  frmEditor.EditorOptions.NormalText := tmpEditorOptions.NormalText;
  frmEditor.EditorOptions.BGColor    := BGColor;

  frmEditor.rtbEdit.Color:=BGColor;
  frmEditor.rtbEdit.font.Name:=ComboBox2.Text;
  frmEditor.rtbTemp.font.Name:=ComboBox2.Text;
  TextStyle := [];
  if iTypeBold then
    TextStyle := TextStyle + [fsBold];

  if iTypeItalic then
    TextStyle := TextStyle + [fsItalic];

  if iTypeUnderline then
    TextStyle := TextStyle + [fsUnderline];

  frmEditor.rtbEdit.Font.Style := TextStyle;
  frmEditor.rtbTemp.Font.Style := TextStyle;
  ProcessText;
  frmOptions.Close;
end;

procedure TfrmOptions.BitBtn1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  BitBtn1.Font.Color:=clBlue;
  BitBtn2.Font.Color:=clBlack;
end;

procedure TfrmOptions.BitBtn2MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  BitBtn1.Font.Color:=clBlack;
  BitBtn2.Font.Color:=clBlue;
end;

procedure TfrmOptions.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  BitBtn1.Font.Color:=clBlack;
  BitBtn2.Font.Color:=clBlack;
end;

procedure TfrmOptions.GroupBox2MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  BitBtn1.Font.Color:=clBlack;
  BitBtn2.Font.Color:=clBlack;
end;

procedure TfrmOptions.BitBtn2Click(Sender: TObject);
begin
  frmOptions.Close;
end;

procedure TfrmOptions.ComboBox1Click(Sender: TObject);
begin
  OutText.Color:=BGColor;
end;

procedure TfrmOptions.Button3Click(Sender: TObject);
var       I : Byte;
    CurWord : Byte;
begin
CurWord:=Memo1.Lines.Count;
  frmEditor.EditorOptions.CurKeyWords:=CurWord;
   for I:=0 to CurWord do
   begin
     frmEditor.EditorOptions.ListKeyWord[I]:=AnsiLowerCase(Memo1.Lines.Strings[I]);
   end;
end;

procedure TfrmOptions.FormCreate(Sender: TObject);
var I:Integer;
begin
  for I := 0 to Screen.Fonts.Count - 1 do
    begin
    ComboBox2.Items.Add(Screen.Fonts[i]);
   end;
  for I:=0 to frmEditor.EditorOptions.CurKeyWords do
  begin
    Memo1.Lines.Strings[I]:=frmEditor.EditorOptions.ListKeyWord[I];
  end;
  ComboBox1.ItemIndex := 4;
  ComboBox2.ItemIndex := 0;
  ListEditColor.ItemIndex:=0;
end;

procedure TfrmOptions.CheckBox1Click(Sender: TObject);
begin
  iTypeBold := CheckBox1.Checked;
end;

procedure TfrmOptions.CheckBox2Click(Sender: TObject);
begin
  iTypeItalic := CheckBox2.Checked;
end;

procedure TfrmOptions.CheckBox3Click(Sender: TObject);
begin
  iTypeUnderLine := CheckBox3.Checked;
end;

procedure TfrmOptions.Button4Click(Sender: TObject);
var
  F : TextFile;
  sTemp : String;
  J:Byte;
begin
J:=0;
  AssignFile(F,'ini\keyword.ini');
  Reset(F);
  Memo1.Lines.Clear;
  while Not eof(F) do
    begin
      Readln(F, sTemp);
      frmEditor.EditorOptions.ListKeyWord[J] := AnsiLowerCase(sTemp);
      Memo1.Lines.Add(sTemp);
      Inc(J);
    end;
  frmEditor.EditorOptions.CurKeyWords:=J;
  CloseFile(F);
end;
procedure TfrmOptions.FormShow(Sender: TObject);
begin
  cbSel.Checked := fProcessText;
end;

procedure TfrmOptions.cbSelClick(Sender: TObject);
begin
  fProcessText := cbSel.Checked;
end;

end.
