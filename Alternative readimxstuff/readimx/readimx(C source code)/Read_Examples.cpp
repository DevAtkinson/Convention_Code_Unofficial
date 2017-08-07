//--------------------------------------------------------------------------------------------------
//
// Copyright (C) 2001-2013 LaVision GmbH.  All Rights Reserved.
//
//--------------------------------------------------------------------------------------------------

/* Read_Examples: Examples for usage of the ReadDLL functions

	The Read_GeneralExample code gives an example for the general usage of
	the ReadIMX and ReadIM7 functions. The code loads a IMG/IMX/VEC file or a IM7/VC7, 
	prints out the size and type of the image or vector file and stores the raw data in a TXT file.
	When the files are compiled on a Linux system, the executable can be called
	with the filename as parameter and then call Read_GeneralExample.

	The BufferType_GetVector code shows how to get a single vector from a loaded vector field.

	The Write_GeneralExample code gives an example for writing IM7 files.

	The ReadIMX_cl function can be called with the CL code above of the function code.
	This function loads a IMG/IMX/IM7/VEC/VC7 file into a DaVis buffer.

  	The WriteIMG_cl function can be called with the CL code above of the function code.
	This function stores a DaVis buffer as IMG file.
*/

#pragma warning (disable: 4996) // fopen

#include "ReadIMX.h"
#include "ReadIM7.h"

/*****************************************************************************/
/* General Example                                                           */
/*****************************************************************************/

// Return TRUE if the vector exists
bool BufferType_GetVector( const BufferType& theBuffer, int theX, int theY, int theFrame, float& vx, float& vy, float& vz )
{
	vx=vy=vz = 0;
	if (theBuffer.image_sub_type<=0)
	{	// image
		return false;
	}

	int frameOffset = theFrame * theBuffer.nx * theBuffer.ny * theBuffer.nz;
	int width = theBuffer.nx;
	int height = theBuffer.ny;
	int componentOffset = width * height;
	int mode;

	if (theX<0 || theX>=width || theY<0 || theY>=height || theFrame<0 || theFrame>=theBuffer.nf)
	{	// invalid position
		return false;
	}

	switch (theBuffer.image_sub_type)
	{
		case 0:	// it's an image and no vector buffer
			return false;
		case 1:	//	PIV vector field with header and 4*2D field
			mode = (int) theBuffer.floatArray[ theX + theY*width + frameOffset ];
			if (mode<=0)
			{	// disabled vector
				return true;
			}
			if (mode>4)
			{	// interpolated or filled vector
				mode = 4;
			}
			mode--;
			vx = theBuffer.floatArray[ theX + theY*width + frameOffset + componentOffset*(mode*2+1) ];
			vy = theBuffer.floatArray[ theX + theY*width + frameOffset + componentOffset*(mode*2+2) ];
			break;
		case 2:	//	simple 2D vector field
			vx = theBuffer.floatArray[ theX + theY*width + frameOffset ];
			vy = theBuffer.floatArray[ theX + theY*width + frameOffset + componentOffset ];
			break;
		case 3:	// same as 1 + peak ratio
			mode = (int) theBuffer.floatArray[ theX + theY*width + frameOffset ];
			if (mode<=0)
			{	// disabled vector
				return true;
			}
			if (mode>4)
			{	// interpolated or filled vector
				mode = 4;
			}
			mode--;
			vx = theBuffer.floatArray[ theX + theY*width + frameOffset + componentOffset*(mode*2+1) ];
			vy = theBuffer.floatArray[ theX + theY*width + frameOffset + componentOffset*(mode*2+2) ];
			break;
		case 4:	// simple 3D vector field
			vx = theBuffer.floatArray[ theX + theY*width + frameOffset ];
			vy = theBuffer.floatArray[ theX + theY*width + frameOffset + componentOffset ];
			vz = theBuffer.floatArray[ theX + theY*width + frameOffset + componentOffset*2 ];
			break;
		case 5:	//	PIV vector field with header and 4*3D field + peak ratio
			mode = (int) theBuffer.floatArray[ theX + theY*width + frameOffset ];
			if (mode<=0)
			{	// disabled vector
				return true;
			}
			if (mode>4)
			{	// interpolated or filled vector
				mode = 4;
			}
			mode--;
			vx = theBuffer.floatArray[ theX + theY*width + frameOffset + componentOffset*(mode*3+1) ];
			vy = theBuffer.floatArray[ theX + theY*width + frameOffset + componentOffset*(mode*3+2) ];
			vz = theBuffer.floatArray[ theX + theY*width + frameOffset + componentOffset*(mode*3+3) ];
			break;
	}
	return true;
}


int Read_GeneralExample( const char* p_sFileName, const char* p_sResultName, bool p_bHeader, bool p_bAttributes, bool p_bDisplayMask )
{
	BufferType myBuffer;
	fprintf(stderr,"Reading '%s'...\n",p_sFileName);

	AttributeList *pAttrList = NULL;
	int err = ReadIM7( p_sFileName, &myBuffer, (p_bAttributes ? &pAttrList : NULL) );
	if (err!=0)
	{
		switch (err)
		{
			case IMREAD_ERR_FILEOPEN:
				fprintf(stderr,"Input file '%s' not found!\n",p_sFileName);
				break;
			case IMREAD_ERR_HEADER:
				fprintf(stderr,"Error in header\n");
				break;
			case IMREAD_ERR_FORMAT:
				fprintf(stderr,"Packing format not supported\n");
				break;
			case IMREAD_ERR_DATA:
				fprintf(stderr,"Error while reading data\n");
				break;
			case IMREAD_ERR_MEMORY:
				fprintf(stderr,"Error out of memory\n");
				break;
			case IMREAD_ERR_ATTRIBUTE_INVALID_TYPE:
				fprintf(stderr,"Error invalid attribute type\n");
				break;
			case IMREAD_ERR_ATTRIBUTE_NO_DATA:
				fprintf(stderr,"Error missing attribute data\n");
				break;
			default:
				fprintf(stderr,"Unknown error %i\n",err);
		}
		return 1;
	}
	
	fprintf(stderr,"File-Info: '%s'\n",p_sFileName);
	fprintf(stderr," Size: %i x %i x %i x %i\n", myBuffer.nx, myBuffer.ny, myBuffer.nz, myBuffer.nf );
	fprintf(stderr," X-Scale: %f * x + %f %s (%s)\n", myBuffer.scaleX.factor, myBuffer.scaleX.offset, myBuffer.scaleX.unit, myBuffer.scaleX.description );
	fprintf(stderr," Y-Scale: %f * x + %f %s (%s)\n", myBuffer.scaleY.factor, myBuffer.scaleY.offset, myBuffer.scaleY.unit, myBuffer.scaleY.description );
	fprintf(stderr," I-Scale: %f * x + %f %s (%s)\n", myBuffer.scaleI.factor, myBuffer.scaleI.offset, myBuffer.scaleI.unit, myBuffer.scaleI.description );
	switch (myBuffer.image_sub_type)
	{
		case BUFFER_FORMAT_IMAGE:
			fprintf(stderr," Type: Image\n");
			break;
		case BUFFER_FORMAT_MEMPACKWORD:
			fprintf(stderr," Type: byte Image\n");
			break;
		case BUFFER_FORMAT_FLOAT:
			fprintf(stderr," Type: float Image\n");
			break;
		case BUFFER_FORMAT_WORD:
			fprintf(stderr," Type: word Image\n");
			break;
		case BUFFER_FORMAT_DOUBLE:
			fprintf(stderr," Type: double Image\n");
			break;
		default:
		{
			const char *TypeName[] = { "Image", "2D-PIV-Vector (header, 4x(Vx,Vy))", "2D-Vector (Vx,Vy)", 
												"2D-PIV+p.ratio (header, 4x(Vx,Vy), peakratio)", 
												"3D-Vector (Vx,Vy,Vz)", "3D-Vector+p.ratio (header, 4x(Vx,Vy), peakratio)" };
			fprintf(stderr," Type: %s\n", TypeName[myBuffer.image_sub_type]);
			fprintf(stderr," Grid size: %i\n", myBuffer.vectorGrid);
		}
	}

	fprintf(stderr,"Mask: %s\n", myBuffer.bMaskArray!=NULL ? "exists" : "no mask" );
	if (p_bDisplayMask && myBuffer.bMaskArray)
	{	// print mask values
		int x,y,iFrame;
		for (iFrame=0; iFrame<myBuffer.nf; iFrame++)
		{
			for (y=0; y<myBuffer.ny; y++)
			{
				for (x=0; x<myBuffer.nx; x++)
					fprintf(stderr,"%i ", myBuffer.bMaskArray[iFrame*myBuffer.nx*myBuffer.ny+y*myBuffer.nx+x] ? 1 : 0 );
				fprintf(stderr,"\n");
			}
		}
	}
	
	fprintf(stderr,"\n");
	if (p_sResultName)
	{	// optional write data into txt file
		fprintf(stderr,"Writing '%s'...\n",p_sResultName);
		FILE* fout = fopen(p_sResultName,"w");
		if (fout==NULL)
		{
			fprintf(stderr,"Can't create output file!\n");
			DestroyBuffer(&myBuffer);
			if (pAttrList)
				DestroyAttributeList( &pAttrList );
			return 1;
		}

		if (p_bHeader)
		{	// print header line with size of image: <points per line> <width> <height> <frames>
			fprintf(fout,"%i %i %i %i\n", myBuffer.nx, myBuffer.nx, myBuffer.ny, myBuffer.nf );
		}
		if (p_bAttributes)
		{	// print all attributes: <name> = <value>
			AttributeList *pAttr = pAttrList;
			while (pAttr)
			{
				char *ptr;
				while ((ptr = strchr(pAttr->value,'\n')) != 0)
					*ptr = '\t';
				fprintf(fout,"%s = %s\n", pAttr->name, pAttr->value );
				pAttr = pAttr->next;
			}
		}

		int x,y,iFrame;
		for (iFrame=0; iFrame<myBuffer.nf; iFrame++)
		{
			for (y=0; y<myBuffer.ny; y++)
			{
				if (myBuffer.image_sub_type > 0)
				{	// vector
					for (x=0; x<myBuffer.nx; x++)
					{
						float vx, vy, vz;
						BufferType_GetVector( myBuffer, x, y, iFrame, vx, vy, vz );
						fprintf(fout,"%i\t%i\t%i\t%g\t%g\t%g\n", x, y, iFrame, vx, vy, vz );
					}
				}
				else
				{	// image
					if (myBuffer.isFloat)
					{	// float data type
						for (x=0; x<myBuffer.nx; x++)
							fprintf(fout,"%10.3f ", myBuffer.floatArray[iFrame*myBuffer.nx*myBuffer.ny+y*myBuffer.nx+x] );
					}
					else
					{	// word data type
						for (x=0; x<myBuffer.nx; x++)
							fprintf(fout,"%i\t", myBuffer.wordArray[iFrame*myBuffer.nx*myBuffer.ny+y*myBuffer.nx+x] );
					}
					fprintf(fout,"\n");
				}
			}
		}
		fclose(fout);
	}

	// now we have to delete the buffer data
	DestroyBuffer(&myBuffer);
	if (pAttrList)
		DestroyAttributeList( &pAttrList );

	return 0;
}


int Write_GeneralExample( const char* p_sFileName )
{
	BufferType myBuffer;
	fprintf(stderr,"Creating float image buffer\n");
	int sizeX = 10;
	int sizeY = 20;
	int sizeF = 2;
	CreateBuffer( &myBuffer, sizeX, sizeY, 1, sizeF, true, 1, BUFFER_FORMAT_IMAGE );

	int x,y,fr;
	for (fr=0; fr<sizeF; fr++)
	{
		for (y=0; y<sizeY; y++)
		{
			for (x=0; x<sizeX; x++)
			{
				myBuffer.floatArray[fr*sizeY*sizeX+y*sizeX+x] = (float)(y*x) * (fr==0?1:-1);
			}
		}
	}

	// create some test attributes
	AttributeList *myAttributes = NULL;
	SetAttribute( &myAttributes, "TestAttribute1", "Value1" );
	SetAttribute( &myAttributes, "TestAttribute2", "Value2" );
	
	// create scales
	SetBufferScale( &myBuffer.scaleX, 2, 3, "Xdescription", "pixel" );
	SetBufferScale( &myBuffer.scaleY, 4, 5, "Ydescription", "pixel" );
	SetBufferScale( &myBuffer.scaleI, 6, 7, "Idescription", "pixel" );

	fprintf(stderr,"Writing '%s'...\n",p_sFileName);
	int err = WriteIM7( p_sFileName, true, &myBuffer, myAttributes );

	// now we have to delete the buffer data
	DestroyBuffer(&myBuffer);
	if (myAttributes)
		DestroyAttributeList( &myAttributes );

	return err;
}


int Write_VectorExample( const char* p_sFileName )
{
	BufferType myBuffer;
	fprintf(stderr,"Creating vector buffer\n");
	int sizeX = 10;
	int sizeY = 10;
	int sizeF = 2;
	int nGridSize = 32;
	CreateBuffer( &myBuffer, sizeX, sizeY, 1, sizeF, true, nGridSize, BUFFER_FORMAT_VECTOR_2D );
	sizeY *= 2;	// two components

	int x,y,fr;
	for (fr=0; fr<sizeF; fr++)
	{
		for (y=0; y<sizeY; y++)
		{
			for (x=0; x<sizeX; x++)
			{
				myBuffer.floatArray[fr*sizeY*sizeX+y*sizeX+x] = (float)(y*x) * (fr==0?1:-1);
			}
		}
	}

	// create some test attributes
	AttributeList *myAttributes = NULL;
	SetAttribute( &myAttributes, "TestAttribute1", "Value1" );
	SetAttribute( &myAttributes, "TestAttribute2", "Value2" );
	
	// create scales
	SetBufferScale( &myBuffer.scaleX, 2, 3, "Xdescription", "pixel" );
	SetBufferScale( &myBuffer.scaleY, 4, 5, "Ydescription", "pixel" );
	SetBufferScale( &myBuffer.scaleI, 6, 7, "Idescription", "pixel" );

	fprintf(stderr,"Writing '%s'...\n",p_sFileName);
	int err = WriteIM7( p_sFileName, true, &myBuffer, myAttributes );

	// now we have to delete the buffer data
	DestroyBuffer(&myBuffer);
	if (myAttributes)
		DestroyAttributeList( &myAttributes );

	return err;
}


#ifdef _WIN32

typedef void (*FunType)();
FunType (*GetFunctionPointer)(int) = NULL;

// Note: if not otherwise specified, the functions return 0 if ok, or != 0 if error occurred
enum {
	F_EXECUTECOMMAND = 0, 		// execute arbitrary CL-command (or macro,...)
   									// can be used for calling any useful CL-subroutine
   F_ISFLOAT,						// same as CL: IsFloat()
   F_ISEMPTY,                 // same as CL: IsEmpty()
   F_GETBUFFERSIZE,				// same as CL: GetBufferSize()
   F_SETBUFFERSIZE,				// same as CL: SetBufferSize()
   F_SETIMAGEFORMAT,				// same as CL: SetImageFormat()
   F_GETBUFFERROWPTR,			// get pointer to row of buffer, return NULL if row does not exit
   									// pointer type: 	Word-buffer: unsigned short* (16-bit data)
                              //						Float-buffer: float* (32-bit data)
                              // 	note that it is sufficient to get the pointer to row 0
                              // 	and count from there since all data comes in one big
                              //		continuous chunk
   F_SHOW,							// same as CL: Show()
   F_MESSAGE,						// same as CL: Message()
   F_GETINT,						// retrieve value of global integer variable[index] (0 for simple int)
   F_GETFLOAT,						// retrieve value of global float variable[index] (0 for simple float)
   F_GETSTRING,					// retrieve value of global string variable[index] (0 for simple string)
   F_SETPIO,    					// same as CL: SetPio(), setting bits of I/O-port 0-2(=A,B,C)
   F_GETPIO,    					// same as CL: GetPio(), readout TTL-I/O-ports
   F_SETINT,						// set value of global integer variable[index] (0 for simple int)
   F_SETFLOAT,						// set value of global float variable[index] (0 for simple float)
   F_SETSTRING,					// set value of global string variable[index] (0 for simple string)
   F_GETVECTORGRID,				// vector buffer: get vector grid spacing
   F_SETVECTORGRID,				// vector buffer: set vector grid spacing
   F_GETVECTOR,					// vector buffer: get 2D-vector, same as CL: GetVector()
   F_SETVECTOR,					// vector buffer: set 2D-vector, same as CL: SetVector()
   F_GET3DVECTOR,					// vector buffer: get 3D-vector, same as CL: Get3DVector()
   F_SET3DVECTOR,					// vector buffer: set 3D-vector, same as CL: Set3DVector()
   F_PIVCALCULATEVECTORFIELD,	// same as CL: PivCalculatevectorField(), returns error code or 0(ok)

   F_STATUSTEXT,
   F_INFOTEXT,

	F_CREATEVOLUME,
	F_RESIZEVOLUME,
	F_GETVOLUMESIZE,
	F_ISVOLUME,
	F_GETVOLUMEINFO,
	F_CREATEVOXEL,
	F_GETVOXEL,
	F_GETFIRSTVOLIT,		// iterator access
	F_GETNEXTVOLIT,
	F_SETVOLIT_VECTOR,
	F_GETVOLIT_VECTOR,
   // set/get float scalar of the buffer; use nScalar=-1 for the vector header
   // Note: vector header = 1 activates vectorN = 0, header = 0 is a disabled vector
	F_SETVOLIT_FLOAT,
	F_GETVOLIT_FLOAT,

	F_GETATTRSTR,
	F_SETATTRSTR,
	F_GETATTRARRAY,
	F_SETATTRARRAY,
	F_DELETEALLATTR,

   F_GETCOLORPIXEL,

// special functions for internal usage:
	F_WIN_SETCALLBACK		= -99,
};

typedef int 	(*IsFloatType)				( int theBufferNumber );
typedef int 	(*IsEmptyType)				( int theBufferNumber );
typedef int 	(*GetBufferSizeType)		( int theBufferNumber, int* theNx, int* theNy, int* theType );
typedef int 	(*SetBufferSizeType)		( int theBufferNumber, int theNx, int theNy, int theType );
typedef int 	(*SetImageFormatType)	( int theBufferNumber, int theFormat );
typedef void* 	(*GetBufferRowPtrType)	( int theBufferNumber, int theRow );
typedef int 	(*GetIntType)				( char* theVarName, int theIndex );
typedef float 	(*GetFloatType)			( char* theVarName, int theIndex );
typedef char* 	(*GetStringType)			( char* theVarName, int theIndex );
typedef void 	(*SetIntType)				( char* theVarName, int theIndex, int value );
typedef void 	(*SetFloatType)			( char* theVarName, int theIndex, float value );
typedef void 	(*SetStringType)			( char* theVarName, int theIndex, char* str );
typedef int 	(*GetVectorGridType)		( int theBufferNumber );
typedef void 	(*SetVectorGridType)		( int theBufferNumber, int theGridSize );
typedef int 	(*GetVectorType)			( int buffer, int x, int y, float& vx, float& vy, int header );
typedef void 	(*SetVectorType)			( int buffer, int x, int y, float vx, float vy, int header );
typedef int 	(*Get3DVectorType)		( int buffer, int x, int y, float& vx, float& vy, float& vz, int header );
typedef void 	(*Set3DVectorType)		( int buffer, int x, int y, float vx, float vy, float vz, int header );
typedef int 	(*PivCalculateVectorFieldType) (int inbuf, int outbuf, int rectangle);

typedef int    (*StatusTextType)			( const char* theText );
typedef int    (*InfoTextType)  		   ( const char* theText );


int 	(*IsFloat)		  		( int theBufferNumber ) = NULL;
int 	(*IsEmpty)		  		( int theBufferNumber ) = NULL;
int 	(*GetBufferSize)		( int theBufferNumber, int* theNx, int* theNy, int* theType ) = NULL;
int 	(*SetBufferSize)		( int theBufferNumber, int theNx, int theNy, int theType ) = NULL;
int 	(*SetImageFormat)		( int theBufferNumber, int theFormat ) = NULL;
void* (*GetBufferRowPtr)	( int theBufferNumber, int theRow ) = NULL;
int 	(*GetInt)				( char* theVarName, int theIndex ) = NULL;
float (*GetFloat)				( char* theVarName, int theIndex ) = NULL;
char* (*GetString)			( char* theVarName, int theIndex ) = NULL;
void 	(*SetInt)				( char* theVarName, int theIndex, int value ) = NULL;
void 	(*SetFloat)				( char* theVarName, int theIndex, float value ) = NULL;
void 	(*SetString)			( char* theVarName, int theIndex, char* str ) = NULL;
int 	(*GetVectorGrid)		( int theBufferNumber ) = NULL;
void 	(*SetVectorGrid)		( int theBufferNumber, int theGridSize ) = NULL;
int 	(*GetVector)			( int buffer, int x, int y, float& vx, float& vy, int header ) = NULL;
void 	(*SetVector)			( int buffer, int x, int y, float vx, float vy, int header ) = NULL;
int 	(*Get3DVector)			( int buffer, int x, int y, float& vx, float& vy, float& vz, int header ) = NULL;
void 	(*Set3DVector)			( int buffer, int x, int y, float vx, float vy, float vz, int header ) = NULL;

int   (*StatusText)			( const char* theText ) = NULL;
int   (*InfoText)			   ( const char* theText ) = NULL;


extern "C" void EXPORT InitDll( FunType (*aGetFunctionPointer)(int) )
{
	GetFunctionPointer = aGetFunctionPointer;
   // get important entry points into DaVis
   IsFloat		 		= (IsFloatType) GetFunctionPointer( F_ISFLOAT );
   IsEmpty		 		= (IsFloatType) GetFunctionPointer( F_ISEMPTY );
   SetBufferSize 		= (SetBufferSizeType) GetFunctionPointer( F_SETBUFFERSIZE );
   SetImageFormat		= (SetImageFormatType) GetFunctionPointer( F_SETIMAGEFORMAT );
   GetBufferSize 		= (GetBufferSizeType) GetFunctionPointer( F_GETBUFFERSIZE );
   GetBufferRowPtr 	= (GetBufferRowPtrType) GetFunctionPointer( F_GETBUFFERROWPTR );
   GetInt 				= (GetIntType) GetFunctionPointer( F_GETINT );
   GetFloat 			= (GetFloatType) GetFunctionPointer( F_GETFLOAT );
   GetString 			= (GetStringType) GetFunctionPointer( F_GETSTRING );
	SetInt				= (SetIntType) GetFunctionPointer( F_SETINT );
	SetFloat				= (SetFloatType) GetFunctionPointer( F_SETFLOAT );
	SetString			= (SetStringType) GetFunctionPointer( F_SETSTRING );
	GetVectorGrid		= (GetVectorGridType) GetFunctionPointer( F_GETVECTORGRID );
	SetVectorGrid		= (SetVectorGridType) GetFunctionPointer( F_SETVECTORGRID );
	GetVector			= (GetVectorType) GetFunctionPointer( F_GETVECTOR );
	SetVector			= (SetVectorType) GetFunctionPointer( F_SETVECTOR );
	Get3DVector			= (Get3DVectorType) GetFunctionPointer( F_GET3DVECTOR );
	Set3DVector			= (Set3DVectorType) GetFunctionPointer( F_SET3DVECTOR );

   StatusText			= (StatusTextType) GetFunctionPointer( F_STATUSTEXT );
   InfoText				= (InfoTextType) GetFunctionPointer( F_INFOTEXT );
}

/*****************************************************************************/
/* Example for Win32                                                         */
/*****************************************************************************/


/* To be used as a DaVis macro:

   string ReadIMX_Name;
   void ReadIMX_cl( int theBufNum, string p_sFileName, int isFormat7 )
   {
      ReadIMX_Name = p_sFileName;
      int doPrintAttributes = TRUE;
      int thePars[3] = {theBufNum,doPrintAttributes,isFormat7};
      int err = CallDll("ReadIMX.dll","ReadIMX_cl",thePars);
      InfoText("Error code: "+err);
   }
*/

extern "C" int EXPORT ReadIMX_cl( int* thePars )
{
   int bufnum = thePars[0];
   int printAttributes = thePars[1];
	int isFormat7 = thePars[2];
   BufferType myBuffer;
   AttributeList* myList = NULL;
   int err;
	if (isFormat7)
		err = ReadIM7( GetString("ReadIMX_Name",0), &myBuffer, printAttributes ? &myList : NULL );
	else
		err = ReadIMX( GetString("ReadIMX_Name",0), &myBuffer, printAttributes ? &myList : NULL );

   if (err==0)
	{
      SetBufferSize(bufnum,myBuffer.nx,myBuffer.totalLines,myBuffer.isFloat);
      if (myBuffer.isFloat)
         memcpy( (float*)GetBufferRowPtr(bufnum,0), myBuffer.floatArray, sizeof(float)*myBuffer.totalLines*myBuffer.nx );
      else
         memcpy( (Word*)GetBufferRowPtr(bufnum,0), myBuffer.wordArray, sizeof(Word)*myBuffer.totalLines*myBuffer.nx );
      free(myBuffer.wordArray);
      while (myList)
		{
         char str[256];
         AttributeList* ptr = myList;
         myList = myList->next;
         sprintf_s(str,sizeof(str),"%s: %s",ptr->name,ptr->value);
         InfoText(str);
         free(ptr->name);
         free(ptr->value);
         free(ptr);
      }
   }
   return err;
}


/* To be used as a DaVis macro:

   string WriteIMG_Name;
   void WriteIMG_cl( int theBufNum, string p_sFileName )
   {
      WriteIMG_Name = p_sFileName;
      int thePars[2] = {theBufNum,0};
      int err = CallDll("ReadIMX.dll","WriteIMG_cl",thePars);
      InfoText("Error code: "+err);
   }
*/

extern "C" int EXPORT WriteIMG_cl( int* thePars )
{
   int bufnum = thePars[0];
	int nx,ny,isFloat;
	GetBufferSize(bufnum,&nx,&ny,&isFloat);
   BufferType myBuffer;
	CreateBuffer( &myBuffer, nx, ny, 1, 1, isFloat, 1, BUFFER_FORMAT_IMAGE );
	if (isFloat)
		memcpy( myBuffer.floatArray, (float*)GetBufferRowPtr(bufnum,0), sizeof(float)*myBuffer.ny*myBuffer.nx );
	else
		memcpy( myBuffer.wordArray, (Word*)GetBufferRowPtr(bufnum,0), sizeof(Word)*myBuffer.ny*myBuffer.nx );
	WriteIMG( GetString("WriteIMG_Name",0), &myBuffer );
	DestroyBuffer(&myBuffer);
	return 0;
}


#endif	//_WIN32


#ifdef _LINUX
/*****************************************************************************/
/* Example for Linux                                                         */
/*****************************************************************************/

int main( int argc, char* argv[] )
{
	int argName = -1, argResultName = -1, nTestReadingTime = 0;
	bool bWriting = false, bVector = false, bHeader = false, bAttributes = false, bDisplayMask = false, bLabViewExample = false;
	int err = 0;
	if (argc<2)
	{	// no parameter given, display help
	help:
		printf("ReadIMX [-h] [-w] [-s] [-a] [-m] [-t <n>] [-L] <filename> <write-filename>\n");
		printf(" (c) LaVision, 2001-2013\n");
		printf("  -h      help\n");
		printf("  -w      write image file\n");
		printf("  -v      write vector file\n");
		printf("  -s      create header line with size of image in text file\n");
		printf("  -a      create attribute list in text file\n");
		printf("  -m      display mask values if read buffer has a mask\n");
		printf("  -t <n>  test reading time by n readings of the same file\n");
		printf("  -L      run LabView example calls\n");
		return 0;
	}
	for (int nArg=1; nArg<argc; nArg++)
	{
		if (argv[nArg][0]=='-')
		{
			switch (argv[nArg][1])
			{
				case 'h':
					goto help;
				case 's':
					bHeader = true;
					break;
				case 'a':
					bAttributes = true;
					break;
				case 'w':
					bWriting = true;
					break;
				case 'v':
					bWriting = true;
					bVector = true;
					break;
				case 't':
					nArg++;
					nTestReadingTime = atoi(argv[nArg]);
					break;
				case 'm':
					bDisplayMask = true;
					break;
				case 'L':
					bLabViewExample = true;
					break;
			}
		}
		else
		{	// filename
			if (argName<1)
				argName = nArg;
			else
				argResultName = nArg;
		}
	}

	const char* sFilename = (argName > 0 ? argv[argName] : "test.im7");
	const char* sResultName = (argResultName > 0 ? argv[argResultName] : "test.txt");
	if (bLabViewExample)
	{
		err = LabViewExample(sFilename,sResultName);
	}
	else
	if (bWriting)
	{
		if (bVector)
		{
			err = Write_VectorExample(sFilename);
		}
		else
		{	// image
			err = Write_GeneralExample(sFilename);
		}
	}
	else
	if (nTestReadingTime > 0)
	{	// test reading time
		for (int i=0; i<nTestReadingTime; i++)
			err = Read_GeneralExample(sFilename,NULL,false,false,false);
	}
	else
	{	// just reading
		err = Read_GeneralExample(sFilename,sResultName,bHeader,bAttributes,bDisplayMask);
	}

	return err;
}


#endif	// _LINUX
