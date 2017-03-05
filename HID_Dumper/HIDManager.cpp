#include "HIDManager.h"

HIDManager::HIDManager()
{
  hid = IOHIDManagerCreate( kCFAllocatorDefault, kIOHIDOptionsTypeNone );
  
  if( !hid )
  {
    puts( "ERROR: HID create failed" );
  }
  else
  {
    // Schedule the hid to query with the run loop
    IOHIDManagerScheduleWithRunLoop( hid,
      CFRunLoopGetCurrent(),
      kCFRunLoopDefaultMode );
  }
}

void HIDManager::showAllDevices()
{
  vector<IODevice> devices = GetAllAvailableDevices();
  for( int i = 0; i < devices.size(); i++ )
  {
    IODevice& dev = devices[i];
    
    /*
    // IOReturn IOHIDDeviceGetReport( IOHIDDeviceRef device, IOHIDReportType reportType, CFIndex reportID,
    //   uint8_t *report, CFIndex *pReportLength);
    ioCheck( IOHIDDeviceOpen( dev, kIOHIDOptionsTypeSeizeDevice ), "ioOpen" );
    //IOHIDElementGetReportSize(dev);
    CFIndex reportSize = 64;
    uint8_t* report = (uint8_t*)malloc(reportSize);
    // "USB data is transferred to and from HID devices packetized into reports. 
    //  These reports consist of one or more element fields usually contained in a hierarchy of collections."
    // https://developer.apple.com/library/mac/technotes/tn2187/_index.html
    // synchronous
    ioCheck( IOHIDDeviceGetReport( 
      devices[i],         // IOHIDDeviceRef for the HID device
      IOHIDReportType::kIOHIDReportTypeInput,   // IOHIDReportType for the report
      0,           // CFIndex for the report ID
      report,      // address of report buffer
      &reportSize ), "get report" ); // address of length of the report
      
    free( report );

    //*/
    
    //ioCheck( IOHIDDeviceClose( dev, 0 ), "ioClose" );
    
  }
}

vector<IODevice> HIDManager::GetAllAvailableDevices()
{
  // Gets all AVAILABLE devices on the PC
  // https://developer.apple.com/reference/iokit/1438371-iohidmanagersetdevicematching?language=objc
  // "Passing a NULL dictionary will result in all devices being enumerated"
  IOHIDManagerSetDeviceMatching( hid, NULL );
  
  // Opens devices specified in IOHIDManagerSetDeviceMatching() call above
  // kIOHIDOptionsTypeSeizeDevice
  if( !ioCheck( IOHIDManagerOpen(
    hid, kIOHIDOptionsTypeNone ), "IOHIDManagerOpen" ) )
  {
    puts( "ERROR: COULD NOT OPEN AN HID DEVICE" );
  }
  
  vector<IOHIDDeviceRef> deviceRefs;
  
  // Copy constructed
  CCFSet<IOHIDDeviceRef> deviceSet( IOHIDManagerCopyDevices( hid ) );
  // Can come back as NULL
  if( !deviceSet.set )
  {
    puts( "Couldn't copy devices (IOHIDManagerCopyDevices)" );
  }
  deviceRefs = deviceSet.toVector();
  
  vector<IODevice> devices;
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
        // Depending on what type of device it is, construct
        // appropriate object type
        
        devices.push_back( deviceRefs[i] );
      }
      else
        printf( "  - Device `%s` by `%s` could not be opened\n",
          IOHIDDeviceGetPropertyAsString(deviceRefs[i], kIOHIDProductKey).c_str(),
          IOHIDDeviceGetPropertyAsString(deviceRefs[i], kIOHIDManufacturerKey).c_str() );
    }
  }
  
  return devices;
}

/// Opens specified devices.
vector<IODevice> HIDManager::open(
  const vector<DeviceTypes::Enum>& devicesToOpen )
{
  // Convert to cfArray
  CCFMutableArray<CFDictionaryRef> cfArray;
  for( int i = 0; i < devicesToOpen.size(); i++ )
  {
    DeviceType &deviceType = DeviceMap[ devicesToOpen[i] ];
    CCFDictionary<CFStringRef, CFNumberRef> cfDic( deviceType.dic );
    cfArray.add( cfDic.dic );
  }
  
  IOHIDManagerSetDeviceMatchingMultiple( hid, cfArray.array );
  if( !ioCheck( IOHIDManagerOpen( hid, kIOHIDOptionsTypeNone ), "IOHIDManager Open" ) )
  {
    // IOHIDManagerOpen errors are nonfatal
  }
  
  //!!
  vector<IODevice> devices;
  return devices;
}

HIDManager::~HIDManager()
{
  IOHIDManagerClose( hid, kIOHIDOptionsTypeNone );
}

