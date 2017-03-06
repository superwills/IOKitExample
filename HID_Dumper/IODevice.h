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
  
  void print() const
  {
    printf( "Product=%s BY Manufacturer=%s\n"
      "  transport=%s\n  category=%s\n"
      "  vendor=%s\n  vendorId=%s\n"
      "  productId=%s\n  versionNumber=%s\n"
      "  serialNumber=%s\n  versionNumber=%s\n"
      "  standardType=%s\n  locationId=%s\n"
      "  page=%d\n  usage=%d\n",
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
  ~IODevice();
  
  static IODevice* Make( IOHIDDeviceRef iDevice );
  // bang the device to tell if its working or not
  inline bool operator!(){ return !device; }
  
  void dumpCollection( string collectionName, const vector<IOElement>& coll );
  void readProperties();
  void readElements();
  
  void check( vector<IOElement> & elts );
  void check();
};

#endif /* IODevice_h */
