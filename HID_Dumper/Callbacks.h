#ifndef Callbacks_h
#define Callbacks_h

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/hid/IOHIDKeys.h>


void hidCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );

// IOHIDReportCallback functions
void mouseCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );
void kbdCallback( void *context, IOReturn result, void *sender, IOHIDReportType type, 
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );
void gamepadCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );

#endif /* Callbacks_h */
