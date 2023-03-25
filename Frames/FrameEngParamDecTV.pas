unit FrameEngParamDecTV;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Winapi.CommCtrl,
  Vcl.ImgList, Vcl.Menus,
  Winapi.ActiveX, JvCheckTreeView, decTreeView,
  DropSource, DragDropText, DragDrop, DropTarget, DragDropFile, DragDropFormats,
  DragDropRecord,
  SynCommons, mORMot, SynTable, mORMotDB, mORMotSqlite3, SynSqlite3,
  mORMotDDD,

  DomSensorCQRS,
  DomSensorInterfaces,
  DomSensorServices,
  DomSensorTypes,
  InfraSensorRepository,

  UnitEngineElecPartClass,
  UnitECUData, HiMECSConst,
  EngineParameterClass,
  UnitEngineParamRecord
  ;

type
  TEngSensorRouteTV = class;

  TFrameDecTreeView1 = class(TFrame)
    DropTextTarget1: TDropTextTarget;
    EngParamSource1: TDropTextSource;
    decTreeView1: TdecTreeView;
    ImageList2: TImageList;
    imTreeView: TImageList;
    PopupMenu2: TPopupMenu;
    Newitem1: TMenuItem;
    NewSubItem1: TMenuItem;
    N1: TMenuItem;
    DeleteItem1: TMenuItem;
    N2: TMenuItem;
    SortCollectItembyNodeIndex1: TMenuItem;
    DataFormatAdapter1: TDataFormatAdapter;
    DataFormatAdapter2: TDataFormatAdapter;
    est1: TMenuItem;
    SaveToFile1: TMenuItem;
    LoadFromFile1: TMenuItem;
    N3: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SaveToDB1: TMenuItem;
    N4: TMenuItem;
    LoadFromDB1: TMenuItem;
    LoadByTagnameFromDB1: TMenuItem;
    LoadBySubTagNameFromDBToSelectedSubNode1: TMenuItem;
    SaveasSubTagFromSelectedToDB1: TMenuItem;
    N5: TMenuItem;
    ShowDiagram1: TMenuItem;
    N6: TMenuItem;
    procedure DropTextTarget1Drop(Sender: TObject; ShiftState: TShiftState;
      APoint: TPoint; var Effect: Integer);
    procedure decTreeView1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure decTreeView1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure DeleteItem1Click(Sender: TObject);
    procedure decTreeView1Deletion(Sender: TObject; Node: TTreeNode);
    procedure Newitem1Click(Sender: TObject);
    procedure NewSubItem1Click(Sender: TObject);
    procedure est1Click(Sender: TObject);
    procedure LoadFromFile1Click(Sender: TObject);
    procedure SaveToFile1Click(Sender: TObject);
    procedure decTreeView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure decTreeView1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SaveToDB1Click(Sender: TObject);
    procedure LoadFromDB1Click(Sender: TObject);
    procedure decTreeView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure decTreeView1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure decTreeView1DblClick(Sender: TObject);
    procedure LoadByTagnameFromDB1Click(Sender: TObject);
    procedure SaveasSubTagFromSelectedToDB1Click(Sender: TObject);
    procedure LoadBySubTagNameFromDBToSelectedSubNode1Click(Sender: TObject);
    procedure ShowDiagram1Click(Sender: TObject);
  private
    FAppPath,
    FDrawingFileName,
    FManualFileName: string;

    FMouseClickParaTV_X,
    FMouseClickParaTV_Y: Integer;

    FTempParamItem: TEngineParameterItem;
    FEngineParameterTarget: TEngineParameterDataFormat;
    FEngParamSource: TEngineParameterDataFormat;

    FDeleteMode: Boolean;
    FNewItemCount: integer;
    FMouseDown4InnerDragMode,
    FControlKeyPressed: Boolean;

    procedure OnGetStream(Sender: TFileContentsStreamOnDemandClipboardFormat;
      Index: integer; out AStream: IStream);
    procedure ProcessCopyMode(AShiftState: TShiftState; APoint: TPoint);

    procedure MoveNode(ATreeView: TTreeView; ATargetNode, ASourceNode: TTreeNode);
    function GetSensorRouteItemByLevelNAbsIndex(ALevel, AAbsIndex: integer): TEngElecPartItem;
    procedure InitDragDrop;
    function GetNodeFromDataItem(ATV: TTreeView; ALevel, AAbsIndex: integer): TTreeNode;
    procedure GetEngElecPartItemAryFromSelectedNode(ADynArr: TDynArray);

    function GetRestServerFromFileDBName(ADBName: string): TSQLRest;
  public
    FProjectNo, FEngineNo, FTagName, FEngParamDBName: string;
//    FSensorRoute: TEngElecPartCollect;//TEngSensorCableRoute;
    FSensorRoute: TEngElecPartItemObjArray;//TEngSensorCableRoute;
    FSensorRouteAry: TDynArray;

    FRootNode: TTreeNode;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DeleteItemFromSensorRoute(ANode: TTreeNode; AJson: string);
    procedure ClearTreeView;

    //AIsEngParam : True = TEngineParameterItemRecord,
    //              False = TEngSensorCableRoute Type
    function AddNewTreeNode(ANode: TTreeNode; ASubNode, AIsEngParam: boolean): TTreeNode;
    function AddTreeNode4EngElecPart(AEngElecPartItem: TEngElecPartItem; AIsEdit: Boolean; ATargetNode: TTreeNode=nil): TTreeNode;
    procedure AddNodeBySubTagNameFromFileDB(ADBFileName: string='');
    //AJson에서 TreView에 모든 Node를 생성함                                         //AIsEdit = True : Edit 모드이므로 SubTagName을 가져오지 않음(이미 TreeView에 있음)
    procedure LoadFromJsonString(ATargetNode: TTreeNode; AJson: string; ABySubTagName, AIsEdit: Boolean);
    //AJson에서 TreView에 한개의 ElecPart Node를 선택된 Node의 하위에 생성함
    procedure LoadElecPartFromJson(AJson: string; ATargetNode: TTreeNode);
    //AFileName에서 TreeView에 모든 Node를 생성함
    procedure LoadFromJsonFile(AFileName: string; APassPhrase: string='');
    procedure LoadFromFileDB(ADBFileName: string=''; AProjectNo: TProjectNo='';
      AEngineNo: TEngineNo=''; ATagName: string=''; AEngParamDBName: string='';
      AUseInternalClient: Boolean=True);
    procedure LoadBySubTagNameFromFileDB(ATargetNode: TTreeNode; ADBFileName: string=''; AProjectNo: TProjectNo='';
      AEngineNo: TEngineNo=''; ATagName: string='');
    procedure UpdateEngParameterItem2Node(ANode: TTreeNode; AEPItem:TEngineParameterItem);
    procedure UpdateEngElecPartItem2Node(ANode: TTreeNode; AEngElecPartItem: TEngElecPartItem);
    procedure ApplyTagName2Node(ANode: TTreeNode; AJson: string);
    procedure SaveToJsonFile(AFileName: string; APassPhrase: string='');
    procedure SaveToDB(AUseMemDB: Boolean; ADBFileName: string='');
    procedure SaveToMemDB;
    procedure SaveToFileDB(ADBFileName: string=''; AUseInternalClient: Boolean=True);
    procedure SaveSelectedNode2FileDB(ADBFileName: string=''; AUseInternalClient: Boolean=True);
    procedure AddTVItem2DB(ARest: TSQLRest);
    procedure AddItemFromAry2DB(ARest: TSQLRest; ADynArr: TDynArray; ASensorRoute: TEngElecPartItemObjArray);
    function GetEngParam2JSONFromDBByTagName(ATagName: string; ADBFileName: string=''): string;
    //AClass에서 TreeView에 모든 Node를 생성함
    procedure LoadFromSensorRouteClass(ATargetNode: TTreeNode;
      AClass: TEngSensorRouteTV; ABySubTagName, AIsEdit: Boolean);
    //Root Node의 Tag Info를 하위 Node에 복사함
    procedure CopyTagInfo2EngElecPart(AClass: TEngSensorRouteTV);
    //AClass에서 Root Node를 생성함
    procedure AddRootNodeFromSensorRouteClass(AClass: TEngSensorRouteTV);
    //AClass에서 Root Node를 제외한 나머지 Nodes를 생성함
    procedure AddNodesFromSensorRouteClass(AClass: TEngSensorRouteTV; AIsEdit: Boolean; ATargetNode: TTreeNode=nil);
    //TreeView의 모든 Item을 Json으로 반환함
    procedure GetJsonFromTreeView(out AJson: string);
    //TreeView의 선택된 한개의 Item을 Json으로 반환함
    //Result = 1 : TEngineParameterItem Type, 2 : TEngElecPartItem Type
    function GetJsonFromSelectedTV(ANode: TTreeNode; out AJson: string): integer;
    function GetJsonFromEngElecPartItemObjArray(AObjArr: TEngElecPartItemObjArray): string;
    procedure SetNodeInfo2SensorRoute(ANode: TTreeNode; AEngElecPartItem: TEngElecPartItem);
    procedure SetProjectInfo(AProjectNo, AEngineNo, ATagName, AEngParamDBName: string);
    procedure SetAppPath(APath: string);
    procedure SetFileName(const AAppPath, ADrawingFN, AManualFN: string);
    function GetPLCModuleNameFromTV: string;
    //TreeView의 node로부터 Data.TEngElecPartItem의 Node Info를 Update함
    procedure ReArrangeDataItemIndexFromNode(ATV: TTreeView=nil);
    function IsSamePanelName(ANode1, ANode2: TTreeNode): Boolean;
    procedure NodeExpandWithSamePanelName;
    function GetPLCInfoRecFromTV(ANode: TTreeNode = nil): TPLCChannelInfoRec;
    function GetPanelInfoRecFromTV(ANode: TTreeNode = nil): TPLCChannelInfoRec;
    function IsSubTagNameInCsv(ACsv, ASubTagName: string): Boolean;

    procedure ShowDiagram;
  end;

  TEngSensorRouteTV = class
    FTempParamItem: TEngineParameterItem;
//    FSensorRoute: TEngElecPartCollect;//TEngSensorCableRoute;
    FSensorRoute: TEngElecPartItemObjArray;//TEngSensorCableRoute;
  public
    FSensorRouteAry: TDynArray;

    constructor Create;
  published
    property TempParamItem: TEngineParameterItem read FTempParamItem write FTempParamItem;
//    property SensorRouteAry: TDynArray read FSensorRouteAry write FSensorRouteAry;
    property SensorRoute: TEngElecPartItemObjArray read FSensorRoute write FSensorRoute;
//    property SensorRoute: TEngElecPartCollect read FSensorRoute write FSensorRoute;
//    property SensorRoute: TEngSensorCableRoute read FSensorRoute write FSensorRoute;
  end;

//  TEngSensorRouteTVObjArray = array of TEngSensorRouteTV;

  procedure SetNodeImages(Node : TTreeNode; HasChildren : boolean);

implementation

uses UnitTreeViewUtil, UnitRttiUtil, UnitEncrypt, UnitStringUtil, UnitProcessUtil,
  UnitEngParamConfig, FrmElecPart, FrmInputData1, FrmSimpleBrowser;

//var
//  g_EngSensorRouteTVAry : TEngSensorRouteTVObjArray;

{$R *.dfm}

procedure SetNodeImages(Node : TTreeNode; HasChildren : boolean);
begin
  if HasChildren then begin
    //Node.HasChildren    := true;
    Node.ImageIndex     := cClosedBook;
    Node.SelectedIndex  := cOpenBook;
  end else begin
    Node.ImageIndex     := cClosedPage;
    Node.SelectedIndex  := cOpenPage;
  end; {if}
end; {SetNodeImages}

procedure TFrameDecTreeView1.AddItemFromAry2DB(ARest: TSQLRest;
  ADynArr: TDynArray; ASensorRoute: TEngElecPartItemObjArray);
var
  i: integer;
  LEngElecPartItem: TEngElecPartItem;
  LCmd: IDomSensorCommand;
  LCQRSRes : TCQRSResult;
begin
  if not ARest.Services.Resolve(IDomSensorCommand, LCmd) then
  begin
    exit;
  end;

  for i := 0 to ADynArr.Count - 1 do
  begin
    LEngElecPartItem := ASensorRoute[i];
    LCQRSRes := LCmd.Add(LEngElecPartItem);
  end;
end;

function TFrameDecTreeView1.AddNewTreeNode(ANode: TTreeNode; ASubNode,
  AIsEngParam: boolean): TTreeNode;
var
  Node1 : TTreeNode;
  LItem: TEngElecPartItem;
  LTitle, LDesc: string;
begin
  Result := nil;

  if AIsEngParam then
  begin
    LItem := nil;
    LTitle := FTempParamItem.TagName;
    LDesc := FTempParamItem.Description;
  end
  else
  begin
    inc(FNewItemCount);

    if FTempParamItem.TagName = '' then
    begin
      LTitle := 'New' + IntToStr(FNewItemCount);
      LDesc := LTitle;
    end
    else
    begin
      LTitle := FTempParamItem.TagName;
      LDesc := FTempParamItem.Description;
    end;

//    LItem := FSensorRoute.Add;
    LItem := TEngElecPartItem.Create;
    LItem.CreateTime := TimeLogFromDateTime(now);
    FSensorRouteAry.Add(LItem);

    LItem.ProjectNo := FTempParamItem.ProjNo;
    LItem.EngineNo := FTempParamItem.EngNo;
//    LItem.ProjectName := FTempParamItem;
    LItem.EngSensor.TagName := LTitle;
    LItem.EngSensor.TagDesc := LDesc;
    LTitle := GetElecPartDisplayName(LItem);
  end;

  if ASubNode then
  begin
    if Assigned(ANode) then
      Node1 := decTreeView1.Items.AddChildObject(ANode,
              LTitle, LItem)
    else
      Node1 := decTreeView1.Items.AddChildObject(nil,
               LTitle, LItem);
  end
  else
  begin
    if Assigned(ANode) then
      Node1 := decTreeView1.Items.AddObject(ANode,
               LTitle, LItem)
    else
      Node1 := decTreeView1.Items.AddObject(nil,
               LTitle, FTempParamItem);
  end;

  if Assigned(LItem) then
  begin
    LItem.AbsoluteIndex := Node1.AbsoluteIndex;
    LItem.NodeIndex := Node1.Index;
    LItem.LevelIndex := Node1.Level;

    if Assigned(ANode) then
    begin
      if ASubNode then
      begin
        LItem.ParentNodeAbsIndex := ANode.AbsoluteIndex;
        LItem.ParentNodeLevel := ANode.Level;
      end
      else
      begin
        if Assigned(ANode.Data) then
        begin
          LItem.ParentNodeAbsIndex := TEngElecPartItem(ANode.Data).ParentNodeAbsIndex;
          LItem.ParentNodeLevel := TEngElecPartItem(ANode.Data).ParentNodeLevel;
        end;
      end;
    end
    else
    begin
      LItem.ParentNodeAbsIndex := -1;
      LItem.ParentNodeLevel := -1;
    end;
  end;

//  LTitle := IntToStr(Node1.Index) + ':' + IntToStr(Node1.AbsoluteIndex) + ':' + IntToStr(Node1.Level);
  Node1.Text := LTitle;

//  Node1.Text := LDesc;
  SetNodeImages(Node1, False);

  if Assigned(ANode) then
    ANode.Expand(True);

  decTreeView1.FullExpand;
  Result := Node1;
end;

procedure TFrameDecTreeView1.AddNodeBySubTagNameFromFileDB(ADBFileName: string);
var
  LInputDataRec: TInputDataRec;
  LResult: integer;
begin
  if ADBFileName = '' then
  begin
    if OpenDialog1.Execute() then
      ADBFileName := OpenDialog1.FileName;
  end;

  LInputDataRec.Label1 := 'DB Name';
  LInputDataRec.Label2 := 'Project No';
  LInputDataRec.Label3 := 'Eng. No';
  LInputDataRec.Label4 := 'Tag Name';

  LInputDataRec.Data1 := ADBFileName;
  LInputDataRec.Data2 := FProjectNo;
  LInputDataRec.Data3 := FEngineNo;
  LInputDataRec.Data4 := FTagName;

  LResult := CrerateInputDataForm(LInputDataRec);

  if LResult = -1 then
  begin
    exit;
  end;

  LoadBySubTagNameFromFileDB(decTreeView1.Selected, LInputDataRec.Data1, LInputDataRec.Data2, LInputDataRec.Data3, LInputDataRec.Data4);
end;

procedure TFrameDecTreeView1.AddNodesFromSensorRouteClass(
  AClass: TEngSensorRouteTV; AIsEdit: Boolean; ATargetNode: TTreeNode);
var
  i: integer;
  LEngElecPartItem: TEngElecPartItem;
  LNode: TTreeNode;
  LBySubTagName: Boolean;
begin
  if Assigned(ATargetNode) then
  begin
    LNode := ATargetNode;
    LBySubTagName := True;
  end
  else
  begin
    LNode := FRootNode;
    LBySubTagName := False;
  end;

  AClass.FSensorRouteAry.Compare := EngElecPartItemAbsoluteIndexCompare;
  AClass.FSensorRouteAry.Sort();

  for i := 0 to AClass.FSensorRouteAry.Count - 1 do
  begin
    LEngElecPartItem := AClass.FSensorRoute[i];

    if LBySubTagName then
    begin
      if i = 0 then
      begin
        //부모 노드의 SubTagName에 추가될 TagName 저장함
        //이미 SubTagName이 존재하면 ';'으로 추가 한다.
        if TEngElecPartItem(LNode.Data).EngSensor.SubTagName = '' then
          TEngElecPartItem(LNode.Data).EngSensor.SubTagName := LEngElecPartItem.EngSensor.TagName
        else
        begin
          if not IsSubTagNameInCsv(TEngElecPartItem(LNode.Data).EngSensor.SubTagName, LEngElecPartItem.EngSensor.TagName) then
            TEngElecPartItem(LNode.Data).EngSensor.SubTagName := TEngElecPartItem(LNode.Data).EngSensor.SubTagName + ';' +
              LEngElecPartItem.EngSensor.TagName;
        end;
      end;

      LNode := AddTreeNode4EngElecPart(LEngElecPartItem, AIsEdit, LNode);
    end
    else
      LNode := AddTreeNode4EngElecPart(LEngElecPartItem, AIsEdit);
  end;

  NodeExpandWithSamePanelName;
end;

procedure TFrameDecTreeView1.AddRootNodeFromSensorRouteClass(
  AClass: TEngSensorRouteTV);
begin
  FTempParamItem.Assign(AClass.FTempParamItem);
  FRootNode := AddNewTreeNode(nil, False, True);
  CopyTagInfo2EngElecPart(AClass);
end;

function TFrameDecTreeView1.AddTreeNode4EngElecPart(AEngElecPartItem: TEngElecPartItem;
  AIsEdit: Boolean; ATargetNode: TTreeNode): TTreeNode;
var
  LParentNode: TTreeNode;
  Node1 : TTreeNode;
  LItem: TEngElecPartItem;
begin
  Result := nil;

  LItem := TEngElecPartItem.Create;
  AEngElecPartItem.AssignTo(TPersistent(LItem));
  FSensorRouteAry.Add(LItem);

  if Assigned(ATargetNode) then
  begin
    Node1 := decTreeView1.Items.AddChildObject(ATargetNode, GetElecPartDisplayName(LItem), LItem);
    LItem.ParentNodeAbsIndex := ATargetNode.AbsoluteIndex;
    LItem.ParentNodeLevel := ATargetNode.Level;
    LItem.AbsoluteIndex := Node1.AbsoluteIndex;
  end
  else
  begin
    LParentNode := GetNodeFromDataItem(decTreeView1, LItem.ParentNodeLevel, LItem.ParentNodeAbsIndex);
//    LParentNode := GetNodeFromIndex(decTreeView1, LItem.ParentNodeLevel, LItem.ParentNodeAbsIndex);

//    if Assigned(LParentNode) then
    Node1 := decTreeView1.Items.AddChildObject(LParentNode, GetElecPartDisplayName(LItem), LItem);
//    LItem.ParentNodeAbsIndex := LParentNode.AbsoluteIndex;
//    LItem.ParentNodeLevel := LParentNode.Level;
  end;

//  LItem.AbsoluteIndex := Node1.AbsoluteIndex;
  LItem.NodeIndex := Node1.Index;
  LItem.LevelIndex := Node1.Level;

  SetNodeImages(Node1, False);

//  decTreeView1.FullExpand;
  Result := Node1;

  if (not AIsEdit) and (LItem.EngSensor.SubTagName <> '') then
  begin
    LoadBySubTagNameFromFileDB(Node1, DefaultSensorRouteDBFileName, LItem.ProjectNo,
      LItem.EngineNo, LItem.EngSensor.SubTagName);
  end
end;

procedure TFrameDecTreeView1.AddTVItem2DB(ARest: TSQLRest);
var
  i: integer;
  LEngElecPartItem: TEngElecPartItem;
  LCmd: IDomSensorCommand;
  LCQRSRes : TCQRSResult;
begin
  if not ARest.Services.Resolve(IDomSensorCommand, LCmd) then
  begin
    exit;
  end;

  for i := 0 to FSensorRouteAry.Count - 1 do
  begin
    LEngElecPartItem := FSensorRoute[i];
    LCQRSRes := LCmd.Add(LEngElecPartItem);
  end;
end;

procedure TFrameDecTreeView1.ApplyTagName2Node(ANode: TTreeNode; AJson: string);
var
  LItem: TEngElecPartItem;
  LDoc: variant;
begin
  if not Assigned(ANode) then
    exit;

//  TDocVariant.New(LDoc);
  LDoc := _JSON(AJson);
  LItem := TEngElecPartItem(ANode.Data);

  LItem.EngSensor.TagName := LDoc.TagName;
  LItem.EngSensor.TagDesc := LDoc.TagDesc;
end;

procedure TFrameDecTreeView1.ClearTreeView;
begin
  decTreeView1.Items.Clear;
  FSensorRouteAry.Clear;
end;

procedure TFrameDecTreeView1.CopyTagInfo2EngElecPart(AClass: TEngSensorRouteTV);
begin

end;

constructor TFrameDecTreeView1.Create(AOwner: TComponent);
begin
  inherited;

//  FSensorRoute := TEngElecPartCollect.Create;
//  FSensorRoute.EngElecParts := TEngElecPartCollect.Create;
  FSensorRouteAry.Init(TypeInfo(TEngElecPartItemObjArray), FSensorRoute);
  FTempParamItem := TEngineParameterItem.Create(nil);
  InitDragDrop;
  FDeleteMode := False;
  FNewItemCount := 0;
end;

procedure TFrameDecTreeView1.decTreeView1DblClick(Sender: TObject);
var
  LNode: TTreeNode;
  LEPItem: TEngineParameterItem;
  LEngElecPartItem: TEngElecPartItem;
  LName: string;
begin
  LNode := decTreeView1.GetNodeAt( FMouseClickParaTV_X, FMouseClickParaTV_Y );

  if Assigned(LNode) then
  begin
    LName := TObject(LNode.Data).ClassName;

    if LName = 'TEngineParameterItem' then
    begin
      LEPItem := TEngineParameterItem(LNode.Data);

      if ShowEngParamItemConfigForm(LEPItem) = mrOK then
      begin
        UpdateEngParameterItem2Node(LNode, LEPItem);
      end;
    end
    else
    if LName = 'TEngElecPartItem' then
    begin
      LEngElecPartItem := TEngElecPartItem(LNode.Data);

      if ShowElecPartForm(LEngElecPartItem,1,FAppPath,FDrawingFileName,FManualFileName) = mrOK then
      begin
        UpdateEngElecPartItem2Node(LNode, LEngElecPartItem);
      end;
    end;
  end;
end;

procedure TFrameDecTreeView1.decTreeView1Deletion(Sender: TObject;
  Node: TTreeNode);
var
//  LHMItem: THiMECSMenuItem;
  i: integer;
begin
//  if Assigned(FMenuBase) then
//  begin
    if FDeleteMode then
    begin
//      LHMItem := THiMECSMenuItem(Node.Data);
//      FMenuBase.HiMECSMenuCollect.Delete(LHMItem.Index);
    end;
//  end;
end;

procedure TFrameDecTreeView1.decTreeView1DragDrop(Sender, Source: TObject; X, Y: Integer);
var
  LTargetNode, LSourceNode: TTreeNode;
  i:integer;
  LEngElecPartItem: TEngElecPartItem;
begin
  if Sender is TdecTreeView then
  begin
    with decTreeView1 do
    begin
      LTargetNode := GetNodeAt( X, Y ); //Get Target Node
      LSourceNode := Selected;

      if (LTargetNode = nil) or (LTargetNode = LSourceNode) then
      begin
        EndDrag(False);
        Exit;
      end;
    end;

    if FControlKeyPressed then
    begin
      CopyTreeNode(decTreeView1);
    end
    else
    begin
      //Node를 Move 하기 전에 LEngElecPartItem를 가져옴
      LEngElecPartItem := GetSensorRouteItemByLevelNAbsIndex(LSourceNode.Level, LSourceNode.AbsoluteIndex);
      //Node가 Move 되면 Level, AbsoluteIndex가 변함
      LSourceNode.MoveTo(LTargetNode, naAddChild);
      SetNodeInfo2SensorRoute(LSourceNode, LEngElecPartItem);
    end;

//    MoveNode(decTreeView1, LTargetNode, LSourceNode);
//    LSourceNode.Free;
  end
  else if (Sender <> decTreeView1) then
  begin
  end;
end;

procedure TFrameDecTreeView1.decTreeView1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  Src, Dst: TTreeNode;
begin
  if (Sender = decTreeView1) then
  begin
    Src := decTreeView1.Selected;
    Dst := decTreeView1.GetNodeAt(X,Y);

    Accept := Assigned(Dst) and (Src <> Dst);
  end;
end;

procedure TFrameDecTreeView1.decTreeView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_CONTROL then
    FControlKeyPressed := True;
end;

procedure TFrameDecTreeView1.decTreeView1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_CONTROL then
    FControlKeyPressed := False;
end;

procedure TFrameDecTreeView1.decTreeView1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LStr: string;
  LNodeType: integer;
begin
  FMouseClickParaTV_X := X;
  FMouseClickParaTV_Y := Y;

  FMouseDown4InnerDragMode := True;

  if decTreeView1.SelectedCount > 0 then
  begin
    if (DragDetectPlus(TWinControl(Sender).Handle, Point(X,Y))) then
    begin
      if decTreeView1.SelectedCount = 1 then
      begin
        // Copy the data into the drop source.
        LNodeType := GetJsonFromSelectedTV(decTreeView1.Selected, LStr);

        case LNodeType of
          1: LStr := 'TEngineParameterItem:'+LStr;
          2: LStr := 'TEngElecPartItem:'+LStr;
        end;

        EngParamSource1.Text := LStr;
      end
      else
      begin
      end;

      EngParamSource1.Execute;
    end;
  end;
end;

procedure TFrameDecTreeView1.decTreeView1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FMouseDown4InnerDragMode := False;
end;

procedure TFrameDecTreeView1.DeleteItem1Click(Sender: TObject);
var
//  HTreeNode: HTreeItem;
  LTreeNode: TTreeNode;
begin
  if MessageDlg(decTreeView1.Selected.Text + ' 를 지우시겠습니까? ' +#13#10,
    mtConfirmation, [mbYes, mbNo], 0, mbYes) = mrYes then
  begin
    try
      FDeleteMode := True;
      LTreeNode := decTreeView1.Selected;
//      LTreeNode := decTreeView1.Items.GetNode(HTreeNode);
      ExecuteWithAllChildren(decTreeView1.Selected, DeleteItemFromSensorRoute, '');
//      LTreeNode.DeleteChildren;
      DeleteItemFromSensorRoute(decTreeView1.Selected, '');
      LTreeNode.Delete;
    finally
      FDeleteMode := False;
    end;
  end;
end;

procedure TFrameDecTreeView1.DeleteItemFromSensorRoute(ANode: TTreeNode; AJson: string);
var
  LItem: TEngElecPartItem;
  i: integer;
begin
  if ANode = nil then
    exit;

  if ANode.Data <> nil then
  begin
    LItem := TEngElecPartItem(ANode.Data);

    i := FSensorRouteAry.IndexOf(LItem);

    if i >= 0 then
      FSensorRouteAry.Delete(i);
//    FSensorRoute.Delete(LItem.Index);
  end;
end;

destructor TFrameDecTreeView1.Destroy;
begin
  FTempParamItem.Free;
  FEngParamSource.Free;
  FEngineParameterTarget.Free;

  FSensorRouteAry.Clear;
//  FreeAndNil(FSensorRoute);

  inherited;
end;

procedure TFrameDecTreeView1.DropTextTarget1Drop(Sender: TObject; ShiftState: TShiftState;
  APoint: TPoint; var Effect: Integer);
var
  LStr, LJson: string;
  LTreeNode: TTreeNode;
begin
  //Inner Drag는 Skip
  if FMouseDown4InnerDragMode then
  begin
    ShowMessage('It is Inner-Drag Mode');
    exit;
  end;

  if (FEngineParameterTarget.HasData) then
  begin
    if FEngineParameterTarget.DataKind = 1 then
    begin

    end
    else
    begin
      FEngineParameterTarget.EPD.FEPItem.AssignToParamItem(FTempParamItem);

      case FEngineParameterTarget.EPD.FDragDataType of
        dddtSingleRecord: begin
          if decTreeView1.Items.Count > 0 then
          begin
            if MessageDlg('TreeView에 Data가 있습니다. 덮어쓰시겠습니까?',
            mtConfirmation, [mbYes, mbNo], 0)=mrNo then
              exit;
          end;

          SetProjectInfo(FEngineParameterTarget.EPD.FEPItem.FProjNo,
            FEngineParameterTarget.EPD.FEPItem.FEngNo,
            FEngineParameterTarget.EPD.FEPItem.FTagName,
            FEngineParameterTarget.EPD.FEPItem.FFExcelRange);
          ProcessCopyMode(FEngineParameterTarget.EPD.FShiftState, APoint);//(FEngineParameterTarget.EPD.FEPItem, ADragCopyMode);
        end;
  //
  //      dddtMultiRecord: begin//ShowMessage(IntToStr(FEngineParameterTarget.EPD.FSourceHandle));
  //        if ssCtrl in FEngineParameterTarget.EPD.FShiftState then
  //          PopupCopyMode(FEngineParameterTarget.EPD.FShiftState, FMousePoint)
  //        else
  //          FDragCopyMode := dcmCopyOnlyNonExist;
  ////          SendHandleCopyData(FEngineParameterTarget.EPD.FSourceHandle, Handle, WParam_REQMULTIRECORD);
  //
  //        if FDragCopyMode <> dcmCopyCancel then
  //          SendHandleCopyDataWithShift(FEngineParameterTarget.EPD.FSourceHandle,
  //            FHandle, WParam_REQMULTIRECORD,
  //            FEngineParameterTarget.EPD.FShiftState,
  //            Ord(FDragCopyMode));
  //
  //        if Assigned(FDisplayMessage) then
  //          FDisplayMessage(DateTimeToStr(now) + ' : Send WParam_REQMULTIRECORD to ' + IntToStr(FEngineParameterTarget.EPD.FSourceHandle));
  ////          FStatusBar.SimpleText := DateTimeToStr(now) + ' : Send WParam_REQMULTIRECORD to ' + IntToStr(FEngineParameterTarget.EPD.FSourceHandle);
  //      end;
      end;//case
    end;//if
  end//if
  else
  if DropTextTarget1.Text <> '' then
  begin
    LTreeNode := decTreeView1.GetNodeAt(APoint.X, APoint.Y);

    if (LTreeNode <> nil) and (LTreeNode.Level > 0) then
    begin
      LJson := DropTextTarget1.Text;
      LStr := strToken(LJson, ':');

      if LStr = 'TEngElecPartItem' then
        LoadElecPartFromJson(LJson, LTreeNode);
    end;
  end;
end;

procedure TFrameDecTreeView1.est1Click(Sender: TObject);
var
  LJson: string;
begin
  ShowMessage(IntToStr(decTreeView1.Selected.Level) + ':' +
    IntToStr(decTreeView1.Selected.AbsoluteIndex) + ':' + IntToStr(decTreeView1.Selected.Index));
  ShowMessage(IntToStr(TEngElecPartItem(decTreeView1.Selected.Data).LevelIndex) + ':' +
    IntToStr(TEngElecPartItem(decTreeView1.Selected.Data).AbsoluteIndex) + ':' + IntToStr(TEngElecPartItem(decTreeView1.Selected.Data).NodeIndex));
//  ShowMessage(IntToStr(FSensorRouteAry.Count));
//  GetJsonFromTreeView(LJson);
//  LoadFromJsonString(LJson);
end;

procedure TFrameDecTreeView1.GetEngElecPartItemAryFromSelectedNode(
  ADynArr: TDynArray);
var
  LNode: TTreeNode;
  LItem: TEngElecPartItem;

  procedure _GetNodeChildren(ANode: TTreeNode);
  begin
    LNode := LNode.getFirstChild;

    if LNode = nil then
      exit;

    repeat
      if Assigned(LNode.Data) then
      begin
        LItem := TEngElecPartItem(LNode.Data);
        ADynArr.Add(LItem);
      end;

      _GetNodeChildren(LNode);

      if Assigned(LNode) then
        LNode := LNode.getNextSibling;
    until (LNode = nil);
  end;
begin
  if Assigned(decTreeView1.Selected) then
  begin
    LNode := decTreeView1.Selected;

    if Assigned(LNode.Data) then
    begin
      LItem := TEngElecPartItem(LNode.Data);
      ADynArr.Add(LItem);
    end;

    _GetNodeChildren(LNode);
  end;
end;

function TFrameDecTreeView1.GetEngParam2JSONFromDBByTagName(ATagName,
  ADBFileName: string): string;
var
  LEngineParamRecord: TEngineParamRecord;
begin
  InitEngineParamClient(ADBFileName);
  LEngineParamRecord := GetEngParamRecFromTagNo(ATagName);
  Result := LEngineParamRecord.GetJSONValues(true, true, soSelect);
end;

function TFrameDecTreeView1.GetJsonFromEngElecPartItemObjArray(
  AObjArr: TEngElecPartItemObjArray): string;
var
  LDynAry: TDynArray;
begin
  LDynAry.Init(TypeInfo(TEngElecPartItemObjArray), AObjArr);
  Result := LDynAry.SaveToJSON();
end;

function TFrameDecTreeView1.GetJsonFromSelectedTV(ANode: TTreeNode; out AJson: string): integer;
var
  LElecPartItem: TEngElecPartItem;
  LParameterItem: TEngineParameterItem;
  LName: string;
begin
  Result := -1;

  if ANode = nil then
    exit;

  if Assigned(ANode.Data) then
  begin
    //Root Node임
    LName := TObject(ANode.Data).ClassName;

    if LName = 'TEngineParameterItem' then
    begin
      LParameterItem := TEngineParameterItem(ANode.Data);
      AJson := ObjectToJson(LParameterItem);
      Result := 1;
    end
    else
    if LName = 'TEngElecPartItem' then
    begin
      LElecPartItem := TEngElecPartItem(ANode.Data);
      AJson := ObjectToJson(LElecPartItem);
      Result := 2;
    end;
  end;
end;

procedure TFrameDecTreeView1.GetJsonFromTreeView(out AJson: string);
var
  LNode: TTreeNode;
  LEngSensorRouteTV: TEngSensorRouteTV;
//  LEngSensorRouteTVAry: TDynArray;
begin
  LNode := GetRootNodeFromTreeView(decTreeView1 as TJvCheckTreeView);

  if Assigned(LNode) then
  begin
//    LEngSensorRouteTVAry.Init(TypeInfo(TEngSensorRouteTVObjArray), g_EngSensorRouteTVAry);
//    LEngSensorRouteTVAry.Clear;

    LEngSensorRouteTV := TEngSensorRouteTV.Create;
    try
      LEngSensorRouteTV.FTempParamItem := FTempParamItem;
      LEngSensorRouteTV.FSensorRoute := FSensorRoute;
      AJson := ObjectToJson(LEngSensorRouteTV);
    finally
      LEngSensorRouteTV.Free;
    end;
  end;
end;

function TFrameDecTreeView1.GetNodeFromDataItem(ATV: TTreeView; ALevel,
  AAbsIndex: integer): TTreeNode;
var
  LNode: TTreeNode;
  LItem: TEngElecPartItem;
begin
  Result := nil;
  LNode := ATV.Items.GetFirstNode;

  while Assigned(LNode) do
  begin
    if Assigned(LNode.Data) then
    begin
      LItem := TEngElecPartItem(LNode.Data);

      if (LItem.LevelIndex = ALevel) and (LItem.AbsoluteIndex = AAbsIndex) then
      begin
        Result := LNode;
        Break;
      end;
    end;

    LNode := LNode.GetNext;
  end;
end;

function TFrameDecTreeView1.GetPanelInfoRecFromTV(
  ANode: TTreeNode): TPLCChannelInfoRec;
var
  LNode: TTreeNode;
  LItem: TEngElecPartItem;
begin
  Result := Default(TPLCChannelInfoRec);

  if Assigned(ANode) then
  begin
    LNode := ANode;
  end
  else
  begin
    LNode := decTreeView1.Items.GetFirstNode;
    LNode := LNode.GetNext;
  end;

  while Assigned(LNode) do
  begin
    if LNode.Level = 0 then
      exit;

    if Assigned(LNode.Data) then
    begin
      LItem := TEngElecPartItem(LNode.Data);

      if LItem.EngSensor.PanelName <> '' then
      begin
        Result.FPanelName := LItem.EngSensor.PanelName;
        Result.FTagName := LItem.EngSensor.TagName;
        Result.FTerminalName := LItem.EngSensor.TerminalName;
        Result.FTerminalNo := LItem.EngSensor.TerminalNo;
        Break;
      end;
    end;

    LNode := LNode.GetNext;
  end;
end;

function TFrameDecTreeView1.GetPLCInfoRecFromTV(ANode: TTreeNode): TPLCChannelInfoRec;
var
  LNode: TTreeNode;
  LItem: TEngElecPartItem;
begin
  Result := Default(TPLCChannelInfoRec);

  if Assigned(ANode) then
    LNode := ANode
  else
  begin
    LNode := decTreeView1.Items.GetFirstNode;
    LNode := LNode.GetNext;
  end;

  while Assigned(LNode) do
  begin
    if Assigned(LNode.Data) then
    begin
      LItem := TEngElecPartItem(LNode.Data);

      if LItem.EngSensor.ModuleName <> '' then
      begin
        Result.FPanelName := LItem.EngSensor.PanelName;
        Result.FPLCModuleName := LItem.EngSensor.ModuleName;
        Result.FTagName := LItem.EngSensor.TagName;
        Result.FPlcChNo := LItem.EngSensor.ChannelNo;
        Break;
      end;
    end;

    LNode := LNode.GetNext;
  end;

end;

function TFrameDecTreeView1.GetPLCModuleNameFromTV: string;
var
  LNode: TTreeNode;
  LItem: TEngElecPartItem;
  LPanelName: string;
  i: integer;
begin
  for i := 0 to decTreeView1.Items.Count - 1 do
  begin
    LNode := decTreeView1.Items[i];

    if Assigned(LNode.Data) then
    begin
      if TEngElecPartItem(LNode.Data).EngSensor.PanelName <> '' then
        LPanelName := TEngElecPartItem(LNode.Data).EngSensor.PanelName;

    end;
  end;
end;

function TFrameDecTreeView1.GetRestServerFromFileDBName(
  ADBName: string): TSQLRest;
var
  LStore: TSynConnectionDefinition;
  LPath: string;
begin

  if ADBName = '' then
  begin
    ADBName := ChangeFileExt(ExeVersion.ProgramFileName, '.sqlite');
  end
  else
  begin
    LPath := ExtractFilePath(ADBName);
    ADBName := ExtractFileName(ADBName);
  end;

  if LPath = '' then
    LPath := FAppPath+'db\';

//    LPath := ExeVersion.ProgramFilePath+'db\';

  SetCurrentDir(LPath);

  // use a local SQlite3 database file
  LStore := TSynConnectionDefinition.CreateFromJSON(StringToUtf8(
              '{	"Kind": "TSQLRestServerDB", '+
                '"ServerName": "'+ADBName+'"' +
              '}'));

  Result := TSQLRestExternalDBCreate( TSQLModel.Create([TSQLRecordEngElecPartItem]), LStore, false, []);
  Result.Model.Owner := Result;

  if Result is TSQLRestServerDB then
    with TSQLRestServerDB(Result) do begin // may be a client in settings :)
      DB.Synchronous := smOff; // faster exclusive access to the file
      DB.LockingMode := lmExclusive;
      CreateMissingTables;     // will create the tables, if necessary
    end;

  Result.ServiceContainer.InjectResolver([TInfraRepoSensorFactory.Create(Result)],true);
  LStore.Free;

//    if Result is TSQLRestServerDB then
//      TSQLRestServerDB(Result).ServiceDefine(TInfraRepoSensor,[IDomSensorCommand,IDomSensorQuery],sicClientDriven);
end;

function TFrameDecTreeView1.GetSensorRouteItemByLevelNAbsIndex(
  ALevel, AAbsIndex: integer): TEngElecPartItem;
begin
//  Result := GetItemByLevelNAbsIndex(FSensorRouteAry, ALevel, AAbsIndex);
  Result := GetItemByLevelNAbsIndex2(FSensorRoute, ALevel, AAbsIndex);
end;

procedure TFrameDecTreeView1.InitDragDrop;
begin
  FEngineParameterTarget := TEngineParameterDataFormat.Create(DropTextTarget1);
  FEngParamSource := TEngineParameterDataFormat.Create(EngParamSource1);

//  (DataFormatAdapter2.DataFormat as TVirtualFileStreamDataFormat).OnGetStream := OnGetStream;
end;

function TFrameDecTreeView1.IsSamePanelName(ANode1, ANode2: TTreeNode): Boolean;
begin
  if (ANode1 = nil) or (ANode2 = nil) then
    exit(False);

  if (ANode1.Data = nil) or (ANode2.Data = nil) then
    exit(False);

  if (ANode1.Level = 0) or (ANode2.Level = 0) then
    exit(False);

  if (ANode1.Level = 1) or (ANode2.Level = 1) then
    exit(True);

  Result := TEngElecPartItem(ANode1.Data).EngSensor.PanelName = TEngElecPartItem(ANode2.Data).EngSensor.PanelName;
end;

function TFrameDecTreeView1.IsSubTagNameInCsv(ACsv,
  ASubTagName: string): Boolean;
var
  LSubTagList: TStringList;
  LSubTagName: string;
begin
  Result := False;
  LSubTagList := TStringList.Create;
  try
    //ACsv = 'VLV+;SSS' 형식으로 저장됨
    if ASubTagName <> '' then
    begin
      while ACsv <> '' do
      begin
        LSubTagName := strToken(ACsv, ';');

        if LSubTagList.IndexOf(LSubTagName) = -1 then
          LSubTagList.Add(LSubTagName);
      end;

      Result := LSubTagList.IndexOf(LSubTagName) > -1;
    end;
  finally
    LSubTagList.Free;
  end;
end;

procedure TFrameDecTreeView1.LoadBySubTagNameFromDBToSelectedSubNode1Click(
  Sender: TObject);
begin
  AddNodeBySubTagNameFromFileDB(DefaultSensorRouteDBFileName);
end;

procedure TFrameDecTreeView1.LoadBySubTagNameFromFileDB(ATargetNode: TTreeNode;
  ADBFileName: string; AProjectNo: TProjectNo; AEngineNo: TEngineNo; ATagName: string);
var
  RestServer: TSQLRest;
  LCmd: IDomSensorCommand;
  LCQRSRes : TCQRSResult;
  LEntitys: TEngElecPartItemObjArray;
  LEngElecPartItem: TEngElecPartItem;
  LEngParamJSON: string;
begin
  RestServer := GetRestServerFromFileDBName(ADBFileName);

  try
    RestServer.Services.Resolve(IDomSensorCommand, LCmd);
    LCQRSRes := LCmd.SelectOneByTagName(AProjectNo, AEngineNo, ATagName);

    if LCQRSRes = cqrsSuccess then
    begin
      LCQRSRes := LCmd.GetAll(LEntitys);
      LEngParamJSON := '{"SensorRoute":'+GetJsonFromEngElecPartItemObjArray(LEntitys);
      LoadFromJsonString(ATargetNode, LEngParamJSON, True, False);
    end;
  finally
    RestServer.Free;
  end;
end;

procedure TFrameDecTreeView1.LoadByTagnameFromDB1Click(Sender: TObject);
var
  LInputDataRec: TInputDataRec;
  LResult: integer;
begin
  LInputDataRec.Label1 := 'DB Name';
  LInputDataRec.Label2 := 'Project No';
  LInputDataRec.Label3 := 'Eng. No';
  LInputDataRec.Label4 := 'Tag Name';

  LResult := CrerateInputDataForm(LInputDataRec);

  if LResult <> -1 then
  begin
    SetProjectInfo('0','0',LInputDataRec.Data4, 'E:\pjh\project\util\HiMECS\Application\Bin\db\HiMECS_DF_A2_Sensor_r4.sqlite');
//    SetProjectInfo(LInputDataRec.Data2, LInputDataRec.Data3,LInputDataRec.Data4, LInputDataRec.Data1); //'E:\pjh\project\util\HiMECS\Application\Bin\db\HiMECS_DF_A2_Sensor_r4.sqlite'
    LoadFromFileDB(DefaultSensorRouteDBFileName, FProjectNo, FEngineNo, FTagName);
  end;
end;

procedure TFrameDecTreeView1.LoadElecPartFromJson(AJson: string;
  ATargetNode: TTreeNode);
var
  LUtf8: RawUTF8;
  LValid: Boolean;
  LElecPartItem: TEngElecPartItem;
begin
  LUtf8 := StringToUTF8(AJson);
  LElecPartItem := TEngElecPartItem.Create;
  JSONToObject(LElecPartItem, PUTF8Char(LUtf8), LValid, nil, [j2oIgnoreUnknownProperty]);
  AddTreeNode4EngElecPart(LElecPartItem, False, ATargetNode);
end;

procedure TFrameDecTreeView1.LoadFromDB1Click(Sender: TObject);
begin
//  SetProjectInfo('8H35DF', '8H35DF','TE05-1','');
//  SetProjectInfo('0', '0','TE05-1','E:\pjh\project\util\HiMECS\Application\Bin\db\HiMECS_DF_A2_Sensor_r4.sqlite');
  SetProjectInfo('0', '0','SV40',GetDefaultDBPath() + DefaultHiMECSParamSensorDBName);
  LoadFromFileDB(DefaultSensorRouteDBFileName, FProjectNo,FEngineNo, FTagName);
end;

procedure TFrameDecTreeView1.LoadFromFile1Click(Sender: TObject);
begin
//  OpenDialog1.InitialDir := FApplicationPath;
  if OpenDialog1.Execute then
  begin
    if OpenDialog1.FileName <> '' then
    begin
      LoadFromJsonFile(OpenDialog1.FileName);
    end;
  end;
end;

procedure TFrameDecTreeView1.LoadFromFileDB(ADBFileName: string; AProjectNo: TProjectNo;
  AEngineNo: TEngineNo; ATagName, AEngParamDBName: string; AUseInternalClient: Boolean);
var
  RestServer: TSQLRest;
  LCmd: IDomSensorCommand;
  LCQRSRes : TCQRSResult;
  LEntitys: TEngElecPartItemObjArray;
  LEngElecPartItem: TEngElecPartItem;
  LEngParamJSON: string;
begin
  RestServer := GetRestServerFromFileDBName(ADBFileName);

  try
    if AUseInternalClient then
    begin
      RestServer.Services.Resolve(IDomSensorCommand, LCmd);

      LCQRSRes := LCmd.SelectOneByTagName(AProjectNo, AEngineNo, ATagName);

      if AEngParamDBName = '' then
        AEngParamDBName := FEngParamDBName;

      if LCQRSRes = cqrsSuccess then
      begin
        LCQRSRes := LCmd.GetAll(LEntitys);

//        Assert(LCmd.GetCount > 0);

        LEngParamJSON := GetEngParam2JSONFromDBByTagName(ATagName, AEngParamDBName);
        LEngParamJSON := '{"TempParamItem":' + LEngParamJSON + ',"SensorRoute":'+GetJsonFromEngElecPartItemObjArray(LEntitys);

        LoadFromJsonString(nil, LEngParamJSON, False, False);
      end;
    end
    else
    begin
//      RestClient := TSQLRestClientURIDll.Create(TSQLModel.Create(RestServer.Model),@URIRequest);
//      try
//        RestClient.Model.Owner := RestClient;
//        RestClient.ServiceDefine([IDomSensorCommand],sicClientDriven);
//        USEFASTMM4ALLOC := true; // for slightly faster process
//        AddTVItem2DB(RestClient);
//      finally
//        RestClient.Free;
//      end;
    end;
  finally
    RestServer.Free;
  end;
end;

procedure TFrameDecTreeView1.LoadFromJsonFile(AFileName: string; APassPhrase: string);
var
  LStrList: TStringList;
  LValid: Boolean;
  LJson: RawUTF8;
  Fs: TFileStream;
  LMemStream: TMemoryStream;
begin
  LStrList := TStringList.Create;
  try
    if APassPhrase <> '' then
    begin
      LMemStream := TMemoryStream.Create;
      Fs := TFileStream.Create(AFileName, fmOpenRead);
      try
        DecryptStream(Fs, LMemStream, APassphrase);
        LMemStream.Position := 0;
        LStrList.LoadFromStream(LMemStream);
      finally
        LMemStream.Free;
        Fs.Free;
      end;

    end
    else
    begin
      LStrList.LoadFromFile(AFileName);
    end;

    SetLength(LJson, Length(LStrList.Text));
    LJson := StringToUTF8(LStrList.Text);
    LoadFromJsonString(nil, LJson, False, False);
  finally
    LStrList.Free;
  end;
end;

procedure TFrameDecTreeView1.LoadFromJsonString(ATargetNode: TTreeNode;
  AJson: string; ABySubTagName: Boolean; AIsEdit: Boolean);
var
  LUtf8: RawUTF8;
  LValid: Boolean;
  LEngSensorRouteTV: TEngSensorRouteTV;
begin
  LEngSensorRouteTV := TEngSensorRouteTV.Create;
  try
    if ABySubTagName then
      LEngSensorRouteTV.FTempParamItem := nil
    else
    begin
      LEngSensorRouteTV.FTempParamItem := TEngineParameterItem.Create(nil);
      decTreeView1.Items.Clear;
      FSensorRouteAry.Clear;
    end;
//    LEngSensorRouteTV.FSensorRoute := TEngElecPartCollect.Create;
    LUtf8 := StringToUTF8(AJson);
    JSONToObject(LEngSensorRouteTV, PUTF8Char(LUtf8), LValid, nil, [j2oIgnoreUnknownProperty]);
    LoadFromSensorRouteClass(ATargetNode, LEngSensorRouteTV, ABySubTagName, AIsEdit);
  finally
    LEngSensorRouteTV.FTempParamItem.Free;
//    LEngSensorRouteTV.FSensorRoute.Free;
    LEngSensorRouteTV.Free;
  end;
end;

procedure TFrameDecTreeView1.LoadFromSensorRouteClass(ATargetNode: TTreeNode;
  AClass: TEngSensorRouteTV; ABySubTagName, AIsEdit: Boolean);
begin
  if ATargetNode = nil then
  begin
    AddRootNodeFromSensorRouteClass(AClass);
  end;

  AddNodesFromSensorRouteClass(AClass, AIsEdit, ATargetNode);
end;

procedure TFrameDecTreeView1.MoveNode(ATreeView: TTreeView; ATargetNode,
  ASourceNode: TTreeNode);
var
  LNode: TTreeNode;
  i: integer;
//  LHMItem: THiMECSMenuItem;
begin
  With ATreeView do
  begin
//    LHMItem := THiMECSMenuItem(ASourceNode.Data);
//    LNode := Items.AddChildObject(ATargetNode, ASourceNode.Text, LHMItem);

    for i := 0 to ASourceNode.Count - 1 do
    begin
      MoveNode(ATreeView, LNode, ASourceNode.Item[i]);
    end;

    //ASourceNode.Free;

//    LHMItem.AbsoluteIndex := LNode.AbsoluteIndex;
//    LHMItem.NodeIndex := LNode.Index;
//    LHMItem.LevelIndex := LNode.Level;
    //LHMItem.Index := LNode.AbsoluteIndex;
    //ShowMessage(IntToStr(LHMItem.Index));
  end;
end;

procedure TFrameDecTreeView1.Newitem1Click(Sender: TObject);
begin
  AddNewTreeNode(decTreeView1.Selected, False, False);
end;

procedure TFrameDecTreeView1.NewSubItem1Click(Sender: TObject);
begin
  AddNewTreeNode(decTreeView1.Selected, True, False);
end;

procedure TFrameDecTreeView1.NodeExpandWithSamePanelName;
var
  LNode: TTreeNode;
begin
  FRootNode.Expand(False);
  LNode := decTreeView1.Items.GetFirstNode;

  while Assigned(LNode) do
  begin
    if IsSamePanelName(LNode, LNode.getFirstChild) then
      LNode.Expand(False);

    LNode := LNode.GetNext;
  end;
end;

procedure TFrameDecTreeView1.OnGetStream(
  Sender: TFileContentsStreamOnDemandClipboardFormat; Index: integer;
  out AStream: IStream);
var
  Stream: TMemoryStream;
  Data: AnsiString;
  i: integer;
  SelIndex: integer;
  Found: boolean;
begin
  Stream := TMemoryStream.Create;
  try
    AStream := nil;
    SelIndex := 0;
    Found := False;

//    for i := 0 to FileGrid.RowCount-1 do
//      if (FileGrid.Row[i].Selected) then
//      begin
//        if (SelIndex = Index) then
//        begin
//          if Assigned(FGSFiles_) then
//          begin
//            Data := FGSFiles_.Files[i].fData;
//            Found := True;
//            break;
//          end;
//        end;
//        inc(SelIndex);
//      end;
//    if (not Found) then
//      exit;

    Stream.Write(PAnsiChar(Data)^, Length(Data));
    AStream := TFixedStreamAdapter.Create(Stream, soOwned);
  except
    Stream.Free;
    raise;
  end;
end;

procedure TFrameDecTreeView1.ProcessCopyMode(AShiftState: TShiftState;
  APoint: TPoint);
begin
  ClearTreeView;

  AddNewTreeNode(nil, False, True);

//  if FDragCopyMode <> dcmCopyCancel then
//    ProcessItemsDrop(FDragCopyMode);
end;

procedure TFrameDecTreeView1.ReArrangeDataItemIndexFromNode(ATV: TTreeView);
var
  LNode: TTreeNode;
  LItem: TEngElecPartItem;
begin
  if not Assigned(ATV) then
    ATV := decTreeView1;

  LNode := ATV.Items.GetFirstNode;

  while Assigned(LNode) do
  begin
    if Assigned(LNode.Data) then
    begin
      LItem := TEngElecPartItem(LNode.Data);

      LItem.AbsoluteIndex := LNode.AbsoluteIndex;
      LItem.NodeIndex := LNode.Index;
      LItem.LevelIndex := LNode.Level;

      if Assigned(LNode.Parent) then
      begin
        LItem.ParentNodeAbsIndex := LNode.Parent.AbsoluteIndex;
        LItem.ParentNodeLevel := LNode.Parent.Level;
      end;
    end;

    LNode := LNode.GetNext;
  end;
end;

procedure TFrameDecTreeView1.SaveasSubTagFromSelectedToDB1Click(
  Sender: TObject);
begin
  SaveSelectedNode2FileDB(DefaultSensorRouteDBFileName);
end;

procedure TFrameDecTreeView1.SaveSelectedNode2FileDB(ADBFileName: string;
  AUseInternalClient: Boolean);
var
  RestServer: TSQLRest;
  RestClient: TSQLRestClientURI;
  LEngElecPartItem, LEngElecPartItem2: TEngElecPartItem;
  LCmd: IDomSensorCommand;
  LCQRSRes : TCQRSResult;
  i, j, LCount: integer;
  LDataExist: Boolean;
  LPrevProjNo, LPrevEngNo, LPrevTagname: string;
  LSensorRoute: TEngElecPartItemObjArray;
  LDynArr: TDynArray;
  LInputDataRec: TInputDataRec;
  LResult: integer;
begin
  if ADBFileName = '' then
  begin
    if OpenDialog1.Execute() then
      ADBFileName := OpenDialog1.FileName;
  end;

  LInputDataRec.Label1 := 'DB Name';
  LInputDataRec.Label2 := 'Project No';
  LInputDataRec.Label3 := 'Eng. No';
  LInputDataRec.Label4 := 'Tag Name';

  LInputDataRec.Data1 := ADBFileName;
  LInputDataRec.Data2 := FProjectNo;
  LInputDataRec.Data3 := FEngineNo;
  LInputDataRec.Data4 := FTagName;

  LResult := CrerateInputDataForm(LInputDataRec);

  if LResult = -1 then
  begin
    exit;
  end;

  LPrevProjNo := '';
  LPrevEngNo := '';
  LPrevTagname := '';


  RestServer := GetRestServerFromFileDBName(ADBFileName);
  LEngElecPartItem2 := TEngElecPartItem.Create;
  try
    LDynArr.Init(TypeInfo(TEngElecPartItemObjArray), LSensorRoute);
    GetEngElecPartItemAryFromSelectedNode(LDynArr);

    if AUseInternalClient then
    begin
      if RestServer.Services.Resolve(IDomSensorCommand, LCmd) then
      begin
        for i := 0 to LDynArr.Count - 1 do
        begin
          LEngElecPartItem := TEngElecPartItem(LSensorRoute[i]);
          LCQRSRes := cqrsNotFound;
          LDataExist := False;

          LCQRSRes := LCmd.SelectOneByTagName(LInputDataRec.Data2,
            LInputDataRec.Data3, LInputDataRec.Data4);

          if LCQRSRes = cqrsSuccess then
            LCQRSRes := LCmd.DeleteAllSelected;

          LPrevProjNo := LInputDataRec.Data2;
          LPrevEngNo := LInputDataRec.Data3;
          LPrevTagname := LInputDataRec.Data4;

          LEngElecPartItem.ProjectNo := LInputDataRec.Data2;
          LEngElecPartItem.EngineNo := LInputDataRec.Data3;
          LEngElecPartItem.EngSensor.TagName := LInputDataRec.Data4;

          LCQRSRes := LCmd.Add(LEngElecPartItem);
        end;//for

        LCQRSRes := LCmd.Commit;
      end;
    end
    else
    begin
      RestClient := TSQLRestClientURIDll.Create(TSQLModel.Create(RestServer.Model),@URIRequest);
      try
        RestClient.Model.Owner := RestClient;
        RestClient.ServiceDefine([IDomSensorCommand],sicClientDriven);
        USEFASTMM4ALLOC := true; // for slightly faster process
        AddItemFromAry2DB(RestClient, LDynArr, LSensorRoute);
      finally
        RestClient.Free;
      end;
    end;
  finally
    LEngElecPartItem2.Free;
    RestServer.Free;
  end;
end;

procedure TFrameDecTreeView1.SaveToDB(AUseMemDB: Boolean; ADBFileName: string);
var
  RestServer4MemDB: TSQLRestServerFullMemory;
  RestServer: TSQLRest;
  RestClient: TSQLRestClientURI;
  LStore: TSynConnectionDefinition;
begin
  if AUseMemDB then
  begin
    SaveToMemDB();
  end
  else
  begin
    SaveToFileDB(ADBFileName);
  end;
end;

procedure TFrameDecTreeView1.SaveToDB1Click(Sender: TObject);
begin
  SaveToDB(False, DefaultSensorRouteDBFileName);
end;

procedure TFrameDecTreeView1.SaveToFile1Click(Sender: TObject);
var
  LFileName: string;
begin
  SaveDialog1.Filter :=  '*.sroute';

  if SaveDialog1.Execute then
  begin
    LFileName := SaveDialog1.FileName;

    if FileExists(LFileName) then
    begin
      if MessageDlg('File is already exist. Are you overwrite? if No press, then save is cancelled.',
                                mtConfirmation, [mbYes, mbNo], 0)= mrNo then
        exit
    end;

    LFileName := ChangeFileExt(LFileName, '.sroute');
    SaveToJsonFile(LFileName);
    ShowMessage(LFileName + ' is saved!');
  end;
end;

procedure TFrameDecTreeView1.SaveToFileDB(ADBFileName: string; AUseInternalClient: Boolean);
var
  RestServer: TSQLRest;
  RestClient: TSQLRestClientURI;
  LEngElecPartItem, LEngElecPartItem2: TEngElecPartItem;
  LCmd: IDomSensorCommand;
  LCQRSRes : TCQRSResult;
  i, j, LCount: integer;
  LDataExist: Boolean;
  LPrevProjNo, LPrevEngNo, LPrevTagname, LSubTagName, LStr: string;
  LSubTagList: TStringList;
begin
  if ADBFileName = '' then
  begin
    if OpenDialog1.Execute() then
      ADBFileName := OpenDialog1.FileName;
  end;

  LPrevProjNo := '';
  LPrevEngNo := '';
  LPrevTagname := '';

  LSubTagList := TStringList.Create;

  RestServer := GetRestServerFromFileDBName(ADBFileName);
  LEngElecPartItem2 := TEngElecPartItem.Create;
  try
    if AUseInternalClient then
    begin
      RestServer.Services.Resolve(IDomSensorCommand, LCmd);

      for i := 0 to FSensorRouteAry.Count - 1 do
      begin
        LEngElecPartItem := TEngElecPartItem(FSensorRoute[i]);
        LCQRSRes := cqrsNotFound;
        LDataExist := False;

        //SubTagName = 'VLV+;SSS' 형식으로 저장됨
        if LEngElecPartItem.EngSensor.SubTagName <> '' then
        begin
          LStr := LEngElecPartItem.EngSensor.SubTagName;

          while LStr <> '' do
          begin
            LSubTagName := strToken(LStr, ';');

            if LSubTagList.IndexOf(LSubTagName) = -1 then
            begin
              LSubTagList.Add(LSubTagName);
            end;
          end;
        end;

        //TagName이 SubTagName 리스트에서 같은 값이 존재하면 DB Save Skip함
        if LSubTagList.IndexOf(LEngElecPartItem.EngSensor.TagName) >= 0 then
          Continue;

        if (LPrevProjNo <> LEngElecPartItem.ProjectNo) or
            (LPrevEngNo <> LEngElecPartItem.EngineNo) or
            (LPrevTagname <> LEngElecPartItem.EngSensor.TagName) then
        begin
          LCQRSRes := LCmd.SelectOneByTagName(LEngElecPartItem.ProjectNo,
            LEngElecPartItem.EngineNo, LEngElecPartItem.EngSensor.TagName);

          if LCQRSRes = cqrsSuccess then
          begin
            LCQRSRes := LCmd.DeleteAllSelected;
          end;
        end;

        LPrevProjNo := LEngElecPartItem.ProjectNo;
        LPrevEngNo := LEngElecPartItem.EngineNo;
        LPrevTagname := LEngElecPartItem.EngSensor.TagName;

//        if LCQRSRes <> cqrsSuccess then
//          continue;


//        if LCount > 0 then
//        begin
//          LDataExist := False;
//
//          for j := 0 to LCount - 1 do
//          begin
//            LCmd.GetNext(LEngElecPartItem2);
//
//            if (LEngElecPartItem2.CreateTime = LEngElecPartItem.CreateTime) then
//            begin
//              LCQRSRes := LCmd.Update(LEngElecPartItem);
//              LDataExist := LCQRSRes=cqrsSuccess;
//              Break;
//            end;
//          end;//for j
//        end;//if LCount > 0

        if not LDataExist then
        begin
          LCQRSRes := LCmd.Add(LEngElecPartItem);
        end;
      end;//for i

      LCQRSRes := LCmd.Commit;
    end
    else
    begin
      RestClient := TSQLRestClientURIDll.Create(TSQLModel.Create(RestServer.Model),@URIRequest);
      try
        RestClient.Model.Owner := RestClient;
        RestClient.ServiceDefine([IDomSensorCommand],sicClientDriven);
        USEFASTMM4ALLOC := true; // for slightly faster process
        AddTVItem2DB(RestClient);
      finally
        RestClient.Free;
      end;
    end;
  finally
    LSubTagList.Free;
    LEngElecPartItem2.Free;
    RestServer.Free;
  end;
end;

procedure TFrameDecTreeView1.SaveToJsonFile(AFileName: string; APassPhrase: string);
var
  LJson: string;
  LStrList: TStringList;
  LMemStream: TMemoryStream;
  Fs: TFileStream;
begin
  LStrList := TStringList.Create;
  try
    GetJsonFromTreeView(LJson);
    LStrList.Add(LJson);

    if APassPhrase = '' then
      LStrList.SaveToFile(AFileName)
    else
    begin
      LMemStream := TMemoryStream.Create;
      Fs := TFileStream.Create(AFileName, fmCreate);
      try
        LStrList.SaveToStream(LMemStream);
        LMemStream.Position := 0;
        EncryptStream(LMemStream, Fs, APassphrase);
      finally
        Fs.Free;
        LMemStream.Free;
      end;
   end;
  finally
    LStrList.Free;
  end;
end;

procedure TFrameDecTreeView1.SaveToMemDB;
var
  RestServer4MemDB: TSQLRestServerFullMemory;
  RestClient: TSQLRestClientURI;
begin
  RestServer4MemDB := TSQLRestServerFullMemory.CreateWithOwnModel([TSQLRecordEngElecPartItem]);

  try // then try from a client-server process
    RestServer4MemDB.ServiceContainer.InjectResolver([TInfraRepoSensorFactory.Create(RestServer4MemDB)],true);
    RestServer4MemDB.ServiceDefine(TInfraRepoSensor,[IDomSensorCommand,IDomSensorQuery],sicClientDriven);

    if RestServer4MemDB.ExportServer then
    begin
      RestClient := TSQLRestClientURIDll.Create(TSQLModel.Create(RestServer4MemDB.Model),@URIRequest);
      try
        RestClient.Model.Owner := RestClient;
        RestClient.ServiceDefine([IDomSensorCommand],sicClientDriven);
        USEFASTMM4ALLOC := true; // for slightly faster process
        AddTVItem2DB(RestClient);
      finally
        RestClient.Free;
      end;
    end;
  finally
    RestServer4MemDB.Free;
  end;
end;

procedure TFrameDecTreeView1.SetAppPath(APath: string);
begin
  FAppPath := APath;
end;

procedure TFrameDecTreeView1.SetFileName(const AAppPath, ADrawingFN, AManualFN: string);
begin
  FAppPath := AAppPath;
  FDrawingFileName := ADrawingFN;
  FManualFileName := AManualFN;
end;

procedure TFrameDecTreeView1.SetNodeInfo2SensorRoute(ANode: TTreeNode; AEngElecPartItem: TEngElecPartItem);
begin
  if Assigned(AEngElecPartItem) then
  begin
    AEngElecPartItem.LevelIndex := ANode.Level;
    AEngElecPartItem.AbsoluteIndex := ANode.AbsoluteIndex;
    AEngElecPartItem.ParentNodeLevel := ANode.Parent.Level;
    AEngElecPartItem.ParentNodeAbsIndex := ANode.Parent.AbsoluteIndex;
  end;
end;

procedure TFrameDecTreeView1.SetProjectInfo(AProjectNo, AEngineNo,
  ATagName, AEngParamDBName: string);
begin
  FProjectNo := AProjectNo;
  FEngineNo := AEngineNo;
  FTagName := ATagName;
  FEngParamDBName := AEngParamDBName;
end;

procedure TFrameDecTreeView1.ShowDiagram;
var
  LURL: string;
begin
  LURL := '/URL:"file://' + ExtractFilePath(Application.ExeName);
  LURL := LURL + 'Applications\Diagram\index.html"';

  ExecNewProcess2(HiMECSCefBrowserName, LURL);
//  CreateNShowSimpleBrowser(LURL);
end;

procedure TFrameDecTreeView1.ShowDiagram1Click(Sender: TObject);
begin
  ShowDiagram;
end;

procedure TFrameDecTreeView1.UpdateEngElecPartItem2Node(ANode: TTreeNode;
  AEngElecPartItem: TEngElecPartItem);
begin
  ANode.Text := GetElecPartDisplayName(AEngElecPartItem);
end;

procedure TFrameDecTreeView1.UpdateEngParameterItem2Node(ANode: TTreeNode;
  AEPItem: TEngineParameterItem);
var
  LStr: string;
begin
  ANode.Text := AEPItem.TagName;
  LStr := '{TagName:"' + AEPItem.TagName + '", TagDesc:"' + AEPItem.Description + '"}';
  ExecuteWithAllChildren2(ANode, ApplyTagName2Node, LStr);
end;

{ TEngSensorRouteTV }

constructor TEngSensorRouteTV.Create;
begin
  FSensorRouteAry.Init(TypeInfo(TEngElecPartItemObjArray), FSensorRoute);
end;

//initialization
//  TJSONSerializer.RegisterObjArrayForJSON([
//    TypeInfo(TEngSensorRouteTVObjArray), TEngSensorRouteTV
//  ]);

end.
