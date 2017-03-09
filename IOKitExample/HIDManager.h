#ifndef HIDManager_h
#define HIDManager_h

#include <vector>
using namespace std;

#include "ioHID.h"

struct HIDManager
{
  IOHIDManagerRef hid;
  vector< IOHIDDeviceRef > devices;
  IOHIDOptionsType deviceOpenOptions;
  
  HIDManager();
  ~HIDManager();
  string getDeviceType( IOHIDDeviceRef device );
  void printDeviceInfo( IOHIDDeviceRef device );
  void printDeviceElements( IOHIDDeviceRef device );
  void getAllAvailableDevices();
};

extern HIDManager* hid;

#endif

