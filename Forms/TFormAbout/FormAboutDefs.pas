//********************************************************************************************************************************
//*                                                                                                                              *
//*     TFormAbout 1.2 ?3delite 2006-2008                                                                                       *
//*     See TFormAbout.txt for details                                                                                           *
//*                                                                                                                              *
//* Two licenses are available if you like this component:                                                                       *
//* Shareware license: 15 Euros                                                                                                  *
//* Commercial license: 100 Euros                                                                                                *
//*                                                                                                                              *
//*     http://www.3delite.hu/Object Pascal Developer Resources/tformabout.html                                                  *
//*                                                                                                                              *
//* If you have any of the aforementioned please email: 3delite@3delite.hu                                                       *
//*                                                                                                                              *
//* Good coding! :)                                                                                                              *
//* 3delite                                                                                                                      *
//********************************************************************************************************************************

unit FormAboutDefs;

interface

uses
  Classes, Graphics, Windows, Forms, ExtCtrls, SysUtils, Dialogs, FormAbout;

type
  TOnOpenURLEvent = procedure(Sender: TObject; URL: String; var Allow: Boolean) of object;
  TOnDeclineEvent = procedure(Sender: TObject) of object;
  TOnOKClickEvent = procedure(Sender: TObject) of object;
  TOnGetRegistrationUserNameEvent = procedure(Sender: TObject; var UserName: String) of object;

//* The TFormAbout class
type
  TFormAbout = class(TComponent)
  private
    fProgramName: String;
    fCopyright: String;
    fHomePage: String;
    fEmail: String;
    fAdditionalLine1: String;
    fAdditionalLine2: String;
    fAdditionalLine3: String;
    fAdditionalURL1: String;
    fAdditionalURL2: String;
    fAdditionalURL3: String;
    fLicenseText: TStrings;
    fLogo: TImage;
    fAlphaBlendedOpen: Boolean;
    fAlphaBlendedClose: Boolean;
    fMonitorNo: Integer;
    fFontProgramName: TFont;
    fFontLinksColor: TColor;
    fFontLinksColorHot: TColor;
    fFontVersionColor: TColor;
    fDisplayProgramName: Boolean;
    fDisplayDeclineButton: Boolean;
    fDisplayRegistrationState: Boolean;
    fURLVersionFile: String;
    fURLDownload: String;
    //* Events
    eOnOpenURL: TOnOpenURLEvent;
    eOnDecline: TOnDeclineEvent;
    eOnOKClick: TOnOKClickEvent;
    eOnGetRegistrationUserName: TOnGetRegistrationUserNameEvent;
    //* Procedures
    procedure SetPicture(const Pic: TPicture);
    function GetPicture: TPicture;
    procedure SetLicenseText(LicenseText: TStrings);
  public
    FormAbout: TFormAboutBox;
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
    function ShowModal(AsSplash: Boolean): Integer;
    procedure Show(AsSplash: Boolean);
    procedure Close;
    function IsNewerVersionAvailable: Boolean;
    function IsNewerVersionAvailableDialog: Boolean;
  published
    property ProgramName: String read fProgramName write fProgramName;
    property Copyright: String read fCopyright write fCopyright;
    property HomePage: String read fHomePage write fHomePage;
    property Email: String read fEmail write fEmail;
    property AdditionalLine1: String read fAdditionalLine1 write fAdditionalLine1;
    property AdditionalLine2: String read fAdditionalLine2 write fAdditionalLine2;
    property AdditionalLine3: String read fAdditionalLine3 write fAdditionalLine3;
    property AdditionalURL1: String read fAdditionalURL1 write fAdditionalURL1;
    property AdditionalURL2: String read fAdditionalURL2 write fAdditionalURL2;
    property AdditionalURL3: String read fAdditionalURL3 write fAdditionalURL3;
    //property AlphaBlendedOpen: Boolean read fAlphaBlendedOpen write fAlphaBlendedOpen default True;
    property AlphaBlendedClose: Boolean read fAlphaBlendedClose write fAlphaBlendedClose default True;
    property MonitorNo: Integer read fMonitorNo write fMonitorNo default 0;
    property FontProgramName: TFont read fFontProgramName write fFontProgramName;
    property FontLinksColor: TColor read fFontLinksColor write fFontLinksColor default clSilver;
    property FontLinksColorHot: TColor read fFontLinksColorHot write fFontLinksColorHot default clHighlight;
    property FontVersionColor: TColor read fFontVersionColor write fFontVersionColor default clWhite;
    property Logo400x150: TPicture read GetPicture write SetPicture;
    property LicenseText: TStrings read fLicenseText write SetLicenseText;
    property DisplayProgramName: Boolean read fDisplayProgramName write fDisplayProgramName default True;
    property DisplayDeclineButton: Boolean read fDisplayDeclineButton write fDisplayDeclineButton default True;
    property DisplayRegistrationState: Boolean read fDisplayRegistrationState write fDisplayRegistrationState default True;
    property URLVersionFile: String read fURLVersionFile write fURLVersionFile;
    property URLDownload: String read fURLDownload write fURLDownload;
    //* Events
    property OnOpenURL: TOnOpenURLEvent read eOnOpenURL write eOnOpenURL;
    property OnDecline: TOnDeclineEvent read eOnDecline write eOnDecline;
    property OnOKClick: TOnOKClickEvent read eOnOKClick write eOnOKClick;
    property OnGetRegistrationUserName: TOnGetRegistrationUserNameEvent read eOnGetRegistrationUserName write eOnGetRegistrationUserName;
end;

procedure Register;

implementation

Uses Helper3delite, ShellAPI, Controls;

procedure Register;
begin
    RegisterComponents('3delite', [TFormAbout]);
end;

constructor TFormAbout.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    fFontLinksColor := clSilver;
    fFontLinksColorHot := clHighlight;
    fFontVersionColor := clWhite;
    fAlphaBlendedOpen := True;
    fAlphaBlendedClose := True;
    fMonitorNo := 0;
    fLogo := TImage.Create(Self);
    fLicenseText := TStringList.Create;
    fFontProgramName := TFont.Create;
    fFontProgramName.Color := clSilver;
    fFontProgramName.Name := 'Verdana';
    fFontProgramName.Size := 14;
    fFontProgramName.Style := fFontProgramName.Style + [fsBold];
    fDisplayProgramName := True;
    fDisplayDeclineButton := True;
    fDisplayRegistrationState := True;
end;

Destructor TFormAbout.Destroy;
begin
    try
        if Assigned(FormAbout)
            then FreeAndNil(FormAbout);
        if Assigned(fLogo)
            then FreeAndNil(fLogo);
        if Assigned(fLicenseText)
            then FreeAndNil(fLicenseText);
        if Assigned(fFontProgramName)
            then FreeAndNil(fFontProgramName);
        inherited Destroy;
    except
        //*
    end;
end;

function TFormAbout.ShowModal(AsSplash: Boolean): Integer;
begin
    Result := 0;
    try
        if NOT Assigned(FormAbout)
            then FormAbout := TFormAboutBox.Create(Self);
        if AsSplash
            then FormAbout.LogoMode
            else FormAbout.AboutMode;
        Result := FormAbout.ShowModal;
    except
        //*
    end;
end;

procedure TFormAbout.Show(AsSplash: Boolean);
begin
    try
        if NOT Assigned(FormAbout)
            then FormAbout := TFormAboutBox.Create(Self);
        if AsSplash
            then FormAbout.LogoMode
            else FormAbout.AboutMode;
        FormAbout.Show;
    except
        //*
    end;
end;

procedure TFormAbout.Close;
begin
    FormAbout.Close;
end;

function TFormAbout.GetPicture: TPicture;
begin
    Result := fLogo.Picture;
end;

procedure TFormAbout.SetPicture(const Pic : TPicture);
begin
    fLogo.Picture := Pic;
end;

procedure TFormAbout.SetLicenseText(LicenseText: TStrings);
begin
    if Assigned(fLicenseText)
        then fLicenseText.Assign(LicenseText)
        else fLicenseText := LicenseText;
end;

function TFormAbout.IsNewerVersionAvailable: Boolean;
var
  NewVerStr: String;
begin
    Result := False;
    if NOT Assigned(FormAbout)
        then FormAbout := TFormAboutBox.Create(Self);
//    try
//        NewVerStr := FormAbout.IdHTTPVersion.Get(fURLVersionFile);
//    except
//        //*
//    end;
    if IsNewerVersion(GetFileVersionStr(Application.ExeName), NewVerStr) then begin
        Result := True;
    end else begin
        Result := False;
    end;
end;

function TFormAbout.IsNewerVersionAvailableDialog: Boolean;
var
  Ver, NewVer: String;
begin
    if NOT Assigned(FormAbout)
        then FormAbout := TFormAboutBox.Create(Self);
    Result := IsNewerVersionAvailable;
    Ver := GetFileVersionStr(Application.ExeName);
//    try
//        NewVer := FormAbout.IdHTTPVersion.Get(fURLVersionFile);
//    except
//        //*
//    end;
    if Result then begin
        if MessageDlg('Newer version available!'
            + (#13#10) + 'Current version: ' + Ver
            + (#13#10) + 'Newer version: ' + NewVer
            + (#13#10) + 'Do you want to download the update now?'
            , mtInformation, [mbYes, mbNo], 0) = mrYes then begin
            ShellExecute(FormAbout.Handle, 'open', PChar(fURLDownload), nil, nil, SW_SHOWNORMAL);
        end;
    end else begin
        MessageDlg('No update available.', mtInformation, [mbOK], 0);
    end;
end;

end.
