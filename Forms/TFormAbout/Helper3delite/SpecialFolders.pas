unit SpecialFolders;

interface

const
  CSIDL_INTERNET                      = $0001;
  CSIDL_PROGRAMS                      = $0002;
  CSIDL_CONTROLS                      = $0003;
  CSIDL_PRINTERS                      = $0004;
  CSIDL_PERSONAL                      = $0005;
  CSIDL_FAVORITES                     = $0006;
  CSIDL_STARTUP                       = $0007;
  CSIDL_RECENT                        = $0008;
  CSIDL_SENDTO                        = $0009;
  CSIDL_BITBUCKET                     = $000a;
  CSIDL_STARTMENU                     = $000b;
  
  CSIDL_MYMUSIC                       = $000d;
  CSIDL_MYVIDEO                       = $000e;

  CSIDL_DESKTOPDIRECTORY              = $0010;
  CSIDL_DRIVES                        = $0011;
  CSIDL_NETWORK                       = $0012;
  CSIDL_NETHOOD                       = $0013;
  CSIDL_FONTS                         = $0014;
  CSIDL_TEMPLATES                     = $0015;
  CSIDL_COMMON_STARTMENU              = $0016;
  CSIDL_COMMON_PROGRAMS               = $0017;
  CSIDL_COMMON_STARTUP                = $0018;
  CSIDL_COMMON_DESKTOPDIRECTORY       = $0019;
  CSIDL_APPDATA                       = $001a;
  CSIDL_PRINTHOOD                     = $001b;
  CSIDL_ALTSTARTUP                    = $001d;
  CSIDL_COMMON_ALTSTARTUP             = $001e;
  CSIDL_COMMON_FAVORITES              = $001f;
  CSIDL_INTERNET_CACHE                = $0020;
  CSIDL_COOKIES                       = $0021;
  CSIDL_HISTORY                       = $0022;
  CSIDL_COMMON_APPDATA                = $0023;
  CSIDL_WINDOWS                       = $0024;
  CSIDL_SYSTEM                        = $0025;
  CSIDL_PROGRAM_FILES                 = $0026;
  CSIDL_MYPICTURES                    = $0027;
  CSIDL_PROFILE                       = $0028;
  CSIDL_SYSTEMX86                     = $0029;
  CSIDL_PROGRAM_FILESX86              = $002A;
  CSIDL_PROGRAM_FILES_COMMON          = $002B;
  CSIDL_PROGRAM_FILES_COMMONX86       = $002C;
  CSIDL_COMMON_TEMPLATES              = $002D;
  CSIDL_COMMON_DOCUMENTS              = $002E;
  CSIDL_COMMON_ADMINTOOLS             = $002F;
  CSIDL_ADMINTOOLS                    = $0030;
  CSIDL_CONNECTIONS                   = $0031;
  CSIDL_COMMON_MUSIC                  = $0035;
  CSIDL_COMMON_PICTURES               = $0036;
  CSIDL_COMMON_VIDEO                  = $0037;
  CSIDL_RESOURCES                     = $0038;
  CSIDL_RESOURCES_LOCALIZED           = $0039;
  CSIDL_COMMON_OEM_LINKS              = $003A;
  CSIDL_CDBURN_AREA                   = $003B;
  CSIDL_COMPUTERSNEARME               = $003D;
  //* Vista?
  CSIDL_PLAYLISTS                     = $003f;
  CSIDL_PHOTOALBUMS                   = $0045;

  CSIDL_FLAG_PER_USER_INIT            = $00800;
  CSIDL_FLAG_NO_ALIAS                 = $001000;
  CSIDL_FLAG_DONT_VERIFY              = $004000;
  CSIDL_FLAG_CREATE                   = $008000;
  CSIDL_FLAG_MASK                     = $00FF00;

function GetSpecialFolder(folderID: integer ): string;

implementation

uses Windows, {SysUtils, ShellAPI,} ShlObj, ActiveX;//, FilesystemDialogsDefs;

function GetSpecialFolder(folderID: Integer): string;
var
  pidl: PItemIDList;
  buf: array[0..255] of char;//FD_MAX_PATH
begin
    Result := '';
    if Succeeded(ShGetSpecialFolderLocation(GetActiveWindow, folderID, pidl)) then begin
        if ShGetPathfromIDList(pidl, buf)
            then Result := buf;
        CoTaskMemFree(pidl);
    end;
end;

end.
