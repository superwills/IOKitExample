#ifndef IODevice_h
#define IODevice_h

#include "ioHID.h"
#include "IOElement.h"

/// An object-representation of an IO device
/// A DEVICE (keyboard) contains many ELEMENTS (A,B,C).
struct IODevice
{
  IOHIDDeviceRef device;
  map< string, string > properties;
  
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
