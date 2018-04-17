unit frmRun;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, mdl_dsg, ExtCtrls;

type
  TfrmRunTime = class(TForm)
    imgDrawField: TImage;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
  public
    Images : Array [1..MAX_COUNT_ISPOLNS] Of TImage;
  end;

var
  frmRunTime: TfrmRunTime;
implementation

uses frmFile;
{$R *.DFM}

procedure TfrmRunTime.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  frmFileMenu.N15Click(Self);
end;

procedure TfrmRunTime.FormShow(Sender: TObject);
var
  FormRect : TRect;
begin
  imgDrawField.Canvas.Brush.Color := clBtnFace;
  FormRect.Left   := 0;
  FormRect.Top    := 0;
  FormRect.Right  := frmRunTime.Width;
  FormRect.Bottom := frmRunTime.Height;
  imgDrawField.Canvas.FillRect(FormRect);

  //ShowMessage(Format('Form : Width = %d, Height = %d', [frmRunTime.Width, frmRunTime.Height]));
  //ShowMessage(Format('Image : ClWidth = %d, ClHeight = %d', [imgDrawField.Width, imgDrawField.Height]));
end;

procedure TfrmRunTime.FormResize(Sender: TObject);
begin
  //ShowMessage('FormResize()'); 
  //imgDrawField.Height := frmRunTime.ClientHeight;
  //imgDrawField.Height := frmRunTime.ClientWidth;
end;

end.
