#ifndef IODevice_h
#define IODevice_h

#include "ioHID.h"
#include "DeviceType.h"
#include "IOElement.h"

/// An object-representation of an IO device: 
struct IODevice
{
  IOHIDDeviceRef device;
  DeviceTypes::Enum deviceType;  
  string name, manufacturer;
  
  /// An IODevice has a given # of elements.
  vector<IOElement> misc, buttons, axes, 
    scancodes, outputs, collections, features;
  
  IODevice();
  IODevice( IOHIDDeviceRef iDevice );
  
  void dumpCollection( string collName, vector<IOElement>& coll );
  
  void readElements();
  // bang the device to tell if its working or not
  bool operator!();
  void check( vector<IOElement> & elts );
  void check();
};


struct IOMouse : public IODevice
{
  IOElement x, y;
  IOMouse(){}
  IOMouse( IODevice& iDevice )
  {
    
  }
  
  void findMouseElements()
  {
    for( int i=0; i < misc.size(); i++ )
    {
      if( misc[i].isMouseX() )
        x = misc[i];
      else if( misc[i].isMouseY() )
        y = misc[i];
    }
  }
};

struct IOKeyboard : public IODevice
{
  IOKeyboard(){}
  IOKeyboard( IODevice& iDevice )
  {
    
  }
};

struct IOGamepad : public IODevice
{
  IOGamepad(){}
  IOGamepad( IODevice& iDevice )
  {
    
  }
};

#endif /* IODevice_h */
