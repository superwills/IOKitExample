#include "cf.h"

string CFGetType( long typeId )
{
  static map<long,string> types = {
    {CFArrayGetTypeID(),"CFArray"},
    {CFBooleanGetTypeID(),"CFBoolean"},
    {CFDataGetTypeID(),"CFData"},
    {CFDateGetTypeID(),"CFDate"},
    {CFDictionaryGetTypeID(),"CFDictionary"},
    {CFNumberGetTypeID(),"CFNumber"},
    {CFStringGetTypeID(),"CFString"},
  };
  return types[typeId];
}

string CFStringGetAsString( CFStringRef cfStr )
{
  string buf;
  if( !cfStr ) return buf;
  long len = CFStringGetLength(cfStr);
  buf.resize( len+1,0 );
  if( !CFStringGetCString( (CFStringRef)cfStr,
    &buf[0], buf.size(),
    kCFStringEncodingMacRoman) )
    puts( "Couldn't copy string" );
  printf( "Str: %s\n", buf.c_str() );
  return buf;
}

string CFNumberGetAsString( CFNumberRef cfNum )
{
  CFLocaleRef locale = CFLocaleCopyCurrent();
  CFNumberFormatterRef formatter = CFNumberFormatterCreate( 
    kCFAllocatorDefault, locale, kCFNumberFormatterDecimalStyle );
    
  //!! This does not work if this is not a .mm file
  CFStringRef cfStr = CFNumberFormatterCreateStringWithNumber(
    kCFAllocatorDefault, formatter, cfNum );
  CFRelease( formatter );
  CFRelease( locale );
  string s = CFStringGetAsString( cfStr );
  CFRelease( cfStr );
  return s;
}

int CFNumberGetAsInt( CFNumberRef num )
{
  CFNumberType type = CFNumberGetType(num);
  
  // The switch selects the correct template
  switch( type )
  {
    case kCFNumberSInt8Type:
      return CFNumberGetValue<SInt8>( num );
    case kCFNumberSInt16Type:
      return CFNumberGetValue<SInt16>( num );
    case kCFNumberSInt32Type:
      return CFNumberGetValue<SInt32>( num );
    case kCFNumberSInt64Type:
      return (int)CFNumberGetValue<SInt64>( num );
    case kCFNumberFloat32Type:
      return CFNumberGetValue<Float32>( num );
    case kCFNumberFloat64Type:
      return CFNumberGetValue<Float64>( num );    
    case kCFNumberCharType:
      return CFNumberGetValue<char>( num );
    case kCFNumberShortType:
      return CFNumberGetValue<short>( num );
    case kCFNumberIntType:
      return CFNumberGetValue<int>( num );
    case kCFNumberLongType:
      return (int)CFNumberGetValue<long>( num );
    case kCFNumberLongLongType:
      return (int)CFNumberGetValue<long long>( num );
    case kCFNumberFloatType:
      return CFNumberGetValue<float>( num );
    case kCFNumberDoubleType:
      return CFNumberGetValue<double>( num );
    default:
      puts( "Unhandled value" );
      return 0;
  }
}
