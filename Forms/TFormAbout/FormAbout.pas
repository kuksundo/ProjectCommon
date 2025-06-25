//********************************************************************************************************************************
//*                                                                                                                              *
//*     TFormAbout 1.0 ?3delite 2006                                                                                            *
//*     See TFormAbout.txt for details                                                                                           *
//*                                                                                                                              *
//* Two licenses are available if you like this component:                                                                       *
//* Registration: 15 Euros                                                                                                       *
//* Commercial license: 100 Euros                                                                                                *
//*                                                                                                                              *
//*     http://www.3delite.hu/Object Pascal Developer Resources/tformabout.html                                                  *
//*                                                                                                                              *
//* If you have any of the aforementioned please email: 3delite@3delite.hu                                                       *
//*                                                                                                                              *
//* Good coding! :)                                                                                                              *
//* 3delite                                                                                                                      *
//********************************************************************************************************************************

unit FormAbout;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls, {Buttons,} ExtCtrls, jpeg, ShellApi, {Inifiles,} SysUtils, Helper3delite;
//  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP;

const
  STR_REGISTERED        = 'Registered for %s';
  STR_UNREGISTERED      = 'Unregistered';

type
  TFormAboutBox = class(TForm)
    PanelAbout: TPanel;
    ImageLogo: TImage;
    LabelVersion: TLabel;
    LabelCopyright: TLabel;
    LabelEmail: TLabel;
    LabelHomePage: TLabel;
    LabelAdditional1: TLabel;
    ButtonOk: TButton;
    PanelBotom: TPanel;
    MemoLicense: TMemo;
    ButtonDecline: TButton;
    PanelContainer: TPanel;
    LabelAdditional2: TLabel;
    TimerFader: TTimer;
    LabelAdditional3: TLabel;
    ButtonOk2: TButton;
    LabelProgramName: TLabel;
    LabelProgramNameShadow: TLabel;
    Panel1: TPanel;
    procedure LabelHomePageClick(Sender: TObject);
    procedure LabelEmailClick(Sender: TObject);
    procedure LabelAdditional1Click(Sender: TObject);
    procedure LabelAdditional2Click(Sender: TObject);
    procedure LabelAdditional3Click(Sender: TObject);
    procedure LabelAdditional1MouseEnter(Sender: TObject);
    procedure LabelAdditional1MouseLeave(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonDeclineClick(Sender: TObject);
    procedure LabelOKClick(Sender: TObject);
    procedure TimerFaderTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
	fAOwner: TComponent;
    fxCounter: Cardinal;
    { Private declarations }
  public
    { Public declarations }
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
    procedure AboutMode;
    procedure LogoMode;
    procedure UpdateLogoPicture;
  end;

implementation

Uses FormAboutDefs;

{$R *.dfm}

Constructor TFormAboutBox.Create(AOwner: TComponent);
begin
    fAOwner := AOwner;
    inherited Create(AOwner);
    fxCounter := 0;
end;

Destructor TFormAboutBox.Destroy;
begin
    fAOwner := nil;
    inherited Destroy;
end;

procedure TFormAboutBox.LabelHomePageClick(Sender: TObject);
var
  Allow: Boolean;
begin
    Allow := True;
    if Assigned((fAOwner as TFormAbout).OnOpenURL)
        then (fAOwner as TFormAbout).OnOpenURL(Self, (fAOwner as TFormAbout).HomePage, Allow);
    if Allow
        then ShellExecute(Handle, 'open', PChar((fAOwner as TFormAbout).HomePage), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormAboutBox.LabelEmailClick(Sender: TObject);
var
  Allow: Boolean;
  em_mail : string;
begin
    Allow := True;
    if Assigned((fAOwner as TFormAbout).OnOpenURL)
        then (fAOwner as TFormAbout).OnOpenURL(Self, (fAOwner as TFormAbout).HomePage, Allow);
    if Allow then begin
        em_mail := 'mailto:' + (fAOwner as TFormAbout).Email + '?subject=' + GetFileDescriptionStr(Application.ExeName) + ' ' + GetFileVersionStr(Application.ExeName) + '&body=' + '';
        ShellExecute(Handle,'open', PChar(em_mail), nil, nil, SW_SHOWNORMAL);
    end;
end;

procedure TFormAboutBox.LabelAdditional1Click(Sender: TObject);
var
  Allow: Boolean;
begin
    Allow := True;
    if Assigned((fAOwner as TFormAbout).OnOpenURL)
        then (fAOwner as TFormAbout).OnOpenURL(Self, (fAOwner as TFormAbout).AdditionalURL1, Allow);
    if Allow
        then ShellExecute(Handle, 'open', PChar((fAOwner as TFormAbout).AdditionalURL1), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormAboutBox.LabelAdditional2Click(Sender: TObject);
var
  Allow: Boolean;
begin
    Allow := True;
    if Assigned((fAOwner as TFormAbout).OnOpenURL)
        then (fAOwner as TFormAbout).OnOpenURL(Self, (fAOwner as TFormAbout).AdditionalURL2, Allow);
    if Allow
        then ShellExecute(Handle, 'open', PChar((fAOwner as TFormAbout).AdditionalURL2), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormAboutBox.LabelAdditional3Click(Sender: TObject);
var
  Allow: Boolean;
begin
    Allow := True;
    if Assigned((fAOwner as TFormAbout).OnOpenURL)
        then (fAOwner as TFormAbout).OnOpenURL(Self, (fAOwner as TFormAbout).AdditionalURL3, Allow);
    if Allow
        then ShellExecute(Handle, 'open', PChar((fAOwner as TFormAbout).AdditionalURL3), nil, nil, SW_SHOWNORMAL);
end;

procedure TFormAboutBox.UpdateLogoPicture;
begin
    try
        ImageLogo.Picture.Assign((fAOwner as TFormAbout).Logo400x150);
        ImageLogo.Invalidate;
        ImageLogo.Update;
    except
        //*
    end;
end;

procedure TFormAboutBox.FormCreate(Sender: TObject);
begin

    Self.DoubleBuffered := True;

    UpdateLogoPicture;

    ClientHeight := PanelAbout.Height + 2;

    ButtonOk.Visible := False;
    ButtonDecline.Visible := False;

end;

procedure TFormAboutBox.LabelOKClick(Sender: TObject);
begin
    Self.ModalResult := mrOk;
    Self.Close;
end;

procedure TFormAboutBox.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
    if (fAOwner as TFormAbout).AlphaBlendedClose then begin
        //if (NOT ButtonOk.Visible) then
        repeat
            AlphaBlendValue := AlphaBlendValue - 15;
            Invalidate;
        until AlphaBlendValue < 20;
        Invalidate;
    end;
    Self.Hide;
end;

procedure TFormAboutBox.FormShow(Sender: TObject);
var
  //Inifile: TIniFile;
  //MonitorNo: Integer;
  UserName: String;
begin

    Self.AlphaBlendValue := 255;

    if (fAOwner as TFormAbout).DisplayProgramName then begin
        if (fAOwner as TFormAbout).ProgramName <> ''
            then LabelProgramName.Caption := (fAOwner as TFormAbout).ProgramName
            else LabelProgramName.Caption := GetFileDescriptionStr(Application.ExeName);
        LabelProgramName.Font.Assign((fAOwner as TFormAbout).FontProgramName);
        LabelProgramNameShadow.Caption := LabelProgramName.Caption;
        LabelProgramNameShadow.Font.Assign(LabelProgramName.Font);
        LabelProgramNameShadow.Font.Color := clBlack;
        LabelProgramName.Show;
        LabelProgramNameShadow.Show;
    end else begin
        LabelProgramName.Hide;
        LabelProgramNameShadow.Hide;
    end;

    LabelCopyright.Caption := (fAOwner as TFormAbout).Copyright;
    LabelHomePage.Caption := (fAOwner as TFormAbout).HomePage;
    LabelEmail.Caption := (fAOwner as TFormAbout).Email;

    LabelAdditional1.Caption := (fAOwner as TFormAbout).AdditionalLine1;
    LabelAdditional2.Caption := (fAOwner as TFormAbout).AdditionalLine2;
    LabelAdditional3.Caption := (fAOwner as TFormAbout).AdditionalLine3;

    MemoLicense.Lines.Text := (fAOwner as TFormAbout).LicenseText.Text;

    if (fAOwner as TFormAbout).AdditionalURL1 <> '' then begin
        LabelAdditional1.OnMouseEnter := LabelAdditional1MouseEnter;
        LabelAdditional1.OnMouseLeave := LabelAdditional1MouseLeave;
        LabelAdditional1.OnClick := LabelAdditional1Click;
        LabelAdditional1.Cursor := crHandPoint;
    end else begin
        LabelAdditional1.OnMouseEnter := nil;
        LabelAdditional1.OnMouseLeave := nil;
        LabelAdditional1.OnClick := nil;
        LabelAdditional1.Cursor := crDefault;
    end;

    if (fAOwner as TFormAbout).AdditionalURL2 <> '' then begin
        LabelAdditional2.OnMouseEnter := LabelAdditional1MouseEnter;
        LabelAdditional2.OnMouseLeave := LabelAdditional1MouseLeave;
        LabelAdditional2.OnClick := LabelAdditional2Click;
        LabelAdditional2.Cursor := crHandPoint;
    end else begin
        LabelAdditional2.OnMouseEnter := nil;
        LabelAdditional2.OnMouseLeave := nil;
        LabelAdditional2.OnClick := nil;
        LabelAdditional2.Cursor := crDefault;
    end;

    if (fAOwner as TFormAbout).AdditionalURL3 <> '' then begin
        LabelAdditional3.OnMouseEnter := LabelAdditional1MouseEnter;
        LabelAdditional3.OnMouseLeave := LabelAdditional1MouseLeave;
        LabelAdditional3.OnClick := LabelAdditional3Click;
        LabelAdditional3.Cursor := crHandPoint;
    end else begin
        LabelAdditional3.OnMouseEnter := nil;
        LabelAdditional3.OnMouseLeave := nil;
        LabelAdditional3.OnClick := nil;
        LabelAdditional3.Cursor := crDefault;
    end;

    if (fAOwner as TFormAbout).DisplayRegistrationState then begin
        UserName := '';
        if Assigned((fAOwner as TFormAbout).OnGetRegistrationUserName)
            then (fAOwner as TFormAbout).OnGetRegistrationUserName(Self, UserName);

        if UserName <> ''
            then LabelVersion.Caption := GetFileVersionStr(Application.ExeName) + ' ' + Format(STR_REGISTERED, [UserName])
            else LabelVersion.Caption := GetFileVersionStr(Application.ExeName) + ' ' + STR_UNREGISTERED;
    end;

    ButtonDecline.Visible := (fAOwner as TFormAbout).DisplayDeclineButton;

    LabelCopyright.Font.Color := (fAOwner as TFormAbout).FontLinksColor;
    LabelHomePage.Font.Color := (fAOwner as TFormAbout).FontLinksColor;
    LabelEmail.Font.Color := (fAOwner as TFormAbout).FontLinksColor;

    LabelAdditional1.Font.Color := (fAOwner as TFormAbout).FontLinksColor;
    LabelAdditional2.Font.Color := (fAOwner as TFormAbout).FontLinksColor;
    LabelAdditional3.Font.Color := (fAOwner as TFormAbout).FontLinksColor;

    LabelVersion.Font.Color := (fAOwner as TFormAbout).FontVersionColor;

    if (fAOwner as TFormAbout).MonitorNo <> 0 then begin
        try
            if (Screen.MonitorCount >= (fAOwner as TFormAbout).MonitorNo) then begin
                MakeFullyVisible(Screen.Monitors[(fAOwner as TFormAbout).MonitorNo]);
                Update;
            end;
        except
            //*
        end;
    end;
    Left := (Screen.Width - Width) div 2;
    Top := (Screen.Height - Height) div 2;
end;

procedure TFormAboutBox.LogoMode;
begin
  	ButtonOk.Visible := False;
    ButtonDecline.Visible := False;
    ButtonOk2.Visible := False;

    PanelBotom.Hide;

    ClientHeight := PanelAbout.Height + 2;

    TimerFader.Enabled := True;
    fxCounter := 0;
end;

procedure TFormAboutBox.AboutMode;
begin

    if (fAOwner as TFormAbout).LicenseText.Text = '' then begin
        LogoMode;
        ButtonOk.Visible := True;
        ButtonOk2.Visible := True;
        Exit;
    end;

  	ButtonOk.Visible := True;
    ButtonDecline.Visible := True;

    PanelBotom.Show;
    ClientHeight := 472;

    ButtonOk2.Visible := False;

    TimerFader.Enabled := True;
    fxCounter := 0;
end;

procedure TFormAboutBox.ButtonDeclineClick(Sender: TObject);
begin
    Self.ModalResult := mrNo;
	if Assigned((fAOwner as TFormAbout).OnDecline)
        then (fAOwner as TFormAbout).OnDecline(Self);
end;

procedure TFormAboutBox.LabelAdditional1MouseEnter(Sender: TObject);
begin
    (Sender as TLabel).Font.Color := (fAOwner as TFormAbout).FontLinksColorHot;
end;

procedure TFormAboutBox.LabelAdditional1MouseLeave(Sender: TObject);
begin
    (Sender as TLabel).Font.Color := (fAOwner as TFormAbout).FontLinksColor;
end;

procedure TFormAboutBox.TimerFaderTimer(Sender: TObject);
begin
    Inc(fxCounter);

    if LabelCopyright.Font.Color < (fAOwner as TFormAbout).FontLinksColor
        then LabelCopyright.Font.Color := LabelCopyright.Font.Color + $1A1A1A;
    if fxCounter > 3
        then if LabelHomePage.Font.Color < (fAOwner as TFormAbout).FontLinksColor
            then LabelHomePage.Font.Color := LabelHomePage.Font.Color + $1A1A1A;
    if fxCounter > 6
        then if LabelEmail.Font.Color < (fAOwner as TFormAbout).FontLinksColor
            then LabelEmail.Font.Color := LabelEmail.Font.Color + $1A1A1A;

    if fxCounter > 9
        then if LabelAdditional1.Font.Color < (fAOwner as TFormAbout).FontLinksColor
            then LabelAdditional1.Font.Color := LabelAdditional1.Font.Color + $1A1A1A;
    if fxCounter > 12
        then if LabelAdditional2.Font.Color < (fAOwner as TFormAbout).FontLinksColor
            then LabelAdditional2.Font.Color := LabelAdditional2.Font.Color + $1A1A1A;
    if fxCounter > 15
        then if LabelAdditional3.Font.Color < (fAOwner as TFormAbout).FontLinksColor
            then LabelAdditional3.Font.Color := LabelAdditional3.Font.Color + $1A1A1A;

end;

procedure TFormAboutBox.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    TimerFader.Enabled := False;

    LabelCopyright.Font.Color := (fAOwner as TFormAbout).FontLinksColor;
    LabelHomePage.Font.Color := (fAOwner as TFormAbout).FontLinksColor;
    LabelEmail.Font.Color := (fAOwner as TFormAbout).FontLinksColor;

    LabelAdditional1.Font.Color := (fAOwner as TFormAbout).FontLinksColor;
    LabelAdditional2.Font.Color := (fAOwner as TFormAbout).FontLinksColor;
    LabelAdditional3.Font.Color := (fAOwner as TFormAbout).FontLinksColor;

    Invalidate;
end;


end.

