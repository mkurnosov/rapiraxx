unit frmUser;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls;

const
  LineWidth = 1;
  WorkCursors: array[0..7] of Integer = (crSizeNWSE,crSizeNS,crSizeNESW,crSizeWE,crSizeNWSE,crSizeNS,crSizeNESW,crSizeWE);

type
  TfrmUserForm = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormDblClick(Sender: TObject);
  private
    {procedure OnImageMouseDown(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnResizeUp(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnResizeDown(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnResizeMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    { Private declarations }
  public
    procedure OnImageMouseDown(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnResizeUp(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnResizeDown(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnResizeMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);

    procedure SelObj(Obj : TImage);
    procedure InsertObject(X1, Y1 , X2, Y2 : Integer);
    procedure DelObj(Obj : TImage);
    procedure HideSelection;

    { Public declarations }
  end;

  procedure AddIspClass(IdxIsp : Word);
  procedure ShutdownConstr;

var
  frmUserForm           : TfrmUserForm;
  GridWidth, GridHeight : Integer;
  GridColor             : Integer;
  iMode                 : Integer;
  LastX, LastY          : Integer;
  OldX, OldY            : Integer;
  CurObj                : TImage;
  LastSelX, LastSelY    : Integer;
  fResizeMode           : Boolean;
  SelLabels : array[0..7] of TImage;
  CurRect : TRect;
  sMainDir : String;
implementation

uses frmIsps, mdl_dsg, frmInspect, frmFile, frmMsg, Editor, Krnl, Debug,
     LibManager;

{$R *.DFM}

procedure ShutdownConstr;
begin
    LibManager.FreeLibraries;
    Application.Terminate;
end;

Function NiceName(sName : String) : String;
Begin
  sName := AnsiLowerCase(sName);
  If Length(sName) > 1 then
    sName := AnsiUpperCase(sName[1]) + Copy(sName, 2, Length(sName) - 1);
  Result := sName;
End;

procedure AddIspClass(IdxIsp : Word);
Var
  i, j, k : Word;
  sBuf  : String;
  sEndMethod : String;
Begin
  If AnsiLowerCase(Trim(BaseIspolns[Ispolns[IdxIsp].BaseIsp].Name)) = 'изображение' then
    Exit;

  frmEditor.rtbEdit.Lines.Add('');
  frmEditor.rtbEdit.Lines.Add('Класс ' + NiceName(BaseIspolns[Ispolns[IdxIsp].BaseIsp].Name));
  sBuf := '';
  for i := 1 to Ispolns[IdxIsp].CountFields do
    If Not BaseField(Ispolns[IdxIsp].Fields[i].Name) then
      sBuf := sBuf + Ispolns[IdxIsp].Fields[i].Name + ', ';

  If sBuf <> '' then
    sBuf := Copy(sBuf, 1, Length(sBuf) - 2);
  frmEditor.rtbEdit.Lines.Add('  ' + sBuf);

  For j := 1 to Ispolns[IdxIsp].CountMethods do
  Begin
    sBuf := '';
    With Ispolns[IdxIsp].Methods[j] do
    Begin
      If Fun then
        sBuf := sBuf + '  Фун '
      Else
        sBuf := sBuf + '  Проц ';
      sBuf := sBuf + NiceName(Name) + '(';

      For k := 1 to CountArgs do
      Begin
        sBuf := sBuf + Args[k];
        If k <> CountArgs then
          sBuf := sBuf + ', ';
      End;
      sBuf := sBuf + ')';

      frmEditor.rtbEdit.Lines.Add(sBuf);

      If Fun then
        sEndMethod := 'кон фун'
      else
        sEndMethod := 'кон проц';

      i := StartLine;
      Repeat
        If i + 1 <= CountCodeLines then
          Inc(i)
        Else
          Break;

        sBuf := MethodsCode[i]^;

        If sBuf <> sEndMethod then
          frmEditor.rtbEdit.Lines.Add('    ' + sBuf)
        Else
          frmEditor.rtbEdit.Lines.Add('  ' + sBuf);
      Until (sBuf = sEndMethod);
    End; { with }
  End;
  frmEditor.rtbEdit.Lines.Add('Кон Класс');
  //ProcessText;
end;

procedure RefreshFields(IspolnIdx : Word);
var
  i : Word;
begin
  i := FindIspField(IspolnIdx, 'сверху');

  Ispolns[IspolnIdx].Fields[i].Int := Ispolns[IspolnIdx].Face.Top;
  Ispolns[IspolnIdx].Fields[FindIspField(IspolnIdx, 'слева')].Int :=
                                            Ispolns[IspolnIdx].Face.Left;

  Ispolns[IspolnIdx].Fields[FindIspField(IspolnIdx, 'ширина')].Int :=
                                           Ispolns[IspolnIdx].Face.Width;

  Ispolns[IspolnIdx].Fields[FindIspField(IspolnIdx, 'высота')].Int :=
                                          Ispolns[IspolnIdx].Face.Height;

  Ispolns[IspolnIdx].Fields[FindIspField(IspolnIdx, 'видимость')].Bool :=
                                          Ispolns[IspolnIdx].Face.Visible;

end;

{procedure tfrmUserForm.OnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Begin
  CurObj := TImage(Sender);
  RefreshFields(CurObj.Tag);
End;}

procedure tfrmUserForm.HideSelection;
var
  i : Integer;
begin
  for i := 0 to 7 do begin
    SelLabels[i].Visible := False;
  end;
  Application.ProcessMessages;
end;

procedure TfrmUserForm.OnResizeUp(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Canvas.Rectangle(CurRect.Left, CurRect.Top, CurRect.Right, CurRect.Bottom);
  CurObj.Left := CurRect.Left;
  CurObj.Top := CurRect.Top;
  CurObj.Width := CurRect.Right-CurRect.Left;
  CurObj.Height := CurRect.Bottom-CurRect.Top;
  SelObj(CurObj);
  fResizeMode := False;
  RefreshFields(CurObj.Tag);
  frmInspector.RefreshProps;
end;

procedure TfrmUserForm.OnResizeDown(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift) then begin
    fResizeMode := True;
    HideSelection;
    CurRect.Left := CurObj.Left;
    CurRect.Top := CurObj.Top;
    CurRect.Bottom := CurObj.Top + CurObj.Height;
    CurRect.Right := CurObj.Left + CurObj.Width;
    Canvas.Rectangle(CurRect.Left, CurRect.Top, CurRect.Right, CurRect.Bottom);
  end;  
end;

procedure TfrmUserForm.OnResizeMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  iNewRect : TRect;
  TempVal : Integer;
begin
  if (fResizeMode) then begin
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := LineWidth;
    case TImage(Sender).Tag of
      0 :
      begin
        iNewRect.Left   := TImage(Sender).Left+X;
        iNewRect.Top    := TImage(Sender).Top+Y;
        iNewRect.Right  := TImage(CurObj).Left+TImage(CurObj).Width;
        iNewRect.Bottom := TImage(CurObj).Top+TImage(CurObj).Height;
      end;
      1 :
      begin
        iNewRect.Left   := TImage(CurObj).Left;
        iNewRect.Top    := TImage(Sender).Top+Y;
        iNewRect.Right  := TImage(CurObj).Left+TImage(CurObj).Width;
        iNewRect.Bottom := TImage(CurObj).Top+TImage(CurObj).Height;
      end;
      2 :
      begin
        iNewRect.Left   := TImage(CurObj).Left;
        iNewRect.Top    := TImage(CurObj).Top+Y;
        iNewRect.Right  := TImage(CurObj).Left+TImage(CurObj).Width+X;
        iNewRect.Bottom := TImage(CurObj).Top+TImage(CurObj).Height;
      end;
      3 :
      begin
        iNewRect.Left   := TImage(CurObj).Left;
        iNewRect.Top    := TImage(CurObj).Top;
        iNewRect.Right  := TImage(CurObj).Left+TImage(CurObj).Width+X;
        iNewRect.Bottom := TImage(CurObj).Top+TImage(CurObj).Height;
      end;
      4 :
      begin
        iNewRect.Left   := TImage(CurObj).Left;
        iNewRect.Top    := TImage(CurObj).Top;
        iNewRect.Right  := TImage(CurObj).Left+TImage(CurObj).Width+X;
        iNewRect.Bottom := TImage(CurObj).Top+TImage(CurObj).Height+Y;
      end;
      5 :
      begin
        iNewRect.Left   := TImage(CurObj).Left;
        iNewRect.Top    := TImage(CurObj).Top;
        iNewRect.Right  := TImage(CurObj).Left+TImage(CurObj).Width;
        iNewRect.Bottom := TImage(CurObj).Top+TImage(CurObj).Height+Y;
      end;
      6 :
      begin
        iNewRect.Left   := TImage(CurObj).Left+X;
        iNewRect.Top    := TImage(CurObj).Top;
        iNewRect.Right  := TImage(CurObj).Left+TImage(CurObj).Width;
        iNewRect.Bottom := TImage(CurObj).Top+TImage(CurObj).Height+Y;
      end;
      7 :
      begin
        iNewRect.Left   := TImage(CurObj).Left+X;
        iNewRect.Top    := TImage(CurObj).Top;
        iNewRect.Right  := TImage(CurObj).Left+TImage(CurObj).Width;
        iNewRect.Bottom := TImage(CurObj).Top+TImage(CurObj).Height;
      end;

    end;
    if (iNewRect.Left > iNewRect.Right) then begin
      TempVal := iNewRect.Left;
      iNewRect.Left := iNewRect.Right;
      iNewRect.Right := TempVal;
    end;

    if (iNewRect.Top > iNewRect.Bottom) then begin
      TempVal := iNewRect.Top;
      iNewRect.Top := iNewRect.Bottom;
      iNewRect.Bottom := TempVal;
    end;

    Canvas.Rectangle(CurRect.Left, CurRect.Top, CurRect.Right, CurRect.Bottom);
    Canvas.Rectangle(iNewRect.Left, iNewRect.Top, iNewRect.Right, iNewRect.Bottom);
    CurRect := iNewRect;
  end;
end;

procedure TfrmUserForm.OnImageMouseDown(Sender: TObject;  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift) then begin
    HideSelection;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := LineWidth;
    iMode := 3;
    CurObj := TImage(Sender);
    Canvas.Rectangle(TImage(Sender).Left-LineWidth div 2,TImage(Sender).Top-LineWidth div 2, TImage(Sender).Left + TImage(Sender).Width + LineWidth div 2, TImage(Sender).Top + TImage(Sender).Height + LineWidth div 2);
    LastSelX := X;
    LastSelY := Y;
    OldX := X;
    OldY := Y;
  end;
end;

procedure TfrmUserForm.InsertObject(X1, Y1 , X2, Y2 : Integer);
var
  i,newX1, newX2, newY1, newY2 : Integer;
begin
  Try
    if (X1 > X2) then begin
      newX1 := X2;
      newX2 := X1;
    end
    else begin
      newX1 := X1;
      newX2 := X2;
    end;

    if (Y1 > Y2) then begin
      newY1 := Y2;
      newY2 := Y1;
    end
    else begin
      newY1 := Y1;
      newY2 := Y2;
    end;

    Inc(CountIspolns);
    Ispolns[CountIspolns].Face   := TImage.Create(frmUserForm);
    Ispolns[CountIspolns].Face.Parent := frmUserForm;
    If wSelectIspoln <> 1 then
      Ispolns[CountIspolns].Face.Picture.LoadFromFile(sIcons[wSelectIspoln-1])
    Else
      Ispolns[CountIspolns].Face.Picture.LoadFromFile(BASE_PICTURE);
    Ispolns[CountIspolns].Face.Left := newX1;
    Ispolns[CountIspolns].Face.Top  := newY1;
    Ispolns[CountIspolns].Face.Width   := newX2 - newX1;
    Ispolns[CountIspolns].Face.Height  := newY2 - newY1;
    Ispolns[CountIspolns].Face.BringToFront;
    Ispolns[CountIspolns].Face.OnMouseDown := OnImageMouseDown;
    Ispolns[CountIspolns].Face.OnMouseMove := OnMouseMove;
    Ispolns[CountIspolns].Face.OnMouseUp   := OnMouseUp;
    Ispolns[CountIspolns].Face.Tag := CountIspolns;
    { *** }
    Ispolns[CountIspolns].CountFields := BaseIspolns[wSelectIspoln].CountFields;
    Ispolns[CountIspolns].Fields := BaseIspolns[wSelectIspoln].Fields;
    Ispolns[CountIspolns].CountMethods := BaseIspolns[wSelectIspoln].CountMethods;
    Ispolns[CountIspolns].Methods := BaseIspolns[wSelectIspoln].Methods;
    Ispolns[CountIspolns].Name := BaseIspolns[wSelectIspoln].Name + IntToStr(CountIspolns);
    Ispolns[CountIspolns].BaseIsp := wSelectIspoln;
    { *** }
    //SelObj(Ispolns[CountIspolns].Face);
    //fSelectIspoln := False;

    i := FindIspField(CountIspolns, 'картинка');
    If wSelectIspoln = 1 then
      Ispolns[CountIspolns].Fields[i].Str := BASE_PICTURE
    Else
      Ispolns[CountIspolns].Fields[i].Str := sIcons[wSelectIspoln - 1];

    // Stretch - True
    Ispolns[CountIspolns].Face.Stretch := True;
    Ispolns[CountIspolns].Fields[FindIspField(CountIspolns, 'растяжение')]
                                                            .Bool := True;
    If Not UsedIspolns[wSelectIspoln] then
    begin
      UsedIspolns[wSelectIspoln] := True;
      AddIspClass(CountIspolns);
    end;

    SelObj(Ispolns[CountIspolns].Face);
    fSelectIspoln := False;
    wSelectIspoln := 0;
    RefreshFields(CountIspolns);
    frmInspector.RefreshProps;
  Except
    frmMessage.ShowMsg('Ошибка добавления исполнителя');
    frmFileMenu.N12Click(Self);
  End;
end;

procedure TfrmUserForm.FormCreate(Sender: TObject);
var
  i : Integer;
begin
  GetDir(0,sMainDir);
  mdl_dsg.Init; {mdl_dsg.pas}

  GridWidth  := 8;
  GridHeight := 8;
  GridColor  := clBlack;
  iMode := 0;
  for i := 0 to 7 do begin
    SelLabels[i] := TImage.Create(Self);
    SelLabels[i].Parent      := Self;
    SelLabels[i].Visible     := False;
    SelLabels[i].Picture.LoadFromFile('ini\1.bmp');
    SelLabels[i].Width       := 12;
    SelLabels[i].Height      := 12;
    SelLabels[i].Cursor      := WorkCursors[i];
    SelLabels[i].OnMouseDown := OnResizeDown;
    SelLabels[i].OnMouseUp   := OnResizeUp;
    SelLabels[i].OnMouseMove := OnResizeMove;
    SelLabels[i].Tag         := i;
  end; {for}
  fResizeMode := False;
  fRunMode    := False;
end;

procedure TfrmUserForm.FormPaint(Sender: TObject);
var i,j : Integer;
  NewWidth, NewHeight : Integer;
begin
  NewWidth  := Round(Self.Width/GridWidth);
  NewHeight := Round(Self.Height/GridHeight);
  for i := 0 to NewWidth do begin
    for j := 0 to NewHeight do begin
      Self.Canvas.Pixels[i*GridWidth,j*GridHeight] := GridColor;
    end;
  end;
end;

procedure TfrmUserForm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (fSelectIspoln = False) then
    iMode := 1
  else                      
    iMode := 2;  
  LastX := X;
  LastY := Y;
  OldX  := X;
  OldY  := Y;
end;

procedure TfrmUserForm.FormMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin                          
  if (iMode = 1) then begin
    Canvas.Pen.Width := 1;
    Canvas.Pen.Style := psDot;
  end
  else if (iMode = 2) or (iMode = 3) then begin
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := LineWidth;
  end;
  if iMode <> 0 then begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Mode := pmNot;
    if (iMode = 3) then begin
      Canvas.Pen.Style := psSolid;
      Canvas.Pen.Width := LineWidth;
      Canvas.Rectangle(CurObj.Left-LineWidth div 2 + (OldX-LastSelX),CurObj.Top-LineWidth div 2 + (OldY-LastSelY), CurObj.Left + CurObj.Width + LineWidth div 2 + (OldX-LastSelX), CurObj.Top + CurObj.Height + LineWidth div 2 + (OldY-LastSelY));
      Canvas.Rectangle(CurObj.Left-LineWidth div 2 + (X-LastSelX),CurObj.Top-LineWidth div 2 + (Y-LastSelY), CurObj.Left + CurObj.Width + LineWidth div 2 + (X-LastSelX), CurObj.Top + CurObj.Height + LineWidth div 2 + (Y-LastSelY));
      RefreshFields(CurObj.Tag);
    end
    else begin
      Canvas.Rectangle(LastX,LastY, OldX, OldY);
      Canvas.Rectangle(LastX,LastY,X,Y);
    end;
    OldX := X;
    OldY := Y;
  end;
end;

procedure TfrmUserForm.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (iMode = 2) then begin
    if ((OldX-LastX) <> 0) and ((OldY-LastY) <> 0) then
      InsertObject(LastX,LastY, OldX, OldY);
  end;
  if (iMode = 1) then begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Style := psDot;
    Canvas.Pen.Mode := pmNot;
    Canvas.Rectangle(LastX,LastY, OldX, OldY);
  end
  else if (iMode = 2) then begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Mode := pmNot;
    Canvas.Pen.Width := LineWidth;
    Canvas.Rectangle(LastX,LastY, OldX, OldY);
  end
  else if (iMode = 3) then begin
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Mode := pmNot;
    Canvas.Pen.Width := LineWidth;
    Canvas.Rectangle(CurObj.Left-LineWidth div 2 + (X-LastSelX),CurObj.Top-LineWidth div 2 + (Y-LastSelY), CurObj.Left + CurObj.Width + LineWidth div 2 + (X-LastSelX), CurObj.Top + CurObj.Height + LineWidth div 2 + (Y-LastSelY));
    CurObj.Left := CurObj.Left + (X-LastSelX);
    CurObj.Top  := CurObj.Top + (Y-LastSelY);
    CurObj.BringToFront;
    SelObj(CurObj);
    RefreshFields(CurObj.Tag);
    frmInspector.RefreshProps;
  end;
  iMode := 0;
end;

procedure TfrmUserForm.DelObj(Obj : TImage);
var
  i    : Word;
begin
  If CountIspolns < 1 then
    Exit;

  Ispolns[Obj.Tag].Face.Free;
  { Смещаем все эл-ты массива на 1 эл. вверх }
  For i := Obj.Tag to CountIspolns - 1 do
  Begin
    Ispolns[i] := Ispolns[i + 1];
    Ispolns[i].Face.Tag := i;
  End;
  
  Dec(CountIspolns);

  if (CountIspolns > 0) then
  begin;
    SelObj(Ispolns[1].Face);
  end
  else begin
    HideSelection;
    frmInspector.Hide;
  end;
end;

procedure TfrmUserForm.SelObj(Obj : TImage);
begin
  CurObj := Obj;
  SelLabels[0].Left := Obj.Left-(SelLabels[0].Width div 2);
  SelLabels[0].Top  := Obj.Top-(SelLabels[0].Height div 2);
  SelLabels[0].Visible := True;
  SelLabels[0].BringToFront;

  SelLabels[1].Left := Obj.Left+(Obj.Width div 2)-(SelLabels[0].Width div 2);
  SelLabels[1].Top  := Obj.Top-(SelLabels[0].Height div 2);
  SelLabels[1].Visible := True;
  SelLabels[1].BringToFront;

  SelLabels[2].Left := (Obj.Left + Obj.Width)-(SelLabels[1].Width div 2);
  SelLabels[2].Top  := Obj.Top-(SelLabels[1].Height div 2);
  SelLabels[2].Visible := True;
  SelLabels[2].BringToFront;

  SelLabels[3].Left := (Obj.Left + Obj.Width)-(SelLabels[1].Width div 2);
  SelLabels[3].Top  := Obj.Top-(SelLabels[1].Height div 2)+(Obj.Height div 2);
  SelLabels[3].Visible := True;
  SelLabels[3].BringToFront;

  SelLabels[4].Left := (Obj.Left + Obj.Width)-(SelLabels[1].Width div 2);
  SelLabels[4].Top  := (Obj.Top+Obj.Height)-(SelLabels[1].Height div 2);
  SelLabels[4].Visible := True;
  SelLabels[4].BringToFront;

  SelLabels[6].Left := Obj.Left-(SelLabels[0].Width div 2);
  SelLabels[6].Top  := (Obj.Top+Obj.Height)-(SelLabels[1].Height div 2);
  SelLabels[6].Visible := True;
  SelLabels[6].BringToFront;

  SelLabels[5].Left := Obj.Left+(Obj.Width div 2)-(SelLabels[0].Width div 2);
  SelLabels[5].Top  := (Obj.Top+Obj.Height)-(SelLabels[1].Height div 2);
  SelLabels[5].Visible := True;
  SelLabels[5].BringToFront;

  SelLabels[7].Left := Obj.Left -(SelLabels[1].Width div 2);
  SelLabels[7].Top  := Obj.Top-(SelLabels[1].Height div 2)+(Obj.Height div 2);
  SelLabels[7].Visible := True;
  SelLabels[7].BringToFront;
  frmInspector.RefreshProps;
end;

procedure TfrmUserForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//  ShowMessage(IntToStr(Key));
  if (Key = 46) then
    DelObj(CurObj);
end;

procedure TfrmUserForm.FormShow(Sender: TObject);
begin
  frmFileMenu.Show;
  frmIspolns.Show;
end;

procedure TfrmUserForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := False;
  Hide;
end;

procedure TfrmUserForm.FormDblClick(Sender: TObject);
begin
  frmEditor.Show;
end;

end.
