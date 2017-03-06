#include "ioHID.h"
#include "cf.h"

string IOHIDDeviceGetName( IOHIDDeviceRef device )
{
  return IOHIDDeviceGetPropertyAsString( device, kIOHIDProductKey );
}

CFTypeRef GetProperty( IOHIDDeviceRef device, const char* key )
{
  // Key as a CFStringRef
  CFStringRef cfKey = CFStringCreateWithCString( kCFAllocatorDefault, key, kCFStringEncodingMacRoman );
  CFTypeRef cfProp = IOHIDDeviceGetProperty( device, cfKey );
  if( cfProp ) CFRetain( cfProp );
  else {
    //string name = IOHIDDeviceGetName( device );
    //printf( "Property %s is not in device %s\n", key, name.c_str() );
    printf( "Property %s is not present\n", key );
  }
  CFRelease( cfKey );
  return cfProp;
}

string IOHIDDeviceGetPropertyAsString( IOHIDDeviceRef device, const char* key )
{
  CFTypeRef cfProp = GetProperty( device, key );
  if( !cfProp )  return "<< empty >>";
  CFShow( cfProp );
  
  string str;
  // If the underlying type is a string type, just get it as a string
  CFTypeID type = CFGetTypeID( cfProp );
  if( type == CFStringGetTypeID() )
    str = CFStringGetAsString( (CFStringRef)cfProp );
  else if( type == CFNumberGetTypeID() )
    str = CFNumberGetAsString( (CFNumberRef)cfProp );
  else
    printf( "Err: Property %s is not a string (CFTypeID=%s)", key, CFGetType(type).c_str() );
  CFRelease( cfProp );
  return str;
}

int IOHIDDeviceGetPropertyAsInt( IOHIDDeviceRef device, const char* key )
{
  CFTypeRef cfProp = GetProperty( device, key );
  if( !cfProp )  return 0;
  CFShow( cfProp );
  
  CFTypeID type = CFGetTypeID( cfProp );
  int num = 0;
  if( type == CFNumberGetTypeID() )
    num = CFNumberGetAsInt( (CFNumberRef)cfProp );
  else
    printf( "Err: Property %s is not an int (CFTypeID=%s)",
      key, CFGetType(type).c_str() );
  CFRelease( cfProp );
  return num;
}

bool ioCheck( IOReturn res, const char* msg )
{
  if( res != kIOReturnSuccess )
  {
    printf( "IOError: %s %s\n", msg, ioErrors[res].c_str() );
  }
  return res == kIOReturnSuccess;
}

map<IOReturn,string> ioErrors = {
  {kIOReturnSuccess, "kIOReturnSuccess KERN_SUCCESS // OK"},
  {kIOReturnError, "general error"},
  {kIOReturnNoMemory, "can't allocate memory "},
  {kIOReturnNoResources, "resource shortage "},
  {kIOReturnIPCError, "error during IPC "},
  {kIOReturnNoDevice, "no such device "},
  {kIOReturnNotPrivileged, "privilege violation "},
  {kIOReturnBadArgument, "invalid argument "},
  {kIOReturnLockedRead, "device read locked "},
  {kIOReturnLockedWrite, "device write locked "},
  {kIOReturnExclusiveAccess, "exclusive access and device already open "},
  {kIOReturnBadMessageID, "sent/received messages had different msg_id"},
  {kIOReturnUnsupported, "unsupported function "},
  {kIOReturnVMError, "misc. VM failure "},
  {kIOReturnInternalError, "internal error "},
  {kIOReturnIOError, "General I/O error "},
  //{kIOReturn???Error, iokit_common_err(0x2cb) // ??? 
  {kIOReturnCannotLock, "can't acquire lock"},
  {kIOReturnNotOpen, "device not open "},
  {kIOReturnNotReadable, "read not supported "},
  {kIOReturnNotWritable, "write not supported "},
  {kIOReturnNotAligned, "alignment error "},
  {kIOReturnBadMedia, "Media Error "},
  {kIOReturnStillOpen, "device(s) still open "},
  {kIOReturnRLDError, "rld failure "},
  {kIOReturnDMAError, "DMA failure "},
  {kIOReturnBusy, "Device Busy "},
  {kIOReturnTimeout, "I/O Timeout "},
  {kIOReturnOffline, "device offline "},
  {kIOReturnNotReady, "not ready "},
  {kIOReturnNotAttached, "device not attached "},
  {kIOReturnNoChannels, "no DMA channels left"},
  {kIOReturnNoSpace, "no space for data "},
  //{ kIOReturn???Error, "??? "
  {kIOReturnPortExists, "port already exists"},
  {kIOReturnCannotWire, "can't wire down physical memory"},
  {kIOReturnNoInterrupt, "no interrupt attached"},
  {kIOReturnNoFrames, "no DMA frames enqueued"},
  {kIOReturnMessageTooLarge, "oversized msg received on interrupt port"},
  {kIOReturnNotPermitted, "not permitted"},
  {kIOReturnNoPower, "no power to device"},
  {kIOReturnNoMedia, "media not present"},
  {kIOReturnUnformattedMedia, "media not formatted"},
  {kIOReturnUnsupportedMode , "no such mode"},
  {kIOReturnUnderrun, "data underrun"},
  {kIOReturnOverrun, "data overrun"},
  {kIOReturnDeviceError, "the device is not working properly!"},
  {kIOReturnNoCompletion, "a completion routine is required"},
  {kIOReturnAborted, "operation aborted"},
  {kIOReturnNoBandwidth, "bus bandwidth would be exceeded"},
  {kIOReturnNotResponding, "device not responding"},
  {kIOReturnIsoTooOld, "isochronous I/O request for distant past!"},
  {kIOReturnIsoTooNew, "isochronous I/O request for distant future"},
  {kIOReturnNotFound, "data was not found"},
  {kIOReturnInvalid, "should never be seen"},
};

map<IOHIDElementType, string> ioElementTypes ={
  {IOHIDElementType::kIOHIDElementTypeCollection, "Collection"},
  {IOHIDElementType::kIOHIDElementTypeFeature, "Feature"},
  {IOHIDElementType::kIOHIDElementTypeInput_Axis, "Input axis"},
  {IOHIDElementType::kIOHIDElementTypeInput_Button, "Input button"},
  {IOHIDElementType::kIOHIDElementTypeInput_Misc, "Input misc"},
  {IOHIDElementType::kIOHIDElementTypeInput_ScanCodes, "Input scancode"},
  {IOHIDElementType::kIOHIDElementTypeOutput, "Output"},
};

map<int,string> ioPages = {
  { kHIDPage_Undefined, "Undefined" },
  { kHIDPage_GenericDesktop, "GenericDesktop" },
  { kHIDPage_Simulation, "Simulation" },
  { kHIDPage_VR, "VR" },
  { kHIDPage_Sport, "Sport" },
  { kHIDPage_Game, "Game" },
  { 0x06,"Reserved 0x06"},
  { kHIDPage_KeyboardOrKeypad, "KeyboardOrKeypad // USB Device Class Definition for Human Interface Devices (HID)." }, // Note: the usage type for all key codes is Selector (Sel).
  { kHIDPage_LEDs, "LEDs" },
  { kHIDPage_Button, "Button" },
  { kHIDPage_Ordinal, "Ordinal" },
  { kHIDPage_Telephony, "Telephony" },
  { kHIDPage_Consumer, "Consumer" },
  { kHIDPage_Digitizer, "Digitizer" },
  { 0x0E, "Reserved 0x0E" },
  { kHIDPage_PID, "PID // USB Physical Interface Device definitions for force feedback and related devices." }, 
  { kHIDPage_Unicode, "Unicode" },
  { 0x11, "Reserved 0x11" }, {0x12, "Reserved 0x12"}, {0x13, "Reserved 0x13"},
  { kHIDPage_AlphanumericDisplay, "Usage" },
  // Reserved 0x15 - 0x1F
  { kHIDPage_Sensor, "Usage" },
  // Reserved 0x21 - 0x7f
  // Monitor 0x80 - 0x83     USB Device Class Definition for Monitor Devices
  // Power 0x84 - 0x87     USB Device Class Definition for Power Devices
  { kHIDPage_PowerDevice, "PowerDevice // Power Device Page " },
  { kHIDPage_BatterySystem, "BatterySystem // Battery System Page" },
  // Reserved 0x88 - 0x8B
  { kHIDPage_BarCodeScanner, "BarCodeScanner // (Point of Sale) USB Device Class Definition for Bar Code Scanner Devices" },
  { kHIDPage_WeighingDevice, "WeighingDevice // (Point of Sale) USB Device Class Definition for Weighing Devices" },
  { kHIDPage_Scale, "Scale // (Point of Sale) USB Device Class Definition for Scale Devices" },
  { kHIDPage_MagneticStripeReader, "MagneticStripeReader" },
  // ReservedPointofSalepages 0x8
  { kHIDPage_CameraControl, "CameraControl" },    // USB Device Class Definition for Image Class Devices
  { kHIDPage_Arcade, "Arcade" },    // OAAF Definitions for arcade and coinop related Devices
  // Reserved 0x92 - 0xFEFF
  // VendorDefined 0xFF00 - 0xFFFF
  { kHIDPage_VendorDefinedStart, "VendorDefinedStart" }, 
};
