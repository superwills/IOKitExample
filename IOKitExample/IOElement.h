#ifndef IOElement_h
#define IOElement_h

#include "ioHID.h"

struct ElementProperties
{
  string name;
  IOHIDElementType type;       // one of misc,button,scancode,axis,collection,output,feature
  string typeName;
  // page & usage of PARENT device is actually held in here in the elt.
  // Each PAGE (KeyboardOrKeypad, Button..) has MANY USAGES (kHIDUsage_KeyboardA, kHIDUsage_KeyboardB..)
  int page;   // kHIDPage_KeyboardOrKeypad, kHIDPage_Button
  int usage;  // GenericDesktop Page: kHIDUsage_GD_Mouse, kHIDUsage_GD_GamePad
  CFIndex logicalMin, logicalMax, reportId;
  int reportSize;
  
  ElementProperties()
  {
    name="uninit";
    type=(IOHIDElementType)0;
    typeName="uninit";
    page=usage=0;
    logicalMin=logicalMax=reportId=reportSize=0;
  }
  
  void print() const
  {
    printf( "Element name=`%s`: type=%d [%s], page=%d [%s], usage=%d [%s], "
      "logicalMin=%ld, logicalMax=%ld, reportId=%ld, reportSize=%d\n",
      name.c_str(), type, typeName.c_str(),
      page, ioPages[ page ].c_str(), usage,
      ioUsages[ page ][ usage ].c_str(),
      logicalMin, logicalMax, reportId, reportSize );
  }
  
};

/// An IOElement is part of a device like a button or
/// an axis.
struct IOElement
{
  IOHIDDeviceRef deviceOwner;  // Reference to the HID device this elt is part of.
  IOHIDElementRef elt;
  
  ElementProperties properties;
  
  /// Last read value.
  long value; 
  double scaledValue; // If you want this use it
  
  void defaults();
  IOElement();
  IOElement( IOHIDDeviceRef iOwner, IOHIDElementRef iElement );
  ~IOElement();
  
  /// Caches new value of elt in `value`
  void update();
};

#endif /* IOElement_h */
