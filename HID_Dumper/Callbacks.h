#ifndef Callbacks_h
#define Callbacks_h

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/hid/IOHIDBase.h>
#include <IOKit/hid/IOHIDKeys.h>

void hidInputReportCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );

void hidInputValueReportCallback( void * _Nullable context, IOReturn result,
  void * _Nullable sender, IOHIDValueRef value);
// IOHIDReportCallback functions
void mouseCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );
void kbdCallback( void *context, IOReturn result, void *sender, IOHIDReportType type, 
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );
void gamepadCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );

#endif /* Callbacks_h */
