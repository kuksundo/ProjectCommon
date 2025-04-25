{*******************************************************}
{                                                       }
{                Delphi Runtime Library                 }
{                                                       }
{      File: psapi.h                                    }
{      Copyright (c) 1994-1999 Microsoft Corporation    }
{      All Rights Reserved.                             }
{                                                       }
{       Translator: Embarcadero Technologies, Inc.      }
{ Copyright(c) 1995-2024 Embarcadero Technologies, Inc. }
{              All rights reserved                      }
{                                                       }
{*******************************************************}

{*******************************************************}
{       WinNT process API Interface Unit                }
{*******************************************************}

unit Winapi.PsAPI;

interface

{$ALIGN ON}
{$MINENUMSIZE 4}
{$WEAKPACKAGEUNIT OFF}

uses Winapi.Windows;

{$HPPEMIT '#include <psapi.h>'}

type
  PPointer = ^Pointer;

  TEnumProcesses = function (lpidProcess: LPDWORD; cb: DWORD; var cbNeeded: DWORD): BOOL stdcall;
  TEnumProcessModules = function (hProcess: THandle; lphModule: PHMODULE; cb: DWORD;
    var lpcbNeeded: DWORD): BOOL stdcall;
  TGetModuleBaseNameA = function (hProcess: THandle; hModule: HMODULE;
    lpBaseName: LPCSTR; nSize: DWORD): DWORD stdcall;
  TGetModuleBaseNameW = function (hProcess: THandle; hModule: HMODULE;
    lpBaseName: LPCWSTR; nSize: DWORD): DWORD stdcall;
  TGetModuleBaseName = TGetModuleBaseNameW;
  TGetModuleFileNameExA = function (hProcess: THandle; hModule: HMODULE;
    lpFilename: LPCSTR; nSize: DWORD): DWORD stdcall;
  TGetModuleFileNameExW = function (hProcess: THandle; hModule: HMODULE;
    lpFilename: LPCWSTR; nSize: DWORD): DWORD stdcall;
  TGetModuleFileNameEx = TGetModuleFileNameExW;

  {$EXTERNALSYM _MODULEINFO}
  _MODULEINFO = record
    lpBaseOfDll: Pointer;
    SizeOfImage: DWORD;
    EntryPoint: Pointer;
  end;
  {$EXTERNALSYM MODULEINFO}
  MODULEINFO = _MODULEINFO;
  {$EXTERNALSYM LPMODULEINFO}
  LPMODULEINFO = ^_MODULEINFO;
  TModuleInfo = _MODULEINFO;
  PModuleInfo = LPMODULEINFO;

  TGetModuleInformation = function (hProcess: THandle; hModule: HMODULE;
    lpmodinfo: LPMODULEINFO; cb: DWORD): BOOL stdcall;
  TEmptyWorkingSet = function (hProcess: THandle): BOOL stdcall;
  TQueryWorkingSet = function (hProcess: THandle; pv: Pointer; cb: DWORD): BOOL stdcall;
  TInitializeProcessForWsWatch = function (hProcess: THandle): BOOL stdcall;

  {$EXTERNALSYM _PSAPI_WS_WATCH_INFORMATION}
  _PSAPI_WS_WATCH_INFORMATION = record
    FaultingPc: Pointer;
    FaultingVa: Pointer;
  end;
  {$EXTERNALSYM PSAPI_WS_WATCH_INFORMATION}
  PSAPI_WS_WATCH_INFORMATION = _PSAPI_WS_WATCH_INFORMATION;
  {$EXTERNALSYM PPSAPI_WS_WATCH_INFORMATION}
  PPSAPI_WS_WATCH_INFORMATION = ^_PSAPI_WS_WATCH_INFORMATION;
  TPSAPIWsWatchInformation = _PSAPI_WS_WATCH_INFORMATION;
  PPSAPIWsWatchInformation = PPSAPI_WS_WATCH_INFORMATION;

  TGetWsChanges = function (hProcess: THandle; lpWatchInfo: PPSAPI_WS_WATCH_INFORMATION;
    cb: DWORD): BOOL stdcall;

  TGetMappedFileNameA = function (hProcess: THandle; lpv: Pointer;
    lpFilename: LPCSTR; nSize: DWORD): DWORD stdcall;
  TGetMappedFileNameW = function (hProcess: THandle; lpv: Pointer;
    lpFilename: LPCWSTR; nSize: DWORD): DWORD stdcall;
  TGetMappedFileName = TGetMappedFileNameW;
  TGetDeviceDriverBaseNameA = function (ImageBase: Pointer; lpBaseName: LPCSTR;
    nSize: DWORD): DWORD stdcall;
  TGetDeviceDriverBaseNameW = function (ImageBase: Pointer; lpBaseName: LPCWSTR;
    nSize: DWORD): DWORD stdcall;
  TGetDeviceDriverBaseName = TGetDeviceDriverBaseNameW;
  TGetDeviceDriverFileNameA = function (ImageBase: Pointer; lpFileName: LPCSTR;
    nSize: DWORD): DWORD stdcall;
  TGetDeviceDriverFileNameW = function (ImageBase: Pointer; lpFileName: LPCWSTR;
    nSize: DWORD): DWORD stdcall;
  TGetDeviceDriverFileName = TGetDeviceDriverFileNameW;

  TEnumDeviceDrivers = function (lpImageBase: PPointer; cb: DWORD;
    var lpcbNeeded: DWORD): BOOL stdcall;

  {$EXTERNALSYM _PROCESS_MEMORY_COUNTERS}
  _PROCESS_MEMORY_COUNTERS = record
    cb: DWORD;
    PageFaultCount: DWORD;
    PeakWorkingSetSize: SIZE_T;
    WorkingSetSize: SIZE_T;
    QuotaPeakPagedPoolUsage: SIZE_T;
    QuotaPagedPoolUsage: SIZE_T;
    QuotaPeakNonPagedPoolUsage: SIZE_T;
    QuotaNonPagedPoolUsage: SIZE_T;
    PagefileUsage: SIZE_T;
    PeakPagefileUsage: SIZE_T;
  end;
  {$EXTERNALSYM PROCESS_MEMORY_COUNTERS}
  PROCESS_MEMORY_COUNTERS = _PROCESS_MEMORY_COUNTERS;
  {$EXTERNALSYM PPROCESS_MEMORY_COUNTERS}
  PPROCESS_MEMORY_COUNTERS = ^_PROCESS_MEMORY_COUNTERS;
  TProcessMemoryCounters = _PROCESS_MEMORY_COUNTERS;
  PProcessMemoryCounters = ^_PROCESS_MEMORY_COUNTERS;

  _PROCESS_MEMORY_COUNTERS_EX = record
    cb: DWORD;
    PageFaultCount: DWORD;
    PeakWorkingSetSize: SIZE_T;
    WorkingSetSize: SIZE_T;
    QuotaPeakPagedPoolUsage: SIZE_T;
    QuotaPagedPoolUsage: SIZE_T;
    QuotaPeakNonPagedPoolUsage: SIZE_T;
    QuotaNonPagedPoolUsage: SIZE_T;
    PagefileUsage: SIZE_T;
    PeakPagefileUsage: SIZE_T;
    PrivateUsage: SIZE_T;
  end;
  {$EXTERNALSYM _PROCESS_MEMORY_COUNTERS_EX}
  PROCESS_MEMORY_COUNTERS_EX = _PROCESS_MEMORY_COUNTERS_EX;
  {$EXTERNALSYM PROCESS_MEMORY_COUNTERS_EX}
  PPROCESS_MEMORY_COUNTERS_EX = ^_PROCESS_MEMORY_COUNTERS_EX;
  {$EXTERNALSYM PPROCESS_MEMORY_COUNTERS_EX}
  TProcessMemoryCountersEx = _PROCESS_MEMORY_COUNTERS_EX;
  PProcessMemoryCountersEx = ^_PROCESS_MEMORY_COUNTERS_EX;

  TGetProcessMemoryInfo = function (Process: THandle;
    ppsmemCounters: PPROCESS_MEMORY_COUNTERS; cb: DWORD): BOOL stdcall;

{$EXTERNALSYM EnumProcesses}
function EnumProcesses(lpidProcess: LPDWORD; cb: DWORD; var cbNeeded: DWORD): BOOL stdcall;
{$EXTERNALSYM EnumProcessModules}
function EnumProcessModules(hProcess: THandle; lphModule: PHMODULE; cb: DWORD;
  var lpcbNeeded: DWORD): BOOL stdcall;
{$EXTERNALSYM GetModuleBaseName}
function GetModuleBaseName(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCWSTR; nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetModuleBaseNameA}
function GetModuleBaseNameA(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCSTR; nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetModuleBaseNameW}
function GetModuleBaseNameW(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCWSTR; nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetModuleFileNameEx}
function GetModuleFileNameEx(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetModuleFileNameExA}
function GetModuleFileNameExA(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCSTR; nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetModuleFileNameExW}
function GetModuleFileNameExW(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetModuleInformation}
function GetModuleInformation(hProcess: THandle; hModule: HMODULE;
  lpmodinfo: LPMODULEINFO; cb: DWORD): BOOL stdcall;
{$EXTERNALSYM EmptyWorkingSet}
function EmptyWorkingSet(hProcess: THandle): BOOL stdcall;
{$EXTERNALSYM QueryWorkingSet}
function QueryWorkingSet(hProcess: THandle; pv: Pointer; cb: DWORD): BOOL stdcall;
{$EXTERNALSYM InitializeProcessForWsWatch}
function InitializeProcessForWsWatch(hProcess: THandle): BOOL stdcall;
{$EXTERNALSYM GetMappedFileName}
function GetMappedFileName(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetMappedFileNameA}
function GetMappedFileNameA(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCSTR; nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetMappedFileNameW}
function GetMappedFileNameW(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetDeviceDriverBaseName}
function GetDeviceDriverBaseName(ImageBase: Pointer; lpBaseName: LPCWSTR;
  nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetDeviceDriverBaseNameA}
function GetDeviceDriverBaseNameA(ImageBase: Pointer; lpBaseName: LPCSTR;
  nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetDeviceDriverBaseNameW}
function GetDeviceDriverBaseNameW(ImageBase: Pointer; lpBaseName: LPCWSTR;
  nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetDeviceDriverFileName}
function GetDeviceDriverFileName(ImageBase: Pointer; lpFileName: LPCWSTR;
  nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetDeviceDriverFileNameA}
function GetDeviceDriverFileNameA(ImageBase: Pointer; lpFileName: LPCSTR;
  nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM GetDeviceDriverFileNameW}
function GetDeviceDriverFileNameW(ImageBase: Pointer; lpFileName: LPCWSTR;
  nSize: DWORD): DWORD stdcall;
{$EXTERNALSYM EnumDeviceDrivers}
function EnumDeviceDrivers(lpImageBase: PPointer; cb: DWORD;
  var lpcbNeeded: DWORD): BOOL stdcall;
{$EXTERNALSYM GetProcessMemoryInfo}
function GetProcessMemoryInfo(Process: THandle;
  ppsmemCounters: PPROCESS_MEMORY_COUNTERS; cb: DWORD): BOOL stdcall;

implementation

function InitEnumProcesses(lpidProcess: LPDWORD; cb: DWORD; var cbNeeded: DWORD): BOOL stdcall; forward;
function InitEnumProcessModules(hProcess: THandle; lphModule: PHMODULE; cb: DWORD;
  var lpcbNeeded: DWORD): BOOL stdcall; forward;
function InitGetModuleBaseName(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCWSTR; nSize: DWORD): DWORD stdcall; forward;
function InitGetModuleBaseNameA(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCSTR; nSize: DWORD): DWORD stdcall; forward;
function InitGetModuleBaseNameW(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCWSTR; nSize: DWORD): DWORD stdcall; forward;
function InitGetModuleFileNameEx(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD stdcall; forward;
function InitGetModuleFileNameExA(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCSTR; nSize: DWORD): DWORD stdcall; forward;
function InitGetModuleFileNameExW(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD stdcall; forward;
function InitGetModuleInformation(hProcess: THandle; hModule: HMODULE;
  lpmodinfo: LPMODULEINFO; cb: DWORD): BOOL stdcall; forward;
function InitEmptyWorkingSet(hProcess: THandle): BOOL stdcall; forward;
function InitQueryWorkingSet(hProcess: THandle; pv: Pointer; cb: DWORD): BOOL stdcall; forward;
function InitInitializeProcessForWsWatch(hProcess: THandle): BOOL stdcall; forward;
function InitGetMappedFileName(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD stdcall; forward;
function InitGetMappedFileNameA(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCSTR; nSize: DWORD): DWORD stdcall; forward;
function InitGetMappedFileNameW(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD stdcall; forward;
function InitGetDeviceDriverBaseName(ImageBase: Pointer; lpBaseName: LPCWSTR;
  nSize: DWORD): DWORD stdcall; forward;
function InitGetDeviceDriverBaseNameA(ImageBase: Pointer; lpBaseName: LPCSTR;
  nSize: DWORD): DWORD stdcall; forward;
function InitGetDeviceDriverBaseNameW(ImageBase: Pointer; lpBaseName: LPCWSTR;
  nSize: DWORD): DWORD stdcall; forward;
function InitGetDeviceDriverFileName(ImageBase: Pointer; lpFileName: LPCWSTR;
  nSize: DWORD): DWORD stdcall; forward;
function InitGetDeviceDriverFileNameA(ImageBase: Pointer; lpFileName: LPCSTR;
  nSize: DWORD): DWORD stdcall; forward;
function InitGetDeviceDriverFileNameW(ImageBase: Pointer; lpFileName: LPCWSTR;
  nSize: DWORD): DWORD stdcall; forward;
function InitEnumDeviceDrivers(lpImageBase: PPointer; cb: DWORD;
  var lpcbNeeded: DWORD): BOOL stdcall; forward;
function InitGetProcessMemoryInfo(Process: THandle;
  ppsmemCounters: PPROCESS_MEMORY_COUNTERS; cb: DWORD): BOOL stdcall; forward;

var
  hDLL: THandle;
  PsAPIVersion: Integer;
  _EnumProcesses: TEnumProcesses = InitEnumProcesses;
  _EnumProcessModules: TEnumProcessModules = InitEnumProcessModules;
  {function}_GetModuleBaseName: TGetModuleBaseNameW = InitGetModuleBaseName;
  {function}_GetModuleFileNameEx: TGetModuleFileNameExW = InitGetModuleFileNameEx;
  {function}_GetModuleBaseNameA: TGetModuleBaseNameA = InitGetModuleBaseNameA;
  {function}_GetModuleFileNameExA: TGetModuleFileNameExA = InitGetModuleFileNameExA;
  {function}_GetModuleBaseNameW: TGetModuleBaseNameW = InitGetModuleBaseNameW;
  {function}_GetModuleFileNameExW: TGetModuleFileNameExW = InitGetModuleFileNameExW;
  _GetModuleInformation: TGetModuleInformation = InitGetModuleInformation;
  _EmptyWorkingSet: TEmptyWorkingSet = InitEmptyWorkingSet;
  _QueryWorkingSet: TQueryWorkingSet = InitQueryWorkingSet;
  _InitializeProcessForWsWatch: TInitializeProcessForWsWatch = InitInitializeProcessForWsWatch;
  {function}_GetMappedFileName: TGetMappedFileNameW = InitGetMappedFileName;
  {function}_GetDeviceDriverBaseName: TGetDeviceDriverBaseNameW = InitGetDeviceDriverBaseName;
  {function}_GetDeviceDriverFileName: TGetDeviceDriverFileNameW = InitGetDeviceDriverFileName;
  {function}_GetMappedFileNameA: TGetMappedFileNameA = InitGetMappedFileNameA;
  {function}_GetDeviceDriverBaseNameA: TGetDeviceDriverBaseNameA = InitGetDeviceDriverBaseNameA;
  {function}_GetDeviceDriverFileNameA: TGetDeviceDriverFileNameA = InitGetDeviceDriverFileNameA;
  {function}_GetMappedFileNameW: TGetMappedFileNameW = InitGetMappedFileNameW;
  {function}_GetDeviceDriverBaseNameW: TGetDeviceDriverBaseNameW = InitGetDeviceDriverBaseNameW;
  {function}_GetDeviceDriverFileNameW: TGetDeviceDriverFileNameW = InitGetDeviceDriverFileNameW;
  _EnumDeviceDrivers: TEnumDeviceDrivers = InitEnumDeviceDrivers;
  _GetProcessMemoryInfo: TGetProcessMemoryInfo = InitGetProcessMemoryInfo;


function IsWindowsVersionOrGreater(wMajorVersion, wMinorVersion, wServicePackMajor: Word): Boolean; inline;
const
  VER_GREATER_EQUAL = 3;
  VER_MAJORVERSION = $00000002;
  VER_MINORVERSION = $00000001;
  VER_SERVICEPACKMAJOR = $00000020;
var
  osvi: TOSVersionInfoEx;
  dwlConditionMask: ULONGLONG;
begin
    FillChar(osvi, SizeOf(TOSVersionInfoEX), 0);
    osvi.dwOSVersionInfoSize := SizeOf(TOSVersionInfoEx);

    dwlConditionMask := VerSetConditionMask(
        VerSetConditionMask(
        VerSetConditionMask(
            0, VER_MAJORVERSION, VER_GREATER_EQUAL),
               VER_MINORVERSION, VER_GREATER_EQUAL),
               VER_SERVICEPACKMAJOR, VER_GREATER_EQUAL);

    osvi.dwMajorVersion := wMajorVersion;
    osvi.dwMinorVersion := wMinorVersion;
    osvi.wServicePackMajor := wServicePackMajor;

    Result := VerifyVersionInfo(osvi, VER_MAJORVERSION or VER_MINORVERSION or VER_SERVICEPACKMAJOR, dwlConditionMask);
end;

function IsWindows7OrGreater: Boolean; inline;
const
  _WIN32_WINNT_WIN7 = $0601;
begin
  Result := IsWindowsVersionOrGreater(hi(_WIN32_WINNT_WIN7), lo(_WIN32_WINNT_WIN7), 0);
end;

function LoadPsAPIProc(const APIName: string; var APIPointer: Pointer): Boolean;
var
  procAddr: Pointer;
begin
  Result := True;
  if PsAPIVersion = 0 then
  begin
    if IsWindows7OrGreater then
      PsAPIVersion := 2  // ver 2
    else
      PsAPIVersion := 1; // ver 1
  end;
  if hDLL = 0 then
  begin
    if PsAPIVersion = 1 then
      hDLL := LoadLibrary('PSAPI.dll')
    else
      hDLL := LoadLibrary('KERNEL32.dll');
    if hDLL = 0 then
      Exit(False);
  end;
  if PsAPIVersion = 1 then
    procAddr := GetProcAddress(hDLL, PChar(APIName))
  else
    procAddr := GetProcAddress(hDLL, PChar('K32' + APIName));
  if procAddr = nil then
    Exit(False);
  APIPointer := procAddr;
end;

function InitEnumProcesses(lpidProcess: LPDWORD; cb: DWORD; var cbNeeded: DWORD): BOOL;
begin
  if not LoadPsAPIProc('EnumProcesses', @_EnumProcesses) then
    Exit(False);
  Result := _EnumProcesses(lpidProcess, cb, cbNeeded);
end;

function InitEnumProcessModules(hProcess: THandle; lphModule: PHMODULE; cb: DWORD;
  var lpcbNeeded: DWORD): BOOL;
begin
  if not LoadPsAPIProc('EnumProcessModules', @_EnumProcessModules) then
    Exit(False);
  Result := _EnumProcessModules(hProcess, lphModule, cb, lpcbNeeded);
end;

function InitGetModuleBaseName(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCWSTR; nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetModuleBaseNameW', @_GetModuleBaseName) then
    Exit(0);
  Result := _GetModuleBaseName(hProcess, hModule, lpBaseName, nSize);
end;
function InitGetModuleBaseNameA(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCSTR; nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetModuleBaseNameA', @_GetModuleBaseNameA) then
    Exit(0);
  Result := _GetModuleBaseNameA(hProcess, hModule, lpBaseName, nSize);
end;
function InitGetModuleBaseNameW(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCWSTR; nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetModuleBaseNameW', @_GetModuleBaseNameW) then
    Exit(0);
  Result := _GetModuleBaseNameW(hProcess, hModule, lpBaseName, nSize);
end;

function InitGetModuleFileNameEx(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetModuleFileNameExW', @_GetModuleFileNameEx) then
    Exit(0);
  Result := _GetModuleFileNameEx(hProcess, hModule, lpFileName, nSize);
end;
function InitGetModuleFileNameExA(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCSTR; nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetModuleFileNameExA', @_GetModuleFileNameExA) then
    Exit(0);
  Result := _GetModuleFileNameExA(hProcess, hModule, lpFileName, nSize);
end;
function InitGetModuleFileNameExW(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetModuleFileNameExW', @_GetModuleFileNameExW) then
    Exit(0);
  Result := _GetModuleFileNameExW(hProcess, hModule, lpFileName, nSize);
end;

function InitGetModuleInformation(hProcess: THandle; hModule: HMODULE;
  lpmodinfo: LPMODULEINFO; cb: DWORD): BOOL;
begin
  if not LoadPsAPIProc('GetModuleInformation', @_GetModuleInformation) then
    Exit(False);
  Result := _GetModuleInformation(hProcess, hModule, lpmodinfo, cb);
end;

function InitEmptyWorkingSet(hProcess: THandle): BOOL;
begin
  if not LoadPsAPIProc('EmptyWorkingSet', @_EmptyWorkingSet) then
    Exit(False);
  Result := _EmptyWorkingSet(hProcess);
end;

function InitQueryWorkingSet(hProcess: THandle; pv: Pointer; cb: DWORD): BOOL;
begin
  if not LoadPsAPIProc('QueryWorkingSet', @_QueryWorkingSet) then
    Exit(False);
  Result := _QueryWorkingSet(hProcess, pv, cb);
end;

function InitInitializeProcessForWsWatch(hProcess: THandle): BOOL;
begin
  if not LoadPsAPIProc('InitializeProcessForWsWatch', @_InitializeProcessForWsWatch) then
    Exit(False);
  Result := _InitializeProcessForWsWatch(hProcess);
end;

function InitGetMappedFileName(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetMappedFileNameW', @_GetMappedFileName) then
    Exit(0);
  Result := _GetMappedFileName(hProcess, lpv, lpFileName, nSize);
end;

function InitGetMappedFileNameA(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCSTR; nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetMappedFileNameA', @_GetMappedFileNameA) then
    Exit(0);
  Result := _GetMappedFileNameA(hProcess, lpv, lpFileName, nSize);
end;

function InitGetMappedFileNameW(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetMappedFileNameW', @_GetMappedFileNameW) then
    Exit(0);
  Result := _GetMappedFileNameW(hProcess, lpv, lpFileName, nSize);
end;

function InitGetDeviceDriverBaseName(ImageBase: Pointer; lpBaseName: LPCWSTR;
  nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetDeviceDriverBasenameW', @_GetDeviceDriverBasename) then
    Exit(0);
  Result := _GetDeviceDriverBasename(ImageBase, lpBaseName, nSize);
end;

function InitGetDeviceDriverBaseNameA(ImageBase: Pointer; lpBaseName: LPCSTR;
  nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetDeviceDriverBasenameA', @_GetDeviceDriverBasenameA) then
    Exit(0);
  Result := _GetDeviceDriverBasenameA(ImageBase, lpBaseName, nSize);
end;

function InitGetDeviceDriverBaseNameW(ImageBase: Pointer; lpBaseName: LPCWSTR;
  nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetDeviceDriverBasenameW', @_GetDeviceDriverBasenameW) then
    Exit(0);
  Result := _GetDeviceDriverBasenameW(ImageBase, lpBaseName, nSize);
end;

function InitGetDeviceDriverFileName(ImageBase: Pointer; lpFileName: LPCWSTR;
  nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetDeviceDriverFileNameW', @_GetDeviceDriverFileName) then
    Exit(0);
  Result := _GetDeviceDriverFileName(ImageBase, lpFileName, nSize);
end;

function InitGetDeviceDriverFileNameA(ImageBase: Pointer; lpFileName: LPCSTR;
  nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetDeviceDriverFileNameA', @_GetDeviceDriverFileNameA) then
    Exit(0);
  Result := _GetDeviceDriverFileNameA(ImageBase, lpFileName, nSize);
end;

function InitGetDeviceDriverFileNameW(ImageBase: Pointer; lpFileName: LPCWSTR;
  nSize: DWORD): DWORD;
begin
  if not LoadPsAPIProc('GetDeviceDriverFileNameW', @_GetDeviceDriverFileNameW) then
    Exit(0);
  Result := _GetDeviceDriverFileNameW(ImageBase, lpFileName, nSize);
end;


function InitEnumDeviceDrivers(lpImageBase: PPointer; cb: DWORD;
  var lpcbNeeded: DWORD): BOOL;
begin
  if not LoadPsAPIProc('EnumDeviceDrivers', @_EnumDeviceDrivers) then
    Exit(False);
  Result := _EnumDeviceDrivers(lpImageBase, cb, lpcbNeeded);
end;

function InitGetProcessMemoryInfo(Process: THandle;
  ppsmemCounters: PPROCESS_MEMORY_COUNTERS; cb: DWORD): BOOL;
begin
  if not LoadPsAPIProc('GetProcessMemoryInfo', @_GetProcessMemoryInfo) then
    Exit(False);
  Result := _GetProcessMemoryInfo(Process, ppsmemCounters, cb);
end;


function EnumProcesses(lpidProcess: LPDWORD; cb: DWORD; var cbNeeded: DWORD): BOOL;
begin
  Result := _EnumProcesses(lpidProcess, cb, cbNeeded);
end;

function EnumProcessModules(hProcess: THandle; lphModule: PHMODULE; cb: DWORD;
  var lpcbNeeded: DWORD): BOOL;
begin
  Result := _EnumProcessModules(hProcess, lphModule, cb, lpcbNeeded);
end;

function GetModuleBaseName(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCWSTR; nSize: DWORD): DWORD;
begin
  Result := _GetModuleBaseName(hProcess, hModule, lpBaseName, nSize);
end;

function GetModuleBaseNameA(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCSTR; nSize: DWORD): DWORD;
begin
  Result := _GetModuleBaseNameA(hProcess, hModule, lpBaseName, nSize);
end;

function GetModuleBaseNameW(hProcess: THandle; hModule: HMODULE;
  lpBaseName: LPCWSTR; nSize: DWORD): DWORD;
begin
  Result := _GetModuleBaseNameW(hProcess, hModule, lpBaseName, nSize);
end;

function GetModuleFileNameEx(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD;
begin
  Result := _GetModuleFileNameEx(hProcess, hModule, lpFileName, nSize);
end;

function GetModuleFileNameExA(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCSTR; nSize: DWORD): DWORD;
begin
  Result := _GetModuleFileNameExA(hProcess, hModule, lpFileName, nSize);
end;

function GetModuleFileNameExW(hProcess: THandle; hModule: HMODULE;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD;
begin
  Result := _GetModuleFileNameExW(hProcess, hModule, lpFileName, nSize);
end;

function GetModuleInformation(hProcess: THandle; hModule: HMODULE;
  lpmodinfo: LPMODULEINFO; cb: DWORD): BOOL;
begin
  Result := _GetModuleInformation(hProcess, hModule, lpmodinfo, cb);
end;

function EmptyWorkingSet(hProcess: THandle): BOOL;
begin
  Result := _EmptyWorkingSet(hProcess);
end;

function QueryWorkingSet(hProcess: THandle; pv: Pointer; cb: DWORD): BOOL;
begin
  Result := _QueryWorkingSet(hProcess, pv, cb);
end;

function InitializeProcessForWsWatch(hProcess: THandle): BOOL;
begin
  Result := _InitializeProcessForWsWatch(hProcess);
end;

function GetMappedFileName(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD;
begin
  Result := _GetMappedFileName(hProcess, lpv, lpFileName, nSize);
end;

function GetMappedFileNameA(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCSTR; nSize: DWORD): DWORD;
begin
  Result := _GetMappedFileNameA(hProcess, lpv, lpFileName, nSize);
end;

function GetMappedFileNameW(hProcess: THandle; lpv: Pointer;
  lpFilename: LPCWSTR; nSize: DWORD): DWORD;
begin
  Result := _GetMappedFileNameW(hProcess, lpv, lpFileName, nSize);
end;

function GetDeviceDriverBaseName(ImageBase: Pointer; lpBaseName: LPCWSTR;
  nSize: DWORD): DWORD;
begin
  Result := _GetDeviceDriverBasename(ImageBase, lpBaseName, nSize);
end;

function GetDeviceDriverBaseNameA(ImageBase: Pointer; lpBaseName: LPCSTR;
  nSize: DWORD): DWORD;
begin
  Result := _GetDeviceDriverBasenameA(ImageBase, lpBaseName, nSize);
end;

function GetDeviceDriverBaseNameW(ImageBase: Pointer; lpBaseName: LPCWSTR;
  nSize: DWORD): DWORD;
begin
  Result := _GetDeviceDriverBasenameW(ImageBase, lpBaseName, nSize);
end;

function GetDeviceDriverFileName(ImageBase: Pointer; lpFileName: LPCWSTR;
  nSize: DWORD): DWORD;
begin
  Result := _GetDeviceDriverFileName(ImageBase, lpFileName, nSize);
end;

function GetDeviceDriverFileNameA(ImageBase: Pointer; lpFileName: LPCSTR;
  nSize: DWORD): DWORD;
begin
  Result := _GetDeviceDriverFileNameA(ImageBase, lpFileName, nSize);
end;

function GetDeviceDriverFileNameW(ImageBase: Pointer; lpFileName: LPCWSTR;
  nSize: DWORD): DWORD;
begin
  Result := _GetDeviceDriverFileNameW(ImageBase, lpFileName, nSize);
end;

function EnumDeviceDrivers(lpImageBase: PPointer; cb: DWORD;
  var lpcbNeeded: DWORD): BOOL;
begin
  Result := _EnumDeviceDrivers(lpImageBase, cb, lpcbNeeded);
end;

function GetProcessMemoryInfo(Process: THandle;
  ppsmemCounters: PPROCESS_MEMORY_COUNTERS; cb: DWORD): BOOL;
begin
  Result := _GetProcessMemoryInfo(Process, ppsmemCounters, cb);
end;

initialization

finalization
  if hDLL <> 0 then
  begin
    FreeLibrary(hDLL);
    hDLL := 0;
  end;
end.
