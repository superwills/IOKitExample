#ifndef main_h
#define main_h

void mouseCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );
void kbdCallback( void *context, IOReturn result, void *sender, IOHIDReportType type, 
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );
void gamepadCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );

#endif /* main_h */
