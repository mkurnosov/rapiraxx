unit LibManager;

interface
uses ConstrDLLSupport, Windows;

const
    MAX_LIBRARIES =  50;
    MAX_IMP_PROC  =  MAX_PROCEDURES * MAX_LIBRARIES;
    MAX_IMP_FUN   =  MAX_FUNCTIONS * MAX_LIBRARIES;

type

    TImpProc = record
        ProcDescr : TExportProcDescription;
        PtrProc   : TDLLExportFun;
    end;

    TImpFun = record
        FunDescr : TExportFunDescription;
        PtrFun  : TDLLExportFun;
    end;

var
    Libs : array [1..MAX_LIBRARIES] of HINST;
    CountLibs : Integer;
    
    ImpProcedures : array [0..MAX_IMP_PROC - 1] of TImpProc;
    CountImpProc  : Integer;

    ImpFunctions  : array [0..MAX_IMP_FUN - 1] of TImpFun;
    CountImpFun   : Integer;

procedure LoadLibraries(const FileName : string);
procedure FreeLibraries;

implementation
uses frmRun, Dialogs, SysUtils;

procedure LoadLibraries(const FileName : string);
var
    FIn  : TextFile;
    sDLLFileName : string;

    hInstance   : HINST;

    DLLInfoProc : TDLLInfoProc;

    DLLInfo  : TDLLExportInfo;
    FormInfo : TFormInfo;

    i : Integer;

begin
    FormInfo.FormHandle   := frmRunTime.Handle;           //  HWND
    FormInfo.CanvasHandle := frmRunTime.imgDrawField.Canvas.Handle;    //  HDC

    AssignFile(FIn, FileName);
    Reset(FIn);

    while not EOF(FIn) do
    begin
        Readln(FIn, sDLLFileName);
                  
        hInstance := LoadLibrary(PChar(sDLLFileName));
        if hInstance <= HINSTANCE_ERROR then
            ShowMessage(Format('Не могу загрузить %s', [sDLLFileName]))
        else
        begin
            Inc(CountLibs);
            Libs[CountLibs] := hInstance;

            DLLInfoProc := GetProcAddress(hInstance, 'GetDLLExportInfo');
            if not Assigned(DLLInfoProc) then
                ShowMessage(Format('Не могу вызвать GetDLLExportInfo из %s',
                                                               [sDLLFileName]))
            else
            begin

                DLLInfoProc(DLLInfo, FormInfo);

                // PROCEDURES
                for i := 0 to DLLInfo.CountProcedures - 1 do
                begin
                    Inc(CountImpProc);
                    ImpProcedures[CountImpProc - 1].ProcDescr :=
                                                         DLLInfo.Procedures[i];

                    ImpProcedures[CountImpProc - 1].PtrProc :=
                     GetProcAddress(hInstance, DLLInfo.Procedures[i].ProcName);

                    if not Assigned(ImpProcedures[CountImpProc - 1].PtrProc) then
                    begin
                        ShowMessage(Format('Не могу получить адрес %s из %s',
                              [DLLInfo.Procedures[i].ProcName, sDLLFileName]));
                        Dec(CountImpProc);
                    end;
                end; // for

                // FOR FUNCTIONS
                for i := 0 to DLLInfo.CountFunctions - 1 do
                begin
                    Inc(CountImpFun);
                    ImpFunctions[CountImpFun - 1].FunDescr :=
                                                         DLLInfo.Functions[i];

                    ImpFunctions[CountImpFun - 1].PtrFun :=
                     GetProcAddress(hInstance, DLLInfo.Functions[i].FunName);

                    if not Assigned(ImpFunctions[CountImpFun - 1].PtrFun) then
                    begin
                        ShowMessage(Format('Не могу получить адрес %s из %s',
                              [DLLInfo.Functions[i].FunName, sDLLFileName]));
                        Dec(CountImpFun);
                    end;
                end; // for
            end; // else
        end; // else
    end; // while

    CloseFile(FIn);
end;

procedure FreeLibraries;
var
    i : Integer;
begin
    for i := 1 to CountLibs do
        FreeLibrary(Libs[i]);
end;

initialization
    CountLibs := 0;
    CountImpProc := 0;
    CountImpFun  := 0;
end.
