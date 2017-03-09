#include "Callbacks.h"
#include "cf.h"
#include "ioHID.h"
#include <IOKit/hid/IOHIDElement.h>
#include <IOKit/hid/IOHIDValue.h>
#include <IOKit/hid/IOHIDUsageTables.h>

// CONTEXT is a variable of your choice,
// 
void hidInputReportCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength )
{
  IOHIDDeviceRef device = (IOHIDDeviceRef)sender;
  
  //printf( "InputReportCallback context=%p result=%d sender=%p type=%d "
  //  "reportID=%d reportValue=%d reportLen=%ld\n",
  //  context, result, sender, type, reportID, *reportValue, reportLength );
  string name = IOHIDDeviceGetPropertyAsString( device, kIOHIDProductKey );
  printf( "Device `%-22s`: ", name.c_str() );
  for( int i = 0; i < reportLength; i++ )
    printf( "[%02x] ", reportValue[i] );
  printf("\r");
  
  printf("\nM: ");
  for( int i = 0 ; i < reportLength; i++ )
  {
    printf( "[%3d] ", (char)reportValue[i] );
  }
  
  MouseReport *mouse = (MouseReport *)reportValue;
  printf( "| x=[%3d] y=[%3d]", mouse->x, mouse->y );
  if( mouse->leftButton() )  printf( " Click" );
}

// Key inputs.. like character entry.
void hidInputValueReportCallback( void * context, IOReturn result,
  void * sender, IOHIDValueRef value )
{
  // From the value
  IOHIDElementRef elt = IOHIDValueGetElement( value );
  IOHIDDeviceRef dev = IOHIDElementGetDevice( elt ) ;
  string eltName = CFStringGetAsString( IOHIDElementGetName( elt ) );
  string deviceName = IOHIDDeviceGetPropertyAsString( dev, kIOHIDProductKey );
  long intValue = IOHIDValueGetIntegerValue( value );
  double scaledValue = IOHIDValueGetScaledValue( value, kIOHIDValueScaleTypePhysical );
  printf( "Device=%s, Element=%s ValueReportCallback context=%p result=%d sender=%p value=%ld floatVal=%f\n",
    deviceName.c_str(), eltName.c_str(), context, result, sender, intValue, scaledValue );
}

void kbdCallback( void *context, IOReturn result, void *sender, IOHIDReportType type, 
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength )
{
  // printf( "\nKeyboard callback context=%d result=%d sender=%d type=%d reportID=%d reportValue=%d reportLen=%d",
  //   context, result, sender, type, reportID, *reportValue, reportLength );
  bool nonzero=0;
  for( int i = 0 ; i < reportLength; i++ )
  {
    nonzero |= reportValue[i];
  }
  if( !nonzero ) return;
  
  printf( "\nK: " );
  for( int i = 0 ; i < reportLength; i++ )
  {
    printf( "[%02d] ", reportValue[i] );
  }
  
  // code below this line shows how to detect individual keys
  
  
  KeyboardReport *kbd = (KeyboardReport *)reportValue;

  // An example:
  if( kbd->isKey( kHIDUsage_KeyboardA ) ) printf( "A " );
  if( kbd->isKey( 'B' ) ) printf( "B " );
  if( kbd->isNumber( 5 ) ) printf( "number 5 " );
  if( kbd->isSpecialKey(KeyboardReport::LShift) )  printf( "LShift " );
  
}

void gamepadCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength )
{
  //printf( "\gamepadCallback callback context=%d result=%d sender=%d type=%d reportID=%d reportValue=%d reportLen=%d",
  //  context, result, sender, type, reportID, *reportValue, reportLength );
  
  
  printf("\nG: ");
  for( int i = 0 ; i < reportLength; i++ )
  {
    printf( "[%4d] ", (char)reportValue[i] );
  }
  
  //Interpreted: I just looked at the output given by the loop above and mapped
  //the bytes to the buttons. I couldn't find any format documentation on this,
  //and it was easy enough to map. I'm using an `Afterglow Gamepad for Xbox 360` by `Performance Designed Products`
  //so if you have another controller, these values may be wrong.
  
  GamepadReport* pad = (GamepadReport*)reportValue;
  if( pad->A() )  printf( "A " );
  if( pad->B() )  printf( "B " );
  if( pad->X() )  printf( "X " );
  if( pad->Y() )  printf( "Y " );
  if( pad->L() )  printf( "L " );
  if( pad->R() )  printf( "R " );
  
  if( pad->Select() )  printf( "select " );
  if( pad->Start() )  printf( "start " );
  if( pad->LeftThumbPressed() )  printf( "LeftThumbPressed " );
  if( pad->RightThumbPressed() )  printf( "RightThumbPressed " );
  
  if( pad->DUp() )  printf( "DUp " );
  if( pad->DDown() )  printf( "DDown " );
  if( pad->DLeft() )  printf( "DLeft " );
  if( pad->DRight() )  printf( "DRight " );
  
  printf( "[%d][%d] [%d %d] [%d %d] ", pad->LTrig, pad->RTrig,
    pad->L_LR, pad->L_UD, pad->R_LR, pad->R_UD );
}


