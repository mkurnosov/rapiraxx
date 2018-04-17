unit frmOut;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmCon = class(TForm)
    lstOut: TListBox;
  private
    { Private declarations }
  public
    procedure PrintMessage(sMsg : String);
  end;

var
  frmCon: TfrmCon;

implementation
{$R *.DFM}

procedure tfrmCon.PrintMessage(sMsg : String);
begin
  lstOut.Items.Add(sMsg);
end;

end.
