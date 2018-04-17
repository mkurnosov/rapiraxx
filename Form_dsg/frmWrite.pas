unit frmWrite;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Explr, Krnl, GlbFun;

type
  TfrmWriteProc = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmWriteProc: TfrmWriteProc;

implementation

uses Editor;

{$R *.DFM}

procedure TfrmWriteProc.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Button1Click(Self);
end;

procedure TfrmWriteProc.Button1Click(Sender: TObject);
var
  i : Word;
  k : Integer;
  tmpStr : String;
begin
  k := 0;
  { Если память под указатель на массив фун еще не выделяли }
  If (Not AllocMemFun) then
  Begin
    AllocMemFun := True;
    New(Functions);
  End;

  frmEditor.rtbEdit.Lines.Add('');
  frmEditor.rtbEdit.Lines.Add('Проц ' + sProcName + '()');
  If Memo1.Lines.Count > 0 then
    For i := 0 to Memo1.Lines.Count - 1 do
      frmEditor.rtbEdit.Lines.Add('  ' + Memo1.Lines[i]);
  frmEditor.rtbEdit.Lines.Add('Кон Проц');

  Inc(CountFunctions);
  New(Functions^[CountFunctions]);

  Functions^[CountFunctions]^.Name := sProcName;

  Functions^[CountFunctions]^.Fun  := False;

  { Инициализируем т.к по умолчянию занчение = ??? }
  Functions^[CountFunctions]^.CountArgs := 0;

  Functions^[CountFunctions]^.StartLine := CountLines + 1;

  New(SourceCode[CountLines + 1]);
  SourceCode[CountLines + 1]^ := 'проц ' + sProcName + '()';

  If Memo1.Lines.Count > 0 then
    for i := 0 to Memo1.Lines.Count - 1 do
    begin
      tmpStr := Memo1.Lines[i];

      GlbFun.EraseBlank(@tmpStr);
      GlbFun.K_LowerCase(@tmpStr);

      { Если строка не пуста и не коментарий, то добавляем её }
      If (Length(tmpStr) <> 0) And (tmpStr <> ' ') And
         (Copy(tmpStr,1,2) <> '//') then
      Begin
        New(SourceCode[CountLines + 2 + k]);
        SourceCode[CountLines + 2 + k]^ := tmpStr;
        Inc(k);
      End;
    end;
  New(SourceCode[CountLines + k + 2]);
  SourceCode[CountLines + k + 2]^ := 'кон проц';
  CountLines := CountLines + k + 2;


  fWriteingProc := False;
  Hide;
  Explr.ShowProc;
end;

procedure TfrmWriteProc.FormShow(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

procedure TfrmWriteProc.FormHide(Sender: TObject);
begin
  Memo1.Lines.Clear;
end;

end.
