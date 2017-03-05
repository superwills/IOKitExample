#ifndef DeviceType_h
#define DeviceType_h

#include "cf.h"
#include "ioHID.h"

namespace DeviceTypes
{
  enum Enum
  {
    Invalid, Mouse, Keyboard, Joystick, Gamepad
  };
  extern map<int, string> Names;
}

/// Structure describing a type of device
/// (eg Mouse, Keyboard, Gamepad)
/// Manages the CF* types
struct DeviceType
{
  /// A dictionary containing the
  /// kIOHIDDeviceUsagePageKey and kIOHIDDeviceUsageKey
  /// properties
  map<CFStringRef, CFNumberRef> dic;
  DeviceType();
  DeviceType( const DeviceType& deviceType );
  DeviceType( int iPage, int iUsage );
  ~DeviceType();
};

extern map<int, DeviceType> DeviceMap;

#endif /* DeviceType_h */
