program Core;

uses
  Forms,
  Main in 'MAIN.PAS' {frmConsole},
  Glbfun in 'GLBFUN.PAS',
  Types in 'TYPES.PAS',
  Krnl in 'KRNL.PAS';

{$R *.RES}

begin
  Application.CreateForm(TfrmConsole, frmConsole);
  Application.Run;
end.
