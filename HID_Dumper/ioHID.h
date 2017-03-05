#ifndef IOHID_H
#define IOHID_H
#include <CoreFoundation/CoreFoundation.h>
#include <map>
#include <vector>
#include <string>
using namespace std;
#include <IOKit/hid/IOHIDLib.h>
#include <IOKit/hid/IOHIDElement.h>

string IOHIDDeviceGetPropertyAsString( IOHIDDeviceRef device, const char* key );
int IOHIDDeviceGetPropertyAsInt( IOHIDDeviceRef device, const char* key );
void printProp( IOHIDDeviceRef device, const char* key );

bool ioCheck( IOReturn res, const char* msg );

extern map<IOReturn,string> ioErrors ;
extern map<IOHIDElementType, string> ioElementTypes;
extern map<int, string> ioPages;

#endif