FormCreate에서
--------------------------------------------------
    focusRectangle := TShape.Create(self) ;

    focusRectangle.Shape := stRectangle;

    focusRectangle.Visible := false;

    focusRectangle.Brush.Style := bsClear;
    focusRectangle.Pen.Style := psDot;
    focusRectangle.Pen.Color := clRed;
    focusRectangle.Pen.Width := 1;

ScreenActiveControlChange 함수에서
-------------------------------------------------
with focusRectangle do
begin
    Parent := Screen.ActiveControl.Parent;

    Top := Screen.ActiveControl.Top - 2;
    Height := Screen.ActiveControl.Height + 4;
    Left := Screen.ActiveControl.Left - 2;
    Width := Screen.ActiveControl.Width + 4;

    Visible := true;
   end;
============================================
Dim Out the Main Form
------------------------------------------------------------------
procedure TDimmerForm.FormCreate(Sender: TObject);
begin
  AlphaBlend := true;
  AlphaBlendValue := 128;
  BorderStyle := bsNone;
end; 
-------------------------------------------------------------------
procedure TDimmerForm.Display(const dimForm: TForm);
begin
  with Self do
  begin
    Left := dimForm.Left;
    Top := dimForm.Top;
    Width := dimForm.Width;
    Height := dimForm.Height;
 
    Show;
  end;
end; 
-----------------------------------------------------------------
procedure TMainForm.ApplicationEvents1ModalBegin(Sender: TObject);
begin
  if Assigned(DimmerForm) then DimmerForm.Display(self);
end;
 
procedure TMainForm.ApplicationEvents1ModalEnd(Sender: TObject);
begin
  if Assigned(DimmerForm) then DimmerForm.Hide;
end;
==================================================
