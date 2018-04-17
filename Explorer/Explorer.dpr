program Explorer;

uses
  Forms,
  Explr in 'explr.pas' {frmExplorer};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmExplorer, frmExplorer);
  Application.Run;
end.
