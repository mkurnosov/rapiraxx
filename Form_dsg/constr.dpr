program constr;

uses
  Forms,
  frmIsps in 'frmIsps.pas' {frmIspolns},
  mdl_dsg in 'mdl_dsg.pas',
  frmFile in 'frmFile.pas' {frmFileMenu},
  Krnl in '..\KERNEL_32\Krnl.pas',
  GlbFun in '..\KERNEL_32\Glbfun.pas',
  Main in '..\KERNEL_32\Main.pas' {frmConsole},
  Explr in '..\Explorer\Explr.pas' {frmExplorer},
  Editor in '..\Editor\Editor.pas' {frmEditor},
  Options in '..\Editor\Options.pas' {frmOptions},
  frmErr in '..\Dialogs\frmErr.pas' {frmError},
  frmMsg in '..\Dialogs\frmMsg.pas' {frmMessage},
  Types in '..\KERNEL_32\Types.pas',
  frmInspect in 'frmInspect.pas' {frmInspector},
  frmUser in 'frmUser.pas' {frmUserForm},
  about in '..\Dialogs\about.pas' {AboutBox},
  frmRun in 'frmRun.pas' {frmRunTime},
  Debug in '..\Debugger\Debug.pas' {frmDebug},
  frmOut in 'frmOut.pas' {frmCon},
  frmWrite in 'frmWrite.pas' {frmWriteProc},
  frmPV in 'frmPV.pas' {frmProc},
  frmCStack in 'frmCStack.pas' {frmCallStack},
  frmWatch in 'frmWatch.pas' {frmWatches},
  LibManager in 'LibManager.pas',
  ConstrDLLSupport in 'ConstrDLLSupport.pas',
  LibView in 'LibView.pas' {frmLibView};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmUserForm, frmUserForm);
  Application.CreateForm(TfrmFileMenu, frmFileMenu);
  Application.CreateForm(TfrmRunTime, frmRunTime);
  Application.CreateForm(TfrmIspolns, frmIspolns);
  Application.CreateForm(TfrmConsole, frmConsole);
  Application.CreateForm(TfrmExplorer, frmExplorer);
  Application.CreateForm(TfrmEditor, frmEditor);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.CreateForm(TfrmError, frmError);
  Application.CreateForm(TfrmMessage, frmMessage);
  Application.CreateForm(TfrmInspector, frmInspector);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TfrmDebug, frmDebug);
  Application.CreateForm(TfrmCon, frmCon);
  Application.CreateForm(TfrmWriteProc, frmWriteProc);
  Application.CreateForm(TfrmProc, frmProc);
  Application.CreateForm(TfrmCallStack, frmCallStack);
  Application.CreateForm(TfrmWatches, frmWatches);
  Application.CreateForm(TfrmLibView, frmLibView);
  Application.Run;
end.
