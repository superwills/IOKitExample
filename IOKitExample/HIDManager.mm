#include "HIDManager.h"
#include "util/cf.h"
#include "ioHID.h"
#include "Callbacks.h"

HIDManager* hid;

HIDManager::HIDManager( IOHIDOptionsType ioOptionsBits )
{
  openOptions = ioOptionsBits;
  hid = IOHIDManagerCreate( kCFAllocatorDefault, openOptions );
  if( !hid )
  {
    puts( "ERROR: HID create failed" );
    return;
  }
  
  getAllAvailableDevices();

#if CALLBACKS_ON
  IOHIDManagerRegisterInputReportCallback( hid, hidInputReportCallback, 0 );
  //IOHIDManagerRegisterInputValueCallback( hid, hidInputValueReportCallback, 0 ) ;
#else
  puts( "CALLBACKS OFF" );
#endif

  IOHIDManagerScheduleWithRunLoop( hid, CFRunLoopGetMain(), kCFRunLoopDefaultMode );
}

HIDManager::~HIDManager()
{
  IOHIDManagerUnscheduleFromRunLoop( hid, CFRunLoopGetMain(), kCFRunLoopDefaultMode );
  for( HIDDevice* device : devices )
    delete device;
  IOHIDManagerClose( hid, openOptions );
}

void HIDManager::getAllAvailableDevices()
{
  // Gets all AVAILABLE devices on the PC
  // https://developer.apple.com/reference/iokit/1438371-iohidmanagersetdevicematching?language=objc
  // "Passing a NULL dictionary will result in all devices being enumerated"
  IOHIDManagerSetDeviceMatching( hid, NULL );
  
  // Opens devices specified in IOHIDManagerSetDeviceMatching() call above
  // kIOHIDOptionsTypeSeizeDevice
  if( !ioCheck( IOHIDManagerOpen( hid, openOptions ), "IOHIDManagerOpen" ) )
  {
    puts( "ERROR: COULD NOT OPEN HID MANAGER" );
    return;
  }
  
  // Copy constructed
  CCFSet<IOHIDDeviceRef> deviceSet( IOHIDManagerCopyDevices( hid ) );
  // Can come back as NULL
  if( !deviceSet.set )
  {
    puts( "Couldn't copy devices (IOHIDManagerCopyDevices)" );
    return;
  }
  
  // iterate the set and construct devices
  vector<IOHIDDeviceRef> hidDeviceRefs = deviceSet.toVector();
  
  // Put the devices into IODevice object wrappers,
  for( IOHIDDeviceRef device : hidDeviceRefs )
  {
    if( !device ) {
      puts( "NULL device found" );
      skip;
    }
    
    devices.push_back( new HIDDevice( device, kIOHIDOptionsTypeNone ) );
  }
}


