#ifndef HIDManager_h
#define HIDManager_h

#include <vector>
#include <map>
using namespace std;

#include "ioHID.h"
#include "IODevice.h"

struct HIDManager
{
  IOHIDManagerRef hid;
  /// Device memory address references and device mappings...
  map< IOHIDDeviceRef, IODevice* > devices;
  
  HIDManager();
  ~HIDManager();
  void getAllAvailableDevices();
};


#endif

