#include "IOElement.h"
#include "cf.h"

void IOElement::defaults()
{
  deviceOwner=0;
  elt=0;
  
  value=0;
  scaledValue=0.;
}

IOElement::IOElement()
{
  defaults();
}

IOElement::IOElement( IOHIDDeviceRef iOwner, IOHIDElementRef iElement )
{
  defaults();
  deviceOwner = iOwner;
  elt = iElement;
  if( !elt ) return;
  
  properties.name = CFStringGetAsString( IOHIDElementGetName( elt ) );
  properties.type = IOHIDElementGetType( elt );
  properties.typeName = ioElementTypes[ properties.type ];
  
  // The ELEMENT has the page, but the device doesn't seem to have it
  // accurately much of the time..
  properties.page = IOHIDElementGetUsagePage( elt );
  properties.usage =  IOHIDElementGetUsage( elt );
  properties.logicalMin = IOHIDElementGetLogicalMin( elt );
  properties.logicalMax = IOHIDElementGetLogicalMax( elt );
  
  // tells you what report an elt will be included in
  properties.reportId = IOHIDElementGetReportID( elt );
  
  // how big the report is that the elt is a part of. redundant between
  properties.reportSize = IOHIDElementGetReportSize( elt );
  // elts that use the same reportId, but.
}

IOElement::~IOElement()
{
  
}

void IOElement::update()
{
  if( !elt ) {
    printf( "Error: Element %s is not initialized\n", properties.name.c_str() );
    return;
  }
  IOHIDValueRef vr = 0;
  IOHIDDeviceGetValue( deviceOwner, elt, &vr );
  if( vr )
  {
    // fetching the value as FLOAT is allowed also,
    value = IOHIDValueGetIntegerValue(vr);
    scaledValue = IOHIDValueGetScaledValue( vr, kIOHIDValueScaleTypePhysical );
  }
}
