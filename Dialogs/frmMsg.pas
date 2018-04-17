unit frmMsg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TfrmMessage = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Image1: TImage;
    Button1: TButton;
    Msg: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
  public
    Procedure ShowMsg(const sMsg : String);
  end;

var
  frmMessage: TfrmMessage;
  Res : Word;
implementation

{$R *.DFM}

Procedure tfrmMessage.ShowMsg(const sMsg : String);
Begin
  Msg.Text := sMsg;
  Res := ShowModal;
End;

procedure TfrmMessage.Button1Click(Sender: TObject);
begin
  frmMessage.ModalResult := 2;
  Close;
end;

procedure TfrmMessage.FormShow(Sender: TObject);
begin
  Button1.SetFocus;  
end;

procedure TfrmMessage.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  ModalResult := 2;
end;

end.
