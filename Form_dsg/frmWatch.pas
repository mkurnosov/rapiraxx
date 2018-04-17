unit frmWatch;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Krnl, Types, frmFile;

type
  TfrmWatches = class(TForm)
    lstWatches: TListBox;
    Button1: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
  public
  end;

  { Обнавляет значение выражений }
  Procedure RefreshWatches;

  //TWatch = Record
    { Если не 0, то это поле объекта }
  //  wObject : Word;
    { Индекс переменной или поля }
  //  wVar : Word;
  //End;

var
  frmWatches: TfrmWatches;

  Watches : Array [1..50] Of String;
  CountWatches : Word;
  fAddingWatch : Boolean;
  
implementation

uses frmMsg;
{$R *.DFM}

Procedure RefreshWatches;
Var
  i    : Word;
  sBuf : String;
  fBuf  : Boolean; 
  tmpAX : TResult;
  tmpBX : TResult;
  tmpCurLine : Word;
  tmpCurCh   : Word;
Begin
  // Вычисляю выражение и добаляю его в lstWatches 
  // Сохраняю fExec и регистры
  // WorkExpression()
  // Востанавливаю fExec и регистры
  // Строку подставляем последнюю, т.к её генерим. сами
  
  frmWatches.lstWatches.Clear;
  sBuf := '';

  For i := 1 to CountWatches do
  Begin
    fBuf       := fExec;
    tmpAX      := AX;
    tmpBX      := BX;
    fExec      := True;
    tmpCurLine := CurLine;
    tmpCurCh   := CurCh; 
    
    CurLine := CountLines + 1;
    CurCh   := 1;
    New(SourceCode[CurLine]);
    SourceCode[CurLine]^ := Watches[i];

    fAddingWatch := True;
    
    WorkExpression;

    fAddingWatch := False;
    
    Case AX.selType Of
      1 : sBuf := #39 + AX.Str + #39;
      2 : sBuf := IntToStr(AX.Int);
      3 : If AX.Bool then
            sBuf := 'ИСТИНА'
          Else
            sBuf := 'ЛОЖЬ';
    End;
    sBuf := Watches[i] + ' : ' + sBuf;
    frmWatches.lstWatches.Items.Add(sBuf);

    Dispose(SourceCode[CurLine]);
    fExec   := fBuf;
    AX      := tmpAX;
    BX      := tmpBX;
    CurLine := tmpCurLine;
    CurCh   := tmpCurCh; 

  End;
End;

Procedure AddWatch;
Var
  sExpr : String;
Begin
  If Not fDebugMode then
  Begin
    frmMessage.ShowMsg('Режим отладки закончен.');
    Exit;
  End;
  
  sExpr := InputBox('Добавление', 'Выражение :', '');
  sExpr := AnsiLowerCase(Trim(sExpr));
  If sExpr = '' then
    Exit;
  
  Inc(CountWatches);
  Watches[CountWatches] := sExpr;
     
  RefreshWatches;
End;

procedure TfrmWatches.Button1Click(Sender: TObject);
begin
  AddWatch;
end;

procedure TfrmWatches.Button3Click(Sender: TObject);
Var
  i : Word;
begin
  If (Not Assigned(lstWatches.Items)) Or (lstWatches.ItemIndex < 0) then
    Exit;

  For i := lstWatches.ItemIndex + 1 To lstWatches.Items.Count - 1 do
    Watches[i] := Watches[i + 1];

  Dec(CountWatches);
  lstWatches.Items.Delete(lstWatches.ItemIndex);
  
  RefreshWatches;
end;

end.
