#include <CoreFoundation/CoreFoundation.h>
#include <map>
#include <vector>
#include <string>
using namespace std;

#include "util/cf.h"
#include "ioHID.h"

#include "HIDManager.h"

#include "Callbacks.h"

int main( int argc, const char *argv[] )
{
  hid = new HIDManager();
  
  // runs until the user quits the app
  CFRunLoopRun();
  
  return 0;
}












