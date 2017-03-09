#ifndef Callbacks_h
#define Callbacks_h

#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/hid/IOHIDBase.h>
#include <IOKit/hid/IOHIDKeys.h>
#include <IOKit/hid/IOHIDUsageTables.h>

void hidInputReportCallback( void *context, IOReturn result, void *sender, IOHIDReportType type,
  uint32_t reportID, uint8_t *reportValue, CFIndex reportLength );

void hidInputValueReportCallback( void * context, IOReturn result,
  void * sender, IOHIDValueRef value);

// For interpreting the report:
/// (On my keyboard) The keyboard report is laid out in 8 bytes like this:
//  K: [00] [00] [00] [00] [00] [00] [00] [00]
// The first byte is used for special key modifiers
// The 2nd byte doesn't seem to be used on my kbd
// the 3rd byte to the 8th byte can contain KEYS THAT ARE CURRENTLY BEING HELD DOWN.
// Since multiple keys can be held down at the same time, up to 6 keys will show up there.
struct KeyboardReport
{
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

struct MouseReport
{
  // x,y are DISPLACEMENTS from previous mouse pos.
  char reportID, button, x, dirX, y, dirY;
  
  bool leftButton(){ return button&kHIDUsage_Button_1; }
  bool rightButton(){ return button&kHIDUsage_Button_2; }
  bool isMovingRight(){ return dirX==0; }
  bool isMovingLeft(){ return dirX==-1; }
  bool isMovingUp(){ return dirY==-1; }
  bool isMovingDown(){ return dirY==0; }
};

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

#endif /* Callbacks_h */
