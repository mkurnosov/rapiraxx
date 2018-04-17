unit LibView;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmLibView = class(TForm)
    lstFun: TListBox;
    grbFun: TGroupBox;
    Button1: TButton;
    GroupBox1: TGroupBox;
    memoTotal: TMemo;
    memoFun: TMemo;
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure lstFunClick(Sender: TObject);
  public
      procedure PrintExportInfo;
  end;

var
  frmLibView: TfrmLibView;

implementation
{$R *.DFM}
uses LibManager;

procedure TfrmLibView.PrintExportInfo;
var
    i : Integer;
begin
    lstFun.Clear;
    memoFun.Clear;
    memoTotal.Clear;

    for i := 0 to CountImpProc - 1 do
        lstFun.Items.Add(ImpProcedures[i].ProcDescr.ProcName);

    for i := 0 to CountImpFun - 1 do
        lstFun.Items.Add(ImpFunctions[i].FunDescr.FunName);

    memoTotal.Lines.Add(Format('Импортированно процедур : %d', [CountImpProc]));
    memoTotal.Lines.Add(Format('Импортированно функций  : %d', [CountImpFun]));

end;

procedure TfrmLibView.FormShow(Sender: TObject);
begin
    PrintExportInfo;
end;

procedure TfrmLibView.Button1Click(Sender: TObject);
begin
    Hide;
end;

procedure TfrmLibView.lstFunClick(Sender: TObject);
begin
    if lstFun.ItemIndex <> -1 then
    begin
        memoFun.Clear;
        if lstFun.ItemIndex + 1 > CountImpProc then      //  FUNCTION
        begin
            memoFun.Lines.Add(ImpFunctions[lstFun.ItemIndex - CountImpProc].FunDescr.FunName);
        end
        else begin
            memoFun.Lines.Add(ImpProcedures[lstFun.ItemIndex].ProcDescr.ProcName);
        end;

    end;
end;

end.
