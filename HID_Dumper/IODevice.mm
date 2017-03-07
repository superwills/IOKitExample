#include "IODevice.h"
#include "cf.h"

/// An object-representation of an IO device: 
IODevice::IODevice() : device( 0 ){}
IODevice::IODevice( IOHIDDeviceRef iDevice ) :
  device( iDevice )
{
  if( !device )
  {
    puts( "NULL device construction!" );
    return;
  }
  
  // Try to open the device
  int options = kIOHIDOptionsTypeNone;// kIOHIDOptionsTypeSeizeDevice;
  if( !ioCheck( IOHIDDeviceOpen( device, options ), "Device open" ) )
    puts( "Device couldn't open" );
  
  readProperties();
  readElements();
  IOHIDDeviceScheduleWithRunLoop( device, CFRunLoopGetMain(), kCFRunLoopDefaultMode );
  
  // debug out
  puts( "======================" );
  for( pair<string,string> p : properties )
    printf( "  - %s: %s\n", p.first.c_str(), p.second.c_str() );
  printf( "ELEMENT COLLECTIONS:\n    - %lu misc\n    - %lu buttons\n    - %lu axes\n"
    "    - %lu scancodes\n    - %lu outputs\n    - %lu collections\n    - %lu features\n",
    misc.size(), buttons.size(), axes.size(),
    scancodes.size(), outputs.size(), collections.size(), features.size() );
    
  // Dump each collection
  dumpCollection( "misc", misc );
  dumpCollection( "buttons", buttons );
  dumpCollection( "axes", axes );
  dumpCollection( "scancodes", scancodes );
  dumpCollection( "outputs", outputs );
  dumpCollection( "collections", collections );
  dumpCollection( "features", features );
  puts( "----------------------" );
}

IODevice::~IODevice()
{
  IOHIDDeviceUnscheduleFromRunLoop( device, CFRunLoopGetMain(), kCFRunLoopDefaultMode );
  IOHIDDeviceClose( device, kIOHIDOptionsTypeNone );
}

IODevice* IODevice::Make( IOHIDDeviceRef iDevice )
{
  if( !iDevice )
  {
    puts( "NULL device construction!" );
    return 0;
  }
  
  // * may concrete type devices to IOMouse, IOKeyboard etc.
  // For now you just get a IODevice object.
  // Depending on what type of device it is, construct
  // appropriate object type
  // Read some of the basic properties of the device.
  return new IODevice( iDevice );
}
  
void IODevice::dumpCollection( string collectionName, const vector<IOElement>& elts )
{
  printf( "IOElements in %s/%s:\n",
    properties[kIOHIDProductKey].c_str(), collectionName.c_str() );
  // Dump each collection
  for( int i = 0; i < elts.size(); i++ )
    elts[i].properties.print();
}

void IODevice::readProperties()
{
  for( string property : ioKeys )
    properties[ property ] = IOHIDDeviceGetPropertyAsString( device, property );
}

void IODevice::readElements()
{
  // This copies ALL elements
  CCFArray<IOHIDElementRef> hidElts = 
    IOHIDDeviceCopyMatchingElements( device, NULL, kIOHIDOptionsTypeNone );
  
  for( int i = 0; i < hidElts.size(); i++ )
  {
    if( !hidElts[i] )  skip;
    IOElement elt( device, hidElts[i] ); // construct to classify
    
    // Wasn't determining device type.. categorize this elt so we could find it later
    // IOHIDElementType elemType = IOHIDElementGetType(elem);
    switch( elt.properties.type )
    {
      case kIOHIDElementTypeInput_Misc: //Misc input data field or varying size.
        misc.push_back( elt );
        break;
      case kIOHIDElementTypeInput_Button: //One bit input data field.
        buttons.push_back( elt );
        break;
      case kIOHIDElementTypeInput_Axis: //Input data field used to represent an axis.
        axes.push_back( elt );
        break;
      case kIOHIDElementTypeInput_ScanCodes://Input data field used to represent a scan code or usage selector.
        scancodes.push_back( elt );
        break;
      case kIOHIDElementTypeOutput://Used to represent an output data field in a report.
        outputs.push_back( elt );
        break;
      case kIOHIDElementTypeFeature://Describes input and output elements not intended for consumption by the end user.
        features.push_back( elt );
        break;
      case kIOHIDElementTypeCollection://Element used to identify a relationship between two or more elements.
        collections.push_back( elt );
        break;
    }
  }
}

void IODevice::check( vector<IOElement> & elts )
{
  puts("");
  for( int i = 0; i < elts.size(); i++ )
  {
    IOElement& elt = elts[i];
    elt.update();
    printf( "%ld ", elt.value );
  }
}

void IODevice::check()
{
  // Check all elts if they are active or not.
  // This is probably less efficient than reports.
  check( misc );  check( buttons );
  check( axes );
  check( scancodes );check( outputs );check( collections );check( features );
}



