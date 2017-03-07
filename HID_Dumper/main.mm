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
  HIDManager hid;
  
  //inputreportcallbacks sent during CFRunLoopRun()
  vector<uint8_t> data( 64, 0 );
  for( pair< IOHIDDeviceRef, IODevice* > p : hid.devices )
  {
    //IOHIDDeviceRegisterInputReportCallback( 
    //  p.first, &data[0], data.size(), hidCallback, p.first );
    IOHIDDeviceRegisterInputValueCallback( p.first, hidInputValueReportCallback, p.first );
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

























