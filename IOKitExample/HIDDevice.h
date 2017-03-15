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
  /// Fields are of the format bxxxx xxnn
  /// eg (b0000 0101)
  /// where the bits before the nn can be any of
  /// the combinations described below and the
  /// nn represents the SIZE OF THE FIELD that
  /// will store the data starting at the byte
  /// immediately beside the flag.
  /// Masks last 2 bits off the byte
  const static int MASK_NN       = 0xFC;
  
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
  
  HIDDevice()
  {
    reportBuffer.resize( BUFFER_SIZE, 0 );
  }
  
  /// Reads a ReportDescriptor and identifies it
  void ReadReportDescriptor( const vector<UInt8>& reportDescriptor )
  {
    // the meaning of the bytes is on page (35) of HID1_11.pdf
    // the first of each pair is what the entry is for.
    // The second is a value.
    int reportBit = 0, // The byte we're describing in the report
      usageMin = 0, usageMax = 0, reportCount = 0;
    DeviceUsage currentUsage;
    vector<DeviceUsage> deviceUsages;
    for( int i = 0; i < reportDescriptor.size(); i++ )
    {
      int flag = reportDescriptor[i] & ~MASK_NN;
      int byteSize = reportDescriptor[i] & MASK_NN;
      if( !byteSize )  skip; // 0 byte field, no data (0xc0)
      
      short value;
      if( byteSize == sizeof( UInt8 ) )
        value = reportDescriptor[i+1]; // whatever value is there in the [i+1]th byte
      else if( byteSize == sizeof( short ) && i < reportDescriptor.size()-2 )
        // interpret as short
        value = *( (short*)( &( reportDescriptor[i+1] ) ) );
      
      switch( flag )
      {
        // Found usage page
        case kUsagePage:    currentUsage.page = value;          break;
        case kLogicalMin:   currentUsage.logicalMin = value;    break;
        case kLogicalMax:   currentUsage.logicalMax = value;    break;  
        case kPhysicalMin:  currentUsage.physicalMin = value;   break;
        case kPhysicalMax:  currentUsage.physicalMax = value;   break;
        case kUnitExponent: puts( "NOTE: Skipped kUnitExponent" );  break;
        case kUnit:         puts( "NOTE: Skipped kUnit" );      break;
        case kReportSize:   currentUsage.reportSizeBits = value;break;
        case kReportID:     currentUsage.reportID = value;      break;
        case kReportCount:  reportCount = value;                break;
        case kPush:         puts( "NOTE: Skipped kPush" );      break;
        case kPop:          puts( "NOTE: Skipped kPop" );       break;
          
        case kUsage:     currentUsage.usage = value;  break;
        case kUsageMin:  usageMin = value;            break;
        case kUsageMax:  usageMax = value;            break;
        case kDesignatorIndex:  puts( "NOTE: Skipped kDesignatorIndex" );  break;
        case kDesignatorMin:  puts( "NOTE: Skipped kDesignatorMin" );  break;
        case kDesignatorMax:  puts( "NOTE: Skipped kDesignatorMax" );  break;
        case kStringIndex:  puts( "NOTE: Skipped kStringIndex" );  break;
        case kStringMin:  puts( "NOTE: Skipped kStringMin" );  break;
        case kStringMax:  puts( "NOTE: Skipped kStringMax" );  break;
        case kDelimiter:  puts( "NOTE: Skipped kDelimiter" );  break;
          
        case kInput:
          // create (usageMax-usageMin) usages
          puts( "INPUT:" );
          for( int usage = usageMin; usage <= usageMax; usage++ )
          {
            currentUsage.startingBit = reportBit;
            reportBit += currentUsage.reportSizeBits;
            currentUsage.usage = usage;
            currentUsage.print();
            deviceUsages.push_back( currentUsage );
          }
        case kOutput:         puts( "NOTE: Skipped kOutput" );  break;
        case kFeature:        puts( "NOTE: Skipped kFeature" );  break;
        case kCollection:     puts( "NOTE: Skipped kCollection" );  break;
        case kEndCollection:  puts( "NOTE: Skipped kEndCollection" );  break;
      }
      
    }
  }
};

#endif /* HIDDevice_h */
