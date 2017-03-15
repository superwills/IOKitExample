#ifndef HIDManager_h
#define HIDManager_h

#include <vector>
using namespace std;

#include "DeviceUsage.h"
#include "ioHID.h"
#include "HIDDevice.h"

#define CALLBACKS_ON 0

struct HIDManager
{
  IOHIDManagerRef hid;
  int openOptions;
  vector< HIDDevice* > devices;
  
  HIDManager( IOHIDOptionsType ioOptionsBits );
  ~HIDManager();
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

