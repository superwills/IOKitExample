#ifndef DeviceUsage_h
#define DeviceUsage_h

#include <string>
using namespace std;

#include "ioHID.h"

/// Because the device usage is often stored in a CFDictionary object
/// in the properties we use this object to pass it around or keep it
struct DeviceUsage
{
  int page, usage, logicalMin, logicalMax, physicalMin, physicalMax,
      reportID, startingBit, reportSizeBits;
  void defaults(){
    page = 0;
    usage = 0;
    logicalMin = 0;
    logicalMax = 1;
    physicalMin = 0;
    physicalMax = 1;
    reportID = 0;
    startingBit = 0; // The starting bit at which the value is stored
    reportSizeBits = 1;
  }
  DeviceUsage()
  {
    defaults();
  }
  DeviceUsage( int iPage, int iUsage )
  { 
    defaults();  
    page = iPage;
    usage = iUsage;
  }
  
  /// Get the data from the report
  int get( const vector<UInt8>& report )
  {
    // The bit we're reading starting from is
    // startingBit.
    // Kick the mask from the left side then.
    // UInt8 is used so 0's come in naturally
    // but if you used SInt8 and shift a 1 in
    // from the left subsequent shifts would be 1's to keep
    // it negative.
    
    UInt8 mask = 0;
    for( int i = 0; i < reportSizeBits; i++ )
    {
      mask >>= 1;   // shift the existing bits over
      mask |= 0x80; // 0x80=0b1000 0000 OR in a new one.
    }
    
    const int bitsPerByte = 8;
    // shift the bits down by the startingBit offset
    int startBitOffset = startingBit % bitsPerByte;
    mask >>= startBitOffset;
    
    int byteIndex = startingBit / bitsPerByte;
    if( byteIndex >= report.size() )
    {
      printf( "ERROR %d index oob\n", byteIndex );
      return 0;// Default value (this will happen with 0 size report also)
    }
    
    return report[ byteIndex ] & mask;
  }
  
  void print() const
  {
    printf( "DEVICE USAGE: page=%d,usage=%d[%s],logMin=%d,logMax=%d,"
    "physMin=%d,physMax=%d,reportID=%d,reportSizeBits=%d\n",
    page,usage,ToString().c_str(),logicalMin,logicalMax,
    physicalMin,physicalMax,reportID,reportSizeBits );
  }
  
  string ToString() const
  {
    return ioUsages[ page ][ usage ];
  }
};

#endif /* DeviceUsage_h */
