unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FormAboutDefs, StdCtrls, JPG, jpeg;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    FormAbout1: TFormAbout;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormAbout1GetRegistrationUserName(Sender: TObject;
      var UserName: String);
    procedure FormAbout1Decline(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
    //* Show our about dialog
    FormAbout1.Show(False);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
    //* Check for an update
    //* You need to set English (!) Version Information for project and create a text file at the specified address which simply contains the
    //* latest version in format: x.y.z.q
    FormAbout1.URLVersionFile := 'http://www.3delite.hu/TFormAbout/verdescription.txt';
    if FormAbout1.IsNewerVersionAvailable
        then MessageDlg('Newer version available!', mtInformation, [mbOK], 0)
        else MessageDlg('No update available!', mtInformation, [mbOK], 0);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
    //* Check for an update with dialog
    //* You need to set English (!) Version Information for project and create a text file at the specified address which simply contains the
    //* latest version in format: x.y.z.q
    //* You have to set URLDownload also for the dialog to work
    FormAbout1.URLVersionFile := 'http://www.3delite.hu/TFormAbout/verdescription.txt';
    FormAbout1.URLDownload := 'http://www.3delite.hu/Object%20Pascal%20Developer%20Resources/download.html#tformabout';
    FormAbout1.IsNewerVersionAvailableDialog;
end;

procedure TForm1.FormAbout1GetRegistrationUserName(Sender: TObject; var UserName: String);
begin
    UserName := '3delite';
end;

procedure TForm1.FormAbout1Decline(Sender: TObject);
begin
    Application.Terminate;
end;

end.
