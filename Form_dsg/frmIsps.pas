unit frmIsps;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls, StdCtrls;

type
  TfrmIspolns = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    sbPtr: TSpeedButton;
    Button1: TButton;
    procedure sbPtrClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure _OnClick(Sender: TObject);
  end;

var
  frmIspolns: TfrmIspolns;

implementation

uses mdl_dsg, frmUser, frmFile, LibManager;
{$R *.DFM}

procedure TfrmIspolns.sbPtrClick(Sender: TObject);
begin
  fSelectIspoln := False;
  wSelectIspoln := 0;
end;

Procedure tfrmIspolns._OnClick(Sender: TObject);
var
  tmpBtn : TSpeedButton;
Begin
  fSelectIspoln := True;
  tmpBtn := TSpeedButton(Sender);
  wSelectIspoln := tmpBtn.Tag;
End;

procedure TfrmIspolns.FormCreate(Sender: TObject);
begin
  LoadBaseIspolns;
  LoadLibraries('options/lib.lst');
end;


procedure TfrmIspolns.Button1Click(Sender: TObject);
begin
  If MessageBox(frmIspolns.Handle,'Вы действительно хотите редактировать файл ?',
  'Редактирование файла исполнителей', MB_YESNO) = IDNO then
    Exit;

  If sProjectFile = '' then
    Case MessageBox(frmIspolns.Handle, PChar('Сохранить изменения в проекте'), 'Конструктор Исполнителей', MB_YESNO) Of
      IDYES : frmFileMenu.N8Click(frmUserForm);
    End
  Else
    Case MessageBox(frmIspolns.Handle, PChar('Сохранить изменения в ' + sProjectFile), 'Конструктор Исполнителей', MB_YESNO) Of
      IDYES : SaveProject(sProjectFile);
    End;
  ExecProgram('EXPLORER.exe');
  ShutdownConstr;
end;

end.
