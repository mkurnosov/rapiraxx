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

  { Максимальный размер стека }
  MAX_STACK_INDEX_COUNT = 2000;

  { макс. кол-во перем-ых в стеке 0..MAX_COUNT_VARS }
  MAX_COUNT_VARS = 500;

  { Разновидности ошибок - Error() }
  ERR_RUN_TIME  = 1; { - времени выполнения          }
  ERR_LOAD_TIME = 2; { - времени загрузки            }
  ERR_WORK_TIME = 3; { - времени работы пользователя }

  { Макс. кол-во классов }
  MAX_COUNT_CLASSES = 50;
  MAX_COUNT_FIELDS  = 50; { макс. кол-во полей у класса   - TClass }
  MAX_COUNT_METHODS = 50; { макс. кол-во методов у класса - TClass }

  { Макс. кол-во объектов }
  MAX_COUNT_OBJECTS = 50;

  ImageFields : Array [1..7] of String = ('сверху', 'слева', 'ширина',
                                          'высота', 'картинка',
                                          'видимость', 'растяжение');
  Type

  EKernelError = Class(Exception);

  TLastError = Record
    sError : String;
    sLine  : String; 
  End;
  
  { множество из символов ReadWord() }
  TCharSet = Set of Char;

  { Указатель на массив функций (Structure too large) }
  PFunction = ^TFunction;
  TFunArray = Array [1..MAX_COUNT_FUNCTIONS] of PFunction;


  { Классы }
  PClass = ^TClass;
  TClass = Record
    Name   : String;  { Имя класса }
    Parent : Word;    { Номер класса-предка }
    { Поля класса (New)}
    Fields : Array [1..MAX_COUNT_FIELDS] of TStack;
    CountFields : Word;
    { Методы класса }
    Methods : Array [1..MAX_COUNT_METHODS] of PFunction;
    CountMethods : Word;
  End;

  TClassArray = Array [1..MAX_COUNT_CLASSES] of PClass;

  { Объекты }
  { Объект - ссылка на класс. Содержит все поля класса }
  PObjects_m = ^TObject_m;
  TObject_m  = Record
    Name : String;
    { Ссылка на класс. Номер класса }
    RefToClass : Word;
    { Поля объекта (делать New)}
    Fields : Array [1..MAX_COUNT_FIELDS] of TStack;
    CountFields : Word;
  End;

  TObjectsArray = Array [1..MAX_COUNT_OBJECTS] of PObjects_m;


  Procedure Init;
  Procedure Done;

  { Начинает интерпретацию файла }
  Procedure Parse;

  { Увеличивает индекс строки }
  Procedure GetString;

  { Загружает файл в SourceCode[] }
  Procedure LoadFile(const sFileName : String);

  Function  Match(const sStr : String):Boolean;

  { Считывает слово симв-лы которого входят в множество ChSet }
  Function ReadWord(ChSet : TCharSet) : String;

  { Считывает имена проц, фун, перем-ых, ... }
  { и проверяет на правельность записи       }
  Function ReadName(ErrNum : Word) : String;

  { Разбирает процедуру или фун. }
  Procedure AnalyzeFunction;

  { Анализирует описание класса }
  Procedure AnalyzeClass;

  { Разбирает метод класса }
  Procedure AnalyzeMethod(IdxClass : Word);

  { Ищет класс по именеи }
  Function FindClass(const sClassName : String) : Word;

  { Ищет метод класса }
  Function FindMethod(const sMethodName : String; IdxClass : Word): Word;

  { Ищет поле в классе }
  Function FindField(const sFieldName : String; IdxClass : Word) : Word;

  { Является ли поле полем класс Изображение }
  Function BaseField(const sName : String) : Boolean;

  { Обработка описания объектов }
  Procedure AnalyzeObjects;

  { Поиск объекта }
  Function FindObject(const sObjName : String) : Word;

  { Ищет метод объекта }
  Function FindObjectMethod(const sMember : String; IdxObject : Word) : Word;

  { Ищет поле объекта }
  Function FindObjectField(const sMember : String; IdxObject : Word) : Word;

  { Вызывает метод класса }
  Procedure CallMethod(IdxClass, IdxMethod, IdxObject : Word);

  { Обработка обращения к предку класса }
  Procedure WorkParent(bLeftPart : Boolean);


  { Прямое обращение к члену класса }
  Function WorkStrightAccess(const sMember : String) : Boolean;

  { Обращение к члену объекта через '.' }
  Procedure WorkObjectMember(IdxObject : Word);

  { Получение значения члена объекта (поля или функции) }
  Procedure GetMemberValue(IdxObject : Word);

  { Получение значения члена класса (поля или функции) при }
  { прямом обращении }
  Function GetMemberValue_2(const sMember : String) : Boolean;

  { Сообщение об ошибке и выход }
  Procedure Error(ErrKind : Byte; ErrNumber : Word);

  { Пропускает пробелы }
  Procedure SkipBlanks;

  { Ищет функцию по имени }
  Function  FindFun(const sFunName : String): Word;

  { Вызывает фун или проц }
  Procedure CallFunction(IdxFun : Word);

  { Вычисляет результат функции }
  Procedure WorkReturn;

  { Косвенно-рекурсивная функция разбора всех опереторов языка }
  Function Statement(const strEnd1, strEnd2 : String) : Byte;

  { Процедура разбора вырожений }
  Procedure WorkExpression;
                    
  { Вычесляет очередной операнд выражения и пихает его в AX }
  Procedure GetOperand;

  { Обработчик скобок }
  Procedure WorkBrackets;

  { Процедуры чтения операндов 3-х типов в AX }
  Procedure ReadBoolean_1;
  Procedure ReadString_1;
  Procedure ReadInteger_1;

  { Считывает в AX значение перем. или фун. }
  Procedure ReadVar;

  { Обработка оператора условия (ветвления) }
  Procedure WorkIf;

  { Цикл ПОВТОР }
  Procedure WorkRepeat;

  { Цикл ПОКА }
  Procedure WorkWhile;

  { Цикл ДЛЯ }
  Procedure WorkFor;

  { Выводит сообщение в ListBox }
  Procedure PrintMsg;

  { Показывает сообщение }
  Procedure ShowMsg;

  { Оператор присвоения и вызов функций }
  Procedure WorkAssignment;

  { Ищет перемнную по имени }
  Function FindVar(const sVarName : String) : Word;

  { Создаёт новую локальную переменную }
  Function CreateNewVar(const sVarName : String) : Word;

  { Сохраняет значение регистра AX в Стек }
  Procedure PUSH;

  { Вытаскивает значение из стека в BX }
  Procedure POP;

  { Выполняет операцию над регистрами }
  Procedure CalcRegs(const sOper : String);

  { Обработка лог. операции ИЛИ }
  Function Operator_OR : Boolean;

  { Обработка лог. операции И }
  Function Operator_AND : Boolean;

  { Обработка лог. операций сравнения }
  Function Operator_G1 : Boolean;

  { Обработка арифметических операций : +, - }
  Function Operator_G2 : Boolean;

  { Обработка арифметических операций : *, / }
  Function Operator_G3 : Boolean;

  { Обработчик ввода }
  Procedure WorkInput(selType : Byte);
                                                               // *  *  *
  procedure CallDLLProc(ProcNum : Integer);                    //   DLL
  function  FindDLLProc : Boolean;                             //   DLL
                                                               //   DLL
  procedure CallDLLFun(FunNum : Integer);                      //   DLL
  function  FindDLLFun : Boolean;                              //   DLL
                                                               // *  *  *
  { Генератор случайных чисел - ГСЧ }
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

  { Исходный код программы }
  SourceCode : Array [1..MAX_SOURCE_LINES] of _PString;
  CountLines : Word;

  CurCh   : Word; { курсор в строке кода - SourceCode[N]^[CurCh] }
  CurLine : Word; { индекс строки кода - SourceCode[CurLine] }

  { Массив процедур и функций }
  Functions : ^TFunArray; { Structure too large }
  CountFunctions : Word;
  AllocMemFun    : Boolean; { Выделяли ли память под Functions }
  { Номер текущей функции (для WorkReturn() ) }
  CurrentFun : Word;

  VarName    : TCharSet; { какие символы можно употреблять в         }
                         { имени переменной                          }

  Second     : TCharSet; { С какого символа не может начинаться имя, }
                         { но дальше они могут присутствовать        }

  { порядковый номер процедуры старт в табл. функций }
  ProcStart : Word;

  { Регистры общего назначения }
  AX, BX : TResult;

  { Cтек. Используется для хранения локальных переменных }
  { и разбра выражений }
  Stack : Array [1..MAX_STACK_INDEX_COUNT] of PStack;
  CurStack : Word;

  { Текущая область видимости локал. перем. в стеке. }
  TopBorder, BottomBorder : Word;

  { Флаг. Можно ли обрабатывать операторы }
  { Устананавливается в WorkIf }
  fExec : Boolean;

  { res для результата Statement }
  res : Byte;


  { Классы _m - т.к classes зарезерв. слово }
  Classes_m : ^TClassArray;
  CountClasses : Word;
  { Выделяли ли память под Classes }
  AllocMemClasses : Boolean;


  { Объекты _m - т.к objects зарезерв. слово }
  Objects_m : ^TObjectsArray;
  CountObjects : Word;
  { Выделяли ли память под Objects }
  AllocMemObjects : Boolean;

  { Номер текущго объекта }
  CurrentObject  : Word;

  { Номер текущего метода (для WorkReturn() ) }
  CurrentMethod : Word;

  { Номер текущего класса }
  CurrentClass : Word;

  LastError : TLastError;

  EmergencyTermination : Boolean;
  fExplorerWork : Boolean;

  { Сейчас интерпретируем, а не загружаем из файла }
  { в GetString }
  fInterpreting : Boolean;

Implementation

Uses GlbFun,   { only for LoadFile()           }
     Dialogs,  { only for ShowMessage in Error }
     Main,     { Для PCur & RobotList }
     Forms,    { for Application.ProcessMessages    }
     frmErr, frmRun, frmFile, mdl_dsg, Graphics, frmOut, Explr,
     Windows, frmUser, Debug, frmCStack, frmWatch,
     LibManager, ConstrDLLSupport;


  { Констсруктор }
  Procedure Init;
  Var
    i : Word;
  Begin
    AllocMemFun := False;
    CountLines  := 0;
    CurCh       := 0;
    CurLine     := 0;
    VarName     := ['a'..'z','а'..'я','ё','_','0'..'9'];
    Second      := ['_','0'..'9'];
    CountFunctions := 0;
    CurStack     := MAX_COUNT_VARS;
    TopBorder    := 0;
    BottomBorder := 0; { Для FindVar() }
    fExec        := True;
    ProcStart    := 0;
    CurrentFun   := 0;
    CountClasses := 0;
    CountObjects    := 0;
    AllocMemObjects := False;
    CurrentObject   := 0;
    CurrentClass    := 0;
    CurrentMethod   := 0;

    { Встроенный класс - изображение }
    Inc(CountClasses);
    AllocMemClasses := True;
    New(Classes_m);
    New(Classes_m[1]);

    With Classes_m^[1]^ do
    Begin
      Name   := 'изображение';  { Имя класса }
      Parent := 0;              { Номер класса-предка }

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

      { Методы класса }
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
  { Загружает файл в SourceCode }
  Procedure LoadFile(const sFileName : String);
  Var
    FText : TextFile;
    sStr  : String;
  Begin
    { Загружает и обрабатывает файл}
    { 1. Удаляет лишние пробелы оставляя по одному.}
    { 2. Переводит текст в нижний регистр, НО НЕ В АПОСТРОФАХ }

    fInterpreting := False;
    
    Try

      AssignFile(FText,sFileName);
      Reset(FText);
      While (Not EOF(FText)) do
      Begin
        Readln(FText, sStr);

        EraseBlank(@sStr);
        K_LowerCase(@sStr);

        { Если строка не пуста и не коментарий, то добавляем её }
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
  { Увеличивает индекс строки }
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
  { пропускает пробелы и табы }
  Procedure SkipBlanks;
  Begin
    While (SourceCode[CurLine]^[CurCh] = ' ') or (SourceCode[CurLine]^[CurCh] = #9) do
      Inc(CurCh);
  End;

  { -------------------------------------------------------------------- }
  Function Match(const sStr : String):Boolean;
  Begin
     SkipBlanks;

    { В строке следующее слово sStr ? }
    If (Copy(SourceCode[CurLine]^, CurCh, Length(sStr)) = sStr) then
    Begin
      Match := True;
      CurCh := CurCh + Length(sStr);
    End
    Else
      Match := False;
  End;

  { -------------------------------------------------------------------- }
  { Считывает слово симв-лы которого входят в множество ChSet }
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
    { ErrNum - используется если плохое имя }
    { Читаем имя фун или проц }
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

    { Крутит ГетСтринг до кон проц }
    procedure GoToEndProc;
    begin
      While Not Match('кон') do
      Begin
        GetString;
        If CurLine > CountLines then  { Проверка на выезд за границу }
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
    { Если идет описание проц. или фун., то добовляет ее в табл. процедур. }
    { Возвращает True если было описание проц. или фун. }
    FunType := 3;

    If Match('проц') then
      FunType := 0
    Else If Match('фун') then
      FunType := 1;

    { Если нет кл. слова проц или фун, то выходим из процедуры }
    If (FunType = 3) then
      Exit;

    { Читаем имя фун или проц }
    sBuf := ReadName(9);

    { Если проца или фун с таким именем уже есть, то Еррор }
    IdxFun := FindFun(sBuf);
    If (IdxFun <> 0) then
      Error(ERR_RUN_TIME, 14); { фуна уже существует }

    { Проверить на имя ОБЪЕКТА }
    If FindObject(sBuf) <> 0 then
      Error(ERR_RUN_TIME, 92);

    { Если память под указатель на массив фун еще не выделяли }
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

    { Инициализируем т.к по умолчянию занчение = ??? }
    Functions^[CountFunctions]^.CountArgs := 0;

    If Not Match('(') then
      Error(ERR_RUN_TIME, 2); { скобки нет }

    SkipBlanks;

    While (Copy(SourceCode[CurLine]^, CurCh, 1) <> ')') do
    Begin
      { читаем имя аргумента }
      sArgName := ReadName(4);

      { Может с таким именем уже есть аргумент }
      If ArgExist(sArgName, CountFunctions) then
        Error(ERR_RUN_TIME, 17);

      { Может с таким именем Фун }
      If FindFun(sArgName) <> 0 then
        Error(ERR_RUN_TIME, 78);

      { Проверить на имя ОБЪЕКТА }
      If FindObject(sArgName) <> 0 then
        Error(ERR_RUN_TIME, 91);

      { Может их слишком много ? }
      If (Functions^[CountFunctions]^.CountArgs + 1) > MAX_COUNT_ARGS then
        Error(ERR_RUN_TIME, 16);

      { Добовляем его в список аргументов функции }
      Inc(Functions^[CountFunctions]^.CountArgs);
      Functions^[CountFunctions]^.Args[Functions^[CountFunctions]^.CountArgs] := sArgName;

      If Match(')') then
        Break;

      If Not Match(',') then
        Error(ERR_RUN_TIME, 3);   { отсутствует запятая }

      If Match(')') then
        Error(ERR_RUN_TIME, 4);   { имя аргумента функции не определенно }
    End;

    { Правильно ли описана фун. (может отсутствовать кон проц) }
    If (CurLine + 1) > CountLines then
      Error(ERR_RUN_TIME, 6);

    { Точка входа в функцию }
    Functions^[CountFunctions]^.StartLine := CurLine;

    GoToEndProc; { катимся до кон проц }

    { Различия проц. и фун. }
    Case FunType of
      0 : Begin
            Functions^[CountFunctions]^.Fun := False;
            If Not Match('проц') then
              Error(ERR_RUN_TIME, 7);
          End;
      1 : Begin
            Functions^[CountFunctions]^.Fun := True;
            If Not Match('фун') then
              Error(ERR_RUN_TIME, 8);
          End;
    End;

    { Если это проц Старт }
    If (sBuf = 'старт') then
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
    { Ищет функцию по имени в таблице функций }
    { Если не нашл возвращаем 0               }
    { Иначе её индекс в таблице               }
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
 { Вызывает фун или проц }
 Procedure CallFunction(IdxFun : Word);
 Var
   wTop, wBottom, wArgs, wFun : Word;
   IdxArg, i         : Word;
   wLine, wCur, wBuf : Word;
   wMethod           : Word;
   sBuf              : String;
 Begin
   { IdxFun - номер фун или проц в таблице фцнкций }
   { Сохраняем старую область видимости }
   wBottom := BottomBorder;
   wTop := TopBorder;

   sBuf := '(';

   If IdxFun <> ProcStart then
   Begin
     { Обязательно должна быть пара скобок : s := f() + 4 }
     If Not Match('(') then
       Error(ERR_RUN_TIME, 41);

     wArgs := 0;
     { Обработка передаваемых параметров }
     { Засовываем в стек передоваемые значения, а затем }
     { присвоим им имена }
     If Functions^[IdxFun]^.CountArgs <> 0 then
     Begin
       Repeat { Бескон-ый цикл (выход - break) }

         { msg('Hello World', 3+4, .и. или .л.) }
         Inc(wArgs);
         { Вычесляем очередной параметр }
         WorkExpression;
         IdxArg := CreateNewVar('');
         { Присваеваем значен. }
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
                   sBuf := sBuf + '.и.'
                 Else
                   sBuf := sBuf + '.л.';
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

     { Сколько приняли парам-ов и ск-ко описано арг-ов }
     If wArgs <> Functions^[IdxFun]^.CountArgs then
       Error(ERR_RUN_TIME, 44);

     { Устанавливаем имена в стеке }
     wArgs := 0;
     For i := wTop + 1 to TopBorder do
     Begin
       Inc(wArgs); { - Какой аргумент по счёту }

      { Может с таким именем уже есть функция }
      wBuf := FindFun(Functions^[IdxFun]^.Args[wArgs]);
      If wBuf <> 0 then
        Error(ERR_RUN_TIME, 48);

      { Проверить на имя ОБЪЕКТА }
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

   { Новая область видимости переменных }
   { т.к войдём в функцию }
   BottomBorder := wTop + 1;

   wLine   := CurLine;
   wCur    := CurCh;
   wFun    := CurrentFun;
   wMethod := CurrentMethod;

   { Меняем номер текущеё функции (для WorkReturn() ) }
   CurrentFun := IdxFun;

   { Если установлен CurrentFun, то CurrentMethod сброшен }
   { и наоборот. }
   CurrentMethod := 0;

   { Премещаемся в тело функции }
   CurLine := Functions^[IdxFun]^.StartLine;

   If Functions^[IdxFun]^.Fun then
     res := Statement('кон фун','кон фун')
   Else
     res := Statement('кон проц','кон проц');

   { Освобождаем память из под аргументов }
   If BottomBorder > 0 then
     For i := BottomBorder to TopBorder do
       Dispose(Stack[i]);

   { Возврат на родину }
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
 { Косвенно-рекурсивная функция разбора всех опереторов языка }
 Function Statement(const strEnd1, strEnd2 : String) : Byte;
 Var
   nEnd : Byte;
 Begin
   { Возвращает 1 - если наткнулись на strEnd1 и 2 - если strEnd2         }
   { strEnd1, strEnd2 - указатели на строки содержащие возможные концовки }
   { для выхода из процедуры                                              }
   GetString;
   nEnd := 0;

   If fDebugMode And (CountWatches > 0) then
     RefreshWatches;

   
   While (nEnd = 0) do
   Begin
     { Проверка на концы }
     If Match(strEnd1) then
       nEnd := 1
     Else If Match(strEnd2) then
       nEnd := 2
     Else
     Begin
       { Развилка всех дорог }
       If Match('если') then
         WorkIf
       Else If Match('повтор') then
         WorkRepeat
       Else If Match('пока') then
         WorkWhile
       Else If Match('для') then
         WorkFor
       Else If Match('возврат') then
         WorkReturn
       Else If Match('вывод') then
         ShowMsg
       Else If Match('печать') then
         PrintMsg
       Else If Match('круг') then
         WorkCircle
       Else If Match('линия') then
         WorkLine
       Else If Match('тчк') then
         WorkPset
       Else If Match('залить') then
         WorkFill
       Else If Match('трг') then
         WorkTriangle
       Else If Match('рисунок') then
         WorkDrawing
       Else If Match('текст') then
         WorkText
       Else Begin
         if not FindDLLProc then
             WorkAssignment;

         If fDebugMode And (CountWatches > 0) then
           RefreshWatches;
       End;
     End; { Else  }

     { Может что-то оставили }
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
             LastError.sError := 'Несоответствие типов формального и фактического параметров';
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
        LastError.sError := 'Неверное число переданных параметров';
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
 { Начинает весь разбор файла }
  Procedure Parse;
  Var
    OldCurLine, OldCurCh : Word;
    i,j : Word;
    ImageIndex : Word;
    Idx : Word;
  Begin

    { Обработчик исключительных ситуаций в ядре   }
    { Ловит Silent Exception создаваемое Abort'ом }
    Try

      { Для минимальной программы необходимо 2 строчки }
      If CountLines < 2 then
        Error(ERR_RUN_TIME, 5);

      While CurLine <> CountLines do
      Begin
        GetString;

        { Сохраняем }
        OldCurCh := CurCh;

        AnalyzeClass;
        AnalyzeFunction;
        AnalyzeObjects;

        { Мы что-нибудь обработали ( судя по CurCh ) ? }
        If CurCh = OldCurCh then
          Error(ERR_RUN_TIME, 61);
      End;

      { Переходим к телу проц Старт используя ProcStart }
      { А видели ли мы проц Старт ? }
      If (ProcStart = 0) then
        Error(ERR_RUN_TIME, 13);

      for i := (CountObjects - CountIspolns + 1) to CountObjects do
      begin
        ImageIndex := i - (CountObjects - CountIspolns + 1) + 1;
        for j := 1 to Objects_m^[i]^.CountFields do
        begin
          Objects_m^[i]^.Fields[FindObjField(i,'сверху')].Int :=
                                      frmRunTime.Images[ImageIndex].Top;

          Objects_m^[i]^.Fields[FindObjField(i,'слева')].Int :=
                                      frmRunTime.Images[ImageIndex].Left;

          Objects_m^[i]^.Fields[FindObjField(i,'ширина')].Int :=
                                     frmRunTime.Images[ImageIndex].Width;

          Objects_m^[i]^.Fields[FindObjField(i,'высота')].Int :=
                                    frmRunTime.Images[ImageIndex].Height;

          Objects_m^[i]^.Fields[FindObjField(i,'картинка')].Str :=
    Ispolns[ImageIndex].Fields[FindIspField(ImageIndex, 'картинка')].Str;

          Objects_m^[i]^.Fields[FindObjField(i,'растяжение')].Bool :=
                                 frmRunTime.Images[ImageIndex].Stretch;

          Objects_m^[i]^.Fields[FindObjField(i,'видимость')].Bool :=
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
      { Вызываем проц Старт }
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
  { Является ли поле полем класс Изображение }
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
    If sFiled = 'имя' then
      Result := True; 
  End;
  
  { -------------------------------------------------------------------- }
  { Обработка описания класса }
  Procedure AnalyzeClass;
  Var
    sClassName  : String;
    sParentName : String;
    sFieldName  : String;
    IdxClass, i : Word;
    OldCurCh    : Word;
    IdxParent   : Word;
  Begin
    { Если описание не класса }
    If Not Match('класс') then
      Exit;

    sClassName := ReadName(53);

    { Такой класс уже есть ? }
    If FindClass(sClassName) <> 0 then
      Error(ERR_RUN_TIME, 54);

    { Если память под указатель на массив классов еще не выделяли }
    If (Not AllocMemClasses) then
    Begin
      AllocMemClasses := True;
      New(Classes_m);
    End;

    { Инкрементируем число классов }
    If (CountClasses + 1) > MAX_COUNT_CLASSES then
      Error(ERR_RUN_TIME, 62);

    Inc(CountClasses);
    New(Classes_m^[CountClasses]);

    { Устнавливаем имя классу }
    Classes_m^[CountClasses]^.Name  := sClassName;

    { инициализация полей }
    Classes_m^[CountClasses]^.Parent       := 0;
    Classes_m^[CountClasses]^.CountFields  := 0;
    Classes_m^[CountClasses]^.CountMethods := 0;

    { Класс порождён от другого класса }
    If Match('(') then
    Begin
      sParentName := ReadName(53);

      { Класс-предок существует ? }
      IdxClass := FindClass(sParentName);
      If IdxClass = 0 then
        Error(ERR_RUN_TIME, 56);

      Classes_m^[CountClasses]^.Parent := IdxClass;

      If Not Match(')') then
        Error(ERR_RUN_TIME, 55);
    End; { if <есть предок> }

    { === Разбираем родные поля и методы === }
    GetString;

    SkipBlanks;
    While (Copy(SourceCode[CurLine]^, CurCh, 9) <> 'кон класс') do
    Begin
      { Теперь идёт описание полей и методов класса }
      { Идёт описание метода или поля ? }
      OldCurCh := CurCh;
      If Match('проц') Or Match('фун') then
      Begin
        { Обработка Метода }
        CurCh := OldCurCh;
        AnalyzeMethod(CountClasses);
      End
      Else { описание полей }
      Begin
        { Значит идёт описание поля }
        { в,пп}
        While True do  { Выходим по Break }
        Begin
          sFieldName := ReadName(57);

          If Not BaseField(sFieldName) then
          begin
          
            { Может такое поле уже есть }
            If FindField(sFieldName, CountClasses) <> 0 then
              Error(ERR_RUN_TIME, 59);

            If FindMethod(sFieldName, CountClasses) <> 0 then
              Error(ERR_RUN_TIME, 77);

            { Добовляем новое поле к классу }
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
          
          { Если конц строки => конец цикла }
          If CurCh >= Length(SourceCode[CurLine]^) then
            Break;

          If Not Match(',') then
            Error(ERR_RUN_TIME, 58);

        End; { While True }

      End; { Else }

      { Можно ли делать GetString }
      If (CurLine + 1) > CountLines then
        Error(ERR_RUN_TIME, 60);

      GetString;
    End; { While CurLine < CountLines ... }

    If Not Match('кон класс') then
      Error(ERR_RUN_TIME, 60);

    { ----------------------------------------------}
    { Наследование элементов предка (если он есть). }
    If Classes_m^[CountClasses]^.Parent <> 0 then
    Begin
      { Теперь Наследуем ПОЛЯ и МЕТОДЫ ПРЕДКА }
      { Методы и поля предка могут быть переопределенны }
      IdxParent   := Classes_m^[CountClasses]^.Parent;

      { от 1 до числа полей у предка }
      For i := 1 to Classes_m^[IdxParent]^.CountFields do
      Begin
        { Если у класса нет такого поля, то добавляем его }
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
        End; {if <нет такого поля>}
      End; {for}

      { Теперь разберёмся с методами предка }
      For i := 1 to Classes_m^[IdxParent]^.CountMethods do
      Begin
        { Если у класса нет такого метода, то добавляем его }
        If FindMethod(Classes_m^[IdxParent]^.Methods[i].Name, CountClasses) = 0 then
        Begin
          With Classes_m^[CountClasses]^ do
          Begin
            Inc(CountMethods);
            { память под новый метод }
            New(Methods[CountMethods]);
            Methods[CountMethods] := Classes_m^[IdxParent]^.Methods[i];
          End; {with}
        End; {if}
      End; {for}
    End {if <есть предок>}
    Else Begin
      { Нет предка }
      { Наследуем от Изображение }
      { поля предка могут быть переопределенны }
           
      { от 1 до числа полей у Изображения }
      For i := 1 to 7 do
      Begin
        { Если у класса нет такого поля, то добавляем его }
        If FindField(Classes_m^[1]^.Fields[i].Name, CountClasses) = 0 then
        Begin
          With Classes_m^[CountClasses]^ do
          Begin
            Inc(CountFields);
            Fields[CountFields] := Classes_m^[1]^.Fields[i];
          End; {with}
        End; {if <нет такого поля>}
      End; {for}
    End; {else}
  End;

  { -------------------------------------------------------------------- }
  { Ищет класс по именеи }
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
  { Ишет поле в классе }
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
  { Разбирает метод класса }
  Procedure AnalyzeMethod(IdxClass : Word);
  Var
    MethodType  : Byte;
    sArgName : String;
    sBuf     : String;
  
    { Крутит ГетСтринг до кон проц }
    procedure GoToEndProc;
    begin
      While Not Match('кон') do
      Begin
        GetString;
        If CurLine > CountLines then  { Проверка на выезд за границу }
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
    { Если идет описание проц. или фун., то добовляет ее в табл. процедур.}
    { Возвращает True если было описание проц. или фун. }
    MethodType := 3;

    If Match('проц') then
      MethodType := 0
    Else If Match('фун') then
      MethodType := 1;

    { Если нет кл. слова проц или фун, то выходим из процедуры }
    If (MethodType = 3) then
      Exit;

    { Читаем имя фун или проц }
    sBuf := ReadName(63);

    { Если проц или фун с таким именем уже есть, то Еррор }
    If FindMethod(sBuf, IdxClass) <> 0 then
      Error(ERR_RUN_TIME, 64); { метод уже существует }

    { Может с ткаим именем поле у класса }
    If FindField(sBuf, IdxClass) <> 0 then
      Error(ERR_RUN_TIME, 76); { с таким именем поле }

    If (Classes_m^[IdxClass]^.CountMethods + 1) > MAX_COUNT_METHODS then
      Error(ERR_RUN_TIME, 65);

    { Увеличиваем кол-во методов у класса }
    Inc(Classes_m^[IdxClass]^.CountMethods);
    { Выделяем память под новый метод }
    New(Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^.CountMethods]);

    { Имя метода }
    Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^.CountMethods]^
                                                           .Name := sBuf;

    { Инициализируем т.к по умолчянию занчение = ??? }
    Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^.CountMethods]^
                                                       .CountArgs := 0;

    If Not Match('(') then
      Error(ERR_RUN_TIME, 66); { скобки нет }

    SkipBlanks;
    While (Copy(SourceCode[CurLine]^, CurCh, 1) <> ')') do
    Begin
      With Classes_m^[IdxClass]^ do
      Begin
        { читаем имя аргумента }
        sArgName := ReadName(67);

        { Может с таким именем уже есть аргумент ? }
        If ArgExist(sArgName, CountMethods) then
          Error(ERR_RUN_TIME, 68);

        { Может с таким именем уже есть функция ? }
        If FindFun(sArgName) <> 0 then
          Error(ERR_RUN_TIME, 79);

        { Может с таким именем поле класса ? }
        If FindField(sArgName, IdxClass) <> 0 then
          Error(ERR_RUN_TIME, 80);

        { Может с таким именем метод класса ? }
        If FindMethod(sArgName, IdxClass) <> 0 then
          Error(ERR_RUN_TIME, 81);

        { Проверить на имя ОБЪЕКТА }
        If FindObject(sArgName) <> 0 then
          Error(ERR_RUN_TIME, 94);

        { Может слишком много аргументов ? }
        If (Methods[CountMethods]^.CountArgs + 1) > MAX_COUNT_ARGS then
          Error(ERR_RUN_TIME, 69);

        { Добовляем его в список аргументов функции }
        Inc(Methods[CountMethods]^.CountArgs);
        Methods[CountMethods]^.Args[Methods[CountMethods]^.CountArgs] := sArgName;

        If Match(')') then
          Break;

        If Not Match(',') then
          Error(ERR_RUN_TIME, 70); { отсутствует запятая }

        If Match(')') then
          Error(ERR_RUN_TIME, 71); { имя аргумента функции не определенно }
      End; { With ... do }
    End;

    { Правильно ли описана фун. (может отсутствовать кон проц) }
    If (CurLine + 1) > CountLines then
      Error(ERR_RUN_TIME, 72);

    { Точка входа в функцию }
    Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^.CountMethods]^
                         .StartLine := CurLine;

    GoToEndProc; { катимся до кон проц }

    { Различия проц. и фун. }
    Case MethodType of
      0 : Begin
            Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^
            .CountMethods]^.Fun := False;
            If Not Match('проц') then
              Error(ERR_RUN_TIME, 74);
          End;
      1 : Begin
            Classes_m^[IdxClass]^.Methods[Classes_m^[IdxClass]^
            .CountMethods]^.Fun := True;
            If Not Match('фун') then
              Error(ERR_RUN_TIME, 75);
          End;
    End;

  End; { procedure }

  { -------------------------------------------------------------------- }
  { Ишет метод класса }
  Function FindMethod(const sMethodName : String; IdxClass : Word): Word;
  Var
    i : Word;
  Begin
    { Ищет метод по имени в таблице методов }
    { Если не нашли возвращаем 0 }
    { Иначе её индекс в таблице  }
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
  { Обработка описания объектов }
  Procedure AnalyzeObjects;
  Var
    sObjName, sClassName : String;
    IdxClass, OldCountObj : Word;
    IdxObj, IdxField : Word;
  Begin
    { объект в,а,п = мой_класс }
    If Not Match('объект') then
      Exit;

    { Память под массив объектов }
    If Not AllocMemObjects then
    Begin                
      AllocMemObjects := True;
      New(Objects_m);
    End;

    { Сохраняем кол-во объектов. }
    { Для копирования полей из класса в объект }
    OldCountObj := CountObjects;
    Repeat
      { читаем имя объекта }
      sObjName := ReadName(82);

      { Может их слишком много ? }
      If (CountObjects + 1) > MAX_COUNT_OBJECTS then
        Error(ERR_RUN_TIME, 83);

      { Может с таким именем объект есть }
      If FindObject(sObjName) <> 0 then
        Error(ERR_RUN_TIME, 84);

      { Может с таким именем функция есть }
      If FindFun(sObjName) <> 0 then
        Error(ERR_RUN_TIME, 85);

      { Память под очередной объект }
      Inc(CountObjects);
      New(Objects_m^[CountObjects]);

      { Имя объекта }
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

    { Получаем имя класса }
    sClassName := ReadName(89);

    { Существует ли такой класс ? }
    IdxClass := FindClass(sClassName);
    If IdxClass = 0 then
      Error(ERR_RUN_TIME, 90);

    { Копируем все поля из класса в объект т.к. у каждого объекта свой }
    { экземпляр полей. К методам доступ через RefToClass }
    For IdxObj := OldCountObj + 1 to CountObjects do
    Begin
      { Все поля класса }
      For IdxField := 1 to Classes_m^[IdxClass]^.CountFields do
      Begin
        Objects_m^[IdxObj]^.Fields[IdxField] :=
                                 Classes_m^[IdxClass]^.Fields[IdxField];
      End;
      { Кол-во полей }
      Objects_m^[IdxObj]^.CountFields := Classes_m^[IdxClass]^.CountFields;

      { Ссылка на класс }
      Objects_m^[IdxObj]^.RefToClass := IdxClass;
    End; { for }

  End;

  { -------------------------------------------------------------------- }
  { Поиск объекта }
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
  { Вызывает метод класса }
  Procedure CallMethod(IdxClass, IdxMethod, IdxObject : Word);
  Var
    wTop, wBottom, wArgs, wFun : Word;
    IdxArg, i         : Word;
    wLine, wCur, wBuf : Word;
    wObject, wMethod  : Word;
    wClass            : Word;
    sBuf : String;
  Begin
    { IdxFun - номер фун или проц в таблице методов класса }
    { Сохраняем старую область видимости }
    wBottom := BottomBorder;
    wTop    := TopBorder;

    With Classes_m^[IdxClass]^ do
    Begin

      sBuf := Objects_m^[IdxObject].Name + '.' + Methods[IdxMethod]^.Name + '(';

      { Обязательно должна быть пара скобок : s := f() + 4 }
      If Not Match('(') then
        Error(ERR_RUN_TIME, 101);

      wArgs := 0;
      { Обработка передаваемых параметров }
      { Засовываем в стек передоваемые значения, а затем }
      { присвоим им имена }
      If Methods[IdxMethod]^.CountArgs <> 0 then
      Begin
        { Бескон-ый цикл (выход - break) }
        Repeat
          { MyObj.msg('Hello World', 3+4, .и. или .л.) }
          Inc(wArgs);
          { Вычесляем очередной параметр }
          WorkExpression;
          IdxArg := CreateNewVar('');

          { Присваеваем значен. }
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
                    sBuf := sBuf + '.и.'
                  Else
                    sBuf := sBuf + '.л.';
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

      { Сколько приняли парам-ов и ск-ко описано арг-ов }
      If wArgs <> Methods[IdxMethod]^.CountArgs then
        Error(ERR_RUN_TIME, 44);

      { Устанавливаем имена в стеке }
      wArgs := 0;
      For i := wTop + 1 to TopBorder do
      Begin
        Inc(wArgs); { - Какой аргумент по счёту }

        { Может с таким именем уже есть функция }
        wBuf := FindFun(Methods[IdxMethod]^.Args[wArgs]);
        If wBuf <> 0 then
          Error(ERR_RUN_TIME, 48);

        { Проверить на имя ОБЪЕКТА }
        If FindObject(Methods[IdxMethod]^.Args[wArgs]) <> 0 then
          Error(ERR_RUN_TIME, 93);

        { Может с таким именем есть метод у класса ? }
        If FindMethod(Methods[IdxMethod]^.Args[wArgs], IdxClass) <> 0 then
          Error(ERR_RUN_TIME, 102);

        { Может с таким именем есть поле у класса ? }
        If FindField(Methods[IdxMethod]^.Args[wArgs], IdxClass) <> 0 then
          Error(ERR_RUN_TIME, 103);

        Stack[i]^.Name := Methods[IdxMethod]^.Args[wArgs];
      End; { for }

      { Новая область видимости переменных }
      { т.к войдём в функцию }
      BottomBorder := wTop + 1;

      wLine   := CurLine;
      wCur    := CurCh;
      wFun    := CurrentFun;
      wMethod := CurrentMethod;
      wObject := CurrentObject;
      wClass  := CurrentClass;

      { Меняем номер текущго метода (для WorkReturn() ) }
      CurrentMethod := IdxMethod;

      { Меняем номер текущго класса }
      CurrentObject := IdxObject;

      { Если установлен CurrentMethod, то CurrentFun сброшен }
      { и наоборот. }
      CurrentFun := 0;

      { Для прямого доступа к полям }
      CurrentClass := IdxClass;

      { Премещаемся в тело функции }
      CurLine := Methods[IdxMethod]^.StartLine;

      If Methods[IdxMethod]^.Fun then
        res := Statement('кон фун','кон фун')
      Else
        res := Statement('кон проц','кон проц');

      { Освобождаем память из под аргументов }
      If BottomBorder > 0 then
        For i := BottomBorder to TopBorder do
          Dispose(Stack[i]);

      { Возврат на родину }
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
  { Обработка оператора условия (ветвления) }
  Procedure WorkIf;
  Var
    fBuf : Boolean;
  Begin
    WorkExpression;
    
    If Not fExec then
    begin
      AX.selType := 3;
    end;
    
    { Рез. выражения должен быть логического типа }
    If AX.selType <> 3 then
      Error(ERR_RUN_TIME, 26);

    { Если Выражение ИСТИНА, то катимся до иначе (если оно есть)   }
    { или до всё (ВЫПОЛНЯЯ ОПЕРАТОРЫ). Если мы до иначе выполнили, }
    { то сбрасываем fExec и едим до всё не выполняя операторы.     }
    { Если иначе нет, то мы своё отработали }

    { Если Выражение ЛОЖЬ, то катимся до иначе (если оно есть)          }
    { или до всё (!!! НЕ ВЫПОЛНЯЯ ОПЕРАТОРЫ). Если мы до иначе доехали, }
    { то устанавливаем fExec и выполняем все операторы до ВСЁ.          }
    { Если иначе нет, то выполнять нечего }

    If AX.Bool then
    Begin
      res   := Statement('иначе','всё');

      { Если дошли до иначе, то катимся до всё не выполняя операторы }
      If res = 1 then
      Begin
        { Сохраняем (из-за рекурсии) }
        fBuf  := fExec;
        fExec := False;

        res   := Statement('всё', 'всё');

        { Востонавливаем старое занчение }
        fExec := fBuf;
      End;
    End
    Else Begin
      { катимся до всё или иначе не выполняя операторы }
      { Сохраняем (из-за рекурсии) }
      fBuf  := fExec;
      fExec := False;

      res   := Statement('иначе', 'всё');
      { Востонавливаем старое занчение }
      fExec := fBuf;

      If res = 1 then  { Дошл до иначе }
      Begin
        res   := Statement('всё', 'всё');
      End;
    End; { AX.Bool = True/False }

  End;

  { -------------------------------------------------------------------- }
  { Цикл ПОВТОР }
  Procedure WorkRepeat;
  Var
    i, RepeatCnt   : Longint;
    wBuf : Word;
  Begin
    { Вычисляем кол-во тактов цикла }
    WorkExpression;

    If fExec then
    Begin
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 28);

      { Кол-во повторов (тактов) цикла }
      RepeatCnt := AX.Int;
    End
    Else RepeatCnt := 1; { Всё равно нужно дойти до }
                         {КЦ (не выполн.) }

    { Запомним старое положение в коде (мы крутимся в }
    { цикле и возвр. сюда) }
    wBuf  := CurLine;
    For i := 1 to RepeatCnt do
    Begin
      CurLine := wBuf;
      res  := Statement('кц', 'кц');
    End;
  End;

  { -------------------------------------------------------------------- }
  { Цикл ПОКА }
  Procedure WorkWhile;
  Var
    wLine, wCur : Word;
    fBuf : Boolean;
  Begin
    If Not fExec then
    Begin
      { Просто спускаемся до КЦ }
      { и выходим из проц. }
      fBuf  := fExec;
      fExec := False;
      res   := Statement('кц','кц');
      fExec := fBuf;
      Exit;
    End;

    wLine := CurLine;
    wCur  := CurCh;
    Repeat { бесконечный цикл }
      CurLine := wLine;
      CurCh   := wCur;
      WorkExpression;
      If AX.selType <> 3 then
        Error(ERR_RUN_TIME, 29);

      If AX.Bool then
        res := Statement('кц','кц')
      Else Begin
        { Выражение ЛОЖНО => спускаемся просто до КЦ }
        { и выходим из проц. }
        fBuf  := fExec;
        fExec := False;
        res   := Statement('кц','кц');
        fExec := fBuf;
        Exit;
      End;
    Until False;
  End;

  { -------------------------------------------------------------------- }
  { Ищет перемнную по имени }
  Function FindVar(const sVarName : String) : Word;
  Var
    i : Word;
  Begin
    FindVar := 0;
    { Если вообще нет переменных }
    If TopBorder < 1 then
      Exit;

    { Ищем в текущей области видемости }
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
  { Создаёт новую локальную переменную }
  Function CreateNewVar(const sVarName : String) : Word;
  Var
    IdxFun, wBuf : Word;
  Begin
    { Может быть их сильно много ? }
    If (TopBorder + 1) > MAX_COUNT_VARS Then
      Error(ERR_RUN_TIME, 32);

    { Может с таким именем уже есть функция }
    IdxFun := FindFun(sVarName);
    If IdxFun <> 0 then
      Error(ERR_RUN_TIME, 48);

    { Может с таким именем уже есть переменная }
    If sVarName <> '' then
    Begin
      wBuf := FindVar(sVarName);
      If wBuf <> 0 then
        Error(ERR_RUN_TIME, 49);

      { проверить на имя ОБЪЕКТА }
      If FindObject(sVarName) <> 0 then
        Error(ERR_RUN_TIME, 95);
    End; { if }


    { Создаём новую и выделяем под неё память }
    Inc(TopBorder);
    New(Stack[TopBorder]);

    { По умолчанию тип переменной - 2 (целочисленный) }
    Stack[TopBorder]^.Name := sVarName;
    Stack[TopBorder]^.selType := 2;
    Stack[TopBorder]^.Str  := '';
    Stack[TopBorder]^.Int  := 0;
    Stack[TopBorder]^.Bool := False;

    { Возвращаем порядковый номер переменной }
    CreateNewVar := TopBorder;
  End;

  { -------------------------------------------------------------------- }
  { Прямое обращения к члену класса }
  Function WorkStrightAccess(const sMember : String) : Boolean;
  Var
    IdxMember  : Word;
    ImageIndex : Word;
  Begin
    WorkStrightAccess := False;

    { Может это метод ? }
    { Ищем у класса }
    IdxMember := FindMethod(sMember, CurrentClass);
    If IdxMember <> 0 then
    Begin
      { Тут вызыватся могут только процедуры }
      If Classes_m^[CurrentClass]^.Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 99);

      { Вызываем метод }
      CallMethod(CurrentClass, IdxMember, CurrentObject);

      { выход из функции }
      WorkStrightAccess := True;
      Exit;
    End;

    { Это поле ? }
    IdxMember := FindField(sMember, CurrentClass);
    If IdxMember <> 0 then
    Begin
      If Not Match(':=') then
        Error(ERR_RUN_TIME, 114);  { нет := }

      WorkExpression;

      Objects_m^[CurrentObject]^.Fields[IdxMember].selType := AX.selType;
      Objects_m^[CurrentObject]^.Fields[IdxMember].Int  := AX.Int;
      Objects_m^[CurrentObject]^.Fields[IdxMember].Str  := AX.Str;
      Objects_m^[CurrentObject]^.Fields[IdxMember].Bool := AX.Bool;

      ImageIndex := CurrentObject - (CountObjects - CountIspolns + 1) + 1; 
      
      If sMember      = 'слева'    then
        frmRunTime.Images[ImageIndex].Left := AX.Int
      Else if sMember = 'сверху'     then
        frmRunTime.Images[ImageIndex].Top  :=  AX.Int
      Else if sMember = 'ширина'    then
        frmRunTime.Images[ImageIndex].Width   := AX.Int
      Else if sMember = 'высота'    then
        frmRunTime.Images[ImageIndex].Height  := AX.Int
      Else if sMember = 'видимость' then
        frmRunTime.Images[ImageIndex].Visible := AX.Bool
      Else if sMember = 'растяжение' then
        frmRunTime.Images[ImageIndex].Stretch := AX.Bool
      Else if sMember = 'картинка'  then
        frmRunTime.Images[ImageIndex].Picture.LoadFromFile(AX.Str);

      Application.ProcessMessages;

     WorkStrightAccess := True;
    End; {if}
  End;

  { -------------------------------------------------------------------- }
  { Обращение к члену объекта через '.' }
  Procedure WorkObjectMember(IdxObject : Word);
  Var
    IdxMember  : Word;
    sMember    : String;
    ImageIndex : Word;
  Begin

    sMember := ReadName(97);

    { Может это метод ? }
    IdxMember := FindObjectMethod(sMember, IdxObject);
    If IdxMember <> 0 then
    Begin
      { Тут вызыватся могут только процедуры }
      If Classes_m^[Objects_m^[IdxObject]^.RefToClass]^
                                   .Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 99);

      { Вызываем метод }
      CallMethod(Objects_m^[IdxObject]^.RefToClass, IdxMember, IdxObject);

      { выход из функции }
      Exit;
    End;

    { Это поле }
    IdxMember := FindObjectField(sMember, IdxObject);
    If IdxMember = 0 then
      Error(ERR_RUN_TIME, 98);

    If Not Match(':=') then
      Error(ERR_RUN_TIME, 114);  { нет := }

    WorkExpression;

    Objects_m^[IdxObject]^.Fields[IdxMember].selType := AX.selType;
    Objects_m^[IdxObject]^.Fields[IdxMember].Int  := AX.Int;
    Objects_m^[IdxObject]^.Fields[IdxMember].Str  := AX.Str;
    Objects_m^[IdxObject]^.Fields[IdxMember].Bool := AX.Bool;


    ImageIndex := IdxObject - (CountObjects - CountIspolns + 1) + 1; 

    If sMember      = 'слева'    then
      frmRunTime.Images[ImageIndex].Left := AX.Int
    Else if sMember = 'сверху'     then
      frmRunTime.Images[ImageIndex].Top  :=  AX.Int
    Else if sMember = 'ширина'    then
      frmRunTime.Images[ImageIndex].Width   := AX.Int
    Else if sMember = 'высота'    then
      frmRunTime.Images[ImageIndex].Height  := AX.Int
    Else if sMember = 'видимость' then
      frmRunTime.Images[ImageIndex].Visible := AX.Bool
    Else if sMember = 'растяжение' then
      frmRunTime.Images[ImageIndex].Stretch := AX.Bool
    Else if sMember = 'картинка'  then
      frmRunTime.Images[ImageIndex].Picture.LoadFromFile(AX.Str);

    Application.ProcessMessages;

  End;

  { -------------------------------------------------------------------- }
  { Оператор присвоения и вызов функций }
  Procedure WorkAssignment;
  Var
    sName  : String;
    Idx, IdxVar : Word;
  Begin
    If Not fExec then
      Exit;

    { Приоритет идентификаторов : }
    { 1. Объектов     }
    { 2. Проц и фун   }
    { 3. Переменных   }

    { Обработка вызова функции или оператора присвоения }

    If Match('предок') then
    Begin
      WorkParent(True);
      Exit;
    End;

    sName  := ReadName(30);

    { Это объект ? }
    Idx := FindObject(sName);
    If Idx <> 0 then
    Begin
      if Not Match('.') then
        Error(ERR_RUN_TIME, 96);

      { Idx - индекс объекта }
      { Обработка обращения к члену объекта }
      WorkObjectMember(Idx);
      Exit;
    End;

    { Если мы в методе, то есть возможность напрямую обращаться }
    { к элементам класса }
    If (CurrentMethod <> 0) And (CurrentObject <> 0) then
    Begin

      If WorkStrightAccess(sName) then
        Exit;
    End;

    { Это функция ? }
    Idx := FindFun(sName);

    If Idx <> 0 then
    Begin
      { Вдруг хотят вызвать проц старт }
      If Idx = ProcStart then
        Error(ERR_RUN_TIME, 46);

      If Functions^[Idx]^.Fun then
        Error(ERR_RUN_TIME, 52);

      { Вызываем фун. или проц и выходим отсюда }
      CallFunction(Idx);
      Exit;
    End;

    IdxVar := FindVar(sName);

    { Если перем. не существует создаём её }
    If IdxVar = 0 then
      IdxVar := CreateNewVar(sName);


    { Значит это опер. присвоения т.к на все остальные опер-ры}
    { языка мы уже проверяли. }
    If Not Match(':=') then
      Error(ERR_RUN_TIME, 31);  { идентификатор не определён }

    { Вычисляем выражение }
    WorkExpression;

    { Присваеваем результат переменной. }
    { Проще присвоить все поля, чем анализировать }
    { selType у AX (всего 3 присвоения или 2 услов. и 3 присвоен) }

    Stack[IdxVar]^.selType  := AX.selType;
    Stack[IdxVar]^.Int  := AX.Int;
    Stack[IdxVar]^.Str  := AX.Str;
    Stack[IdxVar]^.Bool := AX.Bool;
  End;

  { -------------------------------------------------------------------- }
  { Ищет метод объекта }
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
  { Ищет поле объекта }
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
  { Цикл ДЛЯ }
  Procedure WorkFor;
  Var
    sVarName : String;
    V1,V2, Step  : Longint;
    IdxVar,wLine : Word;
    fBuf : Boolean;
    { Считывает границы цикла }
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
      res := Statement('кц','кц');
      Exit;
    End;

    { для и от 1 до 12 шаг 3}
    sVarName := ReadName(30);

    { Если нет имени переменной }
    If sVarName = 'от' then
      Error(ERR_RUN_TIME, 51);

    If Not Match('от') then
      Error(ERR_RUN_TIME, 34);

    { Получаем границы цикла }
    V1 := GetValue;
    If Not Match('до') then
      Error(ERR_RUN_TIME, 36);
    V2 := GetValue;

    { Определяем шаг цикла (1-стандарт) }
    Step := 1;
    If Match('шаг') then
    Begin
      WorkExpression;
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 37);
      Step := AX.Int;
    End;

    { V1 to/dowto V2 - ? }
    wLine := CurLine;
    
    { Получаем порядковый номер счётчика цикла (перемнной) }
    { После работы цикла она остаётся в стеке. }
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
      { Крутим цикл изменяя зачение счётчика }
      Stack[IdxVar]^.Int := V1;
      While Stack[IdxVar]^.Int <= V2 do
      Begin
        CurLine := wLine;
        res := Statement('кц','кц');
        Stack[IdxVar]^.Int := Stack[IdxVar]^.Int + Step;
      End;
    End
    Else If (Step < 0) And (V1 >= V2) then
    Begin
      { Крутим цикл изменяя зачение счётчика }
      Stack[IdxVar]^.Int := V1;
      While Stack[IdxVar]^.Int >= V2 do
      Begin
        CurLine := wLine;
        res := Statement('кц','кц');
        Stack[IdxVar]^.Int := Stack[IdxVar]^.Int + Step;
      End;
    End
    Else If (Step = 0) then
    Begin
      Stack[IdxVar]^.Int := V1;
      While True do
      Begin
        CurLine := wLine;
        res := Statement('кц','кц');
      End;
    End
    Else Begin
      fBuf  := fExec;
      fExec := False;

      res   := Statement('кц', 'кц');

      { Востонавливаем старое занчение }
      fExec := fBuf;  
    End;
  End;

  { -------------------------------------------------------------------- }
  { Вычисляет результат функции }
  Procedure WorkReturn;
  Begin
    If Not fExec then
      Exit;

    WorkExpression;

    { Мы в фун. или методе ? }
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
  { Обработка обращения к предку класса }
  Procedure WorkParent(bLeftPart : Boolean);
  Var
    sName     : String;
    IdxMember : Word;
  Begin
    { If LeftPart then }
    {   Можно обращаться только к процедурам предка }
    { Else }
    {   Можно обращаться только к функциям предка   }

    If (CurrentMethod = 0) Or (CurrentObject = 0) then
      Error(ERR_RUN_TIME, 106);
    If Not Match('.') then
      Error(ERR_RUN_TIME, 107);

    { Имеет ли этот класс предка ? }
    If Classes_m^[CurrentClass]^.Parent = 0 then
      Error(ERR_RUN_TIME, 113);

    sName := ReadName(108);

    IdxMember := FindMethod(sName, Classes_m^[CurrentClass]^.Parent);
    If IdxMember = 0 then
      Error(ERR_RUN_TIME, 111);

    If bLeftPart then
    Begin
      { Тут вызыватся могут только процедуры }
      If Classes_m^[Classes_m^[CurrentClass]^.Parent]^
                                      .Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 99);

      CallMethod(Classes_m^[CurrentClass]^.Parent,
                                           IdxMember,CurrentObject);
    End
    Else Begin
      { Тут вызыватся могут только функции }
      If Not Classes_m^[Classes_m^[CurrentClass]^.Parent]^
                                        .Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 112);

      { Инициализируем возвращаемые значения }
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
        { Извлекаем результат функции }
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
            frmCon.PrintMessage('.и.')
          Else
            frmCon.PrintMessage('.л.');
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
            ShowMessage('.и.')
          Else
            ShowMessage('.л.');
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
      
    //точка (x1,y1)
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

    //круг(x1,y1,r,color)
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
      
    //тчк(x1,y1,color)
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
      
    //линия (x1,y1,x2,y2,color)
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
    
    // залить (x1,y1,x2,y2,color)
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

    // трг(x1,y1,x2,y2,x3,y3,color)
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

    // рисунок (x1,y1,x2,y2,'my.bmp')
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

    // текст(x1,y1,ForeColor, BGColor, '')
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
  { Вычесляет очередной операнд выражения и пихает его в AX }
  Procedure GetOperand;
  Begin
    { Может вызвать функцию, считать из переменной. Значение }
    { пихает в AX () }

    If Match('.') then           { Булевая константа   }
      ReadBoolean_1
    Else If Match(Chr(39)) then  { Строковая константа }
      ReadString_1
    Else If SourceCode[CurLine]^[CurCh] in ['0'..'9'] then  { Число }
      ReadInteger_1
    Else If Match('(') then
      WorkBrackets
    Else If Match('-') then  { Смена знака }
    Begin
      //If Not (SourceCode[CurLine]^[CurCh] in ['0'..'9']) then
      //  Error(ERR_RUN_TIME, 19);
      WorkExpression;
      //ReadInteger_1;
      If AX.selType <> 2 then
        Error(ERR_RUN_TIME, 123);  
      AX.Int := -AX.Int;
    End
    Else If Match('не') then
    Begin
      WorkExpression;
      Case AX.selType of
        2 : AX.Int  := Not AX.Int;
        3 : AX.Bool := Not AX.Bool
        Else
          Error(ERR_RUN_TIME, 40);
      End; { case }
    End
    Else If Match('предок') Then
      WorkParent(False) { предок. стоит в выраж. (после :=) }
    Else If Match('вводстр')then
      WorkInput(1)
    Else If Match('вводцел')then
      WorkInput(2)
    Else If Match('вводлог')then
      WorkInput(3)
    Else If Match('случ') then
      WorkRandom
    Else If Match('точка') then
      WorkPixel
    Else If Match('длинастр') then
      WorkStrLength
    Else If Match('вырезка') then
      WorkStrCopy
    Else If Match('аск') then
      WorkGetAscii
    Else If Match('симв') then
      WorkChr
    Else If Match('стрвчисло') then
      WorkStrToInt  
    Else If Match('числовстр') then
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
    {вырезка(стр,1,3)}

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
  { Обработчик ввода }
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
            sBuf := '.и.'
          Else
            sBuf := '.л.';
    End;

    Case selType of
      1 : sDefault := '';
      2 : sDefault := '0';
      3 : sDefault := '.л.';
    End;

    sBuf := InputBox('Ввод', sBuf, sDefault);

    AX.selType := selType;
    Case selType of
      1 : AX.Str := sBuf;
      2 : AX.Int := StrToInt(sBuf);
      3 : Begin
            AnsiLowerCase(sBuf);
            If (sBuf <> '.и.') And (sBuf <> '.л.') then
              Error(ERR_RUN_TIME, 121);
            If sBuf = '.и.' then
              AX.Bool := True
            Else
              AX.Bool := False;  
          End;
    End;

    If Not Match(')') then
      Error(ERR_RUN_TIME, 122);
  End;

  { -------------------------------------------------------------------- }
  { Генератор случайных чисел - ГСЧ }
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
    // СтрВЧисло(str)
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
    // ЧислоВСтр(цел)
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
  { Обработчик скобок }
  Procedure WorkBrackets;
  Begin
    WorkExpression;
    If Not Match(')') then
      Error(ERR_RUN_TIME, 25);
  End;

  { -------------------------------------------------------------------- }
  { Чтение булевой константы }
  Procedure ReadBoolean_1;
  Begin
    AX.selType := 3; { Boolean }

    If Match('и') then
      AX.Bool := True
    Else If Match('л') then
      AX.Bool := False
    Else
      Error(ERR_RUN_TIME, 20);    { неверное описание лог. константы }

    If Not Match('.') then
        Error(ERR_RUN_TIME, 20);  { неверное описание лог. константы }
  End;

  { -------------------------------------------------------------------- }
  { Чтение строковой константы }
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
  { Чтение целог числа }
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
  { Получение значения члена объекта (поля или функции) }
  Procedure GetMemberValue(IdxObject : Word);
  Var
    sMember   : String;
    IdxMember : Word;
  Begin
    sMember := ReadName(97);

    { Может это метод ? }
    IdxMember := FindObjectMethod(sMember, IdxObject);
    If IdxMember <> 0 then
    Begin
      { Тут вызываться могут только функции }
      If Not Classes_m^[Objects_m^[IdxObject]^.RefToClass]^
                                       .Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 100);

      { Инициализируем возвращаемые значения }
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
        { Извлекаем результат функции }
        AX.selType := Methods[IdxMember]^.Result.selType;
        AX.Int  := Methods[IdxMember]^.Result.Int;
        AX.Str  := Methods[IdxMember]^.Result.Str;
        AX.Bool := Methods[IdxMember]^.Result.Bool;
      End;
    End
    Else Begin
      { Это поле }
      IdxMember := FindObjectField(sMember, IdxObject);
      If IdxMember = 0 then
        Error(ERR_RUN_TIME, 115);

      { Читаем значен. поля в AX }
      { Присваиваю всё подряд чтобы не мучиться }
      AX.selType := Objects_m^[IdxObject]^.Fields[IdxMember].selType;
      AX.Str  := Objects_m^[IdxObject]^.Fields[IdxMember].Str;
      AX.Int  := Objects_m^[IdxObject]^.Fields[IdxMember].Int;
      AX.Bool := Objects_m^[IdxObject]^.Fields[IdxMember].Bool;
      
    End; {else}
  End; 

  { -------------------------------------------------------------------- }
  { Получение значения члена класса (поля или функции) при }
  { прямом обращении }
  Function GetMemberValue_2(const sMember : String) : Boolean;
  Var
    IdxMember : Word;
  Begin
    GetMemberValue_2 := False;

    { Может это метод ? }
    IdxMember := FindMethod(sMember, CurrentClass);
    If IdxMember <> 0 then
    Begin
      { Тут вызываться могут только функции }
      If Not Classes_m^[CurrentClass]^.Methods[IdxMember]^.Fun then
        Error(ERR_RUN_TIME, 100);

      { Инициализируем возвращаемые значения }
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
        { Извлекаем результат функции }
        AX.selType := Methods[IdxMember]^.Result.selType;
        AX.Int  := Methods[IdxMember]^.Result.Int;
        AX.Str  := Methods[IdxMember]^.Result.Str;
        AX.Bool := Methods[IdxMember]^.Result.Bool;
      End;
      GetMemberValue_2 := True;
    End
    Else Begin
      { Это поле }
      IdxMember := FindField(sMember, CurrentClass);
      If IdxMember <> 0 then
      Begin
        { Читаем значен. поля в AX }
        { Присваиваю всё подряд чтобы не мучиться }
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
             LastError.sError := 'Несоответствие типов формального и фактического параметров';
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
        LastError.sError := 'Неверное число переданных параметров';
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
  { Считывает в AX значение перем. или фун. }
  Procedure ReadVar;
  Var
    sName  : String;
    Idx, IdxVar : Word;

  Begin

    //
    if FindDLLFun then
        Exit;
    //
    
    { Приоритет идентификаторов : }
    { 1. Объектов     }
    { 2. Проц и фун   }
    { 3. Переменных   }
    sName  := ReadName(30);

    { Это объект ? }
    Idx := FindObject(sName);
    If Idx <> 0 then
    Begin
      if Not Match('.') then
        Error(ERR_RUN_TIME, 96);

      GetMemberValue(Idx);
      Exit;
    End;

    { Если мы в методе класса, может стоять обращение к членам }
    { без указания объекта }
    If (CurrentMethod <> 0) And (CurrentObject <> 0) then
    Begin
      If GetMemberValue_2(sName) then
        Exit;
    End;

    { Это функция ? }
    Idx := FindFun(sName);

    If Idx <> 0 then
    Begin
      { Это должна быть фун., а не проц. }
      If Not Functions^[Idx]^.Fun then
        Error(ERR_RUN_TIME, 33);

      { Инициализируем возвращаемые значения }
      Functions^[Idx]^.Result.selType := 2;
      Functions^[Idx]^.Result.Str  := '';
      Functions^[Idx]^.Result.Int  := 0;
      Functions^[Idx]^.Result.Bool := False;

      CallFunction(Idx);

      { Извлекаем результат функции }
      AX.selType := Functions^[Idx]^.Result.selType;
      AX.Int  := Functions^[Idx]^.Result.Int;
      AX.Str  := Functions^[Idx]^.Result.Str;
      AX.Bool := Functions^[Idx]^.Result.Bool;
    End
    Else Begin
      { Значит это переменная }
      IdxVar := FindVar(sName);

      { Если такой нет, создаём её }
      If IdxVar = 0 then
        IdxVar := CreateNewVar(sName);

      { Читаем значен. переменной в AX }
      { Присваиваю всё подряд чтобы не мучиться }
      AX.selType := Stack[IdxVar]^.selType;
      AX.Str  := Stack[IdxVar]^.Str;
      AX.Int  := Stack[IdxVar]^.Int;
      AX.Bool := Stack[IdxVar]^.Bool;
    End; { else - var }
  End;

  { -------------------------------------------------------------------- }
  { Сохраняет значение регистра AX в Стек }
  Procedure PUSH;
  Begin
    { Проверка на переполнение стека }
    { Стек не резиновый }
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
  { Вытаскивает значение из стека в BX }
  Procedure POP;
  Begin
    BX.selType := Stack[CurStack]^.selType;
    BX.Str  := Stack[CurStack]^.Str;
    BX.Int  := Stack[CurStack]^.Int;
    BX.Bool := Stack[CurStack]^.Bool;
    { Как бы на другую часть стека не залезть }
    If (CurStack -1) >= MAX_COUNT_VARS then
    Begin
      Dispose(Stack[CurStack]);
      Dec(CurStack);
    End
    Else
      Error(ERR_RUN_TIME, 22);
  End;

  { -------------------------------------------------------------------- }
  { Выполняет операцию над регистрами }
  Procedure CalcRegs(const sOper : String);
  Begin
    { Выполняет операцию и пихает результат в AX }

    { Одинаковы ли типы у операндов ? }
    If AX.selType <> BX.selType then
      Error(ERR_RUN_TIME, 23);  { Несоотв. типов }

    If sOper = 'или' then             { -- OR -- }
    Begin
      If AX.selType <> 3 then
        Error(ERR_RUN_TIME, 23);

      AX.Bool := (AX.Bool OR BX.Bool);
    End
    Else If sOper = 'и' then          { -- AND -- }
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
  { Процедура разбора выражений }
  Procedure WorkExpression;
  Begin
    { Разбирает выражения и помещает рузультат в регистр AX             }
    { AX : TResult;                                                     }
    { В выражении могут быть : лог. операции, арифмет-ие, вызов функций }
    If Not fExec then
      Exit;
      
    GetOperand;
    If CurCh >= Length(SourceCode[CurLine]^) then
      Exit;                       

    While Operator_OR do;
  End;

  { -------------------------------------------------------------------- }
  { Обработка лог. операции ИЛИ }
  Function Operator_OR : Boolean;
  Begin
    { Вовращает True если чего-то вычеслили }
    If CurCh >= Length(SourceCode[CurLine]^) then
    begin
      Operator_OR := False;
      Exit;
    end;

    If Match('или') then
    Begin
      { Сохраняет Регистр AX в стек }
      PUSH;
      { Получаем следующий операнд }
      GetOperand;
      { Обработаем у которых выше приоритет }
      While Operator_AND do;
      { Востонавливаем старый AX в BX }
      POP;
      { Производим операцию над регистрами }
      CalcRegs('или');
      { Мы выполнили один из операторов }
      Operator_OR := True;
    End
    Else
      Operator_OR := Operator_AND;
  End;

  { -------------------------------------------------------------------- }
  { Обработка лог. операции И }
  Function Operator_AND : Boolean;
  Begin
    { Вовращает True если чего-то вычеслили }
    If Match('и') then
    Begin
      PUSH;
      GetOperand;
      While Operator_G1 do;  { >, <, >=, <=, <>, = }
      POP;
      CalcRegs('и');
      Operator_AND := True;
    End
    Else
      Operator_AND := Operator_G1; { >, <, >=, <=, <>, = }
  End;

  { -------------------------------------------------------------------- }
  { Обработка лог. операций сравнения }
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
    { Вовращает True если чего-то вычеслили }
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
  { Обработка арифметических операций : +, - }
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
  { Обработка арифметических операций : *, / }
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
      { Приоритета выше нет }
      Operator_G3 := False;
  End;

  { ----------------------------- * - * - * ---------------------------- }
  { Сообщение об ошибке }
  Procedure Error(ErrKind : Byte; ErrNumber : Word);
  Var
    FError : Text;
    sBuf   : String;
    sSrc   : String;
    i      : Word;
    sErr   : String;
    sErrLine  : String;

  Begin
    { Читаем описание ошибки номер ErrNumber из }
    { errors.def и выводим на экран.            }
    i := 0;
    AssignFile(FError, 'ini\errors.def');
    Reset(FError);

    While (Not EOF(FError)) And (i <> ErrNumber) do
    Begin
      Readln(FError, sBuf);
      EraseBlank(@sBuf);

      { комментарий в файле }
      If (sBuf[1] <> '#') then
        Inc(i);

    End;

    CloseFile(FError);
    sErr     := '';
    sErrLine := '';

    { Тип ошибки }
    Case ErrKind of
      ERR_RUN_TIME  :Begin
                       { На случай если CurLine = 0 }
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
    MessageBox(frmRunTime.Handle,PChar('Ошибка времени выполнения :' + #10#13 +
    #10#13 + LastError.sError + #10#13 + LastError.sLine),'Вниминие', MB_ICONERROR);

    If sProjectFile = '' then
      Case MessageBox(frmError.Handle, PChar('Сохранить изменения в проекте'), 'Конструктор Исполнителей', MB_YESNO) Of
        IDYES : frmFileMenu.N8Click(frmUserForm);
      End
    Else
      Case MessageBox(frmError.Handle, PChar('Сохранить изменения в ' + sProjectFile), 'Конструктор Исполнителей', MB_YESNO) Of
        IDYES : SaveProject(sProjectFile);
      End;
    Application.Terminate;
    }


    Abort;  //  ВСПЛЫВАЕМ !!!

  End; { proc }
End.
