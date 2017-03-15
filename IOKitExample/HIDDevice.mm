#include "HIDDevice.h"
#include "util/util.h"
#include "util/cf.h"

/// Avoid initializer list when using a defaults() function
void HIDDevice::defaults()
{
  device = 0;
  deviceOpenOptions = kIOHIDOptionsTypeNone;
  reportBuffer.resize( BUFFER_SIZE, 0 );
}

HIDDevice::HIDDevice()
{
  defaults();
}

HIDDevice::HIDDevice( IOHIDDeviceRef iDevice, IOHIDOptionsType iDeviceOpenOptions )
{
  defaults();
  device = iDevice;
  deviceOpenOptions = iDeviceOpenOptions;
  if( open() )
  {
    getDeviceDetails();
    //print();
  }
}

HIDDevice::~HIDDevice()
{
  IOHIDDeviceUnscheduleFromRunLoop( device, CFRunLoopGetMain(), kCFRunLoopDefaultMode );
  IOHIDDeviceClose( device, deviceOpenOptions );
}

bool HIDDevice::open()
{
  // Try to open the device
  if( !ioCheck( IOHIDDeviceOpen( device, deviceOpenOptions ), "Device open" ) ) {
    puts( "Device couldn't open" );
    return false;
  }
  IOHIDDeviceScheduleWithRunLoop( device, CFRunLoopGetMain(), kCFRunLoopDefaultMode );
  return true;
}

void HIDDevice::getDeviceDetails()
{
  CFDataRef cfReportDescriptor = (CFDataRef)GetProperty( device, kIOHIDReportDescriptorKey );
  if( cfReportDescriptor )
  {
    vector<UInt8> reportDescriptor = CFDataGetData( cfReportDescriptor );
    CFRelease( cfReportDescriptor );
    ReadReportDescriptor( reportDescriptor );
    for( DeviceUsage usage : deviceUsages )
      usage.print();
  }
}

DeviceUsage HIDDevice::getUsage()
{
  DeviceUsage usage;
  
  // Find the type of device from the DeviceUsagePairs entry (array of dictionary)
  // DeviceUsagePage and DeviceUsage sometimes do appear empty in my runs,
  // but DeviceUsagePairs is filled for me.
  CFTypeRef property = GetProperty( device, kIOHIDDeviceUsagePairsKey );
  CFTypeID type = CFGetTypeID( property );
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
          if( key == kIOHIDDeviceUsagePageKey )  usage.page = val;
          else if( key == kIOHIDDeviceUsageKey )  usage.usage = val;
          else printf( "ERROR key %s isn't page,usage\n", key.c_str() );
        }
        
        printf( "Page=%d, Usage=%d\n", usage.page, usage.usage );
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
  
  return usage;
}

void HIDDevice::print()
{
  puts( "----------------------" );
  string deviceName = IOHIDDeviceGetPropertyAsString( device, kIOHIDProductKey );
  printf( "DEVICE=%s\n", deviceName.c_str() );
  
  ///*
  puts( "Properties:" );
  for( string property : ioKeys )
  {
    string value = IOHIDDeviceGetPropertyAsString( device, property );
    printf( "  - %s: %s\n", property.c_str(), value.c_str() );
  }
  
  //printElements( device );
  //*/
  puts( "----------------------" );
}

void HIDDevice::print( vector<string> keys )
{
  for( string key : keys )
  {
    string value = IOHIDDeviceGetPropertyAsString( device, key );
    printf( "  - %s: %s\n", key.c_str(), value.c_str() );
  }
}

void HIDDevice::printElements()
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
    
    //IOHIDElementCookie cookie = IOHIDElementGetCookie( elt );
    
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

void HIDDevice::ReadReportDescriptor( const vector<UInt8>& reportDescriptor )
{
  print( {  kIOHIDReportDescriptorKey  } );
  // the meaning of the bytes is on page (35) of HID1_11.pdf
  // the first of each pair is what the entry is for.
  // The second is a value.
  int reportBit = 0, // The bit we're on (translates to starting bit of the usage)
      usageMin = 0, usageMax = 0,
      reportCount = 0; // how many reports
  DeviceUsage currentUsage;
  int byteSize = 0;
  for( int i = 0; i < reportDescriptor.size(); i += 1+byteSize )
  {
    byteSize = reportDescriptor[i] & MASK_NN;
    int flag = reportDescriptor[i] & ~MASK_NN;
    //printf( "GOT %d, flag=%d, byteSize=%d", reportDescriptor[i], flag, byteSize );
    //if( !byteSize )  skip; // 0 byte field, no data (0xc0)
    
    short value = 0;
    if( byteSize == sizeof( UInt8 ) )
      value = reportDescriptor[i+1]; // whatever value is there in the [i+1]th byte
    else if( byteSize == sizeof( short ) )
    {
      // interpret as short
      if( i < reportDescriptor.size()-2 )
        value = *( (short*)( &( reportDescriptor[i+1] ) ) );
      else
        error( "The reportDescriptor doesn't have enough space for a short" );
    }
      
    //printf( " VALUE=%d\n", value );
    switch( flag )
    {
      // Found usage page
      case kUsagePage:
        printf( "kUsagePage %d\n", value ); 
        currentUsage.page = value;
        break;
      case kLogicalMin:
        printf( "logicalMin %d\n", value ); 
        currentUsage.logicalMin = value;
        break;
      case kLogicalMax:
        printf( "logicalMax %d\n", value ); 
        currentUsage.logicalMax = value;
        break;
      case kPhysicalMin:
        printf( "physicalMin %d\n", value ); 
        currentUsage.physicalMin = value;
        break;
      case kPhysicalMax:
        printf( "physicalMax %d\n", value ); 
        currentUsage.physicalMax = value; 
        break;
      case kUnitExponent:     puts( "NOTE: Skipped kUnitExponent" );    break;
      case kUnit:             puts( "NOTE: Skipped kUnit" );            break;
      case kReportSize:
        printf( "reportSizeBits %d\n", value ); 
        currentUsage.reportSizeBits = value;
        break;
      case kReportID:
        printf( "reportID %d\n", value ); 
        currentUsage.reportID = value;
        break;
      case kReportCount:
        printf( "reportCount %d\n", value ); 
        reportCount = value;
        break;
      case kPush:             puts( "NOTE: Skipped kPush" );            break;
      case kPop:              puts( "NOTE: Skipped kPop" );             break;
        
      case kUsage:
        printf( "usage %d\n", value ); 
        usageMin = usageMax = currentUsage.usage = value;
        break;
      case kUsageMin:
        printf( "usageMin %d\n", value ); 
        usageMin = value;
        break;
      case kUsageMax:
        printf( "usageMax %d\n", value ); 
        usageMax = value;
        break;
      case kDesignatorIndex:  puts( "NOTE: Skipped kDesignatorIndex" ); break;
      case kDesignatorMin:    puts( "NOTE: Skipped kDesignatorMin" );   break;
      case kDesignatorMax:    puts( "NOTE: Skipped kDesignatorMax" );   break;
      case kStringIndex:      puts( "NOTE: Skipped kStringIndex" );     break;
      case kStringMin:        puts( "NOTE: Skipped kStringMin" );       break;
      case kStringMax:        puts( "NOTE: Skipped kStringMax" );       break;
      case kDelimiter:        puts( "NOTE: Skipped kDelimiter" );       break;
        
      case kInput:
        // create (usageMax-usageMin) usages
        printf( "INPUT %d\n", value ); 
        if( usageMax - usageMin + 1 != reportCount )
        {
          error( "Error: reportCount=%d, usageMin=%d, usageMax=%d\n", reportCount, usageMin, usageMax );
        }
        for( int usage = usageMin; usage <= usageMax; usage++ )
        {
          currentUsage.startingBit = reportBit;
          reportBit += currentUsage.reportSizeBits;
          currentUsage.usage = usage;
          currentUsage.print();
          deviceUsages.push_back( currentUsage );
        }
      case kOutput:         puts( "NOTE: Skipped kOutput" );        break;
      case kFeature:        puts( "NOTE: Skipped kFeature" );       break;
      case kCollection:     puts( "NOTE: Skipped kCollection" );    break;
      case kEndCollection:  puts( "NOTE: Skipped kEndCollection" ); break;
    }
    
  }
}
