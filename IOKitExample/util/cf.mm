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
  if( !cfStr ) {
    buf = "<< empty >>";
    return buf;
  }
  long len = CFStringGetLength(cfStr);
  buf.resize( len+1,0 );
  if( !CFStringGetCString( (CFStringRef)cfStr,
    &buf[0], buf.size(),
    kCFStringEncodingMacRoman) )
    puts( "CFStringGetAsString: Couldn't copy string" );
  buf.pop_back();
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

string CFBooleanGetAsString( CFBooleanRef cfBool )
{
  Boolean val = CFBooleanGetValue( cfBool );
  if( val ) return "True";
  else return "False";
}

vector<UInt8> CFDataGetData( CFDataRef cfData )
{
  long dataSize = CFDataGetLength( cfData );
  vector<UInt8> buf( dataSize, 0 );
  CFRange cfRange = CFRangeMake( 0, dataSize );
  CFDataGetBytes( cfData, cfRange, &buf[0] );
  return buf;
}

string CFDataGetAsString( CFDataRef cfData )
{
  vector<UInt8> buf = CFDataGetData( cfData );
  
  string str;
  char num[80];
  for( int i = 0; i < buf.size(); i++ )
  {
    sprintf( num, "%02x", buf[i] );
    str += string( num );
    if( i%2 ) str += "\n";
    else str += " ";
  }
  return str;
}

string CFArrayGetAsString( CFArrayRef cfArray )
{
  string str = "[";
  long count = CFArrayGetCount( cfArray );
  for( int i = 0 ; i < count; i++ )
  {
    CFTypeRef entry = CFArrayGetValueAtIndex( cfArray, i );
    str += CFGetAsString( entry );
    if( i < count-1 )  str += ", ";
  }
  
  return str + "]";
}

string CFDictionaryGetAsString( CFDictionaryRef cfDict )
{
  string str = "{";
  long count = CFDictionaryGetCount( cfDict );
  vector<CFTypeRef> keys( count, 0 ), vals( count, 0 );
  CFDictionaryGetKeysAndValues( cfDict, (const void**)&keys[0], (const void**)&vals[0] );
  
  for( int i = 0; i < count; i++ ) {
    str += "{" + CFGetAsString( keys[ i ] ) + ":" + CFGetAsString( vals[ i ] ) + "}" ;
    if( i < count - 1 )  str += ", ";
  }
  return str + "}";
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

string CFGetAsString( CFTypeRef cfProp )
{
  if( ! cfProp )  return "<< empty >>";
  string str = "<< unrecognized data type >>";
  
  // If the underlying type is a string type, just get it as a string
  CFTypeID type = CFGetTypeID( cfProp );
  if( type == CFStringGetTypeID() )
    str = CFStringGetAsString( (CFStringRef)cfProp );
  else if( type == CFNumberGetTypeID() )
    str = CFNumberGetAsString( (CFNumberRef)cfProp );
  else if( type == CFBooleanGetTypeID() )
    str = CFBooleanGetAsString( (CFBooleanRef)cfProp );
  else if( type == CFDataGetTypeID() )
    str = CFDataGetAsString( (CFDataRef)cfProp );
  else if( type == CFArrayGetTypeID() )
    str = CFArrayGetAsString( (CFArrayRef)cfProp );
  else if( type == CFDictionaryGetTypeID() )
    str = CFDictionaryGetAsString( (CFDictionaryRef)cfProp );
  else {
    printf( "Unrecognized data type CFTypeID=%s", CFGetType( type ).c_str() );
    CFShow( cfProp );
  }
  return str;
}

template <> string CFGet<string>( CFTypeRef cfProp )
{
  return CFStringGetAsString( (CFStringRef)cfProp );
}
template <> int CFGet<int>( CFTypeRef cfProp )
{
  return CFNumberGetAsInt( (CFNumberRef)cfProp );
}




