unit about;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls;

type
  TAboutBox = class(TForm)
    GroupBox1: TGroupBox;
    Image1: TImage;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Bevel2: TBevel;
    lblKernelVer: TLabel;
    Button1: TButton;
    procedure OKButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation

{$R *.DFM}
Uses Krnl;

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
  Hide;
end;

procedure TAboutBox.FormShow(Sender: TObject);
begin
  lblKernelVer.Caption := 'KERNEL_32   v' + Krnl.VERSION;
end;

end.

