#include "HIDManager.h"
#include "cf.h"

HIDManager::HIDManager()
{
  hid = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone );
  
  if( !hid )
  {
    puts( "ERROR: HID create failed" );
  }
  else
  {
    GetAllAvailableDevices();
    // Schedule the hid to query with the run loop
    IOHIDManagerScheduleWithRunLoop( hid,
      CFRunLoopGetCurrent(),
      kCFRunLoopDefaultMode );
  }
}

vector<IODevice*> HIDManager::GetAllAvailableDevices()
{
  // Gets all AVAILABLE devices on the PC
  // https://developer.apple.com/reference/iokit/1438371-iohidmanagersetdevicematching?language=objc
  // "Passing a NULL dictionary will result in all devices being enumerated"
  IOHIDManagerSetDeviceMatching( hid, NULL );
  
  // Opens devices specified in
  // IOHIDManagerSetDeviceMatching() call above
  // kIOHIDOptionsTypeSeizeDevice
  if( !ioCheck( IOHIDManagerOpen(
    hid, kIOHIDOptionsTypeNone ), "IOHIDManagerOpen" ) )
  {
    puts( "ERROR: COULD NOT OPEN AN HID DEVICE" );
  }
  
  // Copy constructed
  CCFSet<IOHIDDeviceRef> deviceSet( IOHIDManagerCopyDevices( hid ) );
  // Can come back as NULL
  if( !deviceSet.set )
  {
    puts( "Couldn't copy devices (IOHIDManagerCopyDevices)" );
  }
  vector<IOHIDDeviceRef> deviceRefs = deviceSet.toVector();
  
  // Put the devices into IODevice object wrappers,
  for( int i = 0; i < deviceRefs.size(); i++ )
  {
    // don't keep null devices or devices that won't open
    if( deviceRefs[i] )
    {
      // Try to open the device
      int options = 0;// kIOHIDOptionsTypeSeizeDevice;
      if( ioCheck( IOHIDDeviceOpen( deviceRefs[i], options ), "Device open" ) )
      {
        IODevice* device = IODevice::Make( deviceRefs[i] );
        devices.push_back( device );
      }
      else
        printf( "  - Device `%s` by `%s` could not be opened\n",
          IOHIDDeviceGetPropertyAsString(deviceRefs[i], kIOHIDProductKey).c_str(),
          IOHIDDeviceGetPropertyAsString(deviceRefs[i], kIOHIDManufacturerKey).c_str() );
    }
  }
  
  return devices;
}

HIDManager::~HIDManager()
{
  IOHIDManagerClose( hid, kIOHIDOptionsTypeNone );
}

