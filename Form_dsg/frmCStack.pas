unit frmCStack;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmCallStack = class(TForm)
    lstCallStack: TListBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmCallStack: TfrmCallStack;

implementation

{$R *.DFM}

end.
