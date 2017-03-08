#include "HIDManager.h"
#include "cf.h"

HIDManager* hid;

HIDManager::HIDManager()
{
  hid = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone );
  if( !hid )
  {
    puts( "ERROR: HID create failed" );
    return;
  }
  
  getAllAvailableDevices();
  // Schedule the hid to query with the run loop
  IOHIDManagerScheduleWithRunLoop( hid,
    CFRunLoopGetCurrent(),
    kCFRunLoopDefaultMode );
}

HIDManager::~HIDManager()
{
  IOHIDManagerUnscheduleFromRunLoop( hid, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode );
  for( pair< IOHIDDeviceRef, IODevice* > p : devices )
    delete p.second;
  IOHIDManagerClose( hid, kIOHIDOptionsTypeNone );
}

void HIDManager::getAllAvailableDevices()
{
  // Gets all AVAILABLE devices on the PC
  // https://developer.apple.com/reference/iokit/1438371-iohidmanagersetdevicematching?language=objc
  // "Passing a NULL dictionary will result in all devices being enumerated"
  IOHIDManagerSetDeviceMatching( hid, NULL );
  
  // Opens devices specified in IOHIDManagerSetDeviceMatching() call above
  // kIOHIDOptionsTypeSeizeDevice
  if( !ioCheck( IOHIDManagerOpen( hid, kIOHIDOptionsTypeNone ), "IOHIDManagerOpen" ) )
  {
    puts( "ERROR: COULD NOT OPEN AN HID DEVICE" );
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
  
  vector<IOHIDDeviceRef> deviceRefs = deviceSet.toVector();
  
  // Put the devices into IODevice object wrappers,
  for( int i = 0; i < deviceRefs.size(); i++ )
  {
    // don't keep null devices or devices that won't open
    if( deviceRefs[i] )
    {
      IODevice* device = IODevice::Make( deviceRefs[i] );
      if( device )
        devices[ deviceRefs[i] ] = device;
    }
  }
  
}
