#include "HIDManager.h"
//#include <CoreFoundation/CoreFoundation.h>
#include "cf.h"
#include "ioHID.h"
#include "Callbacks.h"

HIDManager* hid;

HIDManager::HIDManager()
{
  deviceOpenOptions = kIOHIDOptionsTypeNone;
  hid = IOHIDManagerCreate( kCFAllocatorDefault, deviceOpenOptions );
  if( !hid )
  {
    puts( "ERROR: HID create failed" );
    return;
  }
  
  getAllAvailableDevices();

  IOHIDManagerRegisterInputReportCallback( hid, hidInputReportCallback, 0 );
  IOHIDManagerScheduleWithRunLoop( hid, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode );
}

HIDManager::~HIDManager()
{
  IOHIDManagerUnscheduleFromRunLoop( hid, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode );
  for( IOHIDDeviceRef device : devices ) {
    IOHIDDeviceUnscheduleFromRunLoop( device, CFRunLoopGetMain(), kCFRunLoopDefaultMode );
    IOHIDDeviceClose( device, deviceOpenOptions );
  }
  IOHIDManagerClose( hid, deviceOpenOptions );
}

string HIDManager::getDeviceType( IOHIDDeviceRef device )
{
  // Find the type of device from the DeviceUsagePairs entry (array of dictionary)
  // DeviceUsagePage and DeviceUsage sometimes do appear empty in my runs,
  // but DeviceUsagePairs is filled for me.
  CFTypeRef property = GetProperty( device, kIOHIDDeviceUsagePairsKey );
  CFTypeID type = CFGetTypeID( property );
  int page=0, usage=0;
  if( type == CFArrayGetTypeID() )
  {
    CFArrayRef cfArray = (CFArrayRef)property;
    //long count = CFArrayGetCount( cfArray );
    int i = 0; // ONLY USE ENTRY 0 (PRIMARY USAGE)
    //for( i=0 ; i < count; i++ )
    {
      CFTypeRef entry = CFArrayGetValueAtIndex( cfArray, i );
      type = CFGetTypeID( entry );
      
      if( type == CFDictionaryGetTypeID() )
      {
        CFDictionaryRef cfDic = (CFDictionaryRef)entry;
        long count = CFDictionaryGetCount( cfDic );
        vector<CFTypeRef> keys( count, 0 ), vals( count, 0 );
        CFDictionaryGetKeysAndValues( cfDic, (const void**)&keys[0], (const void**)&vals[0] );
        
        // Go thru dictionary
        for( int i = 0; i < count; i++ ) {
          string key = CFGet< string >( keys[i] );
          int val = CFGet< int >( vals[i] );
          if( key == kIOHIDDeviceUsagePageKey )  page = val;
          else if( key == kIOHIDDeviceUsageKey )  usage = val;
          else printf( "ERROR key %s isn't page,usage\n", key.c_str() );
        }
        printf( "Page=%d, Usage=%d\n", page, usage );

      }
      else
      {
        puts( "Error: The kIOHIDDeviceUsagePairsKey value isn't a DICTIONARY" );
      }
    }
  }
  else
  {
    puts( "The kIOHIDDeviceUsagePairsKey entry isn't a CFArray!" );
  }
  
  return ioUsages[ page ][ usage ];
}

void HIDManager::printDeviceInfo( IOHIDDeviceRef device )
{
  puts( "----------------------" );
  string deviceName = IOHIDDeviceGetPropertyAsString( device, kIOHIDProductKey );
  printf( "DEVICE=%s, TYPE=%s\n", deviceName.c_str(), getDeviceType( device ).c_str() );
  
  /*
  puts( "Properties:" );
  for( string property : ioKeys )
  {
    string value = IOHIDDeviceGetPropertyAsString( device, property );
    printf( "  - %s: %s\n", property.c_str(), value.c_str() );
  }
  
  printDeviceElements( device );
  */
  puts( "----------------------" );
}

void HIDManager::printDeviceElements( IOHIDDeviceRef device )
{
  // This copies ALL elements
  CCFArray< IOHIDElementRef > elts = IOHIDDeviceCopyMatchingElements(
    device, NULL, deviceOpenOptions );
    
  for( int i = 0; i < elts.size(); i++ )
  {
    IOHIDElementRef elt = elts[i];
    if( !elt ) {
      printf( "%d NULL element\n", i );
      skip;
    }
    
    // Print element info
    string eltName = CFStringGetAsString( IOHIDElementGetName( elt ) );
    IOHIDElementType eltType = IOHIDElementGetType( elt );
    string eltTypeName = ioElementTypes[ eltType ];
    
    // The ELEMENT has the page, but the device doesn't seem to have it
    // accurately much of the time..
    uint32_t page = IOHIDElementGetUsagePage( elt );
    uint32_t usage =  IOHIDElementGetUsage( elt );
    long logicalMin = IOHIDElementGetLogicalMin( elt );
    long logicalMax = IOHIDElementGetLogicalMax( elt );
    
    // tells you what report an elt will be included in
    uint32_t reportId = IOHIDElementGetReportID( elt );
    
    // how big the report is that the elt is a part of. redundant between
    uint32_t reportSize = IOHIDElementGetReportSize( elt );
    // elts that use the same reportId, but.
    
    printf( "    - Element name=`%s`: type=%d [%s], page=%d [%s], usage=%d [%s], "
      "logicalMin=%ld, logicalMax=%ld, reportId=%d, reportSize=%d\n",
      eltName.c_str(), eltType, eltTypeName.c_str(),
      page, ioPages[ page ].c_str(), usage,
      ioUsages[ page ][ usage ].c_str(),
      logicalMin, logicalMax, reportId, reportSize );
 
    
  }
}

void HIDManager::getAllAvailableDevices()
{
  // Gets all AVAILABLE devices on the PC
  // https://developer.apple.com/reference/iokit/1438371-iohidmanagersetdevicematching?language=objc
  // "Passing a NULL dictionary will result in all devices being enumerated"
  IOHIDManagerSetDeviceMatching( hid, NULL );
  
  // Opens devices specified in IOHIDManagerSetDeviceMatching() call above
  // kIOHIDOptionsTypeSeizeDevice
  if( !ioCheck( IOHIDManagerOpen( hid, deviceOpenOptions ), "IOHIDManagerOpen" ) )
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
  
  devices = deviceSet.toVector();
  
  // Put the devices into IODevice object wrappers,
  for( IOHIDDeviceRef device : devices )
  {
    if( !device ) {
      puts( "NULL device found" );
      skip;
    }
    
    // Try to open the device
    if( !ioCheck( IOHIDDeviceOpen( device, deviceOpenOptions ), "Device open" ) )
      puts( "Device couldn't open" );
    IOHIDDeviceScheduleWithRunLoop( device, CFRunLoopGetMain(), kCFRunLoopDefaultMode );
    
    printDeviceInfo( device );
  }
  
}
