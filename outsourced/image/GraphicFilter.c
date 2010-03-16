/////////////////////////////////////////////////////////////////////////////////////
// MODULE:    GraphicFilter.c                                                      //
// COPYRIGHT: Guillaume Dargaud 2001-2002 - Free Use and distribution              //
// PURPOSE:   Applies a pixel transform, 3x3 matrix transfom (filter) ,			   //
//            5x5 or interchannel filter to a bitmap image                         //
// TUTORIAL:  http://www.gdargaud.net/Hack/SourceCode.html                         //
// NOTE:      This is an ANSI C program. If it was written in MMX assembler,	   //
//            it'd be _much_ faster... But then it would be called PhotoShop...    //
// NOTE:      Custom filters can be filled in with special CVI popups: FilterPopup.c/
/////////////////////////////////////////////////////////////////////////////////////

//#include <ansi_c.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "Def.h"
#include "GraphicFilter.h"

// Predefined filters

// Pixel filters, filter name, multipler, divider and bias
tFilter1x1 FilterId1x1=			{ "No __1x1 filter",	 1, 1,   0};
tFilter1x1 FilterNegative=		{ "__Negative",			-1, 1, 255};
tFilter1x1 FilterLighter=		{ "Lighter",			 1, 1,  32};
tFilter1x1 FilterDarker=		{ "Darker",				 1, 1, -32};
tFilter1x1 FilterContrastMore=	{ "Contrast __More",	 2, 1,-128};
tFilter1x1 FilterContrastLess=	{ "Contrast Less",		 1, 2,  64};
// Custom filters (parameters need to be filled in).
tFilter1x1 FilterHistStretch=	{ "Histogram S__tretch", 1, 1, 0};	// must be filled up by histogram function
tFilter1x1 FilterCustom1x1=		{ "__Custom Filter",	 1, 1, 0};	// must be custom defined. See FilterPopup.c


// Contains filter name, 3x3 matrix, divider and bias
tFilter3x3 FilterId3x3=			{ "No __3x3 filter",	{{ 0, 0, 0},{ 0, 1, 0},{ 0, 0, 0}},  1,   0};
tFilter3x3 FilterSmoothen=		{ "Smoothen", 			{{ 1, 1, 1},{ 1, 5, 1},{ 1, 1, 1}}, 13,   0};
tFilter3x3 FilterSharpen=		{ "__Sharpen", 			{{-1,-1,-1},{-1,16,-1},{-1,-1,-1}},  8,   0};
tFilter3x3 FilterSharpenStrong=	{ "Sharpen Strong",		{{-1,-1,-1},{-1, 9,-1},{-1,-1,-1}},  1,   0};
tFilter3x3 FilterFindEdges=		{ "__Find Edges", 		{{-1,-1,-1},{-1, 8,-1},{-1,-1,-1}},  1,   0};
tFilter3x3 FilterContour=		{ "Countour", 			{{-1,-1,-1},{-1, 8,-1},{-1,-1,-1}},  1, 255};
tFilter3x3 FilterEdgeDetect=	{ "Edge Detect",		{{ 1, 1, 1},{ 1,-7, 1},{ 1, 1, 1}},  1,   0};
tFilter3x3 FilterEdgeDetectSoft={ "Edge Detect Soft",	{{ 1, 1, 1},{ 1,-2, 1},{ 1, 1, 1}},  6,   0};
tFilter3x3 FilterEmboss=		{ "Emboss",				{{ 1, 1,-1},{ 1, 1,-1},{ 1,-1,-1}},  1,   0};
// Custom filters (parameters need to be filled in).
tFilter3x3 FilterCustom3x3=		{ "Custom 3x3 Filter",	{{ 0, 0, 0},{ 0, 1, 0},{ 0, 0, 0}},  1,   0};	// must be custom defined. See FilterPopup.c


// 5x5 filters
tFilter5x5 FilterId5x5=			{ "No __5x5 filter",    {{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0, 1, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0}},  1,   0};
tFilter5x5 FilterBlur=			{ "Blur",				{{ 1, 1, 1, 1, 1},{ 1, 1, 1, 1, 1},{ 1, 1, 1, 1, 1},{ 1, 1, 1, 1, 1},{ 1, 1, 1, 1, 1}},  25,   0};
tFilter5x5 FilterCustom5x5=		{ "Custom 5x5 filter",  {{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0, 1, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0}},  1,   0};

// Pixel filters equivalent (identical to Filter1x1 or Filter3x3)
// You can use those if you want only one kind of filter in your app, although you cannot mix channels
// Because of optimization, those filters are as fast as 1x1 or 3x3 filters
tFilter5x5 FilterNegative5x5=	{ "Negative",			{{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0, -1, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0}}, 1, 255};
tFilter5x5 FilterLighter5x5=	{ "Lighter",			{{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0,  1, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0}},  1,  32};
tFilter5x5 FilterDarker5x5=		{ "Darker",				{{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0,  1, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0}},  1, -32};
tFilter5x5 FilterContrastMore5x5={"Contrast More",		{{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0,  2, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0}},  1,-128};
tFilter5x5 FilterContrastLess5x5={"Contrast Less",		{{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0,  1, 0, 0},{ 0, 0, 0, 0, 0},{ 0, 0, 0, 0, 0}},  2,  64};

tFilter5x5 FilterSmoothen5x5=	{ "Smoothen", 			{{ 0, 0, 0, 0, 0},{0, 1, 1, 1,0},{0, 1, 5, 1,0},{0, 1, 1, 1,0},{ 0, 0, 0, 0, 0}}, 13,   0};
tFilter5x5 FilterSharpen5x5=	{ "__Sharpen", 			{{ 0, 0, 0, 0, 0},{0,-1,-1,-1,0},{0,-1,16,-1,0},{0,-1,-1,-1,0},{ 0, 0, 0, 0, 0}},  8,   0};
tFilter5x5 FilterSharpenStrong5x5={"Sharpen Strong",	{{ 0, 0, 0, 0, 0},{0,-1,-1,-1,0},{0,-1, 9,-1,0},{0,-1,-1,-1,0},{ 0, 0, 0, 0, 0}},  1,   0};
tFilter5x5 FilterFindEdges5x5=	{ "__Find Edges", 		{{ 0, 0, 0, 0, 0},{0,-1,-1,-1,0},{0,-1, 8,-1,0},{0,-1,-1,-1,0},{ 0, 0, 0, 0, 0}},  1,   0};
tFilter5x5 FilterContour5x5=	{ "Countour", 			{{ 0, 0, 0, 0, 0},{0,-1,-1,-1,0},{0,-1, 8,-1,0},{0,-1,-1,-1,0},{ 0, 0, 0, 0, 0}},  1, 255};
tFilter5x5 FilterEdgeDetect5x5=	{ "Edge Detect",		{{ 0, 0, 0, 0, 0},{0, 1, 1, 1,0},{0, 1,-7, 1,0},{0, 1, 1, 1,0},{ 0, 0, 0, 0, 0}},  1,   0};
tFilter5x5 FilterEdgeDetectSoft5x5={"Edge Detect Soft",	{{ 0, 0, 0, 0, 0},{0, 1, 1, 1,0},{0, 1,-2, 1,0},{0, 1, 1, 1,0},{ 0, 0, 0, 0, 0}},  6,   0};
tFilter5x5 FilterEmboss5x5=		{ "Emboss",				{{ 0, 0, 0, 0, 0},{0, 1, 1,-1,0},{0, 1, 1,-1,0},{0, 1,-1,-1,0},{ 0, 0, 0, 0, 0}},  1,   0};



// 1x1 channel filters
tFilter1C FilterId1C=			{ "No channel filter", 	{{ 1, 0, 0, 0},		{ 0, 1, 0, 0},		{ 0, 0, 1, 0},		{ 0, 0, 0, 1}},	{ 1, 1, 1, 1},	{ 0, 0, 0, 0}};
tFilter1C FilterMonochrome=		{ "Monochrome",			{{ 77, 150, 29, 0},	{ 77, 150, 29, 0},	{ 77, 150, 29, 0},	{ 0, 0, 0, 1}},	{ 256, 256, 256, 1},{ 0, 0, 0, 0}};
tFilter1C FilterGBR2RGB=		{ "GBR -> RGB",			{{ 0, 1, 0, 0},		{ 0, 0, 1, 0},		{ 1, 0, 0, 0},		{ 0, 0, 0, 1}},	{ 1, 1, 1, 1},	{ 0, 0, 0, 0}};
tFilter1C FilterBRG2RGB=		{ "BRG -> RGB",			{{ 0, 0, 1, 0},		{ 1, 0, 0, 0},		{ 0, 1, 0, 0},		{ 0, 0, 0, 1}},	{ 1, 1, 1, 1},	{ 0, 0, 0, 0}};
tFilter1C FilterWhiteAlpha=		{ "White Alpha",		{{ 1, 0, 0, 256},	{ 0, 1, 0, 256},	{ 0, 0, 1, 256},	{ 0,0,0,1}},  	{ 1, 1, 1, 1},	{ 0, 0, 0, 0}};
tFilter1C FilterCustom1C=		{ "Custom Filter",		{{ 1, 0, 0, 0},		{ 0, 1, 0, 0},		{ 0, 0, 1, 0},		{ 0, 0, 0, 1}},	{ 1, 1, 1, 1},	{ 0, 0, 0, 0}};


///////////////////////////////////////////////////////////////////////////////
// Array of filters for ready availability
tFilter1x1 *Filters1x1[NbFilters1x1]={	&FilterId1x1,			&FilterNegative, 		&FilterLighter,			
										&FilterDarker,			&FilterContrastMore,	&FilterContrastLess,	
										&FilterHistStretch,		&FilterCustom1x1};

// Array of filters for ready availability
tFilter3x3 *Filters3x3[NbFilters3x3]={	&FilterId3x3,			&FilterSmoothen,		&FilterSharpen, 
										&FilterSharpenStrong,	&FilterFindEdges,		&FilterContour, 
										&FilterEdgeDetect,		&FilterEdgeDetectSoft,	&FilterEmboss,
										&FilterCustom3x3};

// Array of filters for ready availability
tFilter5x5 *Filters5x5[NbFilters5x5]={	&FilterId5x5,			
										&FilterNegative5x5,		&FilterLighter5x5,		&FilterDarker5x5,
										&FilterContrastMore5x5,	&FilterContrastLess5x5,
										&FilterSmoothen5x5,		&FilterSharpen5x5,		&FilterSharpenStrong5x5,
										&FilterFindEdges5x5,	&FilterContour5x5,		&FilterEdgeDetect5x5,
										&FilterEdgeDetectSoft5x5,&FilterEmboss5x5,
										&FilterBlur,			&FilterCustom5x5};

// Array of filters for ready availability
tFilter1C *Filters1C[NbFilters1C]=	{	&FilterId1C,			&FilterMonochrome, 		&FilterGBR2RGB,		
										&FilterBRG2RGB,			&FilterWhiteAlpha,		&FilterCustom1C};

//// Array of filters for ready availability
//tFilter3x3 *Filters[NbFilters]={&FilterId,				&FilterSmoothen,		&FilterSharpen, 
//								&FilterSharpenStrong,	&FilterFindEdges,		&FilterContour, 
//								&FilterEdgeDetect,		&FilterEdgeDetectSoft,	&FilterEmboss,
//								&FilterNegative3x3, 	&FilterLighter3x3,		&FilterDarker3x3,
//								&FilterContrastMore3x3,	&FilterContrastLess3x3,	&FilterCustom3x3};


///////////////////////////////////////////////////////////////////////////////
// FUNCTION: Filter1x1
// PURPOSE: applies a simple bit transform to a bitmap image
// INOUT: Bits, bitmap image
// IN: Rowbytes: number of bytes of each row of the image (the image occupies Rowbytes*Height bytes)
//     PixDepth: pixel depth of the image. Accepted values are 8 (greyscale), 24 (RGB) and 32 (RGBA)
//     Width, Heigth: in pixels
// 	   Filter: filter to apply
///////////////////////////////////////////////////////////////////////////////
void Filter1x1(unsigned char *Bits, 
				const int RowBytes, const int PixDepth, 
				const int Width, const int Height,
				tFilter1x1 *Filter) {
	register unsigned char *Pos=Bits, *Limit=Bits+RowBytes*Height;
	register long C;
	
	if (Filter==NULL or Bits==NULL) return;

	if (Filter->Div==0) Filter->Div=1;	// Div must be !=0 (and normally >0)

	// This 'if' is optional and can be removed for tests. It speeds up the program a lot, though.
	if (Filter->Mult==1 and Filter->Div==1 and Filter->Bias==0) return;
	
	while (Pos<Limit) {
		C = (*Pos * Filter->Mult) / Filter->Div + Filter->Bias;
		*Pos++ = (unsigned char)FORCEPIN(0,C,255);
	}
}



///////////////////////////////////////////////////////////////////////////////
// FUNCTION: Filter1C
// PURPOSE: applies a simple bit transform to a bitmap image, mixing up the channels
// INOUT: Bits, bitmap image
// IN: Rowbytes: number of bytes of each row of the image (the image occupies Rowbytes*Height bytes)
//     PixDepth: pixel depth of the image. Accepted values are 8 (greyscale), 24 (RGB) and 32 (RGBA)
//     Width, Heigth: in pixels
// 	   Filter: filter to apply
// NOTE: acts only on RGB or RGBA images
///////////////////////////////////////////////////////////////////////////////
void Filter1C(unsigned char *Bits, 
				const int RowBytes, const int PixDepth, 
				const int Width, const int Height,
				tFilter1C *Filter) {
	register unsigned char *Pos=Bits, *Limit=Bits+RowBytes*Height;
	long R, G, B, A;
	
	if (Filter==NULL or Bits==NULL or PixDepth<24) return;

	if (Filter->Div[0]==0) Filter->Div[0]=1;	// Div must be !=0 (and normally >0)
	if (Filter->Div[1]==0) Filter->Div[1]=1;
	if (Filter->Div[2]==0) Filter->Div[2]=1;
	if (Filter->Div[3]==0) Filter->Div[3]=1;

	// This 'if' is optional and can be removed for tests. It speeds up the program a lot, though.
	if (						  Filter->Mult[1][0]==0 and Filter->Mult[2][0]==0 and  Filter->Mult[3][0]==0 and
		Filter->Mult[0][1]==0 and                           Filter->Mult[2][1]==0 and  Filter->Mult[3][1]==0 and 
		Filter->Mult[0][2]==0 and Filter->Mult[1][2]==0 and                            Filter->Mult[3][2]==0 and 
		Filter->Mult[0][3]==0 and Filter->Mult[1][3]==0 and Filter->Mult[2][3]==0 and 
		Filter->Mult[0][0]*Filter->Div[1]==Filter->Mult[1][1]*Filter->Div[0] and
		Filter->Mult[1][1]*Filter->Div[2]==Filter->Mult[2][2]*Filter->Div[1] and
		Filter->Mult[2][2]*Filter->Div[3]==Filter->Mult[3][3]*Filter->Div[2] and
		Filter->Mult[3][3]*Filter->Div[0]==Filter->Mult[0][0]*Filter->Div[3] and
		Filter->Bias[0]==Filter->Bias[1] and
		Filter->Bias[1]==Filter->Bias[2] and
		Filter->Bias[2]==Filter->Bias[3] and
		Filter->Bias[3]==Filter->Bias[0]) {
			// Use faster and more simple routine
			tFilter1x1 FilterSmpl;
			FilterSmpl.Mult = Filter->Mult[0][0];
			FilterSmpl.Div  = Filter->Div[0];
			FilterSmpl.Bias = Filter->Bias[0];
			Filter1x1(Bits, RowBytes, PixDepth, Width, Height, &FilterSmpl);
			return;
	}

	
	if (PixDepth==32) while (Pos<Limit) {	// RGBA
		R = (Pos[0]*Filter->Mult[0][0] + Pos[1]*Filter->Mult[0][1] + Pos[2]*Filter->Mult[0][2] + Pos[3]*Filter->Mult[0][3])/Filter->Div[0] + Filter->Bias[0];
		G = (Pos[0]*Filter->Mult[1][0] + Pos[1]*Filter->Mult[1][1] + Pos[2]*Filter->Mult[1][2] + Pos[3]*Filter->Mult[1][3])/Filter->Div[1] + Filter->Bias[1];
		B = (Pos[0]*Filter->Mult[2][0] + Pos[1]*Filter->Mult[2][1] + Pos[2]*Filter->Mult[2][2] + Pos[3]*Filter->Mult[2][3])/Filter->Div[2] + Filter->Bias[2];
		A = (Pos[0]*Filter->Mult[3][0] + Pos[1]*Filter->Mult[3][1] + Pos[2]*Filter->Mult[3][2] + Pos[3]*Filter->Mult[3][3])/Filter->Div[3] + Filter->Bias[3];
		Pos[0] = (unsigned char)FORCEPIN(0,R,255);
		Pos[1] = (unsigned char)FORCEPIN(0,G,255);
		Pos[2] = (unsigned char)FORCEPIN(0,B,255);
		Pos[3] = (unsigned char)FORCEPIN(0,A,255);
		Pos+=4;
	} else while (Pos<Limit) {		// RGB
		R = (Pos[0]*Filter->Mult[0][0] + Pos[1]*Filter->Mult[0][1] + Pos[2]*Filter->Mult[0][2])/Filter->Div[0] + Filter->Bias[0];
		G = (Pos[0]*Filter->Mult[1][0] + Pos[1]*Filter->Mult[1][1] + Pos[2]*Filter->Mult[1][2])/Filter->Div[1] + Filter->Bias[1];
		B = (Pos[0]*Filter->Mult[2][0] + Pos[1]*Filter->Mult[2][1] + Pos[2]*Filter->Mult[2][2])/Filter->Div[2] + Filter->Bias[2];
		Pos[0] = (unsigned char)FORCEPIN(0,R,255);
		Pos[1] = (unsigned char)FORCEPIN(0,G,255);
		Pos[2] = (unsigned char)FORCEPIN(0,B,255);
		Pos+=3;
	}
}



///////////////////////////////////////////////////////////////////////////////
// FUNCTION: Filter3x3
// PURPOSE: applies a 3x3 matrix transform to a bitmap image
// INOUT: Bits, bitmap image
// IN: Rowbytes: number of bytes of each row of the image (the image occupies Rowbytes*Height bytes)
//     PixDepth: pixel depth of the image. Accepted values are 8 (greyscale), 24 (RGB) and 32 (RGBA)
//     Width, Heigth: in pixels
// 	   Filter: filter to apply
// NOTE: the borders of the image (one pixel) are left unchanged
///////////////////////////////////////////////////////////////////////////////
void Filter3x3(unsigned char *Bits, 
				const int RowBytes, const int PixDepth, 
				const int Width, const int Height,
				tFilter3x3 *Filter) {
	static unsigned char *PrevLine=NULL, *CurrentLine=NULL, *NextLine=NULL, *TempLine, *Dest, *Pos[3][3];
	static int LastRowBytes=0;

	int BytesPerPixel=PixDepth/8, x, y, C;
	
	if (Filter==NULL or Bits==NULL) return;

	if (Filter->Div==0) Filter->Div=1;	// Div must be !=0 (and normally >0)
	
	// This 'if' is optional and can be removed for tests. It speeds up the program a lot, though.
	if (Filter->Mult[0][0]==0 and Filter->Mult[0][1]==0 and Filter->Mult[0][2]==0 and 
		Filter->Mult[1][0]==0 and                          Filter->Mult[1][2]==0 and 
		Filter->Mult[2][0]==0 and Filter->Mult[2][1]==0 and Filter->Mult[2][2]==0) {
			// Use faster and more simple routine
			tFilter1x1 FilterSmpl;
			FilterSmpl.Mult = Filter->Mult[1][1];
			FilterSmpl.Div  = Filter->Div;
			FilterSmpl.Bias = Filter->Bias;
			Filter1x1(Bits, RowBytes, PixDepth, Width, Height, &FilterSmpl);
			return;
	}

	if (RowBytes>LastRowBytes) {	// First or reallocation
		if (PrevLine!=NULL) free(PrevLine),free(CurrentLine),free(NextLine);
		LastRowBytes=RowBytes;
		PrevLine=Calloc(RowBytes, unsigned char);
		CurrentLine=Calloc(RowBytes, unsigned char);
		NextLine=Calloc(RowBytes, unsigned char);
		// Those are not freed when program exits...
	}
	
	// Junk in LastLine
	memcpy(CurrentLine, Bits, RowBytes);
	memcpy(NextLine, &Bits[RowBytes], RowBytes);
	for (y=1; y<Height-1; y++) {
		TempLine=PrevLine;		// We cycle all 3 so memory moves are not necessary
		PrevLine=CurrentLine;
		CurrentLine=NextLine;
		NextLine=TempLine;
		memcpy(NextLine, &Bits[RowBytes*(y+1)], RowBytes);
		
		Pos[0][0]=PrevLine;    Pos[0][1]=PrevLine+BytesPerPixel;	Pos[0][2]=PrevLine+BytesPerPixel*2;   	// First letter is the column
		Pos[1][0]=CurrentLine; Pos[1][1]=CurrentLine+BytesPerPixel; Pos[1][2]=CurrentLine+BytesPerPixel*2;	// 2nd letter is the line
		Pos[2][0]=NextLine;    Pos[2][1]=NextLine+BytesPerPixel;	Pos[2][2]=NextLine+BytesPerPixel*2;   
		
		Dest=&Bits[1*BytesPerPixel + y*RowBytes];

		for (x=1; x<Width-1; x++) {
			// Red or Grey
			C=	(Filter->Mult[0][0]* *Pos[0][0]++ + Filter->Mult[0][1]* *Pos[0][1]++ + Filter->Mult[0][2]* *Pos[0][2]++ +
				 Filter->Mult[1][0]* *Pos[1][0]++ + Filter->Mult[1][1]* *Pos[1][1]++ + Filter->Mult[1][2]* *Pos[1][2]++ +
				 Filter->Mult[2][0]* *Pos[2][0]++ + Filter->Mult[2][1]* *Pos[2][1]++ + Filter->Mult[2][2]* *Pos[2][2]++) 
				 / Filter->Div + Filter->Bias;
			*Dest++=(unsigned char)FORCEPIN(0,C,255);
			
			if (BytesPerPixel==1) continue;

			// Green
			C=	(Filter->Mult[0][0]* *Pos[0][0]++ + Filter->Mult[0][1]* *Pos[0][1]++ + Filter->Mult[0][2]* *Pos[0][2]++ +
				 Filter->Mult[1][0]* *Pos[1][0]++ + Filter->Mult[1][1]* *Pos[1][1]++ + Filter->Mult[1][2]* *Pos[1][2]++ +
				 Filter->Mult[2][0]* *Pos[2][0]++ + Filter->Mult[2][1]* *Pos[2][1]++ + Filter->Mult[2][2]* *Pos[2][2]++) 
				 / Filter->Div + Filter->Bias;
			*Dest++=(unsigned char)FORCEPIN(0,C,255);

			// Blue
			C=	(Filter->Mult[0][0]* *Pos[0][0]++ + Filter->Mult[0][1]* *Pos[0][1]++ + Filter->Mult[0][2]* *Pos[0][2]++ +
				 Filter->Mult[1][0]* *Pos[1][0]++ + Filter->Mult[1][1]* *Pos[1][1]++ + Filter->Mult[1][2]* *Pos[1][2]++ +
				 Filter->Mult[2][0]* *Pos[2][0]++ + Filter->Mult[2][1]* *Pos[2][1]++ + Filter->Mult[2][2]* *Pos[2][2]++) 
				 / Filter->Div + Filter->Bias;
			*Dest++=(unsigned char)FORCEPIN(0,C,255);
			
			if (BytesPerPixel==3) continue;

			// Alpha
			C=	(Filter->Mult[0][0]* *Pos[0][0]++ + Filter->Mult[0][1]* *Pos[0][1]++ + Filter->Mult[0][2]* *Pos[0][2]++ +
				 Filter->Mult[1][0]* *Pos[1][0]++ + Filter->Mult[1][1]* *Pos[1][1]++ + Filter->Mult[1][2]* *Pos[1][2]++ +
				 Filter->Mult[2][0]* *Pos[2][0]++ + Filter->Mult[2][1]* *Pos[2][1]++ + Filter->Mult[2][2]* *Pos[2][2]++) 
				 / Filter->Div + Filter->Bias;
			*Dest++=(unsigned char)FORCEPIN(0,C,255);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// FUNCTION: Filter5x5
// PURPOSE: applies a 5x5 matrix transform to a bitmap image
// INOUT: Bits, bitmap image
// IN: Rowbytes: number of bytes of each row of the image (the image occupies Rowbytes*Height bytes)
//     PixDepth: pixel depth of the image. Accepted values are 8 (greyscale), 24 (RGB) and 32 (RGBA)
//     Width, Heigth: in pixels
// 	   Filter: filter to apply
// NOTE: the borders of the image (two pixels) are left unchanged
///////////////////////////////////////////////////////////////////////////////
void Filter5x5(unsigned char *Bits, 
				const int RowBytes, const int PixDepth, 
				const int Width, const int Height,
				tFilter5x5 *Filter) {
	static unsigned char *PPLine=NULL, *PrevLine=NULL, *CurrentLine=NULL, *NextLine=NULL, *NNLine=NULL, 
						*TempLine=NULL, *Dest=NULL, *Pos[5][5];
	static int LastRowBytes=0;

	int BytesPerPixel=PixDepth/8, x, y, C;
	
	if (Filter==NULL or Bits==NULL) return;

	if (Filter->Div==0) Filter->Div=1;	// Div must be !=0 (and normally >0)
	
	// This 'if' is optional and can be removed for tests. It speeds up the program a lot, though.
	if (Filter->Mult[0][0]==0 and Filter->Mult[0][1]==0 and Filter->Mult[0][2]==0 and Filter->Mult[0][3]==0 and Filter->Mult[0][4]==0 and 
		Filter->Mult[1][0]==0 and                                                                               Filter->Mult[1][4]==0 and 
		Filter->Mult[2][0]==0 and                                                                               Filter->Mult[2][4]==0 and 
		Filter->Mult[3][0]==0 and                                                                               Filter->Mult[3][4]==0 and 
		Filter->Mult[4][0]==0 and Filter->Mult[4][1]==0 and Filter->Mult[4][2]==0 and Filter->Mult[4][3]==0 and Filter->Mult[4][4]==0) {
			// Use faster and more simple routine
			tFilter3x3 Filter3;
			Filter3.Mult[0][0] = Filter->Mult[1][1]; 
			Filter3.Mult[0][1] = Filter->Mult[1][2]; 
			Filter3.Mult[0][2] = Filter->Mult[1][3];
			Filter3.Mult[1][0] = Filter->Mult[2][1];                          
			Filter3.Mult[1][1] = Filter->Mult[2][2]; 
			Filter3.Mult[1][2] = Filter->Mult[2][3];
			Filter3.Mult[2][0] = Filter->Mult[3][1];
			Filter3.Mult[2][1] = Filter->Mult[3][2];
			Filter3.Mult[2][2] = Filter->Mult[3][3];
			Filter3.Div        = Filter->Div;
			Filter3.Bias       = Filter->Bias;
			Filter3x3(Bits, RowBytes, PixDepth, Width, Height, &Filter3);
			return;
	}

	if (RowBytes>LastRowBytes) {	// First or reallocation
		if (PrevLine!=NULL) free(PrevLine),free(CurrentLine),free(NextLine);
		LastRowBytes=RowBytes;
		PPLine=Calloc(RowBytes, unsigned char);
		PrevLine=Calloc(RowBytes, unsigned char);
		CurrentLine=Calloc(RowBytes, unsigned char);
		NextLine=Calloc(RowBytes, unsigned char);
		NNLine=Calloc(RowBytes, unsigned char);
		// Those are not freed when program exits...
	}
	
	// Junk in LastLine
	memcpy(CurrentLine, Bits, RowBytes);
	memcpy(NNLine, &Bits[RowBytes], RowBytes);
	for (y=2; y<Height-2; y++) {
		TempLine=PrevLine;		// We cycle all 5 so memory moves are not necessary
		PPLine=PrevLine;
		PrevLine=CurrentLine;
		CurrentLine=NextLine;
		NextLine=NNLine;
		NNLine=TempLine;
		memcpy(NNLine, &Bits[RowBytes*(y+1)], RowBytes);
		
		Pos[0][0]=PPLine;      Pos[0][1]=PPLine+BytesPerPixel;	    Pos[0][2]=PPLine+BytesPerPixel*2;      Pos[0][3]=PPLine+BytesPerPixel*3;	  Pos[0][4]=PPLine+BytesPerPixel*4;	
		Pos[1][0]=PrevLine;    Pos[1][1]=PrevLine+BytesPerPixel;	Pos[1][2]=PrevLine+BytesPerPixel*2;    Pos[1][3]=PrevLine+BytesPerPixel*3;    Pos[1][4]=PrevLine+BytesPerPixel*4;  
		Pos[2][0]=CurrentLine; Pos[2][1]=CurrentLine+BytesPerPixel; Pos[2][2]=CurrentLine+BytesPerPixel*2; Pos[2][3]=CurrentLine+BytesPerPixel*3; Pos[2][4]=CurrentLine+BytesPerPixel*4;
		Pos[3][0]=NextLine;    Pos[3][1]=NextLine+BytesPerPixel;	Pos[3][2]=NextLine+BytesPerPixel*2;    Pos[3][3]=NextLine+BytesPerPixel*3;    Pos[3][4]=NextLine+BytesPerPixel*4;   
		Pos[4][0]=NNLine;      Pos[4][1]=NNLine+BytesPerPixel;	    Pos[4][2]=NNLine+BytesPerPixel*2;      Pos[4][3]=NNLine+BytesPerPixel*3;      Pos[4][4]=NNLine+BytesPerPixel*4;   
		
		Dest=&Bits[1*BytesPerPixel + y*RowBytes];

		for (x=2; x<Width-2; x++) {
			// Red or Grey
			C=	(Filter->Mult[0][0]* *Pos[0][0]++ + Filter->Mult[0][1]* *Pos[0][1]++ + Filter->Mult[0][2]* *Pos[0][2]++ + Filter->Mult[0][3]* *Pos[0][3]++ + Filter->Mult[0][4]* *Pos[0][4]++ +
				 Filter->Mult[1][0]* *Pos[1][0]++ + Filter->Mult[1][1]* *Pos[1][1]++ + Filter->Mult[1][2]* *Pos[1][2]++ + Filter->Mult[1][3]* *Pos[1][3]++ + Filter->Mult[1][4]* *Pos[1][4]++ +
				 Filter->Mult[2][0]* *Pos[2][0]++ + Filter->Mult[2][1]* *Pos[2][1]++ + Filter->Mult[2][2]* *Pos[2][2]++ + Filter->Mult[2][3]* *Pos[2][3]++ + Filter->Mult[2][4]* *Pos[2][4]++ +
				 Filter->Mult[3][0]* *Pos[3][0]++ + Filter->Mult[3][1]* *Pos[3][1]++ + Filter->Mult[3][2]* *Pos[3][2]++ + Filter->Mult[3][3]* *Pos[3][3]++ + Filter->Mult[3][4]* *Pos[3][4]++ +
				 Filter->Mult[4][0]* *Pos[4][0]++ + Filter->Mult[4][1]* *Pos[4][1]++ + Filter->Mult[4][2]* *Pos[4][2]++ + Filter->Mult[4][3]* *Pos[4][3]++ + Filter->Mult[4][4]* *Pos[4][4]++) 
				 / Filter->Div + Filter->Bias;
			*Dest++=(unsigned char)FORCEPIN(0,C,255);
			
			if (BytesPerPixel==1) continue;

			// Green
			C=	(Filter->Mult[0][0]* *Pos[0][0]++ + Filter->Mult[0][1]* *Pos[0][1]++ + Filter->Mult[0][2]* *Pos[0][2]++ + Filter->Mult[0][3]* *Pos[0][3]++ + Filter->Mult[0][4]* *Pos[0][4]++ +
				 Filter->Mult[1][0]* *Pos[1][0]++ + Filter->Mult[1][1]* *Pos[1][1]++ + Filter->Mult[1][2]* *Pos[1][2]++ + Filter->Mult[1][3]* *Pos[1][3]++ + Filter->Mult[1][4]* *Pos[1][4]++ +
				 Filter->Mult[2][0]* *Pos[2][0]++ + Filter->Mult[2][1]* *Pos[2][1]++ + Filter->Mult[2][2]* *Pos[2][2]++ + Filter->Mult[2][3]* *Pos[2][3]++ + Filter->Mult[2][4]* *Pos[2][4]++ +
				 Filter->Mult[3][0]* *Pos[3][0]++ + Filter->Mult[3][1]* *Pos[3][1]++ + Filter->Mult[3][2]* *Pos[3][2]++ + Filter->Mult[3][3]* *Pos[3][3]++ + Filter->Mult[3][4]* *Pos[3][4]++ +
				 Filter->Mult[4][0]* *Pos[4][0]++ + Filter->Mult[4][1]* *Pos[4][1]++ + Filter->Mult[4][2]* *Pos[4][2]++ + Filter->Mult[4][3]* *Pos[4][3]++ + Filter->Mult[4][4]* *Pos[4][4]++) 
				 / Filter->Div + Filter->Bias;
			*Dest++=(unsigned char)FORCEPIN(0,C,255);

			// Blue
			C=	(Filter->Mult[0][0]* *Pos[0][0]++ + Filter->Mult[0][1]* *Pos[0][1]++ + Filter->Mult[0][2]* *Pos[0][2]++ + Filter->Mult[0][3]* *Pos[0][3]++ + Filter->Mult[0][4]* *Pos[0][4]++ +
				 Filter->Mult[1][0]* *Pos[1][0]++ + Filter->Mult[1][1]* *Pos[1][1]++ + Filter->Mult[1][2]* *Pos[1][2]++ + Filter->Mult[1][3]* *Pos[1][3]++ + Filter->Mult[1][4]* *Pos[1][4]++ +
				 Filter->Mult[2][0]* *Pos[2][0]++ + Filter->Mult[2][1]* *Pos[2][1]++ + Filter->Mult[2][2]* *Pos[2][2]++ + Filter->Mult[2][3]* *Pos[2][3]++ + Filter->Mult[2][4]* *Pos[2][4]++ +
				 Filter->Mult[3][0]* *Pos[3][0]++ + Filter->Mult[3][1]* *Pos[3][1]++ + Filter->Mult[3][2]* *Pos[3][2]++ + Filter->Mult[3][3]* *Pos[3][3]++ + Filter->Mult[3][4]* *Pos[3][4]++ +
				 Filter->Mult[4][0]* *Pos[4][0]++ + Filter->Mult[4][1]* *Pos[4][1]++ + Filter->Mult[4][2]* *Pos[4][2]++ + Filter->Mult[4][3]* *Pos[4][3]++ + Filter->Mult[4][4]* *Pos[4][4]++) 
				 / Filter->Div + Filter->Bias;
			*Dest++=(unsigned char)FORCEPIN(0,C,255);
			
			if (BytesPerPixel==3) continue;

			// Alpha
			C=	(Filter->Mult[0][0]* *Pos[0][0]++ + Filter->Mult[0][1]* *Pos[0][1]++ + Filter->Mult[0][2]* *Pos[0][2]++ + Filter->Mult[0][3]* *Pos[0][3]++ + Filter->Mult[0][4]* *Pos[0][4]++ +
				 Filter->Mult[1][0]* *Pos[1][0]++ + Filter->Mult[1][1]* *Pos[1][1]++ + Filter->Mult[1][2]* *Pos[1][2]++ + Filter->Mult[1][3]* *Pos[1][3]++ + Filter->Mult[1][4]* *Pos[1][4]++ +
				 Filter->Mult[2][0]* *Pos[2][0]++ + Filter->Mult[2][1]* *Pos[2][1]++ + Filter->Mult[2][2]* *Pos[2][2]++ + Filter->Mult[2][3]* *Pos[2][3]++ + Filter->Mult[2][4]* *Pos[2][4]++ +
				 Filter->Mult[3][0]* *Pos[3][0]++ + Filter->Mult[3][1]* *Pos[3][1]++ + Filter->Mult[3][2]* *Pos[3][2]++ + Filter->Mult[3][3]* *Pos[3][3]++ + Filter->Mult[3][4]* *Pos[3][4]++ +
				 Filter->Mult[4][0]* *Pos[4][0]++ + Filter->Mult[4][1]* *Pos[4][1]++ + Filter->Mult[4][2]* *Pos[4][2]++ + Filter->Mult[4][3]* *Pos[4][3]++ + Filter->Mult[4][4]* *Pos[4][4]++) 
				 / Filter->Div + Filter->Bias;
			*Dest++=(unsigned char)FORCEPIN(0,C,255);
		}
	}
}