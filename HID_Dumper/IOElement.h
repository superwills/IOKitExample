#ifndef IOElement_h
#define IOElement_h

#include "ioHID.h"

/// An IOElement is part of a device like a button or
/// an axis.
struct IOElement
{
  IOHIDDeviceRef deviceOwner;  // Reference to the HID device this elt is part of.
  IOHIDElementRef elt;
  IOHIDElementType type;       // one of misc,button,scancode,axis,collection,output,feature
  
  string name, typeName;
  // page & usage of parent device is actually held in here in the elt.
  // Each PAGE (KeyboardOrKeypad, Button..) has MANY
  // USAGES (kHIDUsage_KeyboardA, kHIDUsage_KeyboardB..)
  int page;   // kHIDPage_KeyboardOrKeypad, kHIDPage_Button
  int usage;  // GenericDesktop Page: kHIDUsage_GD_Mouse, kHIDUsage_GD_GamePad
  CFIndex logicalMin, logicalMax, reportId;
  int reportSize;
  int value; // Last read value.
  
  void defaults();
  IOElement();
  IOElement( IOHIDDeviceRef iOwner, IOHIDElementRef iElement );
  inline int getPage() { return IOHIDElementGetUsagePage(elt); }
  inline int getUsage(){ return IOHIDElementGetUsage(elt); }
  
  // These functions serve to "document" how you find out if a device element is the mouseX element.
  inline bool isMouseX(){
    return page==kHIDPage_GenericDesktop && usage==kHIDUsage_GD_X;
  }
  inline bool isMouseY(){
    return page==kHIDPage_GenericDesktop && usage==kHIDUsage_GD_Y;
  }
  
  void update();
};

#endif /* IOElement_h */
