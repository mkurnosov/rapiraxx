unit Debug;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons;

type
  TfrmDebug = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    lstSourceCode: TListBox;
    sbCallStack: TSpeedButton;
    sbExecEnd: TSpeedButton;
    sbStepOver: TSpeedButton;
    Label1: TLabel;
    lblNumLine: TLabel;
    sbWatches: TSpeedButton;
    sbBreakPoint: TSpeedButton;
    procedure sbStepOverClick(Sender: TObject);
    procedure sbExecEndClick(Sender: TObject);
    procedure sbCallStackClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure sbWatchesClick(Sender: TObject);
    procedure lstSourceCodeDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure sbBreakPointClick(Sender: TObject);
  private
    // Будет обрабатывать пресс. по F8
    procedure WMKeyDown(var Msg: TMsg; var Handled: Boolean);
  public
  end;

  function BreakPoint(Index : Word) : Word;
  procedure DebugerInit;
  procedure MoveItemIndex;

var
  frmDebug: TfrmDebug;
  F8_Pressed : Boolean;
  fRunToEnd  : Boolean;
  
  BreakPoints : Array [1..50] Of Word;
  CountBreaks : Word;

implementation
{$R *.DFM}
uses Krnl, frmFile, frmCStack, frmWatch, frmMsg;

function BreakPoint(Index : Word) : Word;
var
  i : Word;
begin
  Result := 0;
  for i := 1 to CountBreaks do
    if BreakPoints[i] = Index then
    begin
      Result := i;
      Exit;
    end;      
end;

procedure TfrmDebug.WMKeyDown(var Msg: TMsg; var Handled: Boolean);
begin
  Handled := False;

  If Not fDebugMode then
    Exit;

  If (Msg.Message = WM_KEYDOWN) And (Msg.wParam = VK_F8) then
  Begin
    F8_Pressed := True;
    Handled := True;
  End;
end;

procedure MoveItemIndex;
begin
  frmDebug.lstSourceCode.ItemIndex := CurLine - 1;
  frmDebug.lblNumLine.Caption := IntToStr(CurLine);
end;

procedure DebugerInit;
var
  i : Word;
begin
  fRunToEnd := False;
  
  frmDebug.lstSourceCode.Clear;
  frmCallStack.lstCallStack.Clear;

  frmWatches.lstWatches.Clear;
  CountWatches := 0;

  CountBreaks := 0;

  for i := 1 to CountLines do
  begin
    frmDebug.lstSourceCode.Items.Add(SourceCode[i]^);
  end;
  //frmDebug.lstSourceCode.ItemIndex := 0;
  F8_Pressed := False;
  Application.OnMessage := frmDebug.WMKeyDown;

  fAddingWatch := False;
  
  frmDebug.Show;
end;

procedure TfrmDebug.sbStepOverClick(Sender: TObject);
begin
  If fDebugMode then
    PostMessage(frmDebug.Handle, WM_KEYDOWN, VK_F8, 0);
end;

procedure TfrmDebug.sbExecEndClick(Sender: TObject);
begin
  F8_Pressed := True;
  //fDebugMode := False;
  fRunToEnd := True;
  //lstSourceCode.ItemIndex := 0;
end;

procedure TfrmDebug.sbCallStackClick(Sender: TObject);
begin
  frmCallStack.Show;
end;

procedure TfrmDebug.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  If fDebugMode And (Not F8_Pressed) then
  Begin
    frmMessage.ShowMsg('Закончите выполнение программы');
    CanClose := False;
  End
  Else
    frmFileMenu.N15Click(Self);
end;

procedure TfrmDebug.sbWatchesClick(Sender: TObject);
begin
  frmWatches.Show;
end;

procedure TfrmDebug.lstSourceCodeDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  tmpBrush : TBrush;
begin
  with (Control as TListBox).Canvas do
  begin
    tmpBrush := Brush;
    If BreakPoint(Index) > 0 then
      Brush.Color := clGreen;

    FillRect(Rect);
    Brush := tmpBrush;

    TextOut(Rect.Left,Rect.Top,lstSourceCode.Items[Index]);
  end;
end;

procedure TfrmDebug.sbBreakPointClick(Sender: TObject);
var
  i : Word;
begin
  If Assigned(lstSourceCode.Items) And (lstSourceCode.ItemIndex > -1) then
  Begin
    If BreakPoint(lstSourceCode.ItemIndex) > 0 then
    begin
      for i := BreakPoint(lstSourceCode.ItemIndex) to CountBreaks - 1 do 
        BreakPoints[i] := BreakPoints[i + 1];
      Dec(CountBreaks);   
    end
    else begin
      Inc(CountBreaks);
      BreakPoints[CountBreaks] := lstSourceCode.ItemIndex;
    end;  
    lstSourceCode.Repaint;
  End;

end;

end.
