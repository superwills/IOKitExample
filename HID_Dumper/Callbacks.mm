#include "Callbacks.h"
#include <IOKit/hid/IOHIDValue.h>
#include <IOKit/hid/IOHIDUsageTables.h>

void hidInputReportCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength )
{
  // Every ELEMENT can send a REPORT.
  printf( "A callback context=%p result=%d sender=%p type=%d "
    "reportID=%d reportValue=%d reportLen=%ld\n",
    context, result, sender, type, reportID, *reportValue, reportLength );
}

void hidInputValueReportCallback( void * _Nullable context, IOReturn result,
  void * _Nullable sender, IOHIDValueRef value )
{
  long intValue = IOHIDValueGetIntegerValue( value );
  double scaledValue = IOHIDValueGetScaledValue( value, kIOHIDValueScaleTypePhysical );
  printf( "A callback context=%p result=%d sender=%p value=%d floatVal=%f\n",
    context, result, sender, intValue, scaledValue );
}

/// REQUIRED: This only gets called from CFRunLoopRun(). 
/// If you're not in CFRunLoopRun(), your callback will never get called.
void mouseCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength )
{
  //printf( "\nMouse callback context=%d result=%d sender=%d type=%d reportID=%d reportValue=%d reportLen=%d",
  //  context, result, sender, type, reportID, *reportValue, reportLength );
  printf("\nM: ");
  for( int i = 0 ; i < reportLength; i++ )
  {
    printf( "[%3d] ", (char)reportValue[i] );
  }
  
  struct MouseReport{
    // x,y are DISPLACEMENTS from previous mouse pos.
    char reportID, button, x, dirX, y, dirY;
    
    bool leftButton(){ return button&kHIDUsage_Button_1; }
    bool rightButton(){ return button&kHIDUsage_Button_2; }
    bool isMovingRight(){ return dirX==0; }
    bool isMovingLeft(){ return dirX==-1; }
    bool isMovingUp(){ return dirY==-1; }
    bool isMovingDown(){ return dirY==0; }
  };
  MouseReport *mouse = (MouseReport *)reportValue;
  printf( "| x=[%3d] y=[%3d]", mouse->x, mouse->y );
  if( mouse->leftButton() )  printf( " Click" );
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
  
  //
  //
  // For interpreting the report:
  /// (On my keyboard) The keyboard report is laid out in 8 bytes like this:
  //  K: [00] [00] [00] [00] [00] [00] [00] [00]
  // The first byte is used for special key modifiers
  // The 2nd byte doesn't seem to be used on my kbd
  // the 3rd byte to the 8th byte can contain KEYS THAT ARE CURRENTLY BEING HELD DOWN.
  // Since multiple keys can be held down at the same time, up to 6 keys will show up there.
  struct KeyboardReport{
    enum ModifierKeys{ LCtrl=1, LShift=1<<1, LAlt=1<<2, Cmd=1<<3, RShift=1<<5 };
    char specialKeys, unused0, keys[6];
    
    // 6 bytes are for keys held down AT THE SAME TIME.
    // On my keyboard, if I hold more than 4 keys at the same time (with the press of a 5th key)
    // I get all 0x01 in all 6 slots (kHIDUsage_KeyboardErrorRollOver)
    bool isKey( int theKey ) {
      for( int i = 0; i < 6; i++ )
        if( keys[i] == theKey )
          return true;
      return false;
    }
    
    // LETTERS ONLY from A-Z.
    bool isKey( char theKey ) {
      int value = kHIDUsage_KeyboardA + toupper(theKey) - 'A';
      return isKey( value );
    }
    bool isNumber( int theKey ) {
      int value = kHIDUsage_Keyboard1 - 1 + theKey;
      return isKey( value );
    }
    
    bool isSpecialKey(int specialKey) { return specialKeys&specialKey; }
  };
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
  struct GamepadReport
  {
    char unused, reportId, buttons1, buttons2;
    unsigned char LTrig, RTrig;
    short L_LR, L_UD, R_LR, R_UD;
    
    enum Buttons1 {
      ButtonDUp=1,ButtonDDown=1<<1,ButtonDLeft=1<<2,ButtonDRight=1<<3,
      ButtonStart=1<<4,ButtonSelect=1<<5,ButtonLThumbPress=1<<6,ButtonRThumbPress=1<<7
    };
    enum Buttons2 {
      ButtonL=1,ButtonR=1<<1,ButtonCenter=1<<2,ButtonUnused=1<<3,
      ButtonA=1<<4,ButtonB=1<<5,ButtonX=1<<6,ButtonY=1<<7
    };
    
    bool A(){ return buttons2&ButtonA; }
    bool B(){ return buttons2&ButtonB; }
    bool X(){ return buttons2&ButtonX; }
    bool Y(){ return buttons2&ButtonY; }
    bool L(){ return buttons2&ButtonL; }
    bool R(){ return buttons2&ButtonR; }
    
    bool Select(){ return buttons1&ButtonSelect; }
    bool Start(){ return buttons1&ButtonStart; }
    bool LeftThumbPressed(){ return buttons1&ButtonLThumbPress; }
    bool RightThumbPressed(){ return buttons1&ButtonRThumbPress; }
    bool DUp(){ return buttons1&ButtonDUp; }
    bool DDown(){ return buttons1&ButtonDDown; }
    bool DLeft(){ return buttons1&ButtonDLeft; }
    bool DRight(){ return buttons1&ButtonDRight; }
  };
  
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


