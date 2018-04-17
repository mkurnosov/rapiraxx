unit mdl_dsg;

interface
  uses Types, ExtCtrls, Dialogs, Krnl;

  Const
    MAX_COUNT_ISPOLNS = 50;
    MAX_COUNT_PROPS   = 50; { макс. кол-во полей у испол-я   }
    MAX_COUNT_METHODS = 50; { макс. кол-во методов у исполна }

    MAX_COUNT_BASE_ISPOLNS = 20;

    { Кол-во строк на все методы }
    MAX_CODE_LINES = 2000;

  Type

    TIspoln = Record
      Face   : TImage;
      Name   : String;
      Fields : Array [1..MAX_COUNT_PROPS] of TStack;
      CountFields  : Word;
      Methods      : Array [1..MAX_COUNT_METHODS] of TFunction;
      CountMethods : Word;
      BaseIsp      : Word;
    End;


  Var

    { Массив для кода методов базовых исполнителей }
    MethodsCode    : Array [1..MAX_CODE_LINES] of _PString;
    CountCodeLines : Word;

    Ispolns : Array [1..MAX_COUNT_ISPOLNS] of TIspoln;
    CountIspolns : Word;

    { Исполнители которые мы видем в окне 'Исполнители' }
    BaseIspolns : Array [1..MAX_COUNT_BASE_ISPOLNS] of TIspoln;
    CountBaseIspolns : Word;

    { Выбран ли исполн }
    fSelectIspoln : Boolean;
    wSelectIspoln : Word;

    sIcons : Array [1..MAX_COUNT_BASE_ISPOLNS] of String;
    CountIcons : Word;

    BASE_PICTURE : String;

    UsedIspolns  : Array [1..MAX_COUNT_BASE_ISPOLNS] of Boolean;

    Procedure Init;
    Procedure LoadBaseIspolns;

implementation

uses frmIsps, Buttons;

{ ------------------------------------------------------------------- }
Procedure Init;
Begin
  CountIspolns  := 0;
  fSelectIspoln := False;
  CountBaseIspolns := 0;
  CountCodeLines   := 0;
  wSelectIspoln    := 0;

End;

{ ------------------------------------------------------------------- }
{ Загружает на frmIspolns объекты }
Procedure DrawBaseIspolns;
Var
  i : Word;
  btnIsp : Array [1..20] Of TSpeedButton;
  LastLeft : Word;
  FText  : TextFile;
Begin
  CountIcons := 0;
  Assign(FText, 'options\icons.def');
  Reset(FText);
  If Not EOF(FText) then
    Readln(FText, BASE_PICTURE);
    
  While Not EOF(FText) do
  Begin
    Inc(CountIcons);
    Readln(FText, sIcons[CountIcons]);
  End;
  Close(FText);

  LastLeft := 0;
  for i := 1 to CountBaseIspolns do
  begin
    btnIsp[i] := TSpeedButton.Create(frmIspolns);
    btnIsp[i].Parent := frmIspolns.Panel2;
    If i = 1 then
      btnIsp[i].Glyph.LoadFromFile(BASE_PICTURE)
    Else
      btnIsp[i].Glyph.LoadFromFile(sIcons[i - 1]);
    btnIsp[i].Flat := True;
    btnIsp[i].ShowHint := True;
    btnIsp[i].Hint := BaseIspolns[i].Name;
    btnIsp[i].Tag := i;
    if i <= 3 then
      btnIsp[i].Top := 8
    else
      If (i mod 3) <> 0 then
        btnIsp[i].Top := (16 + frmIspolns.sbPtr.Height) * (i div 3)
      Else
        btnIsp[i].Top := (16 + frmIspolns.sbPtr.Height) * ((i div 3) - 1);
    if (i = 1) then
    begin
      btnIsp[1].Left := frmIspolns.sbPtr.Width + frmIspolns.sbPtr.Left + 8;
      LastLeft := btnIsp[1].Left;
    end
    else begin
      If (i mod 3) = 1 then
        LastLeft := frmIspolns.sbPtr.Left;

      btnIsp[i].Left := btnIsp[i - 1].Width + LastLeft + 8;
      LastLeft := btnIsp[i].Left;
    end;
    btnIsp[i].Width   := frmIspolns.sbPtr.Width;
    btnIsp[i].Height  := frmIspolns.sbPtr.Height;
    btnIsp[i].OnClick := frmIspolns._OnClick;
  end;
End;

{ ------------------------------------------------------------------- }
Procedure LoadBaseIspolns;
Var
  OldCurLine, OldCurCh : Word;
  i, j : Word;
Begin
  { 1. Выполняю весь код из ispolns.dat }
  { 2. Переприсвиваю всё }
  { 3. Делаю Done        }

  Krnl.Init;
  { Файл с описанием базовых исполнителей }
  LoadFile('options\ispolns.def');

  If CountLines = 0 then
  Begin
    CountBaseIspolns := 1;
    for i := 1 to CountBaseIspolns do
      UsedIspolns[i] := False;
    BaseIspolns[1].Name := Classes_m^[1]^.Name;
    BaseIspolns[1].CountFields := Classes_m^[1]^.CountFields;
    for j := 1 to BaseIspolns[1].CountFields do
      BaseIspolns[1].Fields[j] := Classes_m^[1]^.Fields[j];

    Done;
    DrawBaseIspolns;
    Exit;
  End;

  { Обработчик исключительных ситуаций }
  Try
    { Для минимальной программы необходимо 2 строчки }
    If CountLines < 2 then
      Krnl.Error(ERR_RUN_TIME, 5);
    While CurLine <> CountLines do
    Begin
      GetString;
      { Сохраняем }
      OldCurCh   := CurCh;
      OldCurLine := CurLine;
      AnalyzeClass;
      { Мы что-нибудь обработали ( судя по CurCh ) ? }
      If (CurCh = OldCurCh) And (CurLine = OldCurLine) then
        Krnl.Error(ERR_RUN_TIME, 61);
    End;
  Except
    Krnl.Error(ERR_RUN_TIME, 117);
  End; {try}

  for i := 1 to CountLines do
  begin
    New(MethodsCode[i]);
    MethodsCode[i]^ := SourceCode[i]^;
  end;

  CountCodeLines := CountLines;
  CountBaseIspolns := CountClasses;

  for i := 1 to CountClasses do
  begin
    BaseIspolns[i].Name := Classes_m^[i]^.Name;
    BaseIspolns[i].CountFields := Classes_m^[i]^.CountFields;
    for j := 1 to BaseIspolns[i].CountFields do
      BaseIspolns[i].Fields[j] := Classes_m^[i]^.Fields[j];
    BaseIspolns[i].CountMethods := Classes_m^[i]^.CountMethods;
    for j := 1 to BaseIspolns[i].CountMethods do
      BaseIspolns[i].Methods[j] := Classes_m^[i]^.Methods[j]^;
  end;
  Done;
  DrawBaseIspolns;

  for i := 1 to CountBaseIspolns do
    UsedIspolns[i] := False;
End; {proc}

end.
