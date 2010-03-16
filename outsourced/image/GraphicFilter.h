#ifndef _GRAPHIC_FILTER
#define _GRAPHIC_FILTER

// 1x1 filter (acts only on one pixel)
typedef struct sFilter1x1 {
	char* Name;			// Name of the filter
	int Mult;			// Multiplier
	int Div;			// Divider
	int Bias;			// Bias. Note that to keep the lightness of an image Sum(Mat)/Div+Bias should be equal to 1
} tFilter1x1;

// 3x3 filter (acts on 9 surrounding pixels)
typedef struct sFilter3x3 {
	char* Name;			// Name of the filter
	int Mult[3][3];		// 3x3 matrix. The central pixel is the pixel where the transformation is applied
	int Div;			// Divider
	int Bias;			// Bias. Note that to keep the lightness of an image Sum(Mat)/Div+Bias should be equal to 1
} tFilter3x3;

// 5x5 filter (acts on 25 surrounding pixels)
typedef struct sFilter5x5 {
	char* Name;			// Name of the filter
	int Mult[5][5];		// 3x3 matrix. The central pixel is the pixel where the transformation is applied
	int Div;			// Divider
	int Bias;			// Bias. Note that to keep the lightness of an image Sum(Mat)/Div+Bias should be equal to 1
} tFilter5x5;

// 1x1 interchannel filter (acts only on one pixel through RGBA channels)
typedef struct sFilter1C {
	char* Name;			// Name of the filter
	int Mult[4][4];		// Multiplier [0][1] From Blue to Red
	int Div[4];			// Divider for R, G, B, A
	int Bias[4];		// Bias. Note that to keep the lightness of an image Sum(Mat)/Div+Bias should be equal to 1
} tFilter1C;


///////////////////////////////////////////////////////////////////////////////
// Predefined filters
extern tFilter1x1	FilterId1x1,			// This one does nothing, just for tests
					FilterNegative,			// 1x1
					FilterLighter,			// 1x1
					FilterDarker,			// 1x1
					FilterContrastMore,		// 1x1
					FilterContrastLess,		// 1x1
					FilterHistStretch,		// 1x1, to be defined
					FilterCustom1x1;		// To be defined

extern tFilter3x3	FilterId3x3, 			// This one does nothing, just for tests
					FilterSmoothen, 
					FilterSharpen, 
					FilterSharpenStrong,
					FilterFindEdges, 
					FilterContour,
					FilterEdgeDetect,
					FilterEdgeDetectSoft,
					FilterEmboss,
					FilterNegative3x3,			// 1x1
					FilterLighter3x3,			// 1x1
					FilterDarker3x3,			// 1x1
					FilterContrastMore3x3,		// 1x1
					FilterContrastLess3x3,		// 1x1
					FilterCustom3x3;		// To be defined

extern tFilter5x5	FilterId5x5, 			// This one does nothing, just for tests
					FilterBlur, 
					FilterCustom5x5;		// To be defined


extern tFilter1C	FilterId1C,
					FilterMonochrome,
					FilterGBR2RGB,
					FilterBRG2RGB,
					FilterWhiteAlpha,
					FilterCustom1C;


///////////////////////////////////////////////////////////////////////////////
//#define NbFilters 15		// predefined filters
#define NbFilters1x1 8		
#define NbFilters3x3 10		
#define NbFilters5x5 16	//3
#define NbFilters1C  6
extern tFilter1x1 *Filters1x1[NbFilters1x1];
extern tFilter3x3 *Filters3x3[NbFilters3x3];
extern tFilter5x5 *Filters5x5[NbFilters5x5];
extern tFilter1C  *Filters1C[NbFilters1C];
//extern tFilter3x3 *Filters[NbFilters];

extern void Filter1x1(unsigned char *Bits, 
				const int RowBytes, const int PixDepth, 
				const int Width, const int Height,
				tFilter1x1 *Filter);

extern void Filter3x3(unsigned char *Bits, 
				const int RowBytes, const int PixDepth, 
				const int Width, const int Height,
				tFilter3x3 *Filter);

extern void Filter5x5(unsigned char *Bits, 
				const int RowBytes, const int PixDepth, 
				const int Width, const int Height,
				tFilter5x5 *Filter);

extern void Filter1C(unsigned char *Bits, 
				const int RowBytes, const int PixDepth, 
				const int Width, const int Height,
				tFilter1C *Filter);
#endif