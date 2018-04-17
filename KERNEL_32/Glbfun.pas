{***************************************}
{  Модуль с глобальными функциями       }
{  и процедурами.                       }
{  Written by Kurnosov M.               }
{***************************************}

Unit GlbFun;

interface

Uses Types;

  Procedure ShowError(ErrNumber : Word);

  { Конвертирует sSrc в нижний регистр }
  { Windows кодировка                  }
  Procedure K_LowerCase(sSrc : PString);

  { Удаляет лишние пробелы ( не трогает между апострофами) }
  Procedure EraseBlank(sSrc : PString);

implementation

Uses Main,     { only for WriteToCon         }
     SysUtils,WinProcs; { only for IntToStr           }

{ -------------------------------------------------------------------- }
Procedure ShowError(ErrNumber : Word);
Var
  FError : Text;
  sBuf   : String;
  i      : Word;
Begin
  { Читаем описание ошибки номер ErrNumber из }
  { errors.def и выводим на экран.            }
  i := 0;
  Assign(FError, 'errors.def');
  Reset(FError);

  While (Not EOF(FError)) And (i <> ErrNumber) do
  Begin
    Readln(FError, sBuf);
    EraseBlank(@sBuf);

    { комментарий в файле }
    If (sBuf[1] <> '#') then
      i := i + 1;

  End;
  Close(FError);

  Writeln('Load-time error : ', sBuf);
  Halt;

End;
{ --------------------------------------------------------------------- }
{ Конвертирует sSrc в нижний регистр }
{ Windows кодировка                  }
Procedure K_LowerCase(sSrc : PString);
Var
  i        : Word;
  sOut     : PString;
  bConvert : Boolean;
Begin

  New(sOut); { Выделение памяти под указатель на строку }
  sOut^    := '';
  bConvert := True;

  For i := 1 to Length(sSrc^) do
  Begin
    If (sSrc^[i] = Chr(39)) then { Обработка Апострофа}
    Begin
      bConvert := Not bConvert;
    End;

    If (bConvert) then
    Begin
      //Case sSrc^[i] of
      //  'А'..'Я': sOut^ := sOut^ + Chr(Ord(sSrc^[i]) + 32);
      //  'A'..'Z': sOut^ := sOut^ + LowerCase(sSrc^[i]);
      //  Else
      //    sOut^ := sOut^ + sSrc^[i];
      //End; { case }
      sOut^ := sOut^ + AnsiLowerCase(sSrc^[i]);
    End
    Else
      sOut^ := sOut^ + sSrc^[i];
  End;

  sSrc^ := sOut^;
End;

{ ---------------------------------------------------------------------- }
{ Удаляет лишние пробелы ( не трогает между апострофами) }
Procedure EraseBlank(sSrc : PString);
Var
  j         : Byte;
  bWasBlank : Boolean;
  bDelete   : Boolean;
  sOut      : PString;
Begin
  j         := 0;

  New(sOut); { - указатель на строку }
  sOut^     := '';
  bWasBlank := False;
  bDelete   := True;

  While (j < Length(sSrc^)) do
  Begin
    Inc(j);
    If (sSrc^[j] = Chr(39)) then
    Begin
      bDelete := Not bDelete;
    End;

    If (sSrc^[j] <> ' ') and (sSrc^[j] <> #9) then
    Begin
      sOut^ := sOut^ + sSrc^[j];
      bWasBlank := False;
    End
    Else
      If (Not bDelete) then
        sOut^ := sOut^ + sSrc^[j]
      Else
      Begin
        { Если предыдущий не пробел, то этот можно оставить }
        If (Not bWasBlank) then
        Begin
          sOut^ := sOut^ + sSrc^[j];
          bWasBlank := True;
        End;
    End; { else }
  End;

  If Length(sOut^) > 0 then
    { Возможно остался пробел в конце и в начале строки }
    If (sOut^[Length(sOut^)] = ' ') or (sOut^[Length(sOut^)] = #9) then
      sOut^ := Copy(sOut^, 1, Length(sOut^) - 1);

  If Length(sOut^) > 0 then
    If (sOut^[1] = ' ') or (sOut^[1] = #9) then
      sOut^ := Copy(sOut^, 2, Length(sOut^) - 1);

  { Все ли апострофы закрыты }
  If (Not bDelete) then
    ShowError(1);

  sSrc^ := sOut^;
End;

End.

