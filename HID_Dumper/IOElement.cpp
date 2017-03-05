#include "IOElement.h"

void IOElement::defaults()
{
  deviceOwner=0;
  elt=0;
  type=(IOHIDElementType)0;
  
  name=typeName="uninit";
  page=usage=0;
  deviceType = DeviceTypes::Invalid;
  logicalMin=logicalMax=0;
  reportId=reportSize=0;
  value=0;
}

IOElement::IOElement()
{
  defaults();
}

IOElement::IOElement( IOHIDDeviceRef iOwner, IOHIDElementRef iElement )
{
  defaults();
  deviceOwner = iOwner;
  elt = iElement;
  if( !elt ) return;
  
  // See http://www.gamedev.net/topic/620920-solved-mapping-problem-with-osx-gamepad-controls-via-hidmanager/
  name = CFStringGetAsString( IOHIDElementGetName( elt ) ); // unfortunately empty most of the time
  type = IOHIDElementGetType( elt );
  typeName = ioElementTypes[type];
  page = getPage();
  usage = getUsage();
  logicalMin = IOHIDElementGetLogicalMin(elt);
  logicalMax = IOHIDElementGetLogicalMax(elt);
  reportId = IOHIDElementGetReportID( elt ); //tells you what report an elt will be included in
  reportSize = IOHIDElementGetReportSize( elt ); // how big the report is that the elt is a part of. redundant between
  // elts that use the same reportId, but.
  
  // The first element in an HID device listing is usually the "PAGE".
  // If you look in IOHIDUsageTables.h (or see http://www.usb.org/developers/devclass_docs/Hut1_11.pdf )
  // basically you have WHAT THIS DEVICE IS MEANT TO BE USED FOR.  When the "PAGE" is
  // set to kHIDPage_GenericDesktop, the "USAGE" will be "WHAT THE DEVICE IS FOR REALLY",
  // usually Mouse, Keyboard etc.  Once you know the "USAGE", the OTHER elts 
  if( page == kHIDPage_GenericDesktop )
  {
    switch(usage)
    {
      case kHIDUsage_GD_Mouse:
        deviceType = DeviceTypes::Mouse;
        break;
      case kHIDUsage_GD_Keyboard:
        deviceType = DeviceTypes::Keyboard;
        break;
      case kHIDUsage_GD_Joystick:
        deviceType = DeviceTypes::Joystick;
        break;
      case kHIDUsage_GD_GamePad:
        deviceType = DeviceTypes::Gamepad;
        break;
      default:
        //none of the above
        printf( "A <<generic desktop elt>>, typename=%s usage=%x, in report=%ld [%d]\n",
               typeName.c_str(), usage, reportId, reportSize );
        break;
    }
  }
  else if( page == kHIDPage_KeyboardOrKeypad )
  {
    //printf( "KEYBOARD KEY report on page %d\n", IOHIDElementGetReportID(elt) );
    printf( "A keyboard KEY, usage=%x, in report=%ld [%d]\n", usage, reportId, reportSize );
  }
  else if( page == kHIDPage_Button )
  {
    // It's some kind of BUTTON.
    printf( "BUTTON, usage=%x in report=%ld [%d]\n", usage, reportId, reportSize );
  }
    
  //IOHIDValueRef pValue;
  //ioCheck( IOHIDDeviceGetValue( devices[i], elts[j], &pValue ), "getval" );
  
}

void IOElement::update()
{
  if( !elt ) return;
  IOHIDValueRef vr = 0;
  IOHIDDeviceGetValue( deviceOwner, elt, &vr );
  if( vr )
  {
    //double scaled=IOHIDValueGetScaledValue(valueRef,kIOHIDValueScaleTypePhysical);
    value=(int)IOHIDValueGetIntegerValue(vr);
  }
}
