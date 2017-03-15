#ifndef HIDManager_h
#define HIDManager_h

#include <vector>
using namespace std;

#include "DeviceUsage.h"
#include "ioHID.h"

struct HIDManager
{
  IOHIDManagerRef hid;
  vector< IOHIDDeviceRef > devices;
  IOHIDOptionsType deviceOpenOptions;
  
  HIDManager();
  ~HIDManager();
  string getDeviceType( IOHIDDeviceRef device );
  
  /// Gets primary device usage from CFDictionary inside the properties.
  DeviceUsage getDeviceUsage( IOHIDDeviceRef device );
  void printDeviceInfo( IOHIDDeviceRef device );
  void printDeviceElements( IOHIDDeviceRef device );
  void getAllAvailableDevices();
};

extern HIDManager* hid;

/// Make raw pointers to the data report to interpret as mouse
struct Mouse
{
  //unsigned char a,b,c,d,e;
};

struct Keyboard
{
};

struct Gamepad
{
};

#endif

