unit UnitComboBoxUtil;

interface

uses Winapi.Windows, Winapi.Messages, Vcl.Controls, Vcl.ExtCtrls, Vcl.StdCtrls,
  Classes,
  JvCombobox;

procedure ComboBox_AutoWidth(const theComboBox: TCombobox);
function GetSetFromCheckCombo(ACheckCombo: TJvCheckedComboBox): integer;
procedure SetCheckBoxBySetValue(ACheckCombo: TJvCheckedComboBox; ACheckValueList: integer);

implementation

uses JHP.Util.Bit32Helper;//, UnitMiscUtil;

procedure ComboBox_AutoWidth(const theComboBox: TCombobox);
//const
//  HORIZONTAL_PADDING = 20;
var
  itemsFullWidth: integer;
  idx: integer;
  itemWidth: integer;
begin
  itemsFullWidth := 0;

  // get the max needed with of the items in dropdown state
  for idx := 0 to -1 + theComboBox.Items.Count do
  begin
    itemWidth := theComboBox.Canvas.TextWidth(theComboBox.Items[idx]);
    Inc(itemWidth, 7 * theComboBox.Font.Size);
    if (itemWidth > itemsFullWidth) then itemsFullWidth := itemWidth;
  end;

  // set the width of drop down if needed
  if (itemsFullWidth > theComboBox.Width) then
  begin
    //check if there would be a scroll bar
    if theComboBox.DropDownCount < theComboBox.Items.Count then
      itemsFullWidth := itemsFullWidth + GetSystemMetrics(SM_CXVSCROLL);

    SendMessage(theComboBox.Handle, CB_SETDROPPEDWIDTH, itemsFullWidth, 0);
  end;
end;

//ACheckCombo.Items에 List Assign 한 이후 임 :
//AcheckCombo에서 Check 된 Bit만 Set Type Integer로 반환 함
function GetSetFromCheckCombo(ACheckCombo: TJvCheckedComboBox): integer;
var
  LpjhBit32: TpjhBit32;
  i: integer;
begin
  LpjhBit32 := 0;

  for i := 0 to ACheckCombo.Items.Count - 1 do
  begin
    LpjhBit32.Bit[i] := ACheckCombo.Checked[i];
  end;

  Result := LpjhBit32;
end;

//ACheckCombo.Items에 List Assign 한 이후 임 :
procedure SetCheckBoxBySetValue(ACheckCombo: TJvCheckedComboBox; ACheckValueList: integer);
var
  LpjhBit32: TpjhBit32;
  i: integer;
begin
  LpjhBit32 := ACheckValueList;

  for i := 0 to ACheckCombo.Items.Count - 1 do
  begin
    ACheckCombo.Checked[i] :=  LpjhBit32.Bit[i];
  end;
end;

end.
