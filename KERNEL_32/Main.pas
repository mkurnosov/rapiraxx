{***************************************}
{  Main File for KERNEL                 }
{  Written by Kurnosov M.               }        
{***************************************}

unit Main;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Menus;

type
  TfrmConsole = class(TForm)
    GroupBox1: TGroupBox;
    Label3: TLabel;
    lblTime: TLabel;
    Label4: TLabel;
    lblLines: TLabel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Run(sFileName : String);
  end;

  procedure Quit(sErr, sErrLine : String);

var
  frmConsole: TfrmConsole;

implementation

Uses GlbFun, Types, Krnl, Explr, frmErr, mdl_dsg, frmFile, Debug;
{$R *.DFM}

procedure Quit(sErr, sErrLine : String);
begin
  Try
    frmError.edtError.Text    := sErr;
    frmError.SourceLine.Text  := sErrLine;
    frmError.ShowModal;
  Except
    ShowMessage('Ошибка :' + #10#13 + sErr + #10#13 + #10#13 + sErrLine);   
    Halt;
  End;
end;

procedure TfrmConsole.FormCreate(Sender: TObject);
begin
  frmConsole.Caption := 'KERNEL_32 v' + VERSION;
end;

procedure TfrmConsole.Run(sFileName : String);
Var
  i : Word;
  lStart, LFinish : Longint;
Begin
  If sFileName <> '' then
  Begin
    { Засекаем время выполнения }
    lStart := GetCurrentTime;

    Krnl.Init;
    LoadFile(sFileName);

    If fDebugMode then
      DebugerInit;
      
    Parse;

    F8_Pressed := True;
    //fDebugMode := False;
    
    If EmergencyTermination then
    begin
      frmFileMenu.N15Click(Self);
      Exit;
   end;
    
    i := CountLines;

    lFinish := GetCurrentTime;
    lStart  := lFinish - lStart; { время работы в мкс }
    lblLines.Caption := IntToStr(i) + ' линий';
    lblTime.Caption  := IntToStr(lStart) + ' мс.';

    DeleteFile(PChar(sFileName));

    If (CountObjects <> 0) Or (CountFunctions > 1) then
      frmExplorer.ShowInfo;
  end;
End;

procedure TfrmConsole.Button1Click(Sender: TObject);
begin
  Hide;
end;

End.
