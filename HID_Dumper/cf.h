#ifndef CF_H
#define CF_H

#include <CoreFoundation/CoreFoundation.h>
#include <map>
#include <vector>
#include <string>
using namespace std;

#define skip continue
#define DESTROY(x) if(x) { delete x; x=0; }
#define DESTROY_VECTOR(v) for( int i = 0; i < v.size(); i++ ) { DESTROY(v[i]); } v.clear();
#define IOCHECK(v,s) ioCheck(v,s,__LINE__)

template <typename T> struct CCFArray
{
  CFArrayRef array;
  CCFArray()
  {
    array = CFArrayCreate( kCFAllocatorDefault, 0, 0, 0 );
  }
  CCFArray(CFArrayRef cf):array(cf) { retain(); }
  void retain() { if(array)CFRetain(array); }
  int size()
  {
    // I check array exists here to allow skip processing in loop if 0
    if( array )
      return (int)CFArrayGetCount( array );
    return 0;
  }
  T operator[]( int i )
  {
    return (T)CFArrayGetValueAtIndex( array, i );
  }
  ~CCFArray()
  {
    if(array)CFRelease( array );
  }
};

template <typename T> struct CCFMutableArray
{
  CFMutableArrayRef array;
  CCFMutableArray()
  {
    array = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
  }
  CCFMutableArray(CFMutableArrayRef cf):array(cf) { retain(); }
  void retain() { if(array)CFRetain(array); }
  void add( T& obj )
  {
    CFArrayAppendValue( array, obj );
  }
  void add( void* obj )
  {
    CFArrayAppendValue( array, obj );
  }
  int size()
  {
    return (int)CFMutableArrayGetCount( array );
  }
  T operator[]( int i )
  {
    return (T)CFArrayGetValueAtIndex( array, i );
  }
  ~CCFMutableArray()
  {
    if(array)CFRelease( array );
  }
};

template <typename T> struct CCFSet
{
  CFSetRef set;
  CCFSet()
  {
    set = CFSetCreate( kCFAllocatorDefault, 0, 0, 0 );
  }
  CCFSet( CFSetRef cf ) : set( cf ) { retain(); }
  void retain() { if( set ) CFRetain( set ); }
  int size() { return CFSetGetCount( set ); }
  vector<T> toVector()
  {
    vector<T> v;
    v.resize( CFSetGetCount(set) );
    CFSetGetValues( set, (const void**)&v[0] );
    return v;
  }
  ~CCFSet() { if( set ) CFRelease( set ); }
};

// A dictionary is a bunch of <T,S> pairs. T&S can only be pointer types though..
template <typename T, typename S> struct CCFDictionary
{
  CFDictionaryRef dic;
  
  CCFDictionary()
  {
    dic = CFDictionaryCreate( kCFAllocatorDefault, 0, 0, 0, 0, 0);
  }
  
  /// Construct a CFDictionary out of a std::map<T,S>
  CCFDictionary( const map<T, S> & m )
  {
    // You have to assemble the keys & values in C arrays
    vector<T> keys;
    vector<S> vals;
    
    for( typename map<T,S>::const_iterator it = m.begin(); it != m.end(); ++it )
    {
      keys.push_back( it->first );
      vals.push_back( it->second );
    }
    dic = CFDictionaryCreate( kCFAllocatorDefault,
      (const void**)&keys[0],
      (const void**)&vals[0],
      m.size(),
      &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks );
  }
  
  // You didn't create it, so I retain once
  CCFDictionary( CFDictionaryRef cf ) : dic( cf ) { retain(); }
  void retain() { if( dic )  CFRetain( dic ); }
  void release() { if( dic )  CFRelease( dic ); }
  int size() { return CFDictionaryGetCount( dic ); }
  void print() const {
    CFShow( dic );
  }
  ~CCFDictionary() { release(); }
};

// A dictionary is a bunch of <T,S> pairs. T&S can only be pointer types though..
template <typename T, typename S> struct CCFMutableDictionary
{
  CFMutableDictionaryRef dic;
  
  CCFMutableDictionary()
  {
    dic = CFDictionaryCreateMutable( kCFAllocatorMalloc, 0, 0, 0 );
  }
  
  /// Construct a CFMutableDictionary out of a std::map<T,S>
  CCFMutableDictionary( const map<T, S> & m )
  {
    // You have to assemble the keys & values in C arrays
    vector<T> keys;
    vector<S> vals;
    
    for( typename map<T,S>::const_iterator it = m.begin(); it != m.end(); ++it )
    {
      keys.push_back( it->first );
      vals.push_back( it->second );
    }
    
    dic = CFMutableDictionaryCreate( kCFAllocatorDefault,
      (const void**)&keys[0],
      (const void**)&vals[0],
      m.size(),
      &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks );
  }
  
  // You didn't create it, so I retain once
  CCFMutableDictionary( CFMutableDictionaryRef cf ) : dic( cf ) { retain(); }
  void retain() { if( dic )  CFRetain( dic ); }
  void release() { if( dic )  CFRelease( dic ); }
  int size() { return CFDictionaryGetCount( dic ); }
  void print() const {
    CFShow( dic );
  }
  ~CCFMutableDictionary() { release(); }
};

string CFGetType( long typeId );
string CFStringGetAsString( CFStringRef cfStr );
string CFNumberGetAsString( CFNumberRef cfNum );
string CFDataGetAsString( CFDataRef cfData );
string CFArrayGetAsString( CFArrayRef cfArray );
string CFDictionaryGetAsString( CFDictionaryRef cfDict );

template <typename T> T CFNumberGetValue( CFNumberRef num )
{
  CFNumberType type = CFNumberGetType(num);
  T val;
  CFNumberGetValue(num, type, &val);
  return val;//sure hope you're right!
}

int CFNumberGetAsInt( CFNumberRef num );

string CFGetAsString( CFTypeRef cfProp );

#endif
