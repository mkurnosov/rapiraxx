unit Explr;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, ComCtrls, OleCtrls, Menus, ExtCtrls, Krnl, ExtDlgs,
  ImgList;

  type
  TfrmExplorer = class(TForm)
    Bevel1: TBevel;
    StatusBar: TStatusBar;
    ImageList1: TImageList;
    dlgOpenPicture: TOpenPictureDialog;
    pcChoose: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Bevel2: TBevel;
    Label1: TLabel;
    ObjectTree: TTreeView;
    Panel2: TPanel;
    Panel3: TPanel;
    Bevel3: TBevel;
    Bevel5: TBevel;
    Label2: TLabel;
    InfoList: TListView;
    Panel1: TPanel;
    lblElem: TLabel;
    lblName: TLabel;
    lblV: TLabel;
    btnChange: TButton;
    edtValue: TEdit;
    cboBool: TComboBox;
    btnPicChoose: TButton;
    btnExecute: TButton;
    lstProc: TListView;
    Button1: TButton;
    Button2: TButton;
    btnView: TButton;
    procedure ObjectTreeClick(Sender: TObject);
    procedure InfoListClick(Sender: TObject);
    procedure btnChangeClick(Sender: TObject);
    procedure edtValueKeyPress(Sender: TObject; var Key: Char);
    procedure btnPicChooseClick(Sender: TObject);
    procedure cboBoolClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
    procedure pcChooseMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
  private
  public
    procedure AddItem(const sName : String);
    procedure ShowInfo;
    function CreateItem(const sName : String): TListItem;
  end;

  Function FindObjField(wObj : Word; sField : String) : Word;
  Procedure ShowProc;

var
  frmExplorer : TfrmExplorer;
  CurrentObj  : Word;
  CurField    : Word;
  CurMethod   : Word;

  fWriteingProc : Boolean; 
  sProcName     : String;     
implementation

uses Types, frmMsg, frmRun, mdl_dsg, frmFile, frmWrite, frmErr, frmPV;

{$R *.DFM}

Function NiceName(sName : String) : String;
Begin
  sName := AnsiLowerCase(sName);
  If Length(sName) > 1 then
    sName := AnsiUpperCase(sName[1]) + Copy(sName, 2, Length(sName) - 1);
  Result := sName;
End;

Function FindObjField(wObj : Word; sField : String) : Word;
Var
  i : Word;
Begin
  Result := 0;
  i := 1;
  While Objects_m^[wObj]^.Fields[i].Name <> sField do
    If i + 1 <=  Objects_m^[wObj]^.CountFields then
      Inc(i)
    Else
      Exit;
  Result := i;
End;

Procedure ShowProc;
var
  i : Word;
  k : Integer;
  Res : TListItem;
Begin
  frmExplorer.lstProc.Items.Clear;
  k := -1;
  for i := 1 to CountFunctions do
  begin
    If Functions^[i]^.Name <> 'старт' then
    begin
      Res := frmExplorer.lstProc.Items.Add;
      Inc(k);
      Res.Caption := Functions^[i]^.Name;
      frmExplorer.lstProc.Items.Item[k].StateIndex := 2;
    end;
  end;
End;

Procedure SetObjectProps(IdxObj : Word);
var
  i : Word;
  ImageIndex : Word;
Begin
  If (CountObjects - CountIspolns + 1) > IdxObj then
    Exit;
    
  ImageIndex := IdxObj - (CountObjects - CountIspolns + 1) + 1;

  i := FindObjField(IdxObj, 'сверху');

  Objects_m^[IdxObj]^.Fields[i].Int := frmRunTime.Images[ImageIndex].Top;

  Objects_m^[IdxObj]^.Fields[FindObjField(IdxObj, 'слева')].Int :=
                                          frmRunTime.Images[ImageIndex].Left;

  Objects_m^[IdxObj]^.Fields[FindObjField(IdxObj, 'ширина')].Int :=
                                         frmRunTime.Images[ImageIndex].Width;

  Objects_m^[IdxObj]^.Fields[FindObjField(IdxObj, 'высота')].Int :=
                                        frmRunTime.Images[ImageIndex].Height;

  Objects_m^[IdxObj]^.Fields[FindObjField(IdxObj, 'картинка')].Str :=
            Ispolns[ImageIndex].Fields[FindIspField(ImageIndex, 'картинка')].Str;

  Objects_m^[IdxObj]^.Fields[FindObjField(IdxObj, 'видимость')].Bool :=
                                       frmRunTime.Images[ImageIndex].Visible;

  Objects_m^[IdxObj]^.Fields[FindObjField(IdxObj, 'растяжение')].Bool :=
                                       frmRunTime.Images[ImageIndex].Stretch;

End;

Procedure RefreshImage(IdxObj : Word);
var
  i : Word;
  ImageIndex : Word;
Begin
  If (CountObjects - CountIspolns + 1) > IdxObj then
    Exit;
    
  ImageIndex := IdxObj - (CountObjects - CountIspolns + 1) + 1;

  i := FindObjField(IdxObj, 'сверху');

  frmRunTime.Images[ImageIndex].Top := Objects_m^[IdxObj]^.Fields[i].Int;

  frmRunTime.Images[ImageIndex].Left := Objects_m^[IdxObj]^.Fields[
                                     FindObjField(IdxObj, 'слева')].Int;

  frmRunTime.Images[ImageIndex].Width := Objects_m^[IdxObj]^.Fields[
                                     FindObjField(IdxObj, 'ширина')].Int;

  frmRunTime.Images[ImageIndex].Height := Objects_m^[IdxObj]^.Fields[
                                     FindObjField(IdxObj, 'высота')].Int;

  frmRunTime.Images[ImageIndex].Picture.LoadFromFile(
       Objects_m^[IdxObj]^.Fields[FindObjField(IdxObj, 'картинка')].Str);

  frmRunTime.Images[ImageIndex].Visible := Objects_m^[IdxObj]^.Fields[
                                 FindObjField(IdxObj, 'видимость')].Bool;

  frmRunTime.Images[ImageIndex].Stretch := Objects_m^[IdxObj]^.Fields[
                                FindObjField(IdxObj, 'растяжение')].Bool;

End;

Procedure DefaultEnabled;
Begin
  frmExplorer.lblV.Visible := False;
  frmExplorer.cboBool.Visible   := False;
  frmExplorer.btnChange.Visible := False;
  frmExplorer.edtValue.Visible  := False;
End;

{ -------------------------------------------------------------------- }
Procedure tfrmExplorer.ShowInfo;
Var
  wObj : Word;
Begin
  Show;
  fWriteingProc := False;

  ObjectTree.Items.Clear;
  InfoList.Items.Clear;
  DefaultEnabled;
  ObjectTree.Items.AddFirst(ObjectTree.TopItem, 'Объекты');

  for wObj := 1 to CountObjects  do
    SetObjectProps(wObj);

  for wObj := 1 to CountObjects do
  begin
    AddItem(NiceName(Objects_m^[wObj].Name));
    ObjectTree.Items.Item[wObj].StateIndex := 3;
  end;
  ShowProc;
End;

{ -------------------------------------------------------------------- }
procedure tfrmExplorer.AddItem(const sName : String);
begin
  ObjectTree.Items.AddChild(ObjectTree.Items[0], sName);
end;

{ -------------------------------------------------------------------- }
function tfrmExplorer.CreateItem(const sName : String): TListItem;
begin
  Result := InfoList.Items.Add;
  Result.Caption := NiceName(sName);
end;

{ -------------------------------------------------------------------- }
procedure TfrmExplorer.ObjectTreeClick(Sender: TObject);
Var
  i : Word;
begin
  If CountObjects < 1 then Exit;

  If (ObjectTree.Selected.Index > -1) And (ObjectTree.Selected.Text <> 'Объекты') then
  Begin
    InfoList.Items.Clear;
    CurrentObj := ObjectTree.Selected.Index + 1;
    With Objects_m^[CurrentObj]^ do
    Begin
      for i := 1 to CountFields do
      begin
        CreateItem(Fields[i].Name);
        InfoList.Items.Item[i- 1].StateIndex := 1;
      end;

      With Classes_m^[RefToClass]^ do
      Begin
        For i := 1 to CountMethods do
        begin
          If Methods[i].Fun then
            CreateItem(Methods[i].Name)
          Else
            CreateItem(Methods[i].Name);
          InfoList.Items.Item[i + Objects_m^[CurrentObj]^.CountFields - 1].StateIndex := 2;
        end;
      End;
    End;
  End;
end;

{ -------------------------------------------------------------------- }
Procedure ShowFieldInfo(FieldNum : Word);
Begin
  frmExplorer.btnExecute.Visible := False;
  frmExplorer.btnChange.Visible  := True;
  frmExplorer.btnChange.Enabled  := True;
  frmExplorer.lblV.Visible := True;
  If Objects_m^[CurrentObj]^.Fields[FieldNum].Name = 'картинка' then
    frmExplorer.btnPicChoose.Visible := True
  Else
    frmExplorer.btnPicChoose.Visible := False;

  CurField := FieldNum;
  With Objects_m^[CurrentObj]^ do
  Begin
    frmExplorer.lblElem.Caption := 'Поле';
    frmExplorer.lblName.Caption := NiceName(Fields[FieldNum].Name);
    Case Fields[FieldNum].selType of
      1 : Begin
            frmExplorer.cboBool.Visible  := False;
            frmExplorer.edtValue.Visible := True;
            frmExplorer.edtValue.Enabled := True;
            frmExplorer.edtValue.Text    := Fields[FieldNum].Str;
          End;
      2 : Begin
            frmExplorer.cboBool.Visible  := False;
            frmExplorer.edtValue.Visible := True;
            frmExplorer.edtValue.Enabled := True;
            frmExplorer.edtValue.Text := IntToStr(Fields[FieldNum].Int);
          End;
      3 : Begin
            frmExplorer.edtValue.Visible := False;
            frmExplorer.cboBool.Visible  := True;
            If Fields[FieldNum].Bool then
              frmExplorer.cboBool.ItemIndex := 0
            Else
              frmExplorer.cboBool.ItemIndex := 1;
          End;
    End; {case}
  End;
End;

{ -------------------------------------------------------------------- }
Procedure ShowMethodInfo(MethodNum : Word);
Var
  i : Word;
  sBuf : String;
  wRef : Word;
Begin
  CurMethod := MethodNum;
  frmExplorer.btnExecute.Visible := True;
  DefaultEnabled;
  wRef := Objects_m^[CurrentObj]^.RefToClass;
  If Classes_m^[wRef]^.Methods[MethodNum].Fun then
    frmExplorer.lblElem.Caption := 'Фун'
  Else
    frmExplorer.lblElem.Caption := 'Проц';
  sBuf := NiceName(Classes_m^[wRef]^.Methods[MethodNum].Name);
  sBuf := sBuf + '(';
  For i := 1 to Classes_m^[wRef]^.Methods[MethodNum].CountArgs do
  Begin
    sBuf := sBuf + Classes_m^[wRef]^.Methods[MethodNum].Args[i];
    If i <> Classes_m^[wRef]^.Methods[MethodNum].CountArgs then
      sBuf := sBuf + ', ';
  End;
  sBuf := sBuf + ')';
  frmExplorer.lblName.Caption := sBuf;
End;

procedure TfrmExplorer.InfoListClick(Sender: TObject);
  function IsField(Idx : Word) : Boolean;
  begin
    If (Idx >= 1) And (Idx <= Objects_m^[CurrentObj]^.CountFields) then
      Result := True
    Else
      Result := False;
  end;
begin
  If InfoList.Items.Count < 1 then
    Exit;

  If Not Assigned(InfoList.Selected) then
    Exit;

  If IsField(InfoList.Selected.Index + 1) then
    ShowFieldInfo(InfoList.Selected.Index + 1)
  Else
    ShowMethodInfo((InfoList.Selected.Index + 1) - Objects_m^[CurrentObj]^
                                                           .CountFields);
end;

procedure TfrmExplorer.btnChangeClick(Sender: TObject);
var
  OldValue : TStack;
  sVal     : String;
begin
  Try
    OldValue := Objects_m^[CurrentObj]^.Fields[CurField];
    sVal := '';
    With Objects_m^[CurrentObj]^.Fields[CurField] do
    Begin
      Case selType of
        1 : begin
              sVal := #39 + edtValue.Text + #39;
              Str  := edtValue.Text;
            end;
        2 : begin
              sVal := edtValue.Text;
              Int  := StrToInt(edtValue.Text);
            end;
        3 : Begin
              If cboBool.Text = 'ИСТИНА' then
              begin
                Bool := True;
                sVal := '.и.';
              end
              Else begin
                Bool := False;
                sVal := '.л.';
              End;
            End;
      End;
      If fWriteingProc then
      begin
        frmWriteProc.Memo1.Lines.Add(Objects_m^[CurrentObj]^.Name + '.' +
        Objects_m^[CurrentObj]^.Fields[CurField].Name + ' := ' + sVal);
      end;
    End;
    RefreshImage(CurrentObj);
  Except
    frmMessage.ShowMsg('Ошибка ввода данных.');
    Objects_m^[CurrentObj]^.Fields[CurField] := OldValue;
  End;
End;

procedure TfrmExplorer.edtValueKeyPress(Sender: TObject; var Key: Char);
begin
  If Key = #13 then
    btnChangeClick(Self);
end;

procedure TfrmExplorer.btnPicChooseClick(Sender: TObject);
var
  CurDir : String;
begin
  GetDir(0, CurDir);
  If dlgOpenPicture.Execute then
  begin
    If Not FileExists(dlgOpenPicture.FileName) then
    begin
      frmMessage.ShowMsg('Файл не найден');
      Exit;
    end;
    
    Objects_m^[CurrentObj]^.Fields[InfoList.Selected.Index + 1].Str :=
                                                 dlgOpenPicture.FileName;
    RefreshImage(CurrentObj);
  end;
  ChDir(CurDir);
end;

procedure TfrmExplorer.cboBoolClick(Sender: TObject);
begin
  btnChangeClick(Self);
end;

procedure TfrmExplorer.btnExecuteClick(Sender: TObject);
var
  sStr  : String;
  sParams : String;
  OldCurCh, OldCurLine : Word;
begin
  With Classes_m^[Objects_m^[CurrentObj].RefToClass]^ do
  Begin
    sParams := '';
    If Methods[CurMethod].CountArgs > 0 then
      If Not InputQuery('Ввод', 'Строка параметров (с запятыми):',sParams) then
        Exit;
        
    btnExecute.Enabled := False;
    sStr := '(' + sParams + ')';


    If fWriteingProc then
    begin
      frmWriteProc.Memo1.Lines.Add(Objects_m^[CurrentObj].Name + '.' + Methods[CurMethod].Name + sStr);
    end;

    Inc(CountLines);
    New(SourceCode[CountLines]);
    SourceCode[CountLines]^ := sStr;

    OldCurCh   := CurCh;
    OldCurLine := CountLines;

    CurLine := CountLines;
    CurCh   := 1;

    fExplorerWork := True;
    //Try
      CallMethod(Objects_m^[CurrentObj].RefToClass, CurMethod, CurrentObj);
    //Except
    //  EmergencyTermination := True;
    // frmError.edtError.Text    := LastError.sError;
    //  frmError.SourceLine.Text  := LastError.sLine;
    //  frmError.ShowModal;
    //End;
    fExplorerWork := False;

    If Methods[CurMethod].Fun then
    Begin
      lblV.Visible := True;
      edtValue.Visible := True;
      edtValue.Enabled := True;
      Case Methods[CurMethod].Result.selType Of
        1 : edtValue.Text := Methods[CurMethod].Result.Str;
        2 : edtValue.Text := IntToStr(Methods[CurMethod].Result.Int);
        3 : Begin
              edtValue.Visible := False;
              cboBool.Visible := True;
              If Methods[CurMethod].Result.Bool then
                cboBool.ItemIndex := 0
              Else
                cboBool.ItemIndex := 1;
            End;
      End;
    End;

    CurCh   := OldCurCh;
    CurLine := OldCurLine;

    Dispose(SourceCode[CountLines]);
    Dec(CountLines);
  End; {with}
  btnExecute.Enabled := True;
end;

procedure TfrmExplorer.pcChooseMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  If pcChoose.ActivePage.PageIndex = 1 then
    ShowProc;
end;
function FindFun(sFunName : String) : Word;
var
  i : Word;
begin
  Result := 0;
  for i := 1 to CountFunctions do
    If Functions^[i]^.Name = sFunName then
    begin
      Result := i;
      Exit; 
    end;
end;

procedure TfrmExplorer.Button1Click(Sender: TObject);
var
  sStr    : String;
  sParams : String;
  OldCurCh, OldCurLine : Word;
  CurFun : Word;
begin
  If lstProc.Items.Count < 1 then
    Exit;

  If Not Assigned(lstProc.Selected) then
    Exit;

  Button1.Enabled := False;

  CurFun := FindFun(lstProc.Selected.Caption);
  If Functions^[CurFun]^.CountArgs > 0 then
    sParams := InputBox('Ввод', 'Строка параметров (с запятыми):','')
  Else
    sParams := '';

    sStr := '(' + sParams + ')';

    If fWriteingProc then
    begin
      frmWriteProc.Memo1.Lines.Add(Functions^[CurFun]^.Name + sStr);
    end;

    Inc(CountLines);
    New(SourceCode[CountLines]);
    SourceCode[CountLines]^ := sStr;

    OldCurCh   := CurCh;
    OldCurLine := CountLines;

    CurLine := CountLines;
    CurCh   := 1;

    fExplorerWork := True;
    CallFunction(CurFun);
    fExplorerWork := False;

    If Functions^[CurFun]^.Fun then
    Begin
      Case Functions^[CurFun]^.Result.selType Of
        1 : sStr := Functions^[CurFun]^.Result.Str;
        2 : sStr := IntToStr(Functions^[CurFun]^.Result.Int);
        3 : Begin
              If Functions^[CurFun]^.Result.Bool then
                sStr := 'ИСТИНА'
              Else
                sStr := 'ЛОЖЬ';
            End;
      End;
      ShowMessage('Функция вернула значение :' + #10#13 + sStr);
    End;

    CurCh   := OldCurCh;
    CurLine := OldCurLine;

    Dispose(SourceCode[CountLines]);
    Dec(CountLines);
    Button1.Enabled := True;
end;

procedure TfrmExplorer.Button2Click(Sender: TObject);
var
  sName : String;
  IdxFun : Word;
begin
  fWriteingProc := True;
  If Not InputQuery('Запись процедуры','Имя процедуры :', sName) then
  begin
    fWriteingProc := False;
    Exit;
  end;

  sName := Trim(sName);
  If sName = '' then
  begin
    frmMessage.ShowMsg('Плохое имя процедуры');
    fWriteingProc := False;
    Exit;
  end;
  sName := AnsiLowerCase(sName);
  sProcName := sName;

  { Если проца или фун с таким именем уже есть, то Еррор }
  IdxFun := FindFun(sProcName);
  If (IdxFun <> 0) then
    Error(ERR_RUN_TIME, 14); { фуна уже существует }

  { Проверить на имя ОБЪЕКТА }
  If FindObject(sProcName) <> 0 then
    Error(ERR_RUN_TIME, 92);

  If (CountFunctions + 1) > MAX_COUNT_FUNCTIONS then
    Error(ERR_RUN_TIME, 15);

  frmWriteProc.Caption := sName + '()';
  frmWriteProc.Show;
end;

procedure TfrmExplorer.btnViewClick(Sender: TObject);
var 
  i : Word;
  CurFun : Word;
  sStr : String;
begin
  If lstProc.Items.Count < 1 then
    Exit;

  If Not Assigned(lstProc.Selected) then
    Exit;

  frmProc.Memo1.Lines.Clear;

  CurFun := FindFun(lstProc.Selected.Caption);
  
  i := Functions^[CurFun]^.StartLine + 1;

  If Functions^[CurFun]^.Fun then
    sStr := 'фун'
  Else
    sStr := 'проц';

  While SourceCode[i]^ <> 'кон ' + sStr do
  Begin
    frmProc.Memo1.Lines.Add(SourceCode[i]^);
    Inc(i);
  End;

  sStr := '';
  for i := 1 to Functions^[CurFun]^.CountArgs do
    If i <> Functions^[CurFun]^.CountArgs then
      sStr := sStr + Functions^[CurFun]^.Args[i] + ','
    Else  
      sStr := sStr + Functions^[CurFun]^.Args[i];
      
  frmProc.Caption := Functions^[CurFun]^.Name + '(' + sStr + ')'; 
  frmProc.Show;  
end;
end.
