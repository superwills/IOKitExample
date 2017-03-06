#ifndef IODevice_h
#define IODevice_h

#include "ioHID.h"
#include "IOElement.h"

struct DeviceProperties
{
  string transport, category, vendorId, vendorIdSource,
    productId, versionNumber,
    manufacturer, product,
    serialNumber, countryCode, standardType, locationId;
  int page;   // kHIDPage_KeyboardOrKeypad, kHIDPage_Button
  int usage;  // GenericDesktop Page: kHIDUsage_GD_Mouse, kHIDUsage_GD_GamePad
  
  void print()
  {
    printf( "product=`%s` by manufacturer=`%s`\n"
      "transport=%s category=%s\n"
      "vendor=%s vendorId=%s\n"
      "productId=%s versionNumber=%s\n"
      "serialNumber=%s versionNumber=%s\n"
      "standardType=%s locationId=%s\n"
      "page=%d usage=%d\n",
      product.c_str(), manufacturer.c_str(),
      transport.c_str(), category.c_str(),
      vendorId.c_str(), vendorIdSource.c_str(),
      productId.c_str(), versionNumber.c_str(),
      serialNumber.c_str(), countryCode.c_str(),
      standardType.c_str(), locationId.c_str(),
      page, usage
    );

  }
};

/// An object-representation of an IO device
/// A DEVICE (keyboard) contains many ELEMENTS (A,B,C).
struct IODevice
{
  IOHIDDeviceRef device;
  DeviceProperties properties;

  /// An IODevice has a given # of elements.
  vector<IOElement> misc, buttons, axes, 
    scancodes, outputs, collections, features;
  
  IODevice();
  IODevice( IOHIDDeviceRef iDevice );
  
  static IODevice* Make( IOHIDDeviceRef iDevice );
  // bang the device to tell if its working or not
  inline bool operator!(){ return !device; }
  
  void dumpCollection( string collName, vector<IOElement>& coll );
  void readElements();
  void check( vector<IOElement> & elts );
  void check();
};

#endif /* IODevice_h */
