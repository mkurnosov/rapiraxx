program Project1;

uses
  Forms,
  Editor in 'Editor.pas' {frmEditor},
  Options in 'Options.pas' {frmOptions};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmEditor, frmEditor);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.Run;
end.
