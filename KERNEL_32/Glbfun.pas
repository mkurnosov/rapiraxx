{***************************************}
{  ������ � ����������� ���������       }
{  � �����������.                       }
{  Written by Kurnosov M.               }
{***************************************}

Unit GlbFun;

interface

Uses Types;

  Procedure ShowError(ErrNumber : Word);

  { ������������ sSrc � ������ ������� }
  { Windows ���������                  }
  Procedure K_LowerCase(sSrc : PString);

  { ������� ������ ������� ( �� ������� ����� �����������) }
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
  { ������ �������� ������ ����� ErrNumber �� }
  { errors.def � ������� �� �����.            }
  i := 0;
  Assign(FError, 'errors.def');
  Reset(FError);

  While (Not EOF(FError)) And (i <> ErrNumber) do
  Begin
    Readln(FError, sBuf);
    EraseBlank(@sBuf);

    { ����������� � ����� }
    If (sBuf[1] <> '#') then
      i := i + 1;

  End;
  Close(FError);

  Writeln('Load-time error : ', sBuf);
  Halt;

End;
{ --------------------------------------------------------------------- }
{ ������������ sSrc � ������ ������� }
{ Windows ���������                  }
Procedure K_LowerCase(sSrc : PString);
Var
  i        : Word;
  sOut     : PString;
  bConvert : Boolean;
Begin

  New(sOut); { ��������� ������ ��� ��������� �� ������ }
  sOut^    := '';
  bConvert := True;

  For i := 1 to Length(sSrc^) do
  Begin
    If (sSrc^[i] = Chr(39)) then { ��������� ���������}
    Begin
      bConvert := Not bConvert;
    End;

    If (bConvert) then
    Begin
      //Case sSrc^[i] of
      //  '�'..'�': sOut^ := sOut^ + Chr(Ord(sSrc^[i]) + 32);
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
{ ������� ������ ������� ( �� ������� ����� �����������) }
Procedure EraseBlank(sSrc : PString);
Var
  j         : Byte;
  bWasBlank : Boolean;
  bDelete   : Boolean;
  sOut      : PString;
Begin
  j         := 0;

  New(sOut); { - ��������� �� ������ }
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
        { ���� ���������� �� ������, �� ���� ����� �������� }
        If (Not bWasBlank) then
        Begin
          sOut^ := sOut^ + sSrc^[j];
          bWasBlank := True;
        End;
    End; { else }
  End;

  If Length(sOut^) > 0 then
    { �������� ������� ������ � ����� � � ������ ������ }
    If (sOut^[Length(sOut^)] = ' ') or (sOut^[Length(sOut^)] = #9) then
      sOut^ := Copy(sOut^, 1, Length(sOut^) - 1);

  If Length(sOut^) > 0 then
    If (sOut^[1] = ' ') or (sOut^[1] = #9) then
      sOut^ := Copy(sOut^, 2, Length(sOut^) - 1);

  { ��� �� ��������� ������� }
  If (Not bDelete) then
    ShowError(1);

  sSrc^ := sOut^;
End;

End.

