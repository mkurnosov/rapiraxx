//**************************************************************************//
//  KERNEL_32 1.2.04                                                        //
//  Written by M. Kurnosov 2000-2001                                        //
//**************************************************************************//

Unit Krnl;

Interface

Uses Types, SysUtils;
Const

  VERSION = '1.2.04';

  MAX_SOURCE_LINES     = 2000; { SourceCode[] }
  MAX_COUNT_FUNCTIONS  = 100;  { Functions[]  }

  { ������������ ������ ����� }
  MAX_STACK_INDEX_COUNT = 2000;

  { ����. ���-�� �����-�� � ����� 0..MAX_COUNT_VARS }
  MAX_COUNT_VARS = 500;

  { ������������� ������ - Error() }
  ERR_RUN_TIME  = 1; { - ������� ����������          }
  ERR_LOAD_TIME = 2; { - ������� ��������            }
  ERR_WORK_TIME = 3; { - ������� ������ ������������ }

  { ����. ���-�� ������� }
  MAX_COUNT_CLASSES = 50;
  MAX_COUNT_FIELDS  = 50; { ����. ���-�� ����� � ������   - TClass }
  MAX_COUNT_METHODS = 50; { ����. ���-�� ������� � ������ - TClass }

  { ����. ���-�� �������� }
  MAX_COUNT_OBJECTS = 50;

  ImageFields : Array [1..7] of String = ('������', '�����', '������',
                                          '������', '��������',
                                          '���������', '����������');
  Type

  EKernelError = Class(Exception);

  TLastError = Record
    sError : String;
    sLine  : String; 
  End;
  
  { ��������� �� �������� ReadWord() }
  TCharSet = Set of Char;

  { ��������� �� ������ ������� (Structure too large) }
  PFunction = ^TFunction;
  TFunArray = Array [1..MAX_COUNT_FUNCTIONS] of PFunction;


  { ������ }
  PClass = ^TClass;
  TClass = Record
    Name   : String;  { ��� ������ }
    Parent : Word;    { ����� ������-������ }
    { ���� ������ (New)}
    Fields : Array [1..MAX_COUNT_FIELDS] of TStack;
    CountFields : Word;
    { ������ ������ }
    Methods : Array [1..MAX_COUNT_METHODS] of PFunction;
    CountMethods : Word;
  End;

  TClassArray = Array [1..MAX_COUNT_CLASSES] of PClass;

  { ������� }
  { ������ - ������ �� �����. �������� ��� ���� ������ }
  PObjects_m = ^TObject_m;
  TObject_m  = Record
    Name : String;
    { ������ �� �����. ����� ������ }
    RefToClass : Word;
    { ���� ������� (������ New)}
    Fields : Array [1..MAX_COUNT_FIELDS] of TStack;
    CountFields : Word;
  End;

  TObjectsArray = Array [1..MAX_COUNT_OBJECTS] of PObjects_m;


  Procedure Init;
  Procedure Done;

  { �������� ������������� ����� }
  Procedure Parse;

  { ����������� ������ ������ }
  Procedure GetString;

  { ��������� ���� � SourceCode[] }
  Procedure LoadFile(const sFileName : String);

  Function  Match(const sStr : String):Boolean;

  { ��������� ����� ����-�� �������� ������ � ��������� ChSet }
  Function ReadWord(ChSet : TCharSet) : String;

  { ��������� ����� ����, ���, �����-��, ... }
  { � ��������� �� ������������ ������       }
  Function ReadName(ErrNum : Word) : String;

  { ��������� ��������� ��� ���. }
  Procedure AnalyzeFunction;

  { ����������� �������� ������ }
  Procedure AnalyzeClass;

  { ��������� ����� ������ }
  Procedure AnalyzeMethod(IdxClass : Word);

  { ���� ����� �� ������ }
  Function FindClass(const sClassName : String) : Word;

  { ���� ����� ������ }
  Function FindMethod(const sMethodName : String; IdxClass : Word): Word;

  { ���� ���� � ������ }
  Function FindField(const sFieldName : String; IdxClass : Word) : Word;

  { �������� �� ���� ����� ����� ����������� }
  Function BaseField(const sName : String) : Boolean;

  { ��������� �������� �������� }
  Procedure AnalyzeObjects;

  { ����� ������� }
  Function FindObject(const sObjName : String) : Word;

  { ���� ����� ������� }
  Function FindObjectMethod(const sMember : String; IdxObject : Word) : Word;

  { ���� ���� ������� }
  Function FindObjectField(const sMember : String; IdxObject : Word) : Word;

  { �������� ����� ������ }
  Procedure CallMethod(IdxClass, IdxMethod, IdxObject : Word);

  { ��������� ��������� � ������ ������ }
  Procedure WorkParent(bLeftPart : Boolean);


  { ������ ��������� � ����� ������ }
  Function WorkStrightAccess(const sMember : String) : Boolean;

  { ��������� � ����� ������� ����� '.' }
  Procedure WorkObjectMember(IdxObject : Word);

  { ��������� �������� ����� ������� (���� ��� �������) }
  Procedure GetMemberValue(IdxObject : Word);

  { ��������� �������� ����� ������ (���� ��� �������) ��� }
  { ������ ��������� }
  Function GetMemberValue_2(const sMember : String) : Boolean;

  { ��������� �� ������ � ����� }
  Procedure Error(ErrKind : Byte; ErrNumber : Word);

  { ���������� ������� }
  Procedure SkipBlanks;

  { ���� ������� �� ����� }
  Function  FindFun(const sFunName : String): Word;

  { �������� ��� ��� ���� }
  Procedure CallFunction(IdxFun : Word);

  { ��������� ��������� ������� }
  Procedure WorkReturn;

  { ��������-����������� ������� ������� ���� ���������� ����� }
  Function Statement(const strEnd1, strEnd2 : String) : Byte;

  { ��������� ������� ��������� }
  Procedure WorkExpression;
                    
  { ��������� ��������� ������� ��������� � ������ ��� � AX }
  Procedure GetOperand;

  { ���������� ������ }
  Procedure WorkBrackets;

  { ��������� ������ ��������� 3-� ����� � AX }
  Procedure ReadBoolean_1;
  Procedure ReadString_1;
  Procedure ReadInteger_1;

  { ��������� � AX �������� �����. ��� ���. }
  Procedure ReadVar;

  { ��������� ��������� ������� (���������) }
  Procedure WorkIf;

  { ���� ������ }
  Procedure WorkRepeat;

  { ���� ���� }
  Procedure WorkWhile;

  { ���� ��� }
  Procedure WorkFor;

  { ������� ��������� � ListBox }
  Procedure PrintMsg;

  { ���������� ��������� }
  Procedure ShowMsg;

  { �������� ���������� � ����� ������� }
  Procedure WorkAssignment;

  { ���� ��������� �� ����� }
  Function FindVar(const sVarName : String) : Word;

  { ������ ����� ��������� ���������� }
  Function CreateNewVar(const sVarName : String) : Word;

  { ��������� �������� �������� AX � ���� }
  Procedure PUSH;

  { ����������� �������� �� ����� � BX }
  Procedure POP;

  { ��������� �������� ��� ���������� }
  Procedure CalcRegs(const sOper : String);

  { ��������� ���. �������� ��� }
  Function Operator_OR : Boolean;

  { ��������� ���. �������� � }
  Function Operator_AND : Boolean;

  { ��������� ���. �������� ��������� }
  Function Operator_G1 : Boolean;

  { ��������� �������������� �������� : +, - }
  Function Operator_G2 : Boolean;

  { ��������� �������������� �������� : *, / }
  Function Operator_G3 : Boolean;

  { ���������� ����� }
  Procedure WorkInput(selType : Byte);
                                                               // *  *  *
  procedure CallDLLProc(ProcNum : Integer);                    //   DLL
  function  FindDLLProc : Boolean;                             //   DLL
                                                               //   DLL
  procedure CallDLLFun(FunNum : Integer);                      //   DLL
  function  FindDLLFun : Boolean;                              //   DLL
                                                               // *  *  *
  { ��������� ��������� ����� - ��� }
  Procedure WorkRandom;
  Procedure WorkLine;
  Procedure WorkFill;
  Procedure WorkCircle;
  Procedure WorkPset;
  Procedure WorkDrawing;
  Procedure WorkTriangle;
  Procedure WorkText;

  procedure WorkStrCopy;
  procedure WorkStrLength;
  Procedure WorkGetAscii;
  Procedure WorkChr;
  Procedure WorkStrToInt;
  Procedure WorkIntToStr;

Var

  { �������� ��� ��������� }
  SourceCode : Array [1..MAX_SOURCE_LINES] of _PString;
  CountLines : Word;

  CurCh   : Word; { ������ � ������ ���� - SourceCode[N]^[CurCh] }
  CurLine : Word; { ������ ������ ���� - SourceCode[CurLine] }

  { ������ �������� � ������� }
  Functions : ^TFunArray; { Structure too large }
  CountFunctions : Word;
  AllocMemFun    : Boolean; { �������� �� ������ ��� Functions }
  { ����� ������� ������� (��� WorkReturn() ) }
  CurrentFun : Word;

  VarName    : TCharSet; { ����� ������� ����� ����������� �         }
                         { ����� ����������                          }

  Second     : TCharSet; { � ������ ������� �� ����� ���������� ���, }
                         { �� ������ ��� ����� ��������������        }

  { ���������� ����� ��������� ����� � ����. ������� }
  ProcStart : Word;

  { �������� ������ ���������� }
  AX, BX : TResult;

  { C���. ������������ ��� �������� ��������� ���������� }
  { � ������ ��������� }
  Stack : Array [1..MAX_STACK_INDEX_COUNT] of PStack;
  CurStack : Word;

  { ������� ������� ��������� �����. �����. � �����. }
  TopBorder, BottomBorder : Word;

  { ����. ����� �� ������������ ��������� }
  { ����������������� � WorkIf }
  fExec : Boolean;

  { res ��� ���������� Statement }
  res : Byte;


  { ������ _m - �.� classes ��������. ����� }
  Classes_m : ^TClassArray;
  CountClasses : Word;
  { �������� �� ������ ��� Classes }
  AllocMemClasses : Boolean;


  { ������� _m - �.� objects ��������. ����� }
  Objects_m : ^TObjectsArray;
  CountObjects : Word;
  { �������� �� ������ ��� Objects }
  AllocMemObjects : Boolean;

  { ����� ������� ������� }
  CurrentObject  : Word;

  { ����� �������� ������ (��� WorkReturn() ) }
  CurrentMethod : Word;

  { ����� �������� ������ }
  CurrentClass : Word;

  LastError : TLastError;

  EmergencyTermination : Boolean;
  fExplorerWork : Boolean;

  { ������ ��������������, � �� ��������� �� ����� }
  { � GetString }
  fInterpreting : Boolean;

Implementation

Uses GlbFun,   { only for LoadFile()           }
     Dialogs,  { only for ShowMessage in Error }
     Main,     { ��� PCur & RobotList }
     Forms,    { for Application.ProcessMessages    }
     frmErr, frmRun, frmFile, mdl_dsg, Graphics, frmOut, Explr,
     Windows, frmUser, Debug, frmCStack, frmWatch,
     LibManager, ConstrDLLSupport;


  { ������������ }
  Procedure Init;
  Var
    i : Word;
  Begin
    AllocMemFun := False;
    CountLines  := 0;
    CurCh       := 0;
    CurLine     := 0;
    VarName     := ['a'..'z','�'..'�','�','_','0'..'9'];
    Second      := ['_','0'..'9'];
    CountFunctions := 0;
    CurStack     := MAX_COUNT_VARS;
    TopBorder    := 0;
    BottomBorder := 0; { ��� FindVar() }
    fExec        := True;
    ProcStart    := 0;
    CurrentFun   := 0;
    CountClasses := 0;
    CountObjects    := 0;
    AllocMemObjects := False;
    CurrentObject   := 0;
    CurrentClass    := 0;
    CurrentMethod   := 0;

    { ���������� ����� - ����������� }
    Inc(CountClasses);
    AllocMemClasses := True;
    New(Classes_m);
    New(Classes_m[1]);

    With Classes_m^[1]^ do
    Begin
      Name   := '�����������';  { ��� ������ }
      Parent := 0;              { ����� ������-������ }

      For i := 1 to 7 do
      Begin
        Fields[i].Name := ImageFields[i];
        Case i of
          1..4 : Fields[i].selType := 2; {int}
          5    : Fields[i].selType := 1; {file name}
          6..7 : Fields[i].selType := 3; {bool}
        End;
        Fields[i].Str  := '';
        Fields[i].Int  := 0;
        Fields[i].Bool := False;
      End;
      CountFields := 7;

      { ������ ������ }
      CountMethods := 0;
    End; {with}

    EmergencyTermination := False;
    fExplorerWork        := False;
    fInterpreting        := False;

    Randomize;
  End;

  Procedure Done;
  var
    i : Word;
  Begin
    For i := 1 to CountLines do
    begin
      Dispose(SourceCode[i]);
    end;

    If AllocMemFun then
      Dispose(Functions);

    If AllocMemClasses then
      Dispose(Classes_m);

    If AllocMemObjects then
      Dispose(Objects_m);
  End;

  { -------------------------------------------------------------------- }
  { ��������� ���� � SourceCode }
  Procedure LoadFile(const sFileName : String);
  Var
    FText : TextFile;
    sStr  : String;
  Begin
    { ��������� � ������������ ����}
    { 1. ������� ������ ������� �������� �� ������.}
    { 2. ��������� ����� � ������ �������, �� �� � ���������� }

    fInterpreting := False;
    
    Try

      AssignFile(FText,sFileName);
      Reset(FText);
      While (Not EOF(FText)) do
      Begin
        Readln(FText, sStr);

        EraseBlank(@sStr);
        K_LowerCase(@sStr);

        { ���� ������ �� ����� � �� ����������, �� ��������� � }
        If (Length(sStr) <> 0) And (sStr <> ' ') And
           (Copy(sStr,1,2) <> '//') then
        Begin
          If (CountLines + 1) > MAX_SOURCE_LINES then
            Error(ERR_RUN_TIME, 27);

          Inc(CountLines);

          New(SourceCode[CountLines]);
          SourceCode[CountLines]^ := sStr;
        End;
      End; { while }

      CloseFile(FText);
    Except
      Error(ERR_RUN_TIME, 119);
    End;
  End;

  { ------------------------------------------------------------------- }
  { ����������� ������ ������ }
  Procedure GetString;
  Begin
    If fDebugMode And fInterpreting then
      If (Not fAddingWatch) And (Not fRunToEnd) And fExec then  
      begin
        While Not F8_Pressed do
          Application.ProcessMessages;
      end
      else 
        if fRunToEnd then
        begin
          If BreakPoint(CurLine) > 0 then
          begin
            fRunToEnd  := False;
            F8_Pressed := False; 
          end;     
        end;
      
    Inc(CurLine);
    CurCh := 1;

    If fDebugMode And fInterpreting And (Not fAddingWatch) And fExec then
    begin
      F8_Pressed := False;
      MoveItemIndex;
    end;
  End;

  { -------------------------------------------------------------------- }
  { ���������� ������� � ���� }
  Procedure SkipBlanks;
  Begin
    While (SourceCode[CurLine]^[CurCh] = ' ') or (SourceCode[CurLine]^[CurCh] = #9) do
      Inc(CurCh);
  End;

  { -------------------------------------------------------------------- }
  Function Match(const sStr : String):Boolean;
  Begin
     SkipBlanks;

    { � ������ ��������� ����� sStr ? }
    If (Copy(SourceCode[CurLine]^, CurCh, Length(sStr)) = sStr) then
    Begin
      Match := True;
      CurCh := CurCh + Length(sStr);
    End
    Else
      Match := False;
  End;

  { -------------------------------------------------------------------- }
  { ��������� ����� ����-�� �������� ������ � ��������� ChSet }
  Function ReadWord(ChSet : TCharSet) : String;
  Var
    sOut   : String;
  Begin
    ReadWord := '';
    sOut     := '';

    SkipBlanks;

    While (SourceCode[CurLine]^[CurCh] in ChSet) do
    Begin
      sOut := sOut + SourceCode[CurLine]^[CurCh];
      If CurCh >= Length(SourceCode[CurLine]^) then
        Break;

      Inc(CurCh);
    End;
    ReadWord:= sOut;
  End;

  { -------------------------------------------------------------------- }
  Function ReadName(ErrNum : Word) : String;
  Var
    sBuf : String;
  Begin
    { ErrNum - ������������ ���� ������ ��� }
    { ������ ��� ��� ��� ���� }
    sBuf := ReadWord(VarName);

    If (sBuf = '')  then
      Error(ERR_RUN_TIME, ErrNum)

    Else If (sBuf[1] in Second) then
      Error(ERR_RUN_TIME, ErrNum);

    ReadName := sBuf;
  End;

  { -------------------------------------------------------------------- }
  Procedure AnalyzeFunction;
  Var
    FunType  : Byte;
    sArgName : String;
    sBuf     : String;
    IdxFun   : Word;

    { ������ ��������� �� ��� ���� }
    procedure GoToEndProc;
    begin
      While Not Match('���') do
      Begin
        GetString;
        If CurLine > CountLines then  { �������� �� ����� �� ������� }
          Error(ERR_RUN_TIME, 11);
      End;
    end;

    Function ArgExist(const ArgName : String; iFun : Word): Boolean;
    var
      i : byte;
    begin
      ArgExist := False;
      for i := 1 to Functions^[iFun]^.CountArgs do
        if Functions^[iFun]^.Args[i] = ArgName then
        begin
          ArgExist := True;
          Exit;
        end;
    end;

  Begin
    { ���� ���� �������� ����. ��� ���., �� ��������� �� � ����. ��������. }
    { ���������� True ���� ���� �������� ����. ��� ���. }
    FunType := 3;

    If Match('����') then
      FunType := 0
    Else If Match('���') then
      FunType := 1;

    { ���� ��� ��. ����� ���� ��� ���, �� ������� �� ��������� }
    If (FunType = 3) then
      Exit;

    { ������ ��� ��� ��� ���� }
    sBuf := ReadName(9);

    { ���� ����� ��� ��� � ����� ������ ��� ����, �� ����� }
    IdxFun := FindFun(sBuf);
    If (IdxFun <> 0) then
      Error(ERR_RUN_TIME, 14); { ���� ��� ���������� }

    { ��������� �� ��� ������� }
    If FindObject(sBuf) <> 0 then
      Error(ERR_RUN_TIME, 92);

    { ���� ������ ��� ��������� �� ������ ��� ��� �� �������� }
    If (Not AllocMemFun) then
    Begin
      AllocMemFun := True;
      New(Functions);
    End;

    If (CountFunctions + 1) > MAX_COUNT_FUNCTIONS then
      Error(ERR_RUN_TIME, 15);

    Inc(CountFunctions);
    New(Functions^[CountFunctions]);

    Functions^[CountFunctions]^.Name := sBuf;

    { �������������� �.� �� ��������� �������� = ??? }
    Functions^[CountFunctions]^.CountArgs := 0;

    If Not Match('(') then
      Error(ERR_RUN_TIME, 2); { ������ ��� }

    SkipBlanks;

    While (Copy(SourceCode[CurLine]^, CurCh, 1) <> ')') do
    Begin
      { ������ ��� ��������� }
      sArgName := ReadName(4);

      { ����� � ����� ������ ��� ���� �������� }
      If ArgExist(sArgName, CountFunctions) then
        Error(ERR_RUN_TIME, 17);

      { ����� � ����� ������ ��� }
      If FindFun(sArgName) <> 0 then
        Error(ERR_RUN_TIME, 78);

      { ��������� �� ��� ������� }
      If FindObject(sArgName) <> 0 then
        Error(ERR_RUN_TIME, 91);

      { ����� �� ������� ����� ? }
      If (Functions^[CountFunctions]^.CountArgs + 1) > MAX_COUNT_ARGS then
        Error(ERR_RUN_TIME, 16);

      { ��������� ��� � ������ ���������� ������� }
      Inc(Functions^[CountFunctions]^.CountArgs);
      Functions^[CountFunctions]^.Args[Functions^[CountFunctions]^.CountArgs] := sArgName;

      If Match(')') then
        Break;

      If Not Match(',') then
        Error(ERR_RUN_TIME, 3);   { ����������� ������� }

      If Match(')') then
        Error(ERR_RUN_TIME, 4);   { ��� ��������� ������� �� ����������� }
    End;

    { ��������� �� ������� ���. (����� ������������� ��� ����) }
    If (CurLine + 1) > CountLines then
      Error(ERR_RUN_TIME, 6);

    { ����� ����� � ������� }
    Functions^[CountFunctions]^.StartLine := CurLine;

    GoToEndProc; { ������� �� ��� ���� }

    { �������� ����. � ���. }
    Case FunType of
      0 : Begin
            Functions^[CountFunctions]^.Fun := False;
            If Not Match('����') then
              Error(ERR_RUN_TIME, 7);
          End;
      1 : Begin
            Functions^[CountFunctions]^.Fun := True;
            If Not Match('���') then
              Error(ERR_RUN_TIME, 8);
          End;
    End;

    { ���� ��� ���� ����� }
    If (sBuf = '�����') then
    Begin
      If FunType = 1 then
        Error(ERR_RUN_TIME, 18);
      If Functions^[CountFunctions]^.CountArgs <> 0 then
        Error(ERR_RUN_TIME, 45);
      ProcStart := CountFunctions;
    End;

  End; { procedure }

  { ------------------------------------------------------------------------- }
  Function FindFun(const sFunName : String): Word;
  Var
    i, idx : Word;
  Begin
    { ���� ������� �� ����� � ������� ������� }
    { ���� �� ���� ���������� 0               }
    { ����� � ������ � �������               }
    idx := 0;

    for i := 1 to CountFunctions do
    begin
      if (Functions^[i]^.Name = sFunName) then
      begin
        idx := i;
        break;
      end;
    end; { for }

    FindFun := idx;
  End;

 { ---------------------------------------------------------------------- }
 { �������� ��� ��� ���� }
 Procedure CallFunction(IdxFun : Word);
 Var
   wTop, wBottom, wArgs, wFun : Word;
   IdxArg, i         : Word;
   wLine, wCur, wBuf : Word;
   wMethod           : Word;
   sBuf              : String;
 Begin
   { IdxFun - ����� ��� ��� ���� � ������� ������� }
   { ��������� ������ ������� ��������� }
   wBottom := BottomBorder;
   wTop := TopBorder;

   sBuf := '(';

   If IdxFun <> ProcStart then
   Begin
     { ����������� ������ ���� ���� ������ : s := f() + 4 }
     If Not Match('(') then
       Error(ERR_RUN_TIME, 41);

     wArgs := 0;
     { ��������� ������������ ���������� }
     { ���������� � ���� ������������ ��������, � ����� }
     { �������� �� ����� }
     If Functions^[IdxFun]^.CountArgs <> 0 then
     Begin
       Repeat { ������-�� ���� (����� - break) }

         { msg('Hello World', 3+4, .�. ��� .�.) }
         Inc(wArgs);
         { ��������� ��������� �������� }
         WorkExpression;
         IdxArg := CreateNewVar('');
         { ����������� ������. }
         Stack[IdxArg]^.selType := AX.selType;
         Stack[IdxArg]^.Str  := AX.Str;
         Stack[IdxArg]^.Int  := AX.Int;
         Stack[IdxArg]^.Bool := AX.Bool;

         If fDebugMode then
         begin
           Case AX.selType of
             1 : sBuf := sBuf + #39 + AX.Str + #39;
             2 : sBuf := sBuf + IntToStr(AX.Int);
             3 : If AX.Bool then
                   sBuf := sBuf + '.�.'
                 Else
                   sBuf := sBuf + '.�.';
           End;
         end;

         If SourceCode[CurLine]^[CurCh] = ')' then
           Break;

         If Not Match(',') then
           Error(ERR_RUN_TIME, 43);

         If fDebugMode then
           sBuf := sBuf + ', ';  
       Until False;
     End; { If CountArgs <> 0 }

     If Not Match(')') then
       Error(ERR_RUN_TIME, 42);

     { ������� ������� �����-�� � ��-�� ������� ���-�� }
     If wArgs <> Functions^[IdxFun]^.CountArgs then
       Error(ERR_RUN_TIME, 44);

     { ������������� ����� � ����� }
     wArgs := 0;
     For i := wTop + 1 to TopBorder do
     Begin
       Inc(wArgs); { - ����� �������� �� ����� }

      { ����� � ����� ������ ��� ���� ������� }
      wBuf := FindFun(Functions^[IdxFun]^.Args[wArgs]);
      If wBuf <> 0 then
        Error(ERR_RUN_TIME, 48);

      { ��������� �� ��� ������� }
      If FindObject(Functions^[IdxFun]^.Args[wArgs]) <> 0 then
        Error(ERR_RUN_TIME, 93);

      Stack[i]^.Name := Functions^[IdxFun]^.Args[wArgs];
     End;
   End; { If IdxFun <> ProcStart }

   If fDebugMode then
   begin
     sBuf := sBuf + ')';
     sBuf := Functions^[IdxFun]^.Name + sBuf + ' : ' + IntToStr(CurLine);;
     frmCallStack.lstCallStack.Items.Add(sBuf);
   end;

   { ����� ������� ��������� ���������� }
   { �.� ����� � ������� }
   BottomBorder := wTop + 1;

   wLine   := CurLine;
   wCur    := CurCh;
   wFun    := CurrentFun;
   wMethod := CurrentMethod;

   { ������ ����� ������ ������� (��� WorkReturn() ) }
   CurrentFun := IdxFun;

   { ���� ���������� CurrentFun, �� CurrentMethod ������� }
   { � ��������. }
   CurrentMethod := 0;

   { ����������� � ���� ������� }
   CurLine := Functions^[IdxFun]^.StartLine;

   If Functions^[IdxFun]^.Fun then
     res := Statement('��� ���','��� ���')
   Else
     res := Statement('��� ����','��� ����');

   { ����������� ������ �� ��� ���������� }
   If BottomBorder > 0 then
     For i := BottomBorder to TopBorder do
       Dispose(Stack[i]);

   { ������� �� ������ }
   CurLine := wLine;
   CurCh   := wCur;
   BottomBorder  := wBottom;
   TopBorder     := wTop;
   CurrentFun    := wFun;
   CurrentMethod := wMethod;

   If fDebugMode then
     frmCallStack.lstCallStack.Items.Delete(frmCallStack.lstCallStack.Items.Count - 1);
 End;

 { ---------------------------------------------------------------------- }
 { ��������-����������� ������� ������� ���� ���������� ����� }
 Function Statement(const strEnd1, strEnd2 : String) : Byte;
 Var
   nEnd : Byte;
 Begin
   { ���������� 1 - ���� ���������� �� strEnd1 � 2 - ���� strEnd2         }
   { strEnd1, strEnd2 - ��������� �� ������ ���������� ��������� �������� }
   { ��� ������ �� ���������                                              }
   GetString;
   nEnd := 0;

   If fDebugMode And (CountWatches > 0) then
     RefreshWatches;

   
   While (nEnd = 0) do
   Begin
     { �������� �� ����� }
     If Match(strEnd1) then
       nEnd := 1
     Else If Match(strEnd2) then
       nEnd := 2
     Else
     Begin
       { �������� ���� ����� }
       If Match('����') then
         WorkIf
       Else If Match('������') then
         WorkRepeat
       Else If Match('����') then
         WorkWhile
       Else If Match('���') then
         WorkFor
       Else If Match('�������') then
         WorkReturn
       Else If Match('�����') then
         ShowMsg
       Else If Match('������') then
         PrintMsg
       Else If Match('����') then
         WorkCircle
       Else If Match('�����') then
         WorkLine
       Else If Match('���') then
         WorkPset
       Else If Match('������') then
         WorkFill
       Else If Match('���') then
         WorkTriangle
       Else If Match('�������') then
         WorkDrawing
       Else If Match('�����') then
         WorkText
       Else Begin
         if not FindDLLProc then
             WorkAssignment;

         If fDebugMode And (CountWatches > 0) then
           RefreshWatches;
       End;
     End; { Else  }

     { ����� ���-�� �������� }
     If (CurCh < Length(SourceCode[CurLine]^)) And fExec then
       Error(Err_RUN_TIME, 39);

     If nEnd = 0 then
       If CurLine >= CountLines then
         Error(ERR_RUN_TIME, 50)
       Else
         GetString;

   End; { While }

   Statement := nEnd;
 End;

 { --------------------------------------------------------------------- }
 procedure CallDLLProc(ProcNum : Integer);
 var
     param     : TDLLProcParam;
     tmpVal    : string;
     //i       : Integer;
 begin
     param.CountParams := 0;
     // sName([arg1, arg2, ...])

     if not Match('(') then
         Error(ERR_RUN_TIME, 41);

     if ImpProcedures[ProcNum].ProcDescr.CountParams <> 0 then
     begin

     repeat
         WorkExpression;
         param.CountParams := param.CountParams + 1;

         case AX.selType of
             1 : tmpVal := AX.Str;
             2 : tmpVal := IntToStr(AX.Int);
             3 : if AX.Bool then
                     tmpVal := 'TRUE'
                 else
                     tmpVal := 'FALSE';
         end;

         if AX.selType <> ImpProcedures[ProcNum].ProcDescr.ParamsTypes[param.CountParams - 1] then
         begin
             LastError.sError := '�������������� ����� ����������� � ������������ ����������';
             LastError.sLine  := SourceCode[CurLine]^;
             Abort;
         end;

         GetMem(param.Params[param.CountParams - 1], Length(tmpVal) + 1);
         StrPCopy(param.Params[param.CountParams - 1], tmpVal);

         If SourceCode[CurLine]^[CurCh] = ')' then
           Break;

         If Not Match(',') then
           Error(ERR_RUN_TIME, 43);

     until False;

     end; // if

     if not Match(')') then
         Error(ERR_RUN_TIME, 42);


    if param.CountParams <> ImpProcedures[ProcNum].ProcDescr.CountParams then
    begin
        LastError.sError := '�������� ����� ���������� ����������';
        LastError.sLine  := SourceCode[CurLine]^;
        Abort;
    end;

    if ImpProcedures[ProcNum].PtrProc(param) = 0 then
    begin
        LastError.sError := String(param.ReturnValue);
        LastError.sLine  := SourceCode[CurLine]^;
        Abort;
    end;

    //for i := 0 to param.CountParams - 1 do
    //    FreeMem(param.Params[i]);
 end;

 { --------------------------------------------------------------------- }
 function FindDLLProc : Boolean;
 var
     i : Integer;
     sName : array [0..255] of Char;
     sProcName : array [0..255] of Char;
     OldCurCh : Integer;
 begin
     Result := False;

     OldCurCh := CurCh;
     sName := '';
     sProcName := '';
     StrPCopy(sName, ReadName(30));

     for i := 0 to CountImpProc - 1 do
     begin
         StrPCopy(sProcName, AnsiLowerCase(ImpProcedures[i].ProcDescr.ProcName));
         if StrComp(sProcName, sName) = 0 then
         begin
             CallDLLProc(i);
             Result := True;
             Exit;
         end;
     end;
     CurCh := OldCurCh;
 end;

 { --------------------------------------------------------------------- }
 { �������� ���� ������ ����� }
  Procedure Parse;
  Var
    OldCurLine, OldCurCh : Word;
    i,j : Word;
    ImageIndex : Word;
    Idx : Word;
  Begin

    { ���������� �������������� �������� � ����   }
    { ����� Silent Exception ����������� Abort'�� }
    Try

      { ��� ����������� ��������� ���������� 2 ������� }
      If CountLines < 2 then
        Error(ERR_RUN_TIME, 5);

      While CurLine <> CountLines do
      Begin
        GetString;

        { ��������� }
        OldCurCh := CurCh;

        AnalyzeClass;
        AnalyzeFunction;
        AnalyzeObjects;

        { �� ���-������ ���������� ( ���� �� CurCh ) ? }
        If CurCh = OldCurCh then
          Error(ERR_RUN_TIME, 61);
      End;

      { ��������� � ���� ���� ����� ��������� ProcStart }
      { � ������ �� �� ���� ����� ? }
      If (ProcStart = 0) then
        Error(ERR_RUN_TIME, 13);

      for i := (CountObjects - CountIspolns + 1) to CountObjects do
      begin
        ImageIndex := i - (CountObjects - CountIspolns + 1) + 1;
        for j := 1 to Objects_m^[i]^.CountFields do
        begin
          Objects_m^[i]^.Fields[FindObjField(i,'������')].Int :=
                                      frmRunTime.Images[ImageIndex].Top;

          Objects_m^[i]^.Fields[FindObjField(i,'�����')].Int :=
                                      frmRunTime.Images[ImageIndex].Left;

          Objects_m^[i]^.Fields[FindObjField(i,'������')].Int :=
                                     frmRunTime.Images[ImageIndex].Width;

          Objects_m^[i]^.Fields[FindObjField(i,'������')].Int :=
                                    frmRunTime.Images[ImageIndex].Height;

          Objects_m^[i]^.Fields[FindObjField(i,'��������')].Str :=
    Ispolns[ImageIndex].Fields[FindIspField(ImageIndex, '��������')].Str;

          Objects_m^[i]^.Fields[FindObjField(i,'����������')].Bool :=
                                 frmRunTime.Images[ImageIndex].Stretch;

          Objects_m^[i]^.Fields[FindObjField(i,'���������')].Bool :=
                                 frmRunTime.Images[ImageIndex].Visible;
        end;
      end;

      for i := 1 to CountObjects do
      begin
        Idx := FindMethod('init', Objects_m^[i]^.RefToClass);
        If Idx = 0 then
          Continue;

        Inc(CountLines);
        New(SourceCode[CountLines]);
        SourceCode[CountLines]^ := '()';

        OldCurCh   := CurCh;
        OldCurLine := CountLines;

        CurLine := CountLines;
        CurCh   := 1;

        CallMethod(Objects_m^[i].RefToClass, Idx, i);

        CurCh   := OldCurCh;
        CurLine := OldCurLine;
        Dispose(SourceCode[CountLines]);
        Dec(CountLines);
      End;

      fInterpreting := True;
      { �������� ���� ����� }
      CallFunction(ProcStart);
    Except
      on EAbort do begin
          EmergencyTermination      := True;
          frmError.edtError.Text    := LastError.sError;
          frmError.SourceLine.Text  := LastError.sLine;
          frmError.ShowModal;
      end;
    End;
  End;

  { -------------------------------------------------------------------- }
  { �������� �� ���� ����� ����� ����������� }
  Function BaseField(const sName : String) : Boolean;
  Var
    i : Byte;
  Begin
    Result := False;
    For i := 1 to 7 do
      If sName = ImageFields[i] then
      Begin
        Result := True;
        Exit;
      End;
  End;


  { -------------------------------------------------------------------- }
  Function BaseFiled(sFiled : String) : Boolean;
  Var
    i : Word;
  Begin
    Result := False;
    for i := 1 to 7 do
      if sFiled = Classes_m^[1]^.Fields[i].Name then
      begin
        Result := True;
        Exit;  
      end;    
    If sFiled = '���' then
      Result := True; 
  End;
  
  { -------------------------------------------------------------------- }
  { ��������� �������� ������ }
  Procedure AnalyzeClass;
  Var
    sClassName  : String;
    sParentName : String;
    sFieldName  : String;
    IdxClass, i : Word;
    OldCurCh    : Word;
    IdxParent   : Word;
  Begin
    { ���� �������� �� ������ }
    If Not Match('�����') then
      Exit;

    sClassName := ReadName(53);

    { ����� ����� ��� ���� ? }
    If FindClass(sClassName) <> 0 then
      Error(ERR_RUN_TIME, 54);

    { ���� ������ ��� ��������� �� ������ ������� ��� �� �������� }
    If (Not AllocMemClasses) then
    Begin
      AllocMemClasses := True;
      New(Classes_m);
    End;

    { �������������� ����� ������� }
    If (CountClasses + 1) > MAX_COUNT_CLASSES then
      Error(ERR_RUN_TIME, 62);

    Inc(CountClasses);
    New(Classes_m^[CountClasses]);

    { ������������ ��� ������ }
    Classes_m^[CountClasses]^.Name  := sClassName;

    { ������������� ����� }
    Classes_m^[CountClasses]^.Parent       := 0;
    Classes_m^[CountClasses]^.CountFields  := 0;
    Classes_m^[CountClasses]^.CountMethods := 0;

    { ����� ������� �� ������� ������ }
    If Match('(') then
    Begin
      sParentName := ReadName(53);

      { �����-������ ���������� ? }
      IdxClass := FindClass(sParentName);
      If IdxClass = 0 then
        Error(ERR_RUN_TIME, 56);

      Classes_m^[CountClasses]^.Parent := IdxClass;

      If Not Match(')') then
        Error(ERR_RUN_TIME, 55);
    End; { if <���� ������> }

    { === ��������� ������ ���� � ������ === }
    GetString;

    SkipBlanks;
    While (Copy(SourceCode[CurLine]^, CurCh, 9) <> '��� �����') do
    Begin
      { ������ ��� �������� ����� � ������� ������ }
      { ��� �������� ������ ��� ���� ? }
      OldCurCh := CurCh;
      If Match('����') Or Match('���') then
      Begin
        { ��������� ������ }
        CurCh := OldCurCh;
        AnalyzeMethod(CountClasses);
      End
      Else { �������� ����� }
      Begin
        { ������ ��� �������� ���� }
        { �,��}
        While True do  { ������� �� Break }
        Begin
          sFieldName := ReadName(57);

          If Not BaseField(sFieldName) then
          begin
          
            { ����� ����� ���� ��� ���� }
            If FindField(sFieldName, CountClasses) <> 0 then
              Error(ERR_RUN_TIME, 59);

            If FindMethod(sFieldName, CountClasses) <> 0 then
              Error(ERR_RUN_TIME, 77);

            { ��������� ����� ���� � ������ }
            Inc(Classes_m^[CountClasses]^.CountFields);

            Classes_m^[CountClasses]^.Fields[Classes_m^[CountClasses]^
                                                .CountFields].Name := sFieldName;
            Classes_m^[CountClasses]^.Fields[Classes_m^[CountClasses]^
                                                .CountFields].selType := 2;
            Classes_m^[CountClasses]^.Fields[Classes_m^[CountClasses]^
                                              .CountFields].Int  := 0;
            Classes_m^[CountClasses]^.Fields[Classes_m^[CountClasses]^
                                              .CountFields].Str  := '';
            Classes_m^[CountClasses]^.Fields[Classes_m^[CountClasses]^
                                                .CountFields].Bool := False;
          End;
          
          { ���� ���� ������ => ����� ����� }
          If CurCh >= Length(SourceCode[CurLine]^) then
            Break;

          If Not Match(',') then
            Error(ERR_RUN_TIME, 58);

        End; { While True }

      End; { Else }

      { ����� �� ������ GetString }
      If (CurLine + 1) > CountLines then
        Error(ERR_RUN_TIME, 60);

      GetString;
    End; { While CurLine < CountLines ... }

    If Not Match('��� �����') then
      Error(ERR_RUN_TIME, 60);

    { ----------------------------------------------}
    { ������������ ��������� ������ (���� �� ����). }
    If Classes_m^[CountClasses]^.Parent <> 0 then
    Begin
      { ������ ��������� ���� � ������ ������ }
      { ������ � ���� ������ ����� ���� ��������������� }
      IdxParent   := Classes_m^[CountClasses]^.Parent;

      { �� 1 �� ����� ����� � ������ }
      For i := 1 to Classes_m^[IdxParent]^.CountFields do
      Begin
        { ���� � ������ ��� ������ ����, �� ��������� ��� }
        If FindField(Classes_m^[IdxParent]^.Fields[i].Name, CountClasses) = 0 then
        Begin
          With Classes_m^[CountClasses]^ do
          Begin
            Inc(CountFields);
            If BaseField(Classes_m^[IdxParent]^.Fields[i].Name) then
              Fields[CountFields] := Classes_m^[IdxParent]^.Fields[i]
            Else Begin
              Fields[CountFields].Name := Classes_m^[IdxParent]^.Fields[i].Name;
              Fields[CountFields].selType := 2;
              Fields[CountFields].Int  := 0;
              Fields[CountFields].Str  := '';
              Fields[CountFields].Bool := False;
            End; {else}
          End; {with}
        End; {if <��� ������ ����>}
      End; {for}

      { ������ ��������� � �������� ������ }
      For i := 1 to Classes_m^[IdxParent]^.CountMethods do
      Begin
        { ���� � ������ ��� ������ ������, �� ��������� ��� }
        If FindMethod(Classes_m^[IdxParent]^.Methods[i].Name, CountClasses) = 0 then
        Begin
          With Classes_m^[CountClasses]^ do
          Begin
            Inc(CountMethods);
            { ������ ��� ����� ����� }
            New(Methods[CountMethods]);
            Methods[CountMethods] := Classes_m^[IdxParent]^.Methods[i];
          End; {with}
        End; {if}
      End; {for}
    End {if <���� ������>}
    Else Begin
      { ��� ������ }
      { ��������� �� ����������� }
      { ���� ������ ����� ���� ��������������� }
           
      { �� 1 �� ����� ����� � ����������� }
      For i := 1 to 7 do
      Begin
        { ���� � ������ ��� ������ ����, �� ��������� ��� }
        If FindField(Classes_m^[1]^.Fields[i].Name, CountClasses) = 0 then
        Begin
          With Classes_m^[CountClasses]^ do
          Begin
            Inc(CountFields);
            Fields[CountFields] := Classes_m^[1]^.Fields[i];
          End; {with}
        End; {if <��� ������ ����>}
      End; {for}
    End; {else}
  End;

  { -------------------------------------------------------------------- }
  { ���� ����� �� ������ }
  Function FindClass(const sClassName : String) : Word;
  Var
    i : Word;
  Begin
    FindClass := 0;
    For i := 1 to CountClasses do
      If Classes_m^[i]^.Name = sClassName then
      Begin
        FindClass := i;
        Exit;
      End;
  End;

  { -------------------------------------------------------------------- }
  { ���� ���� � ������ }
  Function FindField(const sFieldName : String; IdxClass : Word) : Word;
  Var
    i : Word;
  Begin
    FindField := 0;
    For i := 1 to Classes_m^[IdxClass]^.CountFields do
      If Classes_m^[IdxClass]^.Fields[i].Name = sFieldName then
      Begin
        FindField := i;
        Exit;
      End;
  End;

  { -------------------------------------------------------------------- }
  { ��������� ����� ������ }
  Procedure AnalyzeMethod(IdxClass : Word);
  Var
    MethodType  : Byte;
    sArgName : String;
    sBuf     : String;
  
    { ������ ��������� �� ��� ���� }
    procedure GoToEndProc;
    begin
      While Not Match('���') do
      Begin
        GetString;
        If CurLine > CountLines then  { �������� �� ����� �� ������� }
          Error(ERR_RUN_TIME, 73);
      End;
    end;

    Function ArgExist(const ArgName : String; CntMethods : Word): Boolean;
    var
      i : byte;
    begin
      ArgExist := False;
      for i := 1 to Classes_m^[IdxClass]^.Methods[CntMethods]^.CountArgs do
        if Classes_m^[IdxClass]^.Methods[CntMethods]^.Args[i] = ArgName then
        begin
          ArgExist := True;
          Exit;
        end;
    end;

  Begin
    { ���� ���� �������� ����. ��� ���., �� ��������� �� � ����. ��������.}
    { ���������� True ���� ���� �������� ����. ��� ���. }
    MethodType := 3;

    If Match('����') then
      MethodType := 0
    Else If Match('���') then
      MethodType := 1;

    { ���� ��� ��. ����� ���� ��� ���, �� ������� �� ��������� }
    If (MethodType = 3) then
      Exit;

    { ������ ��� ��� ��� ���� }
    sBuf := ReadName(63);

    { ���� ���� ��� ��� � ����� ������ ��� ����, �� ����� }
    If FindMethod(sBuf, IdxClass) <> 0 then
      Error(ERR_RUN_TIME, 64); { ����� ��� ���������� }

    { ����� � ����� ������ ���� � ������ }
    If FindField(sBuf, IdxClass) <> 0 then
      Error(ERR_RUN_TIME, 76); { � ����� ������ ���� }

    If (Classes_m^[IdxClass]^.CountMethods + 1) > MAX_COUNT_METHODS then
      Error(ERR_RUN_TIME, 65);

    { ����������� ���-�� ������� � ������ }
    Inc(Classes_m^[IdxClass]^.CountMethods);
    { �������� ������ ��� ����� ����� }
    New(Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^.CountMethods]);

    { ��� ������ }
    Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^.CountMethods]^
                                                           .Name := sBuf;

    { �������������� �.� �� ��������� �������� = ??? }
    Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^.CountMethods]^
                                                       .CountArgs := 0;

    If Not Match('(') then
      Error(ERR_RUN_TIME, 66); { ������ ��� }

    SkipBlanks;
    While (Copy(SourceCode[CurLine]^, CurCh, 1) <> ')') do
    Begin
      With Classes_m^[IdxClass]^ do
      Begin
        { ������ ��� ��������� }
        sArgName := ReadName(67);

        { ����� � ����� ������ ��� ���� �������� ? }
        If ArgExist(sArgName, CountMethods) then
          Error(ERR_RUN_TIME, 68);

        { ����� � ����� ������ ��� ���� ������� ? }
        If FindFun(sArgName) <> 0 then
          Error(ERR_RUN_TIME, 79);

        { ����� � ����� ������ ���� ������ ? }
        If FindField(sArgName, IdxClass) <> 0 then
          Error(ERR_RUN_TIME, 80);

        { ����� � ����� ������ ����� ������ ? }
        If FindMethod(sArgName, IdxClass) <> 0 then
          Error(ERR_RUN_TIME, 81);

        { ��������� �� ��� ������� }
        If FindObject(sArgName) <> 0 then
          Error(ERR_RUN_TIME, 94);

        { ����� ������� ����� ���������� ? }
        If (Methods[CountMethods]^.CountArgs + 1) > MAX_COUNT_ARGS then
          Error(ERR_RUN_TIME, 69);

        { ��������� ��� � ������ ���������� ������� }
        Inc(Methods[CountMethods]^.CountArgs);
        Methods[CountMethods]^.Args[Methods[CountMethods]^.CountArgs] := sArgName;

        If Match(')') then
          Break;

        If Not Match(',') then
          Error(ERR_RUN_TIME, 70); { ����������� ������� }

        If Match(')') then
          Error(ERR_RUN_TIME, 71); { ��� ��������� ������� �� ����������� }
      End; { With ... do }
    End;

    { ��������� �� ������� ���. (����� ������������� ��� ����) }
    If (CurLine + 1) > CountLines then
      Error(ERR_RUN_TIME, 72);

    { ����� ����� � ������� }
    Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^.CountMethods]^
                         .StartLine := CurLine;

    GoToEndProc; { ������� �� ��� ���� }

    { �������� ����. � ���. }
    Case MethodType of
      0 : Begin
            Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^
            .CountMethods]^.Fun := False;
            If Not Match('����') then
              Error(ERR_RUN_TIME, 74);
          End;
      1 : Begin
            Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^
            .CountMethods]^.Fun := True;
            If Not Match('���') then
              Error(ERR_RUN_TIME, 75);
          End;
    End;

  End; { procedure }

  { -------------------------------------------------------------------- }
  { ���� ����� ������ }
  Function FindMethod(const sMethodName : String; IdxClass : Word): Word;
  Var
    i : Word;
  Begin
    { ���� ����� �� ����� � ������� ������� }
    { ���� �� ����� ���������� 0 }
    { ����� � ������ � �������  }
    FindMethod := 0;
    for i := 1 to Classes_m^[IdxClass]^.CountMethods do
    begin
      if (Classes_m^[IdxClass]^.Methods[i]^.Name = sMethodName) then
      begin
        FindMethod := i;
        Exit;
      end;
    end; { for }
  End;

  { -------------------------------------------------------------------- }
  { ��������� �������� �������� }
  Procedure AnalyzeObjects;
  Var
    sObjName, sClassName : String;
    IdxClass, OldCountObj : Word;
    IdxObj, IdxField : Word;
  Begin
    { ������ �,�,� = ���_����� }
    If Not Match('������') then
      Exit;

    { ������ ��� ������ �������� }
    If Not AllocMemObjects then
    Begin                
      AllocMemObjects := True;
      New(Objects_m);
    End;

    { ��������� ���-�� ��������. }
    { ��� ����������� ����� �� ������ � ������ }
    OldCountObj := CountObjects;
    Repeat
      { ������ ��� ������� }
      sObjName := ReadName(82);

      { ����� �� ������� ����� ? }
      If (CountObjects + 1) > MAX_COUNT_OBJECTS then
        Error(ERR_RUN_TIME, 83);

      { ����� � ����� ������ ������ ���� }
      If FindObject(sObjName) <> 0 then
        Error(ERR_RUN_TIME, 84);

      { ����� � ����� ������ ������� ���� }
      If FindFun(sObjName) <> 0 then
        Error(ERR_RUN_TIME, 85);

      { ������ ��� ��������� ������ }
      Inc(CountObjects);
      New(Objects_m^[CountObjects]);

      { ��� ������� }
      Objects_m^[CountObjects]^.Name := sObjName;

      If CurCh >= Length(SourceCode[CurLine]^) then
        Error(ERR_RUN_TIME, 87);

      SkipBlanks;
      If Copy(SourceCode[CurLine]^,CurCh,1) = '=' then
        Break;

      If Not Match(',') then
        Error(ERR_RUN_TIME, 86);

      SkipBlanks;
    Until (Copy(SourceCode[CurLine]^,CurCh,1) = '=');

    If Not Match('=') then
      Error(ERR_RUN_TIME, 88);

    { �������� ��� ������ }
    sClassName := ReadName(89);

    { ���������� �� ����� ����� ? }
    IdxClass := FindClass(sClassName);
    If IdxClass = 0 then
      Error(ERR_RUN_TIME, 90);

    { �������� ��� ���� �� ������ � ������ �.�. � ������� ������� ���� }
    { ��������� �����. � ������� ������ ����� RefToClass }
    For IdxObj := OldCountObj + 1 to CountObjects do
    Begin
      { ��� ���� ������ }
      For IdxField := 1 to Classes_m^[IdxClass]^.CountFields do
      Begin
        Objects_m^[IdxObj]^.Fields[IdxField] :=
                                 Classes_m^[IdxClass]^.Fields[IdxField];
      End;
      { ���-�� ����� }
      Objects_m^[IdxObj]^.CountFields := Classes_m^[IdxClass]^.CountFields;

      { ������ �� ����� }
      Objects_m^[IdxObj]^.RefToClass := IdxClass;
    End; { for }

  End;

  { -------------------------------------------------------------------- }
  { ����� ������� }
  Function FindObject(const sObjName : String) : Word;
  Var
    i : Word;  
  Begin
    FindObject := 0;
    For i := 1 to CountObjects do
    Begin
      If Objects_m^[i]^.Name = sObjName then
      Begin
        FindObject := i;
        Exit;
      End;
    End; { for }
  End;

  { ---------------------------------------------------------------------- }
  { �������� ����� ������ }
  Procedure CallMethod(IdxClass, IdxMethod, IdxObject : Word);
  Var
    wTop, wBottom, wArgs, wFun : Word;
    IdxArg, i         : Word;
    wLine, wCur, wBuf : Word;
    wObject, wMethod  : Word;
    wClass            : Word;
    sBuf : String;
  Begin
    { IdxFun - ����� ��� ��� ���� � ������� ������� ������ }
    { ��������� ������ ������� ��������� }
    wBottom := BottomBorder;
    wTop    := TopBorder;

    With Classes_m^[IdxClass]^ do
    Begin

      sBuf := Objects_m^[IdxObject].Name + '.' + Methods[IdxMethod]^.Name + '(';

      { ����������� ������ ���� ���� ������ : s := f() + 4 }
      If Not Match('(') then
        Error(ERR_RUN_TIME, 101);

      wArgs := 0;
      { ��������� ������������ ���������� }
      { ���������� � ���� ������������ ��������, � ����� }
      { �������� �� ����� }
      If Methods[IdxMethod]^.CountArgs <> 0 then
      Begin
        { ������-�� ���� (����� - break) }
        Repeat
          { MyObj.msg('Hello World', 3+4, .�. ��� .�.) }
          Inc(wArgs);
          { ��������� ��������� �������� }
          WorkExpression;
          IdxArg := CreateNewVar('');

          { ����������� ������. }
          Stack[IdxArg]^.selType := AX.selType;
          Stack[IdxArg]^.Str  := AX.Str;
          Stack[IdxArg]^.Int  := AX.Int;
          Stack[IdxArg]^.Bool := AX.Bool;

          If fDebugMode then
          begin
            Case AX.selType of
              1 : sBuf := sBuf + #39 + AX.Str + #39;
              2 : sBuf := sBuf + IntToStr(AX.Int);
              3 : If AX.Bool then
                    sBuf := sBuf + '.�.'
                  Else
                    sBuf := sBuf + '.�.';
            End;
          end;

          If SourceCode[CurLine]^[CurCh] = ')' then
            Break;
          If Not Match(',') then
            Error(ERR_RUN_TIME, 43);

          If fDebugMode then
            sBuf := sBuf + ', ';
            
        Until False;
      End; { If CountArgs <> 0 }

      If Not Match(')') then
        Error(ERR_RUN_TIME, 104);

      If fDebugMode then
      begin
        sBuf := sBuf + ') : ' + IntToStr(CurLine);
        frmCallStack.lstCallStack.Items.Add(sBuf);
      end;

      { ������� ������� �����-�� � ��-�� ������� ���-�� }
      If wArgs <> Methods[IdxMethod]^.CountArgs then
        Error(ERR_RUN_TIME, 44);

      { ������������� ����� � ����� }
      wArgs := 0;
      For i := wTop + 1 to TopBorder do
      Begin
        Inc(wArgs); { - ����� �������� �� ����� }

        { ����� � ����� ������ ��� ���� ������� }
        wBuf := FindFun(Methods[IdxMethod]^.Args[wArgs]);
        If wBuf <> 0 then
          Error(ERR_RUN_TIME, 48);

        { ��������� �� ��� ������� }
        If FindObject(Methods[IdxMethod]^.Args[wArgs]) <> 0 then
          Error(ERR_RUN_TIME, 93);

        { ����� � ����� ������ ���� ����� � ������ ? }
        If FindMethod(Methods[IdxMethod]^.Args[wArgs], IdxClass) <> 0 then
          Error(ERR_RUN_TIME, 102);

        { ����� � ����� ������ ���� ���� � ������ ? }
        If FindField(Methods[IdxMethod]^.Args[wArgs], IdxClass) <> 0 then
          Error(ERR_RUN_TIME, 103);

        Stack[i]^.Name := Methods[IdxMethod]^.Args[wArgs];
      End; { for }

      { ����� ������� ��������� ���������� }
      { �.� ����� � ������� }
      BottomBorder := wTop + 1;

      wLine   := CurLine;
      wCur    := CurCh;
      wFun    := CurrentFun;
      wMethod := CurrentMethod;
      wObject := CurrentObject;
      wClass  := CurrentClass;

      { ������ ����� ������� ������ (��� WorkReturn() ) }
      CurrentMethod := IdxMethod;

      { ������ ����� ������� ������ }
      CurrentObject := IdxObject;

      { ���� ���������� CurrentMethod, �� CurrentFun ������� }
      { � ��������. }
      CurrentFun := 0;

      { ��� ������� ������� � ����� }
      CurrentClass := IdxClass;

      { ����������� � ���� ������� }
      CurLine := Methods[IdxMethod]^.StartLine;

      If Methods[IdxMethod]^.Fun then
        res := Statement('��� ���','��� ���')
      Else
        res := Statement('��� ����','��� ����');

      { ����������� ������ �� ��� ���������� }
      If BottomBorder > 0 then
        For i := BottomBorder to TopBorder do
          Dispose(Stack[i]);

      { ������� �� ������ }
      CurLine := wLine;
      CurCh   := wCur;
      BottomBorder  := wBottom;
      TopBorder     := wTop;
      CurrentMethod := wMethod;
      CurrentObject := wObject;
      CurrentClass  := wClass;
      CurrentFun    := wFun;

      If fDebugMode then
        frmCallStack.lstCallStack.Items.Delete(frmCallStack.lstCallStack.Items.Count - 1);
    End; {with}
  End;

  { -------------------------------------------------------------------- }
  { ��������� ��������� ������� (���������) }
  Procedure WorkIf;
  Var
    fBuf : Boolean;
  Begin
    WorkExpression;
    
    If Not fExec then
    begin
      AX.selType := 3;
    end;
    
    { ���. ��������� ������ ���� ����������� ���� }
    If AX.selType <> 3 then
      Error(ERR_RUN_TIME, 26);

    { ���� ��������� ������, �� ������� �� ����� (���� ��� ����)   }
    { ��� �� �� (�������� ���������). ���� �� �� ����� ���������, }
    { �� ���������� fExec � ���� �� �� �� �������� ���������.     }
    { ���� ����� ���, �� �� ��� ���������� }

    { ���� ��������� ����, �� ������� �� ����� (���� ��� ����)          }
    { ��� �� �� (!!! �� �������� ���������). ���� �� �� ����� �������, }
    { �� ������������� fExec � ��������� ��� ��������� �� �Ѩ.          }
    { ���� ����� ���, �� ��������� ������ }

    If AX.Bool then
    Begin
      res   := Statement('�����','��');

      { ���� ����� �� �����, �� ������� �� �� �� �������� ��������� }
      If res = 1 then
      Begin
        { ��������� (��-�� ��������) }
        fBuf  := fExec;
        fExec := False;

        res   := Statement('��', '��');

        { �������������� ������ �������� }
        fExec := fBuf;
      End;
    End
    Else Begin
      { ������� �� �� ��� ����� �� �������� ��������� }
      { ��������� (��-�� ��������) }
      fBuf  := fExec;
      fExec := False;

      res   := Statement('�����', '��');
      { �������������� ������ �������� }
      fExec := fBuf;

      If res = 1 then  { ���� �� ����� }
      Begin
        res   := Statement('��', '��');
      End;
    End; { AX.Bool = True/False }

  End;

  { -------------------------------------------------------------------- }
  { ���� ������ }
  Procedure WorkRepeat;
  Var
    i, RepeatCnt   : Longint;
    wBuf : Word;
  Begin
    { ��������� ���-�� ������ ����� }
    WorkExpression;

    If fExec then
    Begin
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 28);

      { ���-�� �������� (������) ����� }
      RepeatCnt := AX.Int;
    End
    Else RepeatCnt := 1; { �� ����� ����� ����� �� }
                         {�� (�� ������.) }

    { �������� ������ ��������� � ���� (�� �������� � }
    { ����� � �����. ����) }
    wBuf  := CurLine;
    For i := 1 to RepeatCnt do
    Begin
      CurLine := wBuf;
      res  := Statement('��', '��');
    End;
  End;

  { -------------------------------------------------------------------- }
  { ���� ���� }
  Procedure WorkWhile;
  Var
    wLine, wCur : Word;
    fBuf : Boolean;
  Begin
    If Not fExec then
    Begin
      { ������ ���������� �� �� }
      { � ������� �� ����. }
      fBuf  := fExec;
      fExec := False;
      res   := Statement('��','��');
      fExec := fBuf;
      Exit;
    End;

    wLine := CurLine;
    wCur  := CurCh;
    Repeat { ����������� ���� }
      CurLine := wLine;
      CurCh   := wCur;
      WorkExpression;
      If AX.selType <> 3 then
        Error(ERR_RUN_TIME, 29);

      If AX.Bool then
        res := Statement('��','��')
      Else Begin
        { ��������� ����� => ���������� ������ �� �� }
        { � ������� �� ����. }
        fBuf  := fExec;
        fExec := False;
        res   := Statement('��','��');
        fExec := fBuf;
        Exit;
      End;
    Until False;
  End;

  { -------------------------------------------------------------------- }
  { ���� ��������� �� ����� }
  Function FindVar(const sVarName : String) : Word;
  Var
    i : Word;
  Begin
    FindVar := 0;
    { ���� ������ ��� ���������� }
    If TopBorder < 1 then
      Exit;

    { ���� � ������� ������� ��������� }
    For i := BottomBorder to TopBorder do
    Begin
      If Stack[i]^.Name = sVarName then
      Begin
        FindVar := i;
        Exit;
      End;
    End; { for }
  End;

  { -------------------------------------------------------------------- }
  { ������ ����� ��������� ���������� }
  Function CreateNewVar(const sVarName : String) : Word;
  Var
    IdxFun, wBuf : Word;
  Begin
    { ����� ���� �� ������ ����� ? }
    If (TopBorder + 1) > MAX_COUNT_VARS Then
      Error(ERR_RUN_TIME, 32);

    { ����� � ����� ������ ��� ���� ������� }
    IdxFun := FindFun(sVarName);
    If IdxFun <> 0 then
      Error(ERR_RUN_TIME, 48);

    { ����� � ����� ������ ��� ���� ���������� }
    If sVarName <> '' then
    Begin
      wBuf := FindVar(sVarName);
      If wBuf <> 0 then
        Error(ERR_RUN_TIME, 49);

      { ��������� �� ��� ������� }
      If FindObject(sVarName) <> 0 then
        Error(ERR_RUN_TIME, 95);
    End; { if }


    { ������ ����� � �������� ��� �� ������ }
    Inc(TopBorder);
    New(Stack[TopBorder]);

    { �� ��������� ��� ���������� - 2 (�������������) }
    Stack[TopBorder]^.Name := sVarName;
    Stack[TopBorder]^.selType := 2;
    Stack[TopBorder]^.Str  := '';
    Stack[TopBorder]^.Int  := 0;
    Stack[TopBorder]^.Bool := False;

    { ���������� ���������� ����� ���������� }
    CreateNewVar := TopBorder;
  End;

  { -------------------------------------------------------------------- }
  { ������ ��������� � ����� ������ }
  Function WorkStrightAccess(const sMember : String) : Boolean;
  Var
    IdxMember  : Word;
    ImageIndex : Word;
  Begin
    WorkStrightAccess := False;

    { ����� ��� ����� ? }
    { ���� � ������ }
    IdxMember := FindMethod(sMember, CurrentClass);
    If IdxMember <> 0 then
    Begin
      { ��� ��������� ����� ������ ��������� }
      If Classes_m^[CurrentClass]^.Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 99);

      { �������� ����� }
      CallMethod(CurrentClass, IdxMember, CurrentObject);

      { ����� �� ������� }
      WorkStrightAccess := True;
      Exit;
    End;

    { ��� ���� ? }
    IdxMember := FindField(sMember, CurrentClass);
    If IdxMember <> 0 then
    Begin
      If Not Match(':=') then
        Error(ERR_RUN_TIME, 114);  { ��� := }

      WorkExpression;

      Objects_m^[CurrentObject]^.Fields[IdxMember].selType := AX.selType;
      Objects_m^[CurrentObject]^.Fields[IdxMember].Int  := AX.Int;
      Objects_m^[CurrentObject]^.Fields[IdxMember].Str  := AX.Str;
      Objects_m^[CurrentObject]^.Fields[IdxMember].Bool := AX.Bool;

      ImageIndex := CurrentObject - (CountObjects - CountIspolns + 1) + 1; 
      
      If sMember      = '�����'    then
        frmRunTime.Images[ImageIndex].Left := AX.Int
      Else if sMember = '������'     then
        frmRunTime.Images[ImageIndex].Top  :=  AX.Int
      Else if sMember = '������'    then
        frmRunTime.Images[ImageIndex].Width   := AX.Int
      Else if sMember = '������'    then
        frmRunTime.Images[ImageIndex].Height  := AX.Int
      Else if sMember = '���������' then
        frmRunTime.Images[ImageIndex].Visible := AX.Bool
      Else if sMember = '����������' then
        frmRunTime.Images[ImageIndex].Stretch := AX.Bool
      Else if sMember = '��������'  then
        frmRunTime.Images[ImageIndex].Picture.LoadFromFile(AX.Str);

      Application.ProcessMessages;

     WorkStrightAccess := True;
    End; {if}
  End;

  { -------------------------------------------------------------------- }
  { ��������� � ����� ������� ����� '.' }
  Procedure WorkObjectMember(IdxObject : Word);
  Var
    IdxMember  : Word;
    sMember    : String;
    ImageIndex : Word;
  Begin

    sMember := ReadName(97);

    { ����� ��� ����� ? }
    IdxMember := FindObjectMethod(sMember, IdxObject);
    If IdxMember <> 0 then
    Begin
      { ��� ��������� ����� ������ ��������� }
      If Classes_m^[Objects_m^[IdxObject]^.RefToClass]^
                                   .Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 99);

      { �������� ����� }
      CallMethod(Objects_m^[IdxObject]^.RefToClass, IdxMember, IdxObject);

      { ����� �� ������� }
      Exit;
    End;

    { ��� ���� }
    IdxMember := FindObjectField(sMember, IdxObject);
    If IdxMember = 0 then
      Error(ERR_RUN_TIME, 98);

    If Not Match(':=') then
      Error(ERR_RUN_TIME, 114);  { ��� := }

    WorkExpression;

    Objects_m^[IdxObject]^.Fields[IdxMember].selType := AX.selType;
    Objects_m^[IdxObject]^.Fields[IdxMember].Int  := AX.Int;
    Objects_m^[IdxObject]^.Fields[IdxMember].Str  := AX.Str;
    Objects_m^[IdxObject]^.Fields[IdxMember].Bool := AX.Bool;


    ImageIndex := IdxObject - (CountObjects - CountIspolns + 1) + 1; 

    If sMember      = '�����'    then
      frmRunTime.Images[ImageIndex].Left := AX.Int
    Else if sMember = '������'     then
      frmRunTime.Images[ImageIndex].Top  :=  AX.Int
    Else if sMember = '������'    then
      frmRunTime.Images[ImageIndex].Width   := AX.Int
    Else if sMember = '������'    then
      frmRunTime.Images[ImageIndex].Height  := AX.Int
    Else if sMember = '���������' then
      frmRunTime.Images[ImageIndex].Visible := AX.Bool
    Else if sMember = '����������' then
      frmRunTime.Images[ImageIndex].Stretch := AX.Bool
    Else if sMember = '��������'  then
      frmRunTime.Images[ImageIndex].Picture.LoadFromFile(AX.Str);

    Application.ProcessMessages;

  End;

  { -------------------------------------------------------------------- }
  { �������� ���������� � ����� ������� }
  Procedure WorkAssignment;
  Var
    sName  : String;
    Idx, IdxVar : Word;
  Begin
    If Not fExec then
      Exit;

    { ��������� ��������������� : }
    { 1. ��������     }
    { 2. ���� � ���   }
    { 3. ����������   }

    { ��������� ������ ������� ��� ��������� ���������� }

    If Match('������') then
    Begin
      WorkParent(True);
      Exit;
    End;

    sName  := ReadName(30);

    { ��� ������ ? }
    Idx := FindObject(sName);
    If Idx <> 0 then
    Begin
      if Not Match('.') then
        Error(ERR_RUN_TIME, 96);

      { Idx - ������ ������� }
      { ��������� ��������� � ����� ������� }
      WorkObjectMember(Idx);
      Exit;
    End;

    { ���� �� � ������, �� ���� ����������� �������� ���������� }
    { � ��������� ������ }
    If (CurrentMethod <> 0) And (CurrentObject <> 0) then
    Begin

      If WorkStrightAccess(sName) then
        Exit;
    End;

    { ��� ������� ? }
    Idx := FindFun(sName);

    If Idx <> 0 then
    Begin
      { ����� ����� ������� ���� ����� }
      If Idx = ProcStart then
        Error(ERR_RUN_TIME, 46);

      If Functions^[Idx]^.Fun then
        Error(ERR_RUN_TIME, 52);

      { �������� ���. ��� ���� � ������� ������ }
      CallFunction(Idx);
      Exit;
    End;

    IdxVar := FindVar(sName);

    { ���� �����. �� ���������� ������ � }
    If IdxVar = 0 then
      IdxVar := CreateNewVar(sName);


    { ������ ��� ����. ���������� �.� �� ��� ��������� ����-��}
    { ����� �� ��� ���������. }
    If Not Match(':=') then
      Error(ERR_RUN_TIME, 31);  { ������������� �� �������� }

    { ��������� ��������� }
    WorkExpression;

    { ����������� ��������� ����������. }
    { ����� ��������� ��� ����, ��� ������������� }
    { selType � AX (����� 3 ���������� ��� 2 �����. � 3 ��������) }

    Stack[IdxVar]^.selType  := AX.selType;
    Stack[IdxVar]^.Int  := AX.Int;
    Stack[IdxVar]^.Str  := AX.Str;
    Stack[IdxVar]^.Bool := AX.Bool;
  End;

  { -------------------------------------------------------------------- }
  { ���� ����� ������� }
  Function FindObjectMethod(const sMember : String; IdxObject : Word) : Word;
  Var
    i : Word;
  Begin
    FindObjectMethod := 0;
    With Classes_m^[Objects_m^[IdxObject]^.RefToClass]^ do
    Begin
      For i := 1 to CountMethods do
        If Methods[i]^.Name = sMember then
        Begin
          FindObjectMethod := i;
          Exit;
        End;
    End; { with }
  End;

  { -------------------------------------------------------------------- }
  { ���� ���� ������� }
  Function FindObjectField(const sMember : String; IdxObject : Word) : Word;
  Var
    i : Word;
  Begin
    FindObjectField := 0;
    For i := 1 to Objects_m^[IdxObject]^.CountFields do
      If Objects_m^[IdxObject]^.Fields[i].Name = sMember then
      Begin
        FindObjectField := i;
        Exit;
      End;
  End;

  { -------------------------------------------------------------------- }
  { ���� ��� }
  Procedure WorkFor;
  Var
    sVarName : String;
    V1,V2, Step  : Longint;
    IdxVar,wLine : Word;
    fBuf : Boolean;
    { ��������� ������� ����� }
    function GetValue : Longint;
    begin
      WorkExpression;
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 35);
      GetValue := AX.Int;
    end;

  Begin
    If Not fExec then
    Begin
      res := Statement('��','��');
      Exit;
    End;

    { ��� � �� 1 �� 12 ��� 3}
    sVarName := ReadName(30);

    { ���� ��� ����� ���������� }
    If sVarName = '��' then
      Error(ERR_RUN_TIME, 51);

    If Not Match('��') then
      Error(ERR_RUN_TIME, 34);

    { �������� ������� ����� }
    V1 := GetValue;
    If Not Match('��') then
      Error(ERR_RUN_TIME, 36);
    V2 := GetValue;

    { ���������� ��� ����� (1-��������) }
    Step := 1;
    If Match('���') then
    Begin
      WorkExpression;
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 37);
      Step := AX.Int;
    End;

    { V1 to/dowto V2 - ? }
    wLine := CurLine;
    
    { �������� ���������� ����� �������� ����� (���������) }
    { ����� ������ ����� ��� ������� � �����. }
    IdxVar := FindVar(sVarName);
    If IdxVar = 0 then
      IdxVar := CreateNewVar(sVarName)
    Else
    Begin
      If Stack[IdxVar]^.selType <> 2 then
        Error(ERR_RUN_TIME, 38);
    End;
        
    If (Step > 0) And (V1 <= V2) then
    begin
      { ������ ���� ������� ������� �������� }
      Stack[IdxVar]^.Int := V1;
      While Stack[IdxVar]^.Int <= V2 do
      Begin
        CurLine := wLine;
        res := Statement('��','��');
        Stack[IdxVar]^.Int := Stack[IdxVar]^.Int + Step;
      End;
    End
    Else If (Step < 0) And (V1 >= V2) then
    Begin
      { ������ ���� ������� ������� �������� }
      Stack[IdxVar]^.Int := V1;
      While Stack[IdxVar]^.Int >= V2 do
      Begin
        CurLine := wLine;
        res := Statement('��','��');
        Stack[IdxVar]^.Int := Stack[IdxVar]^.Int + Step;
      End;
    End
    Else If (Step = 0) then
    Begin
      Stack[IdxVar]^.Int := V1;
      While True do
      Begin
        CurLine := wLine;
        res := Statement('��','��');
      End;
    End
    Else Begin
      fBuf  := fExec;
      fExec := False;

      res   := Statement('��', '��');

      { �������������� ������ �������� }
      fExec := fBuf;  
    End;
  End;

  { -------------------------------------------------------------------- }
  { ��������� ��������� ������� }
  Procedure WorkReturn;
  Begin
    If Not fExec then
      Exit;

    WorkExpression;

    { �� � ���. ��� ������ ? }
    If CurrentFun <> 0 then
    Begin
      If Not Functions^[CurrentFun]^.Fun then
        Error(ERR_RUN_TIME, 47);

      Functions^[CurrentFun]^.Result.selType := AX.selType;
      Functions^[CurrentFun]^.Result.Str  := AX.Str;
      Functions^[CurrentFun]^.Result.Int  := AX.Int;
      Functions^[CurrentFun]^.Result.Bool := AX.Bool;End
    Else Begin
      If Not Classes_m^[Objects_m^[CurrentObject]^.RefToClass]^
                                  .Methods[CurrentMethod]^.Fun then
        Error(ERR_RUN_TIME, 105);

      With Classes_m^[CurrentClass]^ do
      Begin
        Methods[CurrentMethod]^.Result.selType := AX.selType;
        Methods[CurrentMethod]^.Result.Str  := AX.Str;
        Methods[CurrentMethod]^.Result.Int  := AX.Int;
        Methods[CurrentMethod]^.Result.Bool := AX.Bool;
      End; {with}
    End;
  End;

  { -------------------------------------------------------------------- }
  { ��������� ��������� � ������ ������ }
  Procedure WorkParent(bLeftPart : Boolean);
  Var
    sName     : String;
    IdxMember : Word;
  Begin
    { If LeftPart then }
    {   ����� ���������� ������ � ���������� ������ }
    { Else }
    {   ����� ���������� ������ � �������� ������   }

    If (CurrentMethod = 0) Or (CurrentObject = 0) then
      Error(ERR_RUN_TIME, 106);
    If Not Match('.') then
      Error(ERR_RUN_TIME, 107);

    { ����� �� ���� ����� ������ ? }
    If Classes_m^[CurrentClass]^.Parent = 0 then
      Error(ERR_RUN_TIME, 113);

    sName := ReadName(108);

    IdxMember := FindMethod(sName, Classes_m^[CurrentClass]^.Parent);
    If IdxMember = 0 then
      Error(ERR_RUN_TIME, 111);

    If bLeftPart then
    Begin
      { ��� ��������� ����� ������ ��������� }
      If Classes_m^[Classes_m^[CurrentClass]^.Parent]^
                                      .Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 99);

      CallMethod(Classes_m^[CurrentClass]^.Parent,
                                           IdxMember,CurrentObject);
    End
    Else Begin
      { ��� ��������� ����� ������ ������� }
      If Not Classes_m^[Classes_m^[CurrentClass]^.Parent]^
                                        .Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 112);

      { �������������� ������������ �������� }
      With Classes_m^[Classes_m^[CurrentClass]^.Parent]^ do
      Begin
        Methods[IdxMember]^.Result.selType := 2;
        Methods[IdxMember]^.Result.Str  := '';
        Methods[IdxMember]^.Result.Int  := 0;
        Methods[IdxMember]^.Result.Bool := False;
      End;

      CallMethod(Classes_m^[CurrentClass]^.Parent,
                                           IdxMember, CurrentObject);

      With Classes_m^[Classes_m^[CurrentClass]^.Parent]^ do
      Begin
        { ��������� ��������� ������� }
        AX.selType := Methods[IdxMember]^.Result.selType;
        AX.Int  := Methods[IdxMember]^.Result.Int;
        AX.Str  := Methods[IdxMember]^.Result.Str;
        AX.Bool := Methods[IdxMember]^.Result.Bool;
      End;
    End; {else}
  End;

  { -------------------------------------------------------------------- }
  Procedure PrintMsg;
  Begin
    If Not fExec then
      Exit;

    WorkExpression;
    If frmCon.Visible = False then
    begin
      frmCon.lstOut.Clear;
      frmCon.Show;
    end;

    Case AX.selType of
      1 : frmCon.PrintMessage(AX.Str);
      2 : frmCon.PrintMessage(IntToStr(AX.Int));
      3 : If AX.Bool then
            frmCon.PrintMessage('.�.')
          Else
            frmCon.PrintMessage('.�.');
    End;
  End;

  { -------------------------------------------------------------------- }
  Procedure ShowMsg;
  Begin
    If Not fExec then
      Exit;

    WorkExpression;

    Case AX.selType of
      1 : ShowMessage(AX.Str);
      2 : ShowMessage(IntToStr(AX.Int));
      3 : If AX.Bool then
            ShowMessage('.�.')
          Else
            ShowMessage('.�.');
    End;
  End;

  procedure ReadVal(var Val : Integer; fLast : Boolean);
  begin
    WorkExpression;
    If (AX.selType <> 2) then
      Error(ERR_RUN_TIME, 123);

    Val := AX.Int;
    If (Not Match(',')) And (Not fLast) then
      Error(ERR_RUN_TIME, 43);
  end;

  { -------------------------------------------------------------------- }
  Procedure WorkPixel;
  var
    x,y : Integer;
  Begin
    If Not fExec then
      Exit;
      
    //����� (x1,y1)
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    ReadVal(x, False);
    ReadVal(y, True);

    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);

    AX.selType := 2;
    AX.Int := frmRunTime.imgDrawField.Canvas.Pixels[x,y];  
  End;

  { -------------------------------------------------------------------- }
  Procedure WorkCircle;
  var
    x1,y1,r  : Integer;
    sColor   : String;
    tmpBrush : TBrush; 
  Begin
    If Not fExec then
      Exit;

    //����(x1,y1,r,color)
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    ReadVal(x1, False);
    ReadVal(y1, False);
    ReadVal(r,  False);

    sColor := ReadName(30);
    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);

    Application.ProcessMessages;
    tmpBrush := frmRunTime.imgDrawField.Canvas.Brush;
    frmRunTime.imgDrawField.Canvas.Brush.Style := bsClear;
    frmRunTime.imgDrawField.Canvas.Pen.Color := StringToColor(sColor);
    frmRunTime.imgDrawField.Canvas.Ellipse(x1 - r, y1 - r, x1 + r, y1 + r);
    frmRunTime.imgDrawField.Canvas.Brush := tmpBrush;
  End;

  { -------------------------------------------------------------------- }
  Procedure WorkPset;
  var
    x1,y1  : Integer;
    sColor : String;
  Begin
    If Not fExec then
      Exit;
      
    //���(x1,y1,color)
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    ReadVal(x1, False);
    ReadVal(y1, False);

    sColor := ReadName(30);
    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);

    Application.ProcessMessages;
    frmRunTime.imgDrawField.Canvas.Pixels[x1,y1] := StringToColor(sColor);

  End;

  { -------------------------------------------------------------------- }
  Procedure WorkLine;
  var
    x1,y1,x2,y2: Integer;
    sColor : String;
  Begin
    If Not fExec then
      Exit;
      
    //����� (x1,y1,x2,y2,color)
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    ReadVal(x1, False);
    ReadVal(y1, False);
    ReadVal(x2, False);
    ReadVal(y2, False);

    sColor := ReadName(30);
    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);

    Application.ProcessMessages;
    frmRunTime.imgDrawField.Canvas.Pen.Color := StringToColor(sColor);
    frmRunTime.imgDrawField.Canvas.MoveTo(x1,y1);
    frmRunTime.imgDrawField.Canvas.LineTo(x2,y2);

  End;

  { -------------------------------------------------------------------- }
  Procedure WorkFill;
  var
    x1,y1,x2,y2: Integer;
    sColor : String;
    OldColor : TColor;
    MyRect   : TRect; 
  Begin
    If Not fExec then
      Exit;
    
    // ������ (x1,y1,x2,y2,color)
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    ReadVal(x1, False);
    ReadVal(y1, False);
    ReadVal(x2, False);
    ReadVal(y2, False);

    sColor := ReadName(30);
    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);

    MyRect.Left  := x1;
    MyRect.Top   := y1;
    MyRect.Bottom := y2;
    MyRect.Right := x2;

    Application.ProcessMessages;
    OldColor := frmRunTime.imgDrawField.Canvas.Brush.Color;
    frmRunTime.imgDrawField.Canvas.Brush.Color := StringToColor(sColor);
    frmRunTime.imgDrawField.Canvas.FillRect(MyRect);
    frmRunTime.imgDrawField.Canvas.Brush.Color := OldColor;
  End;

  { -------------------------------------------------------------------- }
  Procedure WorkTriangle;
  var
    sColor : String;
    OldColor : TColor;
    Coords   : Array [1..3] Of TPoint;
  Begin
    If Not fExec then
      Exit;

    // ���(x1,y1,x2,y2,x3,y3,color)
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    ReadVal(Coords[1].x, False);
    ReadVal(Coords[1].y, False);
    ReadVal(Coords[2].x, False);
    ReadVal(Coords[2].y, False);
    ReadVal(Coords[3].x, False);
    ReadVal(Coords[3].y, False);

    sColor := ReadName(30);
    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);


    Application.ProcessMessages;
    OldColor := frmRunTime.imgDrawField.Canvas.Brush.Color;

    frmRunTime.imgDrawField.Canvas.Brush.Color := StringToColor(sColor);
    frmRunTime.imgDrawField.Canvas.Polygon(Coords);
    frmRunTime.imgDrawField.Canvas.Brush.Color := OldColor;
  End;

  { -------------------------------------------------------------------- }
  Procedure WorkDrawing;
  var
    x1,y1,x2,y2 : Integer;
    MyRect      : TRect;
    MyImage     : Graphics.TBitmap;
  Begin
    If Not fExec then
      Exit;

    // ������� (x1,y1,x2,y2,'my.bmp')
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    ReadVal(x1, False);
    ReadVal(y1, False);
    ReadVal(x2, False);
    ReadVal(y2, False);

    WorkExpression;

    If AX.selType <> 1 then
      Error(ERR_RUN_TIME, 123);

    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);

    MyRect.Left   := x1;
    MyRect.Top    := y1;
    MyRect.Bottom := y2;
    MyRect.Right  := x2;

    MyImage := Graphics.TBitmap.Create;
    MyImage.LoadFromFile(AX.Str);

    Application.ProcessMessages;
    frmRunTime.imgDrawField.Canvas.StretchDraw(MyRect, MyImage);

  End;

  { -------------------------------------------------------------------- }
  Procedure WorkText;
  var
    x1, y1      : Integer;
    ForeColor   : string;
    BGColor     : string;
    txt         : string;
    colors      : array [0..1] of TColor;
  Begin
    If Not fExec then
      Exit;

    // �����(x1,y1,ForeColor, BGColor, '')
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    ReadVal(x1, False);
    ReadVal(y1, False);

    ForeColor := ReadName(30);

    If Not Match(',') then
      Error(ERR_RUN_TIME, 43);

    BGColor := ReadName(30);

    If Not Match(',') then
      Error(ERR_RUN_TIME, 43);

    WorkExpression;
    If AX.selType <> 1 then
      Error(ERR_RUN_TIME, 123);
    txt := AX.Str;

    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);

    Application.ProcessMessages;

    frmRunTime.imgDrawField.Canvas.Brush.Color := StringToColor(BGColor);
    frmRunTime.imgDrawField.Canvas.Font.Color := StringToColor(ForeColor);

    colors[0] := frmRunTime.imgDrawField.Canvas.Brush.Color;
    colors[1] := frmRunTime.imgDrawField.Canvas.Font.Color;

    frmRunTime.imgDrawField.Canvas.TextOut(x1, y1, txt);

    frmRunTime.imgDrawField.Canvas.Brush.Color := colors[0];
    frmRunTime.imgDrawField.Canvas.Font.Color := colors[1];
  End;

  { -------------------------- EXPRESSION ------------------------------ }
  { ��������� ��������� ������� ��������� � ������ ��� � AX }
  Procedure GetOperand;
  Begin
    { ����� ������� �������, ������� �� ����������. �������� }
    { ������ � AX () }

    If Match('.') then           { ������� ���������   }
      ReadBoolean_1
    Else If Match(Chr(39)) then  { ��������� ��������� }
      ReadString_1
    Else If SourceCode[CurLine]^[CurCh] in ['0'..'9'] then  { ����� }
      ReadInteger_1
    Else If Match('(') then
      WorkBrackets
    Else If Match('-') then  { ����� ����� }
    Begin
      //If Not (SourceCode[CurLine]^[CurCh] in ['0'..'9']) then
      //  Error(ERR_RUN_TIME, 19);
      WorkExpression;
      //ReadInteger_1;
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 123);  
      AX.Int := -AX.Int;
    End
    Else If Match('��') then
    Begin
      WorkExpression;
      Case AX.selType of
        2 : AX.Int  := Not AX.Int;
        3 : AX.Bool := Not AX.Bool
        Else
          Error(ERR_RUN_TIME, 40);
      End; { case }
    End
    Else If Match('������') Then
      WorkParent(False) { ������. ����� � �����. (����� :=) }
    Else If Match('�������')then
      WorkInput(1)
    Else If Match('�������')then
      WorkInput(2)
    Else If Match('�������')then
      WorkInput(3)
    Else If Match('����') then
      WorkRandom
    Else If Match('�����') then
      WorkPixel
    Else If Match('��������') then
      WorkStrLength
    Else If Match('�������') then
      WorkStrCopy
    Else If Match('���') then
      WorkGetAscii
    Else If Match('����') then
      WorkChr
    Else If Match('���������') then
      WorkStrToInt  
    Else If Match('���������') then
      WorkIntToStr
    Else
      ReadVar;
  End;

  { -------------------------------------------------------------------- }
  procedure WorkStrCopy;
  var
    sBuf : String;
    StartPos, CountCh : Integer;
  Begin
    {�������(���,1,3)}

    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    WorkExpression;
    If (AX.selType <> 1) then
      Error(ERR_RUN_TIME, 123);

    sBuf := AX.Str;
    If Not Match(',') then
      Error(ERR_RUN_TIME, 43);

    ReadVal(StartPos, False);
    ReadVal(CountCh, True);

    AX.selType := 1;
    AX.Str := Copy(sBuf, StartPos, CountCh);
    
    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);
  End;

  { -------------------------------------------------------------------- }
  Procedure WorkChr;
  Begin
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    WorkExpression;
    If AX.selType <> 2 then
      Error(ERR_RUN_TIME, 123);

    AX.selType := 1;
    AX.Str     := Chr(Byte(AX.Int));

    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);
  End;

  { -------------------------------------------------------------------- }
  Procedure WorkGetAscii;
  Begin
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    WorkExpression;
    If AX.selType <> 1 then
      Error(ERR_RUN_TIME, 123);

    If Length(AX.Str) < 1 then 
      Error(ERR_RUN_TIME, 126);
      
    AX.selType := 2;
    AX.Int     := Ord(AX.Str[1]);

    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);
  End;

  { -------------------------------------------------------------------- }
  Procedure WorkStrLength;
  Begin
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    WorkExpression;
    If AX.selType <> 1 then
      Error(ERR_RUN_TIME, 123);

    AX.selType := 2;
    AX.Int := Length(AX.Str);

    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);
  End;

  { -------------------------------------------------------------------- }
  { ���������� ����� }
  Procedure WorkInput(selType : Byte);
  Var
    sBuf     : String;
    sDefault : String;
  Begin
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    WorkExpression;
    Case AX.selType of
      1 : sBuf := AX.Str;
      2 : sBuf := IntToStr(AX.Int);
      3 : If AX.Bool then
            sBuf := '.�.'
          Else
            sBuf := '.�.';
    End;

    Case selType of
      1 : sDefault := '';
      2 : sDefault := '0';
      3 : sDefault := '.�.';
    End;

    sBuf := InputBox('����', sBuf, sDefault);

    AX.selType := selType;
    Case selType of
      1 : AX.Str := sBuf;
      2 : AX.Int := StrToInt(sBuf);
      3 : Begin
            AnsiLowerCase(sBuf);
            If (sBuf <> '.�.') And (sBuf <> '.�.') then
              Error(ERR_RUN_TIME, 121);
            If sBuf = '.�.' then
              AX.Bool := True
            Else
              AX.Bool := False;  
          End;
    End;

    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);
  End;

  { -------------------------------------------------------------------- }
  { ��������� ��������� ����� - ��� }
  Procedure WorkRandom;
  Begin
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    WorkExpression;
    If AX.selType <> 2 then
      Error(ERR_RUN_TIME, 123);

    AX.selType := 2;
    AX.Int := Random(AX.Int);

    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);
  End;

  { -------------------------------------------------------------------- }
  { }
  Procedure WorkStrToInt;
  Begin
    // ���������(str)
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    WorkExpression;
    If AX.selType <> 1 then
      Error(ERR_RUN_TIME, 123);

    AX.selType := 2;
    AX.Int := StrToInt(AX.Str);

    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);
  End;

  Procedure WorkIntToStr;
  Begin
    // ���������(���)
    If Not Match('(') then
      Error(ERR_RUN_TIME, 120);

    WorkExpression;
    If AX.selType <> 2 then
      Error(ERR_RUN_TIME, 123);

    AX.selType := 1;
    AX.Str := IntToStr(AX.Int);

    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);
  End;

  { -------------------------------------------------------------------- }
  { ���������� ������ }
  Procedure WorkBrackets;
  Begin
    WorkExpression;
    If Not Match(')') then
      Error(ERR_RUN_TIME, 25);
  End;

  { -------------------------------------------------------------------- }
  { ������ ������� ��������� }
  Procedure ReadBoolean_1;
  Begin
    AX.selType := 3; { Boolean }

    If Match('�') then
      AX.Bool := True
    Else If Match('�') then
      AX.Bool := False
    Else
      Error(ERR_RUN_TIME, 20);    { �������� �������� ���. ��������� }

    If Not Match('.') then
        Error(ERR_RUN_TIME, 20);  { �������� �������� ���. ��������� }
  End;

  { -------------------------------------------------------------------- }
  { ������ ��������� ��������� }
  Procedure ReadString_1;
  Begin
    AX.selType := 1;  { string }
    AX.Str := '';

    While SourceCode[CurLine]^[CurCh] <> Chr(39) do
    Begin
      AX.Str := AX.Str + SourceCode[CurLine]^[CurCh];
      Inc(CurCh);
    End;
    Inc(CurCh);
  End;

  { -------------------------------------------------------------------- }
  { ������ ����� ����� }
  Procedure ReadInteger_1;
  Var
    sInt : String;
  Begin
    AX.selType := 2;  { Integer }
    sInt := '';

    While (SourceCode[CurLine]^[CurCh] in ['0'..'9']) and
          (CurCh <= Length(SourceCode[CurLine]^)) do
    Begin
      sInt := sInt + SourceCode[CurLine]^[CurCh];
      Inc(CurCh);
    End;
    Try
      AX.Int := StrToInt(sInt);
    Except
      Error(ERR_RUN_TIME, 118);
    End;
  End;

  { -------------------------------------------------------------------- }
  { ��������� �������� ����� ������� (���� ��� �������) }
  Procedure GetMemberValue(IdxObject : Word);
  Var
    sMember   : String;
    IdxMember : Word;
  Begin
    sMember := ReadName(97);

    { ����� ��� ����� ? }
    IdxMember := FindObjectMethod(sMember, IdxObject);
    If IdxMember <> 0 then
    Begin
      { ��� ���������� ����� ������ ������� }
      If Not Classes_m^[Objects_m^[IdxObject]^.RefToClass]^
                                       .Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 100);

      { �������������� ������������ �������� }
      With Classes_m^[Objects_m^[IdxObject]^.RefToClass]^ do
      Begin
        Methods[IdxMember]^.Result.selType := 2;
        Methods[IdxMember]^.Result.Str  := '';
        Methods[IdxMember]^.Result.Int  := 0;
        Methods[IdxMember]^.Result.Bool := False;
      End;

      CallMethod(Objects_m^[IdxObject]^.RefToClass, IdxMember, IdxObject);

      With Classes_m^[Objects_m^[IdxObject]^.RefToClass]^ do
      Begin
        { ��������� ��������� ������� }
        AX.selType := Methods[IdxMember]^.Result.selType;
        AX.Int  := Methods[IdxMember]^.Result.Int;
        AX.Str  := Methods[IdxMember]^.Result.Str;
        AX.Bool := Methods[IdxMember]^.Result.Bool;
      End;
    End
    Else Begin
      { ��� ���� }
      IdxMember := FindObjectField(sMember, IdxObject);
      If IdxMember = 0 then
        Error(ERR_RUN_TIME, 115);

      { ������ ������. ���� � AX }
      { ���������� �� ������ ����� �� �������� }
      AX.selType := Objects_m^[IdxObject]^.Fields[IdxMember].selType;
      AX.Str  := Objects_m^[IdxObject]^.Fields[IdxMember].Str;
      AX.Int  := Objects_m^[IdxObject]^.Fields[IdxMember].Int;
      AX.Bool := Objects_m^[IdxObject]^.Fields[IdxMember].Bool;
      
    End; {else}
  End; 

  { -------------------------------------------------------------------- }
  { ��������� �������� ����� ������ (���� ��� �������) ��� }
  { ������ ��������� }
  Function GetMemberValue_2(const sMember : String) : Boolean;
  Var
    IdxMember : Word;
  Begin
    GetMemberValue_2 := False;

    { ����� ��� ����� ? }
    IdxMember := FindMethod(sMember, CurrentClass);
    If IdxMember <> 0 then
    Begin
      { ��� ���������� ����� ������ ������� }
      If Not Classes_m^[CurrentClass]^.Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 100);

      { �������������� ������������ �������� }
      With Classes_m^[CurrentClass]^ do
      Begin
        Methods[IdxMember]^.Result.selType := 2;
        Methods[IdxMember]^.Result.Str  := '';
        Methods[IdxMember]^.Result.Int  := 0;
        Methods[IdxMember]^.Result.Bool := False;
      End;

      CallMethod(CurrentClass, IdxMember, CurrentObject);

      With Classes_m^[CurrentClass]^ do
      Begin
        { ��������� ��������� ������� }
        AX.selType := Methods[IdxMember]^.Result.selType;
        AX.Int  := Methods[IdxMember]^.Result.Int;
        AX.Str  := Methods[IdxMember]^.Result.Str;
        AX.Bool := Methods[IdxMember]^.Result.Bool;
      End;
      GetMemberValue_2 := True;
    End
    Else Begin
      { ��� ���� }
      IdxMember := FindField(sMember, CurrentClass);
      If IdxMember <> 0 then
      Begin
        { ������ ������. ���� � AX }
        { ���������� �� ������ ����� �� �������� }
        AX.selType := Objects_m^[CurrentObject]^.Fields[IdxMember].selType;
        AX.Str  := Objects_m^[CurrentObject]^.Fields[IdxMember].Str;
        AX.Int  := Objects_m^[CurrentObject]^.Fields[IdxMember].Int;
        AX.Bool := Objects_m^[CurrentObject]^.Fields[IdxMember].Bool;
        GetMemberValue_2 := True;
      End; {if}
    End; {else}
  End;

 { --------------------------------------------------------------------- }
 procedure CallDLLFun(FunNum : Integer);
 var
     param     : TDLLProcParam;
     tmpVal    : string;
     //i       : Integer;
 begin
     param.CountParams := 0;
     // x := sName([arg1, arg2, ...])

     if not Match('(') then
         Error(ERR_RUN_TIME, 41);

     if ImpFunctions[FunNum].FunDescr.CountParams <> 0 then
     begin

     repeat
         WorkExpression;
         param.CountParams := param.CountParams + 1;

         case AX.selType of
             1 : tmpVal := AX.Str;
             2 : tmpVal := IntToStr(AX.Int);
             3 : if AX.Bool then
                     tmpVal := 'TRUE'
                 else
                     tmpVal := 'FALSE';
         end;

         if AX.selType <> ImpFunctions[FunNum].FunDescr.ParamsTypes[param.CountParams - 1] then
         begin
             LastError.sError := '�������������� ����� ����������� � ������������ ����������';
             LastError.sLine  := SourceCode[CurLine]^;
             Abort;
         end;

         GetMem(param.Params[param.CountParams - 1], Length(tmpVal) + 1);
         StrPCopy(param.Params[param.CountParams - 1], tmpVal);

         If SourceCode[CurLine]^[CurCh] = ')' then
           Break;

         If Not Match(',') then
           Error(ERR_RUN_TIME, 43);

     until False;

     end; // if

     if not Match(')') then
         Error(ERR_RUN_TIME, 42);


    if param.CountParams <> ImpFunctions[FunNum].FunDescr.CountParams then
    begin
        LastError.sError := '�������� ����� ���������� ����������';
        LastError.sLine  := SourceCode[CurLine]^;
        Abort;
    end;

    if ImpFunctions[FunNum].PtrFun(param) = 0 then
    begin
        LastError.sError := String(param.ReturnValue);
        LastError.sLine  := SourceCode[CurLine]^;
        Abort;
    end
    else begin
        AX.selType := ImpFunctions[FunNum].FunDescr.ReturnType;
        case AX.selType of
            1 : AX.Str  := String(param.ReturnValue);
            2 : AX.Int  := StrToInt(param.ReturnValue);
            3 : AX.Bool := Boolean(param.ReturnValue);
        end;
    end;

    //for i := 0 to param.CountParams - 1 do
    //    FreeMem(param.Params[i]);
 end;

 { --------------------------------------------------------------------- }
 function FindDLLFun : Boolean;
 var
     i : Integer;
     sName : array [0..255] of Char;
     sFunName : array [0..255] of Char;
     OldCurCh : Integer;
 begin
     Result := False;

     sName := '';
     sFunName := '';
     OldCurCh := CurCh;
     StrPCopy(sName, ReadName(30));

     for i := 0 to CountImpFun - 1 do
     begin
         StrPCopy(sFunName, AnsiLowerCase(ImpFunctions[i].FunDescr.FunName));
         if StrComp(sFunName, sName) = 0 then
         begin
             CallDLLFun(i);
             Result := True;
             Exit;
         end;
     end;
     CurCh := OldCurCh;
 end;

  { -------------------------------------------------------------------- }
  { ��������� � AX �������� �����. ��� ���. }
  Procedure ReadVar;
  Var
    sName  : String;
    Idx, IdxVar : Word;

  Begin

    //
    if FindDLLFun then
        Exit;
    //
    
    { ��������� ��������������� : }
    { 1. ��������     }
    { 2. ���� � ���   }
    { 3. ����������   }
    sName  := ReadName(30);

    { ��� ������ ? }
    Idx := FindObject(sName);
    If Idx <> 0 then
    Begin
      if Not Match('.') then
        Error(ERR_RUN_TIME, 96);

      GetMemberValue(Idx);
      Exit;
    End;

    { ���� �� � ������ ������, ����� ������ ��������� � ������ }
    { ��� �������� ������� }
    If (CurrentMethod <> 0) And (CurrentObject <> 0) then
    Begin
      If GetMemberValue_2(sName) then
        Exit;
    End;

    { ��� ������� ? }
    Idx := FindFun(sName);

    If Idx <> 0 then
    Begin
      { ��� ������ ���� ���., � �� ����. }
      If Not Functions^[Idx]^.Fun then
        Error(ERR_RUN_TIME, 33);

      { �������������� ������������ �������� }
      Functions^[Idx]^.Result.selType := 2;
      Functions^[Idx]^.Result.Str  := '';
      Functions^[Idx]^.Result.Int  := 0;
      Functions^[Idx]^.Result.Bool := False;

      CallFunction(Idx);

      { ��������� ��������� ������� }
      AX.selType := Functions^[Idx]^.Result.selType;
      AX.Int  := Functions^[Idx]^.Result.Int;
      AX.Str  := Functions^[Idx]^.Result.Str;
      AX.Bool := Functions^[Idx]^.Result.Bool;
    End
    Else Begin
      { ������ ��� ���������� }
      IdxVar := FindVar(sName);

      { ���� ����� ���, ������ � }
      If IdxVar = 0 then
        IdxVar := CreateNewVar(sName);

      { ������ ������. ���������� � AX }
      { ���������� �� ������ ����� �� �������� }
      AX.selType := Stack[IdxVar]^.selType;
      AX.Str  := Stack[IdxVar]^.Str;
      AX.Int  := Stack[IdxVar]^.Int;
      AX.Bool := Stack[IdxVar]^.Bool;
    End; { else - var }
  End;

  { -------------------------------------------------------------------- }
  { ��������� �������� �������� AX � ���� }
  Procedure PUSH;
  Begin
    { �������� �� ������������ ����� }
    { ���� �� ��������� }
    If CurStack < MAX_STACK_INDEX_COUNT Then
    Begin
      Inc(CurStack);
      New(Stack[CurStack]);

      Stack[CurStack]^.selType  := AX.selType;
      Stack[CurStack]^.Str  := AX.Str;
      Stack[CurStack]^.Int  := AX.Int;
      Stack[CurStack]^.Bool := AX.Bool;
    End
    Else
      Error(ERR_RUN_TIME, 21);
  End;

  { -------------------------------------------------------------------- }
  { ����������� �������� �� ����� � BX }
  Procedure POP;
  Begin
    BX.selType := Stack[CurStack]^.selType;
    BX.Str  := Stack[CurStack]^.Str;
    BX.Int  := Stack[CurStack]^.Int;
    BX.Bool := Stack[CurStack]^.Bool;
    { ��� �� �� ������ ����� ����� �� ������� }
    If (CurStack -1) >= MAX_COUNT_VARS then
    Begin
      Dispose(Stack[CurStack]);
      Dec(CurStack);
    End
    Else
      Error(ERR_RUN_TIME, 22);
  End;

  { -------------------------------------------------------------------- }
  { ��������� �������� ��� ���������� }
  Procedure CalcRegs(const sOper : String);
  Begin
    { ��������� �������� � ������ ��������� � AX }

    { ��������� �� ���� � ��������� ? }
    If AX.selType <> BX.selType then
      Error(ERR_RUN_TIME, 23);  { �������. ����� }

    If sOper = '���' then             { -- OR -- }
    Begin
      If AX.selType <> 3 then
        Error(ERR_RUN_TIME, 23);

      AX.Bool := (AX.Bool OR BX.Bool);
    End
    Else If sOper = '�' then          { -- AND -- }
    Begin
      If AX.selType <> 3 then
        Error(ERR_RUN_TIME, 23);
      AX.Bool := (AX.Bool AND BX.Bool);
    End
    Else If sOper = '=' then          { -- = -- }
    Begin
      Case AX.selType of
        1 : AX.Bool := (AX.Str  = BX.Str);
        2 : AX.Bool := (AX.Int  = BX.Int);
        3 : AX.Bool := (AX.Bool = BX.Bool);
      End;
      AX.selType := 3;
    End
    Else If sOper = '<' then          { -- < -- }
    Begin
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 23);
      AX.selType := 3;
      AX.Bool := (BX.Int < AX.Int);
    End
    Else If sOper = '>' then          { -- > -- }
    Begin
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 23);
      AX.selType := 3;
      AX.Bool := (BX.Int > AX.Int);
    End
    Else If sOper = '<=' then          { -- <= -- }
    Begin
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 23);
      AX.selType := 3;
      AX.Bool := (BX.Int <= AX.Int);
    End
    Else If sOper = '>=' then          { -- >= -- }
    Begin
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 23);
      AX.selType := 3;
      AX.Bool := (BX.Int >= AX.Int);
    End
    Else If sOper = '<>' then          { -- <> -- }
    Begin
      Case AX.selType of
        1 : AX.Bool := (AX.Str  <> BX.Str);
        2 : AX.Bool := (AX.Int  <> BX.Int);
        3 : AX.Bool := (AX.Bool <> BX.Bool);
      End;
      AX.selType := 3;
    End
    Else If sOper = '+' then           { -- + -- }
    Begin
      If (AX.selType <> 1) And (AX.selType <> 2) then
        Error(ERR_RUN_TIME, 23);
      AX.Str := BX.Str + AX.Str;
      AX.Int := BX.Int + AX.Int;
    End
    Else If sOper = '-' then           { -- - -- }
    Begin
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 23);
      AX.Int := BX.Int - AX.Int;
    End
    Else If sOper = '*' then           { -- * -- }
    Begin
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 23);
      AX.Int := BX.Int * AX.Int;
    End
    Else If sOper = '/' then           { -- / -- }
    Begin
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 23);
      If AX.Int = 0 then
        Error(ERR_RUN_TIME, 24);

      AX.Int := BX.Int div AX.Int;
    End
    Else If sOper = 'mod' then           { -- / -- }
    Begin
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 23);
      If AX.Int = 0 then
        Error(ERR_RUN_TIME, 24);
      AX.Int := BX.Int mod AX.Int;
    End;
  End;

  { -------------------------------------------------------------------- }
  { ��������� ������� ��������� }
  Procedure WorkExpression;
  Begin
    { ��������� ��������� � �������� ��������� � ������� AX             }
    { AX : TResult;                                                     }
    { � ��������� ����� ���� : ���. ��������, �������-��, ����� ������� }
    If Not fExec then
      Exit;
      
    GetOperand;
    If CurCh >= Length(SourceCode[CurLine]^) then
      Exit;                       

    While Operator_OR do;
  End;

  { -------------------------------------------------------------------- }
  { ��������� ���. �������� ��� }
  Function Operator_OR : Boolean;
  Begin
    { ��������� True ���� ����-�� ��������� }
    If CurCh >= Length(SourceCode[CurLine]^) then
    begin
      Operator_OR := False;
      Exit;
    end;

    If Match('���') then
    Begin
      { ��������� ������� AX � ���� }
      PUSH;
      { �������� ��������� ������� }
      GetOperand;
      { ���������� � ������� ���� ��������� }
      While Operator_AND do;
      { �������������� ������ AX � BX }
      POP;
      { ���������� �������� ��� ���������� }
      CalcRegs('���');
      { �� ��������� ���� �� ���������� }
      Operator_OR := True;
    End
    Else
      Operator_OR := Operator_AND;
  End;

  { -------------------------------------------------------------------- }
  { ��������� ���. �������� � }
  Function Operator_AND : Boolean;
  Begin
    { ��������� True ���� ����-�� ��������� }
    If Match('�') then
    Begin
      PUSH;
      GetOperand;
      While Operator_G1 do;  { >, <, >=, <=, <>, = }
      POP;
      CalcRegs('�');
      Operator_AND := True;
    End
    Else
      Operator_AND := Operator_G1; { >, <, >=, <=, <>, = }
  End;

  { -------------------------------------------------------------------- }
  { ��������� ���. �������� ��������� }
  Function Operator_G1 : Boolean;
  Var
    sOper : String;

    procedure WorkOper;
    begin
      PUSH;
      GetOperand;
      While Operator_G2 do;  { +, -}
      POP;
      CalcRegs(sOper);
      Operator_G1 := True;
    end;

  Begin
    { >, <, >=, <=, <>, = }
    { ��������� True ���� ����-�� ��������� }
    sOper := '';

    If Match('<=') then
    Begin
      sOper := '<=';
      WorkOper;
    End
    Else If Match('>=') then
    Begin
      sOper := '>=';
      WorkOper;
    End
    Else If Match('<>') then
    Begin
      sOper := '<>';
      WorkOper;
    End
    Else If Match('=') then
    Begin
      sOper := '=';
      WorkOper;
    End
    Else If Match('<') then
    Begin
      sOper := '<';
      WorkOper;
    End
    Else If Match('>') then
    Begin
      sOper := '>';
      WorkOper;
    End;

    If sOper = '' then
      Operator_G1 := Operator_G2;
  End;

  { -------------------------------------------------------------------- }
  { ��������� �������������� �������� : +, - }
  Function Operator_G2 : Boolean;
  Begin
    If Match('+') then
    Begin
      PUSH;
      GetOperand;
      While Operator_G3 do;  { *, / }
      POP;
      CalcRegs('+');
      Operator_G2 := True;
    End
    Else If Match('-') then
    Begin
      PUSH;
      GetOperand;
      While Operator_G3 do;  { *, / }
      POP;
      CalcRegs('-');
      Operator_G2 := True;
    End
    Else
      Operator_G2 := Operator_G3;
  End;

  { -------------------------------------------------------------------- }
  { ��������� �������������� �������� : *, / }
  Function Operator_G3 : Boolean;
  Begin
    If Match('*') then
    Begin
      PUSH;
      GetOperand;
      POP;
      CalcRegs('*');
      Operator_G3 := True;
    End
    Else If Match('/') then
    Begin
      PUSH;
      GetOperand;
      POP;
      CalcRegs('/');
      Operator_G3 := True;
    End
    Else If Match('mod') then
    Begin
      PUSH;
      GetOperand;
      POP;
      CalcRegs('mod');
      Operator_G3 := True;
    End
    Else
      { ���������� ���� ��� }
      Operator_G3 := False;
  End;

  { ----------------------------- * - * - * ---------------------------- }
  { ��������� �� ������ }
  Procedure Error(ErrKind : Byte; ErrNumber : Word);
  Var
    FError : Text;
    sBuf   : String;
    sSrc   : String;
    i      : Word;
    sErr   : String;
    sErrLine  : String;

  Begin
    { ������ �������� ������ ����� ErrNumber �� }
    { errors.def � ������� �� �����.            }
    i := 0;
    AssignFile(FError, 'ini\errors.def');
    Reset(FError);

    While (Not EOF(FError)) And (i <> ErrNumber) do
    Begin
      Readln(FError, sBuf);
      EraseBlank(@sBuf);

      { ����������� � ����� }
      If (sBuf[1] <> '#') then
        Inc(i);

    End;

    CloseFile(FError);
    sErr     := '';
    sErrLine := '';

    { ��� ������ }
    Case ErrKind of
      ERR_RUN_TIME  :Begin
                       { �� ������ ���� CurLine = 0 }
                       sSrc := '';
                       If (CurLine > 0) and (CurLine <= CountLines) then
                         sErrLine := 'Line ' + IntToStr(CurLine) + ' :' +
                                            #13#10 + SourceCode[CurLine]^;
                       sErr  := sBuf;
                       For i := 1 to TopBorder do
                         Dispose(Stack[i]);
                       Done;
                       LastError.sError := sErr;
                       LastError.sLine  := sErrLine;
                     End;

      ERR_LOAD_TIME :Begin
                       sBuf:= 'Load-time error : ' + sBuf;
                       ShowMessage(sBuf);
                       Done;
                       LastError.sError := '';
                       LastError.sLine  := '';
                     End;

      ERR_WORK_TIME :Begin
                       sBuf := 'Work-time error : ' + sBuf;
                       ShowMessage(sBuf);
                       Done;
                       LastError.sError := '';
                       LastError.sLine  := '';
                     End;
    End; {case}

    {
    MessageBox(frmRunTime.Handle,PChar('������ ������� ���������� :' + #10#13 +
    #10#13 + LastError.sError + #10#13 + LastError.sLine),'��������', MB_ICONERROR);

    If sProjectFile = '' then
      Case MessageBox(frmError.Handle, PChar('��������� ��������� � �������'), '����������� ������������', MB_YESNO) Of
        IDYES : frmFileMenu.N8Click(frmUserForm);
      End
    Else
      Case MessageBox(frmError.Handle, PChar('��������� ��������� � ' + sProjectFile), '����������� ������������', MB_YESNO) Of
        IDYES : SaveProject(sProjectFile);
      End;
    Application.Terminate;
    }


    Abort;  //  ��������� !!!

  End; { proc }
End.
