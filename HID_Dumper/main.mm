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

int main( int argc, const char *	argv[] )
{
  HIDManager hid;
  
  //inputreportcallbacks sent during CFRunLoopRun()

  for( int i = 0; i < hid.devices.size(); i++ )
  {
    IODevice *device = hid.devices[i];
    //uint8_t *report = (uint8_t *)malloc( device->properties.reportSize );
    //IOHIDDeviceRegisterInputReportCallback( device, report, reportSize, &callback, 0 );
  }
  
  //uint8_t *kbdReport = (uint8_t *)malloc( 8 );
  //IOHIDDeviceRegisterInputReportCallback(hid.kbd.device, kbdReport, 8, &kbdCallback, 0);
  
  ///uint8_t *gamepadReport = (uint8_t *)malloc( 64 );
  ///IOHIDDeviceRegisterInputReportCallback(hid.gamepad.dev, gamepadReport, 64, &gamepadCallback, 0);
  
  // There are 2 ways to get input that I could find:
  puts( " *** PUSH ANY KEY OR MOVE THE MOUSE ***" );
  CFRunLoopRun(); // this will go on forever until the user quits the app
  
  //free( mouseReport );
  //free( kbdReport );
  //free( gamepadReport );
  

}

























