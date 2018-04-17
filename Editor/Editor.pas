unit Editor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, checklst, ExtCtrls, ShellApi, RichEdit;
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
    CurKeyWords : Byte;
    ListKeyWord : array[0..100] of String[100];
  end;

  TfrmEditor = class(TForm)
    Status: TStatusBar;
    rtbEdit: TRichEdit;
    rtbTemp: TRichEdit;
    procedure rtbEditKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rtbEditKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rtbEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure rtbEditChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public
    EditorOptions : TOptions;
    Procedure Must_Die_Editor;
  end;

  procedure ProcessText;
  procedure SelectWord(sWord : string; CurPos : LongInt);
  function CaseWordType(sWord : string) : Integer;
  function IsKeyword(sWord : string) : Boolean;
  function GetNextWord(sStr : string; var CurPos : Longint) : string;
  procedure SkipSpace(sStr : string;  var CurPos : LongInt);
  function BreakSymbol(cSymbol : Char) : Boolean;

var
  frmEditor: TfrmEditor;
  Struct   : String;
  CharPos  : TPoint;
  fProcessText : Boolean;
implementation

uses Options, mdl_dsg, frmUser;


{$R *.DFM}
{ ------------------------------------------------------------------- }
{ Нормальный ли символ ? }
function BreakSymbol(cSymbol : Char) : Boolean;
begin
  if cSymbol in [#9,' ',#13,#10] then
    BreakSymbol := True
  else
    BreakSymbol := False;
end;

{ Пропускает пробелы }
procedure SkipSpace(sStr : string;  var CurPos : LongInt);
begin
  if CurPos >= Length(sStr) then Exit;
  while BreakSymbol(sStr[CurPos]) do
  begin
    If (CurPos >= Length(sStr)) then
      Exit;
    Inc(CurPos);
  end; {while}
end;

{ Возвращает следующее слово после CurPos }
function GetNextWord(sStr : string; var CurPos : Longint) : string;
var
  sTemp : string;
begin
  SkipSpace(sStr, CurPos);
  if Length(sStr) > Length(Struct) then
  begin
    if Copy(sStr, CurPos, Length(Struct)) = Struct then
    begin
      CurPos := CurPos + Length(Struct);
      sTemp := Struct + sTemp;
      if CurPos > Length(sStr) then
      begin
        GetNextWord := sTemp;
        Exit;
      end;
    end;
  end;

  while not BreakSymbol(sStr[CurPos]) do
  begin
    sTemp  := sTemp + sStr[CurPos];
    Inc(CurPos);
    if CurPos > Length(sStr) then
    begin
      GetNextWord := sTemp;
      Break;
    end;
  end; {while}
GetNextWord := sTemp;
end;

{ Ключевое ли это слово ? }
function IsKeyword(sWord : string) : Boolean;
var
  i : Integer;
begin
  IsKeyword := False;
  sWord := AnsiLowerCase(sWord);

  for i := 0 To frmEditor.EditorOptions.CurKeyWords do
    if frmEditor.EditorOptions.ListKeyWord[i] = sWord then
    begin
      IsKeyword := True;
      Exit;
    end; {if}
End;

{ Возвращает тип слова }
function CaseWordType(sWord : string) : Integer;
begin
  case sWord[1] of
    #39       : Result := 0;
    '0'..'9'  : Result := 1;
    '.'       : Result := 2;
  else
    if IsKeyword(sWord) then
      Result := 3
    else
      Result := 4;
  end; {case}
end;

{ Выделяет слово в rtbTemp }
procedure SelectWord(sWord : string; CurPos : LongInt);
begin
  frmEditor.rtbTemp.SelStart := CurPos - Length(sWord) - 1;
  frmEditor.rtbTemp.SelLength := Length(sWord);

  // 1 - Цифра
  // 2 - Логическая константа
  // 3 - Ключевое слово
  // 4 - Идентификатор

  case CaseWordType(sWord) of
    0 : frmEditor.rtbTemp.SelAttributes.Color := frmEditor.EditorOptions.Str;
    1 : frmEditor.rtbTemp.SelAttributes.Color := frmEditor.EditorOptions.Number;
    2 : frmEditor.rtbTemp.SelAttributes.Color := frmEditor.EditorOptions.BoolValue;
    3 : frmEditor.rtbTemp.SelAttributes.Color := frmEditor.EditorOptions.KeyWord;
    4 : frmEditor.rtbTemp.SelAttributes.Color := frmEditor.EditorOptions.NormalText;
  end;
end;

{ Разбор и обработка текста }
procedure ProcessText;
var
  CurPos, TextCur : Longint;
  sWord    : string;
  sText    : string;
begin
  If Not fProcessText then 
    Exit;
  
  frmEditor.rtbTemp.Text := frmEditor.rtbEdit.Text;
  sText := frmEditor.rtbEdit.Text;
  TextCur    := frmEditor.rtbEdit.SelStart;
  CurPos     := 1;

  { Теперь все выделения делаем в rtbTemp }
  while CurPos < Length(sText) do
  begin
    sWord := GetNextWord(sText, CurPos);
    If sWord <> '' Then  SelectWord(sWord, CurPos);
  end;
  frmEditor.rtbTemp.Lines.SaveToFile('editcode.$$$');
  frmEditor.rtbEdit.Lines.LoadFromFile('editcode.$$$');
  frmEditor.rtbEdit.SelStart := TextCur;
end;

{ ------------------------------------------------------------------ }
{ Начальная инициализация редактора }
procedure Init;
var
  F : File of TOptions;
begin
  fProcessText := True;
  AssignFile(F,'ini/editor.ini');
  Reset(F);
  Read(F,frmEditor.EditorOptions);
  CloseFile(f);
  frmEditor.rtbEdit.Color:=frmEditor.EditorOptions.BGColor;
  Struct := #39; 
end;
{ ------------------------------------------------------------------ }

procedure TfrmEditor.rtbEditKeyPress(Sender: TObject; var Key: Char);
begin
  // Если нажали Enter
  if Key = #13 then
    ProcessText;
end;

procedure TfrmEditor.FormCreate(Sender: TObject);
begin
   { Инициализируем редактор }
   Init;
   rtbEdit.Lines.Add('Проц Старт()');
   rtbEdit.Lines.Add('  ');
   rtbEdit.Lines.Add('Кон проц ');
   rtbEdit.SelStart := 16;
   ProcessText;
end;

Procedure tfrmEditor.Must_Die_Editor;
var
  F : File of TOptions;
begin
  AssignFile(F,'ini\editor.ini');
  ReWrite(F);
  Write(F,frmEditor.EditorOptions);
  CloseFile(F);
  //DeleteFile('editcode.$$$');
end;
  
procedure TfrmEditor.FormClose(Sender: TObject; var Action: TCloseAction);
var
  F : File of TOptions;
begin
  AssignFile(F,'ini\editor.ini');
  ReWrite(F);
  Write(F,frmEditor.EditorOptions);
  CloseFile(F);
  //DeleteFile('editcode.$$$');
end;

procedure TfrmEditor.rtbEditKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If (ssShift in Shift) And (Key = VK_INSERT) then
    ProcessText;
end;

procedure TfrmEditor.rtbEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  rtbEdit.SelAttributes.Color:=frmEditor.EditorOptions.NormalText;
end;

procedure TfrmEditor.rtbEditChange(Sender: TObject);
begin
  CharPos.Y := SendMessage(rtbEdit.Handle, EM_EXLINEFROMCHAR, 0,
    rtbEdit.SelStart);
  CharPos.X := (rtbEdit.SelStart -
    SendMessage(rtbEdit.Handle, EM_LINEINDEX, CharPos.Y, 0));
  Inc(CharPos.Y);
  Inc(CharPos.X);
  Status.Panels[0].Text := Format('Line: %3d   Col: %3d', [CharPos.Y, CharPos.X]);
end;

procedure TfrmEditor.FormShow(Sender: TObject);
begin
  ProcessText;
end;

end.
