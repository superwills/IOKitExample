#ifndef util_h
#define util_h

#include <Foundation/Foundation.h>
#include <stdarg.h>
#include <time.h>
#include <stdio.h>
#include <string>
using namespace std;

const extern char* ProgramName;

/// Logging.
enum ErrorLevel
{
  Info    = 1 << 0, // 1
  Warning = 1 << 1, // 2
  Error   = 1 << 2  // 4
};
extern const char* ErrorLevelName[];

enum ConsoleColor
{
  ConsoleRed,ConsoleYellow,ConsoleGray
};

tm* getCurrentTime();

string getCurrentTimeString();

// decorates the log message with [appname][thread][error level][current time]:  message
void logDecorate( int logLevel, short color, const char *fmt, va_list args );

string logDecorateGetString( int logLevel, const char *fmt, va_list args ) ;

void error( const char *fmt, ... );

void error( NSError* nsError, const char *msg );

void warning( const char *fmt, ... );

void info( short iColor, const char *fmt, ... );

void info( const char *fmt, ... );


#endif /* util_h */
