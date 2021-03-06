#ifndef IOHID_H
#define IOHID_H

#include <CoreFoundation/CoreFoundation.h>
#include <map>
#include <vector>
#include <string>
using namespace std;
#include <IOKit/hid/IOHIDDevice.h>
#include <IOKit/hid/IOHIDElement.h>
#include <IOKit/hid/IOHIDLib.h>

CFTypeRef GetProperty( IOHIDDeviceRef device, string key );
string IOHIDDeviceGetPropertyAsString( IOHIDDeviceRef device, string key );

bool ioCheck( IOReturn res, const char* msg );

extern map<IOReturn,string> ioErrors;
extern map<IOHIDElementType, string> ioElementTypes;
extern map<int, string> ioPages;
extern map<int, map<int, string> > ioUsages;
extern vector<string> ioKeys;

#endif
