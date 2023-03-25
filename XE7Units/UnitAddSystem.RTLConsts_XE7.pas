unit UnitAddSystem.RTLConsts_XE7;

interface

resourcestring
  sSameArrays = 'Source and Destination arrays must not be the same';
  SWindowsServer2012R2 = 'Windows Server 2012 R2';
  SWindows8Point1 = 'Windows 8.1';
  SItaskbarInterfaceException = '%s interface is not supported on this OS version';
  SHookException = 'Could not hook messages, buttons and preview events will not work';
  SInitializeException = 'Could not initialize taskbar. Error: %d';
  SInstanceException = 'There is another taskbar control instance';
  SButtonsLimitException = 'Windows taskbar only supports %d buttons on preview tabs';
  SCouldNotRegisterTabException = 'Could not register tab. Error %d';
  SInvalidProgressValueException = '%d is incorrect. Should be between 0 and %d';
  SThumbPreviewException = 'Failed to set bitmap as thumbnail preview. Error: %d';
  SBitmapPreviewException = 'Failed to set bitmap as preview. Error: %d';
  SZipFileNameEmpty        = 'File name must not be empty';
  SSensorIndexError = 'The sensor on the specified index (%d) is not found';
  {$IFDEF ANDROID}
  SAssetFileNotFound = 'Cannot deploy, "%s" file not found in assets';
  {$ENDIF}
  { System.DateUtils }
  SInvalidDateString = 'Invalid date string: %s';
  SInvalidTimeString = 'Invalid time string: %s';
  SInvalidOffsetString = 'Invalid time Offset string: %s';

  { System.Devices }
  sCannotManuallyConstructDevice = 'Manual construction of TDeviceInfo is not supported'; // move to System.RTLConsts.
  sAttributeExists = 'Attribute ''%s'' already exists';
  sDeviceExists = 'Device ''%s'' already exists';

  { System.NetEncoding }
  sErrorDecodingURLText = 'Error decoding URL style (%%XX) encoded string at position %d';
  sInvalidURLEncodedChar = 'Invalid URL encoded character (%s) at position %d';
  sInvalidHTMLEncodedChar = 'Invalid HTML encoded character (%s) at position %d';

  { System.Threading }
  sStopAfterBreak = 'The Break method was previously called. Break and Stop may not be used in combination in iterations of the same loop';
  sBreakAfterStop = 'The Stop method was previously called. Break and Stop may not be used in combination in iterations of the same loop';
  sInvalidTaskConstruction = 'Cannot construct an ITask in this manner';
  sEmptyJoinTaskList = 'List of tasks to Join method empty';
  sWaitNilTask = 'At least one task in array nil';
  sCannotStartCompletedTask = 'Cannot start a task that has already completed';
  sOneOrMoreTasksCancelled = 'One or more tasks were cancelled';
  sDefaultAggregateExceptionMsg = 'One or more errors occurred';

const
  SMenuSeparator: string = '-';   // do not localize
implementation

end.
