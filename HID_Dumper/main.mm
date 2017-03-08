#include <CoreFoundation/CoreFoundation.h>
#include <map>
#include <vector>
#include <string>
using namespace std;

#include "cf.h"
#include "ioHID.h"

#include "HIDManager.h"
#include "IODevice.h"

#include "Callbacks.h"

int main( int argc, const char *argv[] )
{
  hid = new HIDManager();
  
  // This is all we need for the state-snapshot reports (arrays of bytes
  // with the current state of the device.) For the mouse this is like
  // something like 5 bytes of data, keyboard 8 bytes, gamepad 14 bytes
  IOHIDManagerRegisterInputReportCallback( hid->hid, hidInputReportCallback, hid );
  
  // VALUE REPORTS: For receiving inputs on specific input.
  // For the gamepad this seems to flood with constant updates from the device for
  // all elements.
  //IOHIDManagerRegisterInputValueCallback( hid->hid, hidInputValueReportCallback, 0 );
  //inputreportcallbacks sent during CFRunLoopRun()
  /*
  for( pair< IOHIDDeviceRef, IODevice* > p : hid->devices )
  {
    // For reports of data from a device
    // Size of report for DEVICE: guess 64 bytes.
    // https://developer.apple.com/library/prerelease/content/documentation/DeviceDrivers/Conceptual/HID/new_api_10_5/tn2187.html
    //IOHIDDeviceRegisterInputReportCallback( 
    //  p.first, &p.second->buffer[0], p.second->buffer.size(),
    //  hidInputReportCallback, p.first );
    
    //IOHIDDeviceRegisterInputValueCallback( p.first, hidInputValueReportCallback, p.first );
  }
  */
  // runs until the user quits the app
  CFRunLoopRun();
  
}

























