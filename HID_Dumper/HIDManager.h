#ifndef HIDManager_h
#define HIDManager_h

#include <vector>
using namespace std;

#include "ioHID.h"
#include "IODevice.h"
#include "DeviceType.h"

struct HIDManager
{
  IOHIDManagerRef hid;
  IOMouse mouse;
  IOKeyboard kbd;
  IOGamepad gamepad;
  
  HIDManager();
  void showAllDevices();
  vector<IODevice> GetAllAvailableDevices();
  vector<IODevice> open(
    const vector<DeviceTypes::Enum>& devicesToOpen );
  ~HIDManager();
};


#endif

