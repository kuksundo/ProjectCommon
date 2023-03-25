{*******************************************************}
{                                                       }
{           CodeGear Delphi Runtime Library             }
{                                                       }
{ Copyright(c) 1995-2014 Embarcadero Technologies, Inc. }
{                                                       }
{*******************************************************}

unit System.JSONConsts;

interface

resourcestring
  SCannotCreateObject = 'The input value is not a valid Object';
  SUTF8Start = 'UTF8: A start byte not followed by enough continuation bytes in position %s';
  SUTF8UnexpectedByte = 'UTF8: An unexpected continuation byte in %s-byte UTF8 in position %s';
  SUTF8InvalidHeaderByte = 'UTF8: Type cannot be determined out of header byte at position %s';
  SFieldValueMissing = 'Internal: Field %s has no serialized value';
  SFieldExpected = 'Internal: Field %s conversion is incomplete';
  SArrayExpected = 'Internal: Array expected instead of %s';
  SValueExpected = 'Internal: JSON value expected instead of %s';
  SNoArray = 'Internal: Array expected instead of nil';
  STypeExpected = 'Internal: Type expected';
  STypeFieldsPairExpected = 'Internal: Type fields pair expected';
  SInvalidContext = 'Internal: Current context cannot accept a value';
  SObjectExpectedForPair = 'Internal: Object context expected when processing a pair';
  SInvalidContextForPair = 'Internal: Current context cannot accept a pair';
  SNoConversionForType = 'Internal: No conversion possible for type: %s';
  SInconsistentConversion = 'Internal: Conversion failed, converted object is most likely incomplete';
  STypeNotSupported = 'Internal: Type %s is not currently supported';
  SNoTypeInterceptorExpected = 'Field attribute should provide a field interceptor instead of a type one on field %s';

  SCannotCreateType = 'Internal: Cannot instantiate type %s';
  SObjectNotFound = 'Internal: Object type %s not found for id: %s';
  SUnexpectedPairName = 'Internal: Invalid pair name %s: expected %s or %s';
  SObjectExpectedInArray = 'Object expected at position %d in JSON array %s';
  SStringExpectedInArray = 'String expected at position %d in JSON array %s';
  SNoFieldFoundForType = 'Internal: Field %s cannot be found in type %s';
  SArrayExpectedForField = 'JSON array expected for field %s in JSON %s';
  SObjectExpectedForField = 'JSON object expected for field %s in JSON %s';
  SInvalidJSONFieldType = 'Un-marshaled array cannot be set as a field value. A reverter may be missing for field %s of %s';
  SNoValueConversionForField = 'Internal: Value %s cannot be converted to be assigned to field %s in type %s';
  SInvalidTypeForField = 'Cannot set value for field %s as it is expected to be an array instead of %s';
  SNoConversionAvailableForValue = 'Value %s cannot be converted into %s. You may use a user-defined reverter';
  SValueNotFound = 'Value ''%s'' not found';
  SCannotConvertJSONValueToType = 'Conversion from %0:s to %1:s is not supported';
  SEndOfPath = 'End of path';
  SErrorInPath = 'Error in path';

implementation

end.
