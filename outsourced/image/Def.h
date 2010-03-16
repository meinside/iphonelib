/**************************************************************************************************
  FILE:      Def.h
  PURPOSE:   General declarations and macros. Used by both MSVC and LabWindows/CVI
  COPYRIGHT: (c) 1983-2002 Guillaume Dargaud. Inspired from various sources.
  NOTE:      The macro _CVI_ controls whether to compile for CVI or MSVC
**************************************************************************************************/
#ifndef _DEF
#define _DEF

#include <iso646.h>	// for 'and', 'or'...

///////////////////////////////////////////////////////////////////////////////
#ifndef NULL
	#define NULL 0
#endif


///////////////////////////////////////////////////////////////////////////////
// NAN: Not A Number. Indicate a wrong or non significant value - 
// Must always be tested, i.e. never assume that it's "close to zero, anyway" !
// Could be any value, esp IEEE nan, error or infinity formats.
// Note: IEEE nan is not used because of trans-system compatibility issues and 
// also float-double incompatibility
#define NAN ((float)1e-30)
#ifdef _CVI_
	#include <toolbox.h>	// you need to include toolbox.fp in your project
	#define IS_NAN(x) (FP_Compare((x), NAN)==0)
#else	// WARNING: system specific, MUST BE TESTED
	#define IS_NAN(x) (x==NAN)
#endif


///////////////////////////////////////////////////////////////////////////////
// Macs and SGIs are Big-Endian; PCs are little endian
// Swap 32 bit endian values, long integer only
#define SWAP_ENDIAN(a) ( (((a) bitand 0x000000FF) << 24) bitor\
						 (((a) bitand 0x0000FF00) << 8) bitor\
						 (((a) bitand 0x00FF0000) >> 8) bitor\
						 (((a) bitand 0xFF000000) >> 24) )
// Note, more complete code can be found in "SwapEndian.c"


///////////////////////////////////////////////////////////////////////////////
// 64 bit integer conversion, convert high and low 32 bit integer to one double
#define Shift32bits ((double)4294967296.0)
#define Double64(High, Low) ((High)*Shift32bits+(Low))


///////////////////////////////////////////////////////////////////////////////
// Trigonometry
#define Pi       3.1415926535897932384626433832795028841971
#define DegToRad 0.017453292519943295769236907684886 
#define RadToDeg 57.295779513082320876798154814105     // Use * for conversions between degrees and radians
#define RAD(x)   ((x)*DegToRad)		// Convert from Deg to Rad
#define SINC(x)  ((x) != 0.0  ? sin(PI*(x))/(PI*(x)): 1.0)
#define Ln10     2.3025850929940456840179914546844    // For inverse of log10.
#define InvLog10(x) ( exp((x)*Ln10) )		// Inverse of Log10


///////////////////////////////////////////////////////////////////////////////
// Time conversion. Very complex and bugged subject.
#define MS2CVI_TIME   2208902400   // Because MS time starts at 1/1/1970 and ANSI C at 1/1/1900
//#define MS2CVI_TIME 2208978000   // Because MS time starts at 1/1/1970 and ANSI C at 1/1/1900
#define IsCviTime(t) ((t)>=MS2CVI_TIME)	// Check if a date after 1970 is in CVI format

#define FILE2CVI_SEC 9435484800.0	// Convert from FILETIME/1e7 to time_t
#define FILE2CVI_TIME(FileTime) (int)(Double64((FileTime).dwHighDateTime, (FileTime).dwLowDateTime)/1e7 - FILE2CVI_SEC)


///////////////////////////////////////////////////////////////////////////////
// Memory allocations
// Malloc: Example: double *pD=Malloc(double);
// Calloc: Example: double *pD=Calloc(100, double);
// Free: Same as free, but makes sure the pointer is NULL afterwards
#define Malloc(type)   (type *)malloc(sizeof(type))
#define Calloc(nb,type) (type *)calloc(nb, sizeof(type))
#define Free(Ptr) { free(Ptr); Ptr=NULL; }

///////////////////////////////////////////////////////////////////////////////
// Beware: the following macros all have side effects
// MIN(a,b): 		Returns the min of 2 values 
// MAX(a,b): 		Returns the max of 2 values 
// MIN3(a,b,c): 	Returns the min of 3 values 
// MAX3(a,b,c): 	Returns the min of 3 values 
// BETWEEN(a,b,c):	Returns TRUE if b is between a and c (inclusive)
// FORCEPIN(a,b,c):	Forces value (b) to be between a and c
// SIGN(a):			Returns -1 if a<0, 1 if a>0 and 0 if a=0
#define MIN(a,b) ((a)<=(b)?(a):(b))
#define MAX(a,b) ((a)>=(b)?(a):(b))
#define MIN3(a,b,c) ((a)<=(b) ? (a)<=(c)?(a):(c) : (b)<=(c)?(b):(c) )
#define MAX3(a,b,c) ((a)>=(b) ? (a)>=(c)?(a):(c) : (b)>=(c)?(b):(c) )
#define BETWEEN(a,b,c) ((a)<=(b) and (b)<=(c))
#define FORCEPIN(a,b,c) ((a)>(b) ? (a) : (b)>(c) ? (c) : (b))	
#define SIGN(a) ((a)>0 ? 1 : (a)<0 ? -1 : 0)


///////////////////////////////////////////////////////////////////////////////
// Log of 2 related macros
// FloorLog2(x): Closest lower exponent of 2. Ex: FloorLog2(1000)=9 because 2^9=512 
// RoundLog2(x): Closest exponent of 2
// CeilLog2(x):  Closest higher exponent of 2
#define Ln2 0.69314718055994530941723212145818 // log(2)
#define InvLn2 1.4426950408889634073599246810019       // 1/log(2)
#define FloorLog2(x) ((int)(floor(log(x)*InvLn2)))
#define RoundLog2(x) ((int)(floor(log(x)*InvLn2+0.5)))
#define CeilLog2(x) ((int)(ceil(log(x)*InvLn2)))


///////////////////////////////////////////////////////////////////////////////
// Complex numbers
typedef struct {
	float Re, Im;
} complex;

//typedef enum {false, true} bool;


// Basic types (from Windows)
#pragma warning(disable:4209 4142)

typedef unsigned char  BYTE;        // 8-bit unsigned entity
typedef unsigned short WORD;        // 16-bit unsigned number
typedef unsigned int   UINT;        // machine sized unsigned number (preferred)
//typedef long           LONG;      // 32-bit signed number
typedef unsigned long  DWORD;       // 32-bit unsigned number
//typedef short          BOOL;      // BOOLean (0 or !=0)
typedef void*          POSITION;    // abstract iteration position

#ifndef TRUE
	#define TRUE 1
	#define FALSE 0
#endif
#ifndef YES
	#define YES 1
	#define NO 0
#endif
#ifndef OPEN
	#define OPEN 1
	#define CLOSE 0
#endif
#ifndef MODIF
	#define MODIF 1
	#define NOMODIF 0
#endif

#pragma warning(default:4209 4142)


///////////////////////////////////////////////////////////////////////////////
#ifdef _DEBUG
	// NOTE: you should #include <stdlib.h> if you use those macros
	#define TRACE     printf
	#define ASSERT(f) ((f) ? (void)0 : printf("Assertion " #f " failed file %s line %d",__FILE__, __LINE__))
#else
	#define ASSERT(f) ((void)0)
	#define TRACE     ((void)0)
#endif // _DEBUG


#endif // _DEF
