#ifndef HIDDevice_h
#define HIDDevice_h

#include <MacTypes.h>
#include <stdio.h>
#include <map>
#include <vector>
using namespace std;

#include "cf.h"
#include "DeviceUsage.h"

/// Abstracts an HID device 
struct HIDDevice
{
  IOHIDDeviceRef device;
  IOHIDOptionsType deviceOpenOptions;
  
  /// A standard buffer size to get report data in
  /// The buffer must be greater than or equal to
  /// the size of the report
  /// https://developer.apple.com/library/prerelease/content/documentation/DeviceDrivers/Conceptual/HID/new_api_10_5/tn2187.html
  /// "CFIndex reportSize = 64;"    // note: this should be greater than or equal to the size of the report
  const static int BUFFER_SIZE = 64;
  /// The buffer of bytes read on last report
  vector< UInt8 > reportBuffer;
  /// Maps byte numbers in the report to USAGES
  vector< DeviceUsage > deviceUsages;
  
  /// Avoid initializer list when using a defaults() function
  void defaults();
  HIDDevice();
  HIDDevice( IOHIDDeviceRef iDevice, IOHIDOptionsType iDeviceOpenOptions );
  ~HIDDevice();
  bool open();
  void getDeviceDetails();
  
  /// Gets primary device usage from CFDictionary inside the properties.
  DeviceUsage getUsage();
  void print();
  void print( vector<string> keys );
  void printElements();
  
  /// Reads a ReportDescriptor and identifies it
  void ReadReportDescriptor( const vector<UInt8>& reportDescriptor );
  
private:
  /// Fields are of the format bxxxx xxnn
  /// eg (b0000 0101)
  /// where the bits before the nn can be any of
  /// the combinations described below and the
  /// nn represents the SIZE OF THE FIELD that
  /// will store the data starting at the byte
  /// immediately beside the flag.
  /// Masks last 2 bits off the byte
  const static int MASK_NN       = 0x03;
  
  // Main: page 28 of HID1_11.pdf
  const static int kInput        = 0x80;
  const static int kOutput       = 0x90;
  const static int kFeature      = 0xB0;
  const static int kCollection   = 0xA0;
  const static int kEndCollection= 0xC0;
  
  // Global: page 35 of HID1_11.pdf
  const static int kUsagePage    = 0x04;
  const static int kLogicalMin   = 0x14;
  const static int kLogicalMax   = 0x24;
  const static int kPhysicalMin  = 0x34;
  const static int kPhysicalMax  = 0x44;
  const static int kUnitExponent = 0x54;
  const static int kUnit         = 0x64;
  const static int kReportSize   = 0x74;
  const static int kReportID     = 0x84;
  const static int kReportCount  = 0x94;
  const static int kPush         = 0xA4;
  const static int kPop          = 0xB4;

  // Local: page 40 of HID1_11.pdf
  const static int kUsage        = 0x08;
  const static int kUsageMin     = 0x18;
  const static int kUsageMax     = 0x28;
  const static int kDesignatorIndex = 0x38;
  const static int kDesignatorMin   = 0x48;
  const static int kDesignatorMax   = 0x58;
  const static int kStringIndex  = 0x78;
  const static int kStringMin    = 0x88;
  const static int kStringMax    = 0x98;
  const static int kDelimiter    = 0xA8;
};

#endif /* HIDDevice_h */
