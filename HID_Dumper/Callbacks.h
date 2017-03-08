#ifndef Callbacks_h
#define Callbacks_h

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/hid/IOHIDBase.h>
#include <IOKit/hid/IOHIDKeys.h>

void hidInputReportCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );

void hidInputValueReportCallback( void * context, IOReturn result,
  void * sender, IOHIDValueRef value);

#endif /* Callbacks_h */
