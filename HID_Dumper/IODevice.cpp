#include "IODevice.h"

/// An object-representation of an IO device: 
IODevice::IODevice() : device( 0 ){}
IODevice::IODevice( IOHIDDeviceRef iDevice ) :
  device( iDevice )
{
  if( device )
  {
    IOHIDDeviceScheduleWithRunLoop( device, CFRunLoopGetMain(), kCFRunLoopDefaultMode );
    name = IOHIDDeviceGetPropertyAsString( device, kIOHIDProductKey );
    manufacturer = IOHIDDeviceGetPropertyAsString( device, kIOHIDManufacturerKey );
    printf( "Found `%s` by `%s`\n", name.c_str(), manufacturer.c_str() );
    readElements();
  }
  else puts( "NULL device construction!" );
}
  
void IODevice::dumpCollection( string collName, vector<IOElement>& coll )
{
  printf( "IOElements in %s:\n", collName.c_str() );
  // Dump each collection
  for( int i = 0; i < coll.size(); i++ )
  {
    printf( "  - %s\n", coll[i].name.c_str() );
  }
}

void IODevice::readElements()
{
  // This copies ALL elements
  CCFArray<IOHIDElementRef> hidElts = 
    IOHIDDeviceCopyMatchingElements( device, NULL, kIOHIDOptionsTypeNone );
  
  for( int i = 0; i < hidElts.size(); i++ )
  {
    skipIfNot( hidElts[i] );
    IOElement elt( device, hidElts[i] ); // construct to classify
    
    if( elt.deviceType != DeviceTypes::Invalid )
    {
      // this elt is a keyboard.. it means the DEVICE holding this elt is also a keyboard.
      // you can't tell a device is a keyboard until you read its elts.. weird but true.
      deviceType = elt.deviceType;
    }
  
    // Wasn't determining device type.. categorize this elt so we could find it later
    // IOHIDElementType elemType = IOHIDElementGetType(elem);
    switch(elt.type)
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
  
  printf( "  - `%s` is a %s and has\n"
    "    - %lu misc\n    - %lu buttons\n    - %lu axes\n"
    "    - %lu scancodes\n    - %lu outputs\n    - %lu collections\n    - %lu features\n",
    name.c_str(), DeviceTypes::Names[deviceType].c_str(),
    misc.size(), buttons.size(), axes.size(),
    scancodes.size(), outputs.size(), collections.size(), features.size() );
    
  // Dump each collection
  //dumpCollection( "misc", misc );
  //dumpCollection( "buttons", buttons );
  //dumpCollection( "axes", axes );
  //dumpCollection( "scancodes", scancodes );
  //dumpCollection( "outputs", outputs );
  //dumpCollection( "collections", collections );
  //dumpCollection( "features", features );
}

// bang the device to tell if its working or not
bool IODevice::operator!(){ return !device; }

void IODevice::check( vector<IOElement> & elts )
{
  puts("");
  for( int i = 0; i < elts.size(); i++ )
  {
    IOElement& elt = elts[i];
    elt.update();
    
    printf( "%3d ", elt.value );
  }
}

void IODevice::check()
{
  // Check all elts if they are active or not.  This is probably less efficient than reports.
  check( misc );  check( buttons );
  //check( axes );
  //check( scancodes );check( outputs );check( collections );check( features );
}



