#ifndef HIDManager_h
#define HIDManager_h

#include <vector>
using namespace std;

#include "ioHID.h"
#include "IODevice.h"

struct HIDManager
{
  IOHIDManagerRef hid;
  vector<IODevice*> devices;
  //IOMouse mouse;
  //IOKeyboard kbd;
  //IOGamepad gamepad;
  
  HIDManager();
  vector<IODevice*> GetAllAvailableDevices();
  ~HIDManager();
};


#endif

