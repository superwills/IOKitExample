#include "DeviceType.h"

map<int, string> DeviceTypes::Names = {
  { Invalid, "Invalid device" },
  { Mouse, "Mouse" },
  { Keyboard, "Keyboard" },
  { Joystick, "Joystick" },
  { Gamepad, "Gamepad" },
};

map<int, DeviceType> DeviceMap = {
  { DeviceTypes::Mouse, DeviceType( kHIDPage_GenericDesktop, kHIDUsage_GD_Mouse ) },
  { DeviceTypes::Keyboard, DeviceType( kHIDPage_GenericDesktop, kHIDUsage_GD_Keyboard ) },
  { DeviceTypes::Joystick, DeviceType( kHIDPage_GenericDesktop, kHIDUsage_GD_Joystick ) },
  { DeviceTypes::Gamepad, DeviceType( kHIDPage_GenericDesktop, kHIDUsage_GD_GamePad ) },
};

DeviceType::DeviceType()
{
  
}

DeviceType::DeviceType( const DeviceType& deviceType )
{
  dic = deviceType.dic;
  // Need to up the RETAIN count on copy
  for( map<CFStringRef, CFNumberRef>::iterator it = dic.begin(); it != dic.end(); ++it )
  {
    //printf( "%s copy tor %d, ", s, CFGetRetainCount( it->second ) );
    CFRetain( it->first );
    CFRetain( it->second );
    //printf( "%d\n", CFGetRetainCount( it->second ) );
  }
}

DeviceType::DeviceType( int iPage, int iUsage )
{
  dic[ CFSTR( kIOHIDDeviceUsagePageKey ) ] =
    CFNumberCreate( kCFAllocatorDefault, CFNumberType::kCFNumberIntType, &iPage); //MUST BE INT, not CFIndex 
  dic[ CFSTR( kIOHIDDeviceUsageKey ) ] = 
    CFNumberCreate( kCFAllocatorDefault, CFNumberType::kCFNumberIntType, &iUsage);
}

DeviceType::~DeviceType()
{
  //puts( "DeviceType DTOR" );
  for( map<CFStringRef, CFNumberRef>::iterator it = dic.begin(); it != dic.end(); ++it )
  {
    //printf( "%s dtor %d, ", s, CFGetRetainCount( it->second ) );
    CFRelease( it->first );
    CFRelease( it->second );
    //printf( "%d\n", CFGetRetainCount( it->second ) );
  }
}

