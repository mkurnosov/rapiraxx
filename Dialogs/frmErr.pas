unit frmErr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, frmFile;

type
  TfrmError = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label2: TLabel;
    edtError: TEdit;
    Button1: TButton;
    SourceLine: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmError: TfrmError;

implementation

uses Krnl, frmUser;

{$R *.DFM}

procedure TfrmError.Button1Click(Sender: TObject);
begin
  //If sProjectFile = '' then
  //  Case MessageBox(frmError.Handle, PChar('Сохранить изменения в проекте'), 'Конструктор Исполнителей', MB_YESNO) Of
  //    IDYES : frmFileMenu.N8Click(frmUserForm);
  //  End
  //Else
  //  Case MessageBox(frmError.Handle, PChar('Сохранить изменения в ' + sProjectFile), 'Конструктор Исполнителей', MB_YESNO) Of
  //    IDYES : SaveProject(sProjectFile);
  //  End;
  //Application.Terminate;
  ModalResult := 2;
  Hide;
end;

procedure TfrmError.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  ModalResult := 2;
end;

end.
