unit frmInspect;
                   
interface                                        

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, ComCtrls;

type
  TfrmInspector = class(TForm)
    pnlAlignProps: TPanel;
    cboListProps: TComboBox;
    txtStrProps: TEdit;
    cmdAccept: TButton;
    sgProps: TStringGrid;
    odOpenPicture: TOpenDialog;
    procedure pnlAlignPropsResize(Sender: TObject);
    procedure txtStrPropsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cmdAcceptClick(Sender: TObject);
    procedure cboListPropsChange(Sender: TObject);
    procedure sgPropsDrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgPropsClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    procedure RefreshProps;
    procedure RefreshFace;
    procedure SetCurObject(Index : Integer);
    procedure ChangeProp;
    procedure ChangeListProps;
    { Public declarations }
  end;

var
  frmInspector: TfrmInspector;

implementation

uses frmUser, frmIsps, mdl_dsg, frmMsg, Krnl, frmFile;

{$R *.DFM}

Function NiceName(sName : String) : String;
Begin
  sName := AnsiLowerCase(sName);
  If Length(sName) > 1 then
    sName := AnsiUpperCase(sName[1]) + Copy(sName, 2, Length(sName) - 1);
  Result := sName;
End;

procedure TfrmInspector.RefreshFace;
var
  i : Word;
  IspolnIdx : Word;
begin
  IspolnIdx := CurObj.Tag;
  
  i := FindIspField(IspolnIdx, 'сверху');
  Ispolns[IspolnIdx].Face.Top    := Ispolns[IspolnIdx].Fields[i].Int;

  Ispolns[IspolnIdx].Face.Left   := Ispolns[IspolnIdx].Fields[
                                  FindIspField(IspolnIdx, 'слева')].Int;
  Ispolns[IspolnIdx].Face.Width  := Ispolns[IspolnIdx].Fields[
                                  FindIspField(IspolnIdx, 'ширина')].Int;

  Ispolns[IspolnIdx].Face.Height := Ispolns[IspolnIdx].Fields[
                                  FindIspField(IspolnIdx, 'высота')].Int;
                                  
  Ispolns[IspolnIdx].Face.Picture.LoadFromFile(Ispolns[IspolnIdx].Fields[
                               FindIspField(IspolnIdx, 'картинка')].Str); 

  Ispolns[IspolnIdx].Face.Stretch := Ispolns[IspolnIdx].Fields[
                             FindIspField(IspolnIdx, 'растяжение')].Bool; 

end;

procedure TfrmInspector.RefreshProps;
var
  i         : Integer;
  IspolnIdx : Word;
begin
  If CountIspolns <> 0 then
  begin
    if Not frmInspector.Visible then
      frmInspector.Show;

    sgProps.Row := 0;
    if (not frmInspector.Active) then begin
      txtStrProps.Text := '';
      cboListProps.Items.Clear;
    end;
    IspolnIdx := CurObj.Tag;

    sgProps.RowCount := Ispolns[IspolnIdx].CountFields + 1;

    sgProps.Cells[0,0] := 'Имя';
    sgProps.Cells[1,0] := NiceName(Ispolns[IspolnIdx].Name);
    
    for i := 1 to Ispolns[IspolnIdx].CountFields do
    begin
      sgProps.Cells[0,i] := NiceName(Ispolns[IspolnIdx].Fields[i].Name);

      Case Ispolns[IspolnIdx].Fields[i].selType of
        1 : sgProps.Cells[1,i] := Ispolns[IspolnIdx].Fields[i].Str;
        2 : sgProps.Cells[1,i] := IntToStr(Ispolns[IspolnIdx].Fields[i].Int);
        3 : If Ispolns[IspolnIdx].Fields[i].Bool then
              sgProps.Cells[1,i] := 'ИСТИНА'     
            Else
              sgProps.Cells[1,i] := 'ЛОЖЬ';
      End; {case}
    end;
    sgPropsClick(Self);
    frmUserForm.SetFocus;
  end;
end;

procedure TfrmInspector.SetCurObject(Index : Integer);
begin
  if (CountIspolns <= Index) then 
    Exit;
  RefreshProps;
end;

procedure TfrmInspector.pnlAlignPropsResize(Sender: TObject);
begin
  txtStrProps.Left   := cmdAccept.Width + 12;
  cboListProps.Left  := txtStrProps.Left;
  txtStrProps.Width  := pnlAlignProps.Width-cmdAccept.Width-15;
  cboListProps.Width := txtStrProps.Width;
end;

procedure TfrmInspector.ChangeProp;
var
  i, IspolnIdx : Word;
  sBuf : String;
  fExist : Boolean;
begin
  Try
  IspolnIdx :=  CurObj.Tag;

  If sgProps.Row = 0 then 
  Begin
    sBuf := txtStrProps.Text;    
    sBuf := Trim(AnsiLowerCase(sBuf));
    If (sBuf = '') Or (Not (sBuf[1] in ['a'..'z','а'..'я','ё'])) then
      frmMessage.ShowMsg('Плохое имя исполнителя.')
    Else Begin
      fExist := False;
      For i := 1 to CountIspolns do
        If (Ispolns[i].Name = sBuf) And (i <> IspolnIdx) then
        Begin
          fExist := True;
          Break; 
        End;  
      If Not fExist then
        Ispolns[IspolnIdx].Name := sBuf
      Else
        frmMessage.ShowMsg('Плохое имя исполнителя.');
    End; {else}
  End
  Else Begin
    Case Ispolns[IspolnIdx].Fields[sgProps.Row].selType of
      1 : Ispolns[IspolnIdx].Fields[sgProps.Row].Str := txtStrProps.Text;     
      2 : Ispolns[IspolnIdx].Fields[sgProps.Row].Int := StrToInt(txtStrProps.Text);
    End;
  End;  

  Except
    frmMessage.ShowMsg('Неверный формат данных');
    frmFileMenu.N12Click(Self);
  End;
  
  RefreshFace;
  frmUserForm.SelObj(CurObj);
  frmUserForm.Repaint;
  RefreshProps;
end;

procedure TfrmInspector.ChangeListProps;
var
  IspolnIdx : Word;
begin
  IspolnIdx := Word(CurObj.Tag);
  Ispolns[IspolnIdx].Fields[sgProps.Row].Bool  := not Boolean(cboListProps.ItemIndex);

  RefreshFace;
  frmUserForm.SelObj(CurObj);
  frmUserForm.Repaint;
  RefreshProps;
end;

procedure TfrmInspector.txtStrPropsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = 13) then
  begin
    ChangeProp;
    Key := 0;
  end;
end;

procedure TfrmInspector.cmdAcceptClick(Sender: TObject);
begin
  If cmdAccept.Caption = '&Выбор...' then
    If odOpenPicture.Execute then
      txtStrProps.Text := odOpenPicture.FileName;

  if (txtStrProps.Visible) then
    ChangeProp
  
end;

procedure TfrmInspector.cboListPropsChange(Sender: TObject);
begin
  ChangeListProps;
end;

procedure TfrmInspector.sgPropsDrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  sgProps.ColWidths[Col] := sgProps.ClientWidth div 2;
end;

procedure TfrmInspector.sgPropsClick(Sender: TObject);
var
  IspolnIdx : Word;
  ListIndex : Word;
begin
  { 1. Меняем поле ввода }
  if (CountIspolns <> 0) then
  begin
    IspolnIdx := CurObj.Tag;

    if (sgProps.Row <= Ispolns[IspolnIdx].CountFields) then
    begin
      cmdAccept.Caption := '&Принять';
      txtStrProps.ReadOnly := False;
      txtStrProps.Color    := clWhite;
      cboListProps.Color   := clWhite;
      cboListProps.Enabled := True;
      ListIndex := sgProps.Row;

      If ListIndex = 0 then
      Begin
        txtStrProps.Text := Ispolns[IspolnIdx].Name;
        txtStrProps.Tag  := 0;
        txtStrProps.Visible := True;
        cboListProps.Visible := False;
        If Sender = sgProps then
        Begin
          txtStrProps.SetFocus;
          txtStrProps.SelectAll;
        End;
      End
      Else Begin
        If (Ispolns[IspolnIdx].Fields[ListIndex].selType = 1) then
        begin
          txtStrProps.Text := Ispolns[IspolnIdx].Fields[ListIndex].Str;
          txtStrProps.Tag  := 0;
          txtStrProps.Visible := True;
          cboListProps.Visible := False;
          If Sender = sgProps then
          Begin
            txtStrProps.SetFocus;
            txtStrProps.SelectAll;
          End;
          If Ispolns[IspolnIdx].Fields[ListIndex].Name = 'картинка' then
            cmdAccept.Caption := '&Выбор...';
        end
        else if (Ispolns[IspolnIdx].Fields[ListIndex].selType = 2) then
        begin
          txtStrProps.Tag     := 1;
          txtStrProps.Visible := True;
          cboListProps.Visible := False;
          txtStrProps.Text := IntToStr(Ispolns[IspolnIdx].Fields[ListIndex].Int);
          If Sender = sgProps then
          Begin
            txtStrProps.SetFocus;
            txtStrProps.SelectAll;
          End;
        end
        else if (Ispolns[IspolnIdx].Fields[ListIndex].selType = 3) then
        begin
          txtStrProps.Visible := False;
          cboListProps.Clear;
          cboListProps.Items.Add('ИСТИНА');
          cboListProps.Items.Add('ЛОЖЬ');
          if (Ispolns[IspolnIdx].Fields[ListIndex].Bool) then
            cboListProps.ItemIndex := 0
          else
            cboListProps.ItemIndex := 1;
          cboListProps.Visible := True;
        end;
      End; {else}
    end;
  end;
end;

procedure TfrmInspector.FormResize(Sender: TObject);
var
  i : Word; 
begin
  for i := 0 to sgProps.ColCount - 1 do
    sgProps.ColWidths[i] := sgProps.ClientWidth div 2;  
end;

end.
