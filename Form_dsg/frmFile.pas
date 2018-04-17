unit frmFile;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ToolWin, ComCtrls, Menus, Buttons, frmUser, mdl_dsg, ExtCtrls, frmRun;

type
  TfrmFileMenu = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    ToolBar1: TToolBar;
    SpeedButton1: TSpeedButton;
    sbNew: TSpeedButton;
    sbOpen: TSpeedButton;
    sbSave: TSpeedButton;
    SpeedButton5: TSpeedButton;
    sbRun: TSpeedButton;
    sbStop: TSpeedButton;
    SpeedButton8: TSpeedButton;
    sbHelp: TSpeedButton;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    OpenDlg: TOpenDialog;
    SaveDlg: TSaveDialog;
    N21: TMenuItem;
    Researcher1: TMenuItem;
    N22: TMenuItem;
    N23: TMenuItem;
    N24: TMenuItem;
    N25: TMenuItem;
    N26: TMenuItem;
    procedure N16Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N19Click(Sender: TObject);
    procedure N12Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure sbHelpClick(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N20Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure sbNewClick(Sender: TObject);
    procedure sbOpenClick(Sender: TObject);
    procedure sbSaveClick(Sender: TObject);
    procedure sbRunClick(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure sbStopClick(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure Researcher1Click(Sender: TObject);
    procedure N24Click(Sender: TObject);
    procedure N23Click(Sender: TObject);
    procedure N25Click(Sender: TObject);
    procedure N26Click(Sender: TObject);
    procedure FUCK1Click(Sender: TObject);
  private
    { Обработчик сообщения - изменен коорд. и размеров окна }
    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
  public
    { Public declarations }
  end;

  Function  FindIspField(wIsp : Word; sField : String) : Word;
  Procedure SaveProject(sFileName : String);
  procedure ExecProgram(sPath :  String);

var
  frmFileMenu: TfrmFileMenu;
  iMinWidth   : Integer;
  iMinHeight  : Integer;
  iMaxWidth   : Integer;
  iMaxHeight  : Integer;

  fRunMode     : Boolean;
  fDebugMode   : Boolean;

  sProjectFile : String;
  FormsV : Array [1..4] of Boolean;

implementation

uses frmIsps, frmInspect, about, Editor, Options, frmMsg,
     Main, Explr, Krnl, ShellApi, frmOut, frmWrite, frmErr, Debug,
  frmCStack, frmWatch, LibView;

{$R *.DFM}
{ Обработчик сообщения - изменен коорд. и размеров окна }
procedure TfrmFileMenu.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
 inherited;
  with Msg.MinMaxInfo^ do
  begin
    with ptMinTrackSize do
    begin
      X := iMinWidth;
      Y := iMinHeight;
    end;  { with }

    with ptMaxTrackSize do
    begin
      X := iMaxWidth;
      Y := iMaxHeight;
    end;  { with }
  end;  { with }
end;

Function SaveChanges : Integer;
Begin
  // 1 - YES,
  // 2 - NO
  // 3 - CANCEL
  Result := 1;

  If sProjectFile = '' then
    Case MessageDlg('Сохранить изменения в проекте ?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) Of
      mrYes    : frmFileMenu.N8Click(frmUserForm);   ////.///////
      mrNo     : Result := 2;
      mrCancel : Result := 3;
    End
  Else
    Case MessageDlg('Сохранить изменения в ' + sProjectFile + ' ?', mtConfirmation, [mbYes, mbNo, mbCancel], 0) Of 
      mrYes    : SaveProject(sProjectFile);
      mrNo     : Result := 2;
      mrCancel : Result := 3;
    End
End;

Function FindIspField(wIsp : Word; sField : String) : Word;
Var
  i : Word;
Begin
  i := 1;
  While Ispolns[wIsp].Fields[i].Name <> sField do
    Inc(i);
  Result := i;
End;

Procedure LoadIspoln(IdxIsp : Word);
var
  i : Word;
Begin
    Ispolns[IdxIsp].Face := TImage.Create(frmUserForm);
    Ispolns[IdxIsp].Face.Parent := frmUserForm;

    i := FindIspField(IdxIsp, 'картинка');
    If Ispolns[IdxIsp].Fields[i].Str <> '' then
      Ispolns[IdxIsp].Face.Picture.LoadFromFile(Ispolns[IdxIsp].Fields[i].Str);

    Ispolns[IdxIsp].Face.Left := Ispolns[IdxIsp].Fields[
                                      FindIspField(IdxIsp, 'слева')].Int;

    Ispolns[IdxIsp].Face.Top := Ispolns[IdxIsp].Fields[
                                     FindIspField(IdxIsp, 'сверху')].Int;

    Ispolns[IdxIsp].Face.Width := Ispolns[IdxIsp].Fields[
                                      FindIspField(IdxIsp, 'ширина')].Int;

    Ispolns[IdxIsp].Face.Height := Ispolns[IdxIsp].Fields[
                                      FindIspField(IdxIsp, 'высота')].Int;

    Ispolns[IdxIsp].Face.BringToFront;
    Ispolns[IdxIsp].Face.OnMouseDown := frmUserForm.OnImageMouseDown;
    Ispolns[IdxIsp].Face.OnMouseMove := frmUserForm.OnMouseMove;
    Ispolns[IdxIsp].Face.OnMouseUp   := frmUserForm.OnMouseUp;
    Ispolns[IdxIsp].Face.Tag := IdxIsp;

    // Stretch - True
    Ispolns[IdxIsp].Face.Stretch := Ispolns[IdxIsp].Fields[
                                FindIspField(IdxIsp, 'растяжение')].Bool;
End;

Procedure SetPrjFile(sFileName : String);
Begin
  sProjectFile := sFileName;
  If sProjectFile <> '' then
    frmFileMenu.Caption := 'Конструктор Исполнителей [' + sProjectFile + ']'
  Else
    frmFileMenu.Caption := 'Конструктор Исполнителей';

End;

Procedure HideAll;
Begin
  frmEditor.Hide;
  frmInspector.Hide;
End;

Procedure CloseProject;
Var
  i : Word;
Begin
  SetPrjFile('');
  HideAll;
  frmUSerForm.HideSelection;
  fSelectIspoln := False;
  wSelectIspoln := 0;
  for i := 1 to CountBaseIspolns do
    UsedIspolns[i] := False;

  for i := 1 to CountIspolns do
  begin
    Ispolns[i].Face.Free;
  end;
  CountIspolns  := 0;

  frmEditor.rtbEdit.Clear;
  frmEditor.rtbEdit.Lines.Add('Проц Старт()');
  frmEditor.rtbEdit.Lines.Add('  ');
  frmEditor.rtbEdit.Lines.Add('Кон проц ');
  frmEditor.rtbEdit.SelStart := 16;
  ProcessText;
End;

Procedure OpenProject(sFileName, sDir : String);
Var
  F : TextFile;
  sFormF : String;
  sCodeF : String;
  Flag   : Byte;
  wBuf   : Integer;
  sBuf   : String;
  i, j   : Word;

  Function ReadData : Integer;
  begin
    Readln(F, wBuf);
    Result := wBuf;
  end;

Begin
  Try
  AssignFile(F, sFileName);
  Reset(F);
  Flag := 0;
  While Flag < 2 do
  begin
    If Not EOF(F) then
      Readln(F, sBuf);
    sBuf := TrimRight(TrimLeft(sBuf));
    If Length(sBuf) > 0 then
    Begin
      If sBuf[1] <> '#' then
        If Flag < 1 then
        Begin
          sCodeF := sBuf;
          Inc(Flag);
        End
        Else Begin
          sFormF := sBuf;
          Inc(Flag);
        End;
    End;
  End;
  CloseFile(F);

  frmEditor.rtbEdit.Lines.LoadFromFile(sCodeF);
  ProcessText;

  AssignFile(F, sFormF);
  Reset(F);

  frmUserForm.Show;
  frmUserForm.Left   := ReadData;
  frmUserForm.Top    := ReadData;
  frmUserForm.Width  := ReadData;
  frmUserForm.Height := ReadData;;

  CountIspolns := ReadData;
  If CountIspolns > 0 then
  Begin
    for i := 1 to CountIspolns do
    begin
      Readln(F, Ispolns[i].Name);
      Readln(F, Ispolns[i].BaseIsp);
      Readln(F, Ispolns[i].CountFields);
      Ispolns[i].Methods := BaseIspolns[Ispolns[i].BaseIsp].Methods;
      for j := 1 to Ispolns[i].CountFields do
      begin
        Readln(F, Ispolns[i].Fields[j].Name);
        Readln(F, Ispolns[i].Fields[j].selType);
        Case Ispolns[i].Fields[j].selType Of
          1 : Readln(F, Ispolns[i].Fields[j].Str);
          2 : Readln(F, Ispolns[i].Fields[j].Int);
          3 : Begin
                Readln(F, wBuf);
                Ispolns[i].Fields[j].Bool := (wBuf = 1);
              End;
        End;
      end;
    end;

    for i := 1 to CountIspolns do
    begin
     LoadIspoln(i);
    end;

    frmUserForm.SelObj(Ispolns[1].Face);
    frmInspector.RefreshProps;
    ChDir(sDir);
  End; {if}
  CloseFile(F);

  Except
    frmMessage.ShowMsg('Ошибка работы с файлом');
  End;
End;

Procedure SaveProject(sFileName : String);
Var
  FPrj  : TextFile;
  j,i  : Word;
  F : TextFile;
  s, sDir, sBuf  : String;

  procedure GetFileName(var sPath : String);
  var
    n : Word;
  begin
    n := Length(sPath);
    While (sPath[n] <> '\') And (sPath[n] <> '/') do
      If n - 1 > 0 then
        Dec(n)
      Else
        Break;
    sDir := Copy(sPath, 1, n - 1);
    If n > 1 then
      sPath := Copy(sPath, n + 1, Length(sPath) - n);
  end;

Begin
  SetPrjFile(sFileName);

  GetDir(0, sBuf);

  GetFileName(sFileName);
  ChDir(sDir);

  sFileName := Copy(sFileName, 1, Length(sFileName) - 4);
  frmEditor.rtbEdit.Lines.SaveToFile(sFileName + '.isp');

  AssignFile(FPrj, sFileName + '.prj');
  Rewrite(FPrj);
  Writeln(FPrj, sFileName + '.isp');
  Writeln(FPrj, sFileName + '.frm');
  CloseFile(FPrj);

  AssignFile(F, sFileName + '.frm');
  Rewrite(F);
  Writeln(F, frmUserForm.Left);
  Writeln(F, frmUserForm.Top);
  Writeln(F, frmUserForm.Width);
  Writeln(F, frmUserForm.Height);

  Writeln(F, CountIspolns);
  for i := 1 to CountIspolns do
  begin
    Writeln(F, Ispolns[i].Name);
    Writeln(F, Ispolns[i].BaseIsp);
    Writeln(F, Ispolns[i].CountFields);
    for j := 1 to Ispolns[i].CountFields do
    begin
      Writeln(F, Ispolns[i].Fields[j].Name);
      If Ispolns[i].Fields[j].Name = 'картинка' then
      begin
        s := Ispolns[i].Fields[j].Str;
        GetFileName(s);
        GetDir(0, sDir);
        CopyFile(PChar(sMainDir + '/' + Ispolns[i].Fields[j].Str), PChar(sDir + '\' + s), False);
        Ispolns[i].Fields[j].Str := sDir + '\' + s;
      end;
      Writeln(F, Ispolns[i].Fields[j].selType);
      Case Ispolns[i].Fields[j].selType Of
        1 : Writeln(F, Ispolns[i].Fields[j].Str);
        2 : Writeln(F, Ispolns[i].Fields[j].Int);
        3 : Begin
              If Ispolns[i].Fields[j].Bool then
                Writeln(F, '1')
              Else
                Writeln(F, '0');
            End;
      End;
    end;
  end;
  CloseFile(F);
  ChDir(sBuf);
End;

procedure TfrmFileMenu.N16Click(Sender: TObject);
begin
  If N2.Items[0].Checked then
    frmIspolns.Hide
  Else
    frmIspolns.Show;
end;

procedure TfrmFileMenu.N17Click(Sender: TObject);
begin
  If CountIspolns <> 0 then
    If N2.Items[1].Checked then
      frmInspector.Hide
    Else
      frmInspector.Show;
end;

procedure TfrmFileMenu.N19Click(Sender: TObject);
begin
  If N2.Items[3].Checked then
    frmUserForm.Hide
  Else
    frmUserForm.Show;
end;

procedure TfrmFileMenu.N12Click(Sender: TObject);
begin
  If SaveChanges <> 3 then
  begin
    frmEditor.Must_Die_Editor;
    ShutdownConstr;
  end;
end;

procedure TfrmFileMenu.FormCreate(Sender: TObject);
begin

  Left       := 0;
  Top        := 0;

  iMinWidth  := Width;
  iMaxWidth  := Screen.Width;

  iMinHeight := 96;
  iMaxHeight := 96;

  Width      := Screen.Width;
  Height     := Screen.Height;

end;

procedure TfrmFileMenu.N13Click(Sender: TObject);
begin
  AboutBox.Show;
end;

procedure TfrmFileMenu.sbHelpClick(Sender: TObject);
begin
  AboutBox.Show;
end;

procedure TfrmFileMenu.N18Click(Sender: TObject);
begin
  If N2.Items[2].Checked then
    frmEditor.Hide
  Else
    frmEditor.Show;
end;

procedure TfrmFileMenu.N2Click(Sender: TObject);
begin
  N2.Items[0].Checked := frmIspolns.Visible;
  If Not fRunMode then
    If (CountIspolns = 0) And (CountFunctions < 2)  then
      N2.Items[1].Enabled := False
    Else
      N2.Items[1].Enabled := True;

  N2.Items[1].Checked := frmInspector.Visible;
  N2.Items[2].Checked := frmEditor.Visible;
  N2.Items[3].Checked := frmUserForm.Visible;
  N2.Items[4].Checked := frmOptions.Visible;
  Researcher1.Checked := frmExplorer.Visible;
  N21.Checked := frmConsole.Visible;

  If Not fRunMode then
  Begin
    Researcher1.Enabled := False;
    N21.Enabled := False
  End
  Else Begin
    If CountISpolns > 0 then
      Researcher1.Enabled := True;
    N21.Enabled := True;
  End;
end;

procedure TfrmFileMenu.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  N12Click(Self);  
end;

procedure TfrmFileMenu.N20Click(Sender: TObject);
begin
  frmOptions.tmpEditorOptions.Str        := frmEditor.EditorOptions.Str;
  frmOptions.tmpEditorOptions.Keyword    := frmEditor.EditorOptions.Keyword;
  frmOptions.tmpEditorOptions.BoolValue  := frmEditor.EditorOptions.BoolValue;
  frmOptions.tmpEditorOptions.Rem        := frmEditor.EditorOptions.Rem;
  frmOptions.tmpEditorOptions.Number     := frmEditor.EditorOptions.Number;
  frmOptions.tmpEditorOptions.Error      := frmEditor.EditorOptions.Error;
  frmOptions.tmpEditorOptions.NormalText := frmEditor.EditorOptions.NormalText;
  frmOptions.ShowModal;
end;

procedure TfrmFileMenu.N6Click(Sender: TObject);
var
  CurDir : String;
begin
  If SaveChanges <> 3 then
  Begin
    GetDir(0, CurDir);
    If OpenDlg.Execute then
    begin
      If Not FileExists(OpenDlg.FileName) then
      begin
        frmMessage.ShowMsg('Файл не найден');
        Exit;
      end;

      CloseProject;
      //ChDir(CurDir);
      OpenProject(OpenDlg.FileName, CurDir);
      SetPrjFile(OpenDlg.FileName);
    end;
    ChDir(CurDir);
  End;
end;

procedure TfrmFileMenu.N5Click(Sender: TObject);
begin
  If SaveChanges <> 3 then
    CloseProject;
end;

procedure TfrmFileMenu.N10Click(Sender: TObject);
begin
  If SaveChanges <> 3 then
    CloseProject;
end;

procedure TfrmFileMenu.N8Click(Sender: TObject);
var
  CurDir : String;

  function ExtensionExist(sFName : String) : Boolean;
  var
    i : Word;
  begin
    i := Length(sFName);
    Result := False;
    While (sFName[i] <> '\') And (sFName[i] <> '/') do
    begin
      If sFName[i] = '.' then
      begin
        Result := True;
        Exit;
      end;
      If (i - 1) > 0 then
        Dec(i)
      Else
        Break;  
    end;
  end;

begin
  GetDir(0, CurDir);

  If SaveDlg.Execute then
  Begin
    If ExtensionExist(SaveDlg.FileName) then
      SaveProject(SaveDlg.FileName)
    Else
      SaveProject(SaveDlg.FileName + '.prj');
  End;
  ChDir(CurDir);
end;

procedure TfrmFileMenu.N7Click(Sender: TObject);
begin
  If sProjectFile <> '' then
    SaveProject(sProjectFile)
  Else
    N8Click(Self);      
end;

procedure TfrmFileMenu.sbNewClick(Sender: TObject);
begin
  N5Click(Self);
end;

procedure TfrmFileMenu.sbOpenClick(Sender: TObject);
begin
  N6Click(Self);
end;

procedure TfrmFileMenu.sbSaveClick(Sender: TObject);
begin
  N7Click(Self);
end;

procedure TfrmFileMenu.sbRunClick(Sender: TObject);
begin
  N14Click(Self);
end;

procedure TfrmFileMenu.N14Click(Sender: TObject);
var
  i : Word;
  FOut : TextFile;
begin
  { 1. Все используемые классы добовляем в код }
  { 2. Создаём новую форму }
  { 3. Грузим на неё исполнители }
  { 4. }
  fRunMode := True;

  FormsV[1] := AboutBox.Visible;
  FormsV[2] := frmEditor.Visible;
  FormsV[3] := frmInspector.Visible;
  FormsV[4] := frmIspolns.Visible;

  AboutBox.Hide;
  frmEditor.Hide;
  frmInspector.Hide;
  frmIspolns.Hide;

  sbStop.Enabled := True;
  sbNew.Enabled  := False;
  sbOpen.Enabled := False;
  sbSave.Enabled := False;
  sbRun.Enabled  := False;

  for i := 0 to 5 do
    N1.Items[i].Enabled := False;

  for i := 0 to 4 do
    N2.Items[i].Enabled := False;

  N3.Items[0].Enabled := False;
  N3.Items[1].Enabled := True;
  N3.Items[2].Enabled := False;

{ --------------------------------------------------------------------- }
  frmRunTime.Left      := frmUserForm.Left;
  frmRunTime.Top       := frmUserForm.Top;
  frmRunTime.Width     := frmUserForm.Width;
  frmRunTime.Height    := frmUserForm.Height;
  frmRunTime.Caption   := frmUserForm.Caption;

  for i := 1 to CountIspolns do
  begin
    frmRunTime.Images[i]         := TImage.Create(frmRunTime);
    frmRunTime.Images[i].Parent  := frmRunTime;
    frmRunTime.Images[i].Left    := Ispolns[i].Face.Left;
    frmRunTime.Images[i].Top     := Ispolns[i].Face.Top;
    frmRunTime.Images[i].Width   := Ispolns[i].Face.Width;
    frmRunTime.Images[i].Height  := Ispolns[i].Face.Height;
    frmRunTime.Images[i].Picture := Ispolns[i].Face.Picture;
    frmRunTime.Images[i].Stretch := Ispolns[i].Face.Stretch;
    frmRunTime.Images[i].Visible := Ispolns[i].Fields[
                                    FindIspField(i, 'видимость')].Bool;

    frmRunTime.Images[i].BringToFront;
  end;
  frmUserForm.Hide;

  { Создаем временный файл }
  AssignFile(FOut, 'temp.$$$');
  Rewrite(FOut);

  Write(FOut, frmEditor.rtbEdit.Text);

  for i := 1 to CountIspolns do
  begin
    Writeln(FOut, 'объект ', Ispolns[i].Name, ' = ', BaseIspolns[Ispolns[i].BaseIsp].Name);
  end;

  CloseFile(FOut);
  frmRunTime.Show;
  frmConsole.Run('temp.$$$');
end;

procedure TfrmFileMenu.sbStopClick(Sender: TObject);
begin
  N15Click(Self);
end;

procedure TfrmFileMenu.N15Click(Sender: TObject);
var
  i : Word;
begin
  If fDebugMode And (Not F8_Pressed) then
  Begin
    frmMessage.ShowMsg('Закончите выполнение программы');
    Exit;
  End;

  frmDebug.Hide;

  fRunMode   := False;
  fDebugMode := False;

  N3.Items[1].Enabled := False;

  AboutBox.Visible     := FormsV[1];
  frmEditor.Visible    := FormsV[2];
  frmInspector.Visible := FormsV[3];
  frmIspolns.Visible   := FormsV[4];

  sbStop.Enabled := False;;
  sbNew.Enabled  := True;
  sbOpen.Enabled := True;
  sbSave.Enabled := True;
  sbRun.Enabled  := True;

  for i := 0 to 5 do
    N1.Items[i].Enabled := True;

  for i := 0 to 4 do
    N2.Items[i].Enabled := True;

  N3.Items[0].Enabled := True;
  N3.Items[2].Enabled := True;

{ --------------------------------------------------------------------- }
  frmCallStack.Hide;
  frmWatches.Hide;
  
  frmCon.Hide;
  frmRunTime.Hide;
  for i := 1 to CountIspolns do
    frmRunTime.Images[i].Free;

  frmExplorer.Hide;

  If Not EmergencyTermination then 
    Done;

  fWriteingProc := False;
  frmWriteProc.Hide;
  
  frmUserForm.Show;
end;

procedure TfrmFileMenu.N21Click(Sender: TObject);
begin
  If N21.Checked then
    frmConsole.Hide
  Else
    frmConsole.Show;
end;

procedure TfrmFileMenu.Researcher1Click(Sender: TObject);
begin
  If Researcher1.Checked then
    frmExplorer.Hide
  Else
    frmExplorer.Show;
end;

procedure ExecProgram(sPath :  String);
var
  sDir : String;
begin
  GetDir(0, sDir);
  ShellExecute(frmFileMenu.Handle, 'open', PChar(sPath),'','', SW_SHOWNORMAL);
  ChDir(sDir);
end;


procedure TfrmFileMenu.N24Click(Sender: TObject);
begin
  ExecProgram('explorer');
end;

procedure TfrmFileMenu.N23Click(Sender: TObject);
begin
  ExecProgram('tasprj');
end;

procedure TfrmFileMenu.N25Click(Sender: TObject);
begin
  fDebugMode := True;
  N14Click(Self);
end;

procedure TfrmFileMenu.N26Click(Sender: TObject);
begin
    frmLibView.Show;
end;

procedure TfrmFileMenu.FUCK1Click(Sender: TObject);
var
    x : boolean;
begin
    x := OpenDlg.Execute;
    //SaveDlg.Execute;
    if x then
        ShowMessage('good exec')
    else
        ShowMessage('bad exec');

    ShutdownConstr;
end;

end.
