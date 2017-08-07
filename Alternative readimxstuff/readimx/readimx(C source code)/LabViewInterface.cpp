//--------------------------------------------------------------------------------------------------
//
// Copyright (C) 2001-2013 LaVision GmbH.  All Rights Reserved.
//
//--------------------------------------------------------------------------------------------------

#include "ReadIMX.h"
#include "ReadIM7.h"

#ifndef min
#	define min(a,b)	((a)<(b) ? (a) : (b))
#endif
#ifndef max
#	define max(a,b)	((a)>(b) ? (a) : (b))
#endif

#pragma warning(disable:4996)	// Disable warning about safety of sscanf, strncpy and fopen

/*****************************************************************************/
// LabView functions
/*****************************************************************************/

BufferType		LabViewBuffer;						///< Temporary buffer created by LabView_OpenIMX() to be given to LabView via LabView_ReadIMX_x().
AttributeList*	LabViewAttributeList = NULL;	///< List of attributes read by LabView_OpenIMX() or set by LabView_SetAttribute().
bool				LabViewAttributeOwn = false;	///< If TRUE then user created attributes via LabView_SetAttribute().

/// @brief Open and read a IMX/IMG/IM7 file with image data and attributes.
/// @return File handle for calls to LabView_ReadIMX_x and LabView_CloseIMX.
extern "C" int EXPORT LabView_OpenIMX( const char* theFileName, int* theWidth, int* theHeight )
{
	DestroyAttributeList(&LabViewAttributeList);
	LabViewAttributeOwn = false;
	if (ReadIM7(theFileName,&LabViewBuffer,&LabViewAttributeList)==0)
	{
		*theWidth  = LabViewBuffer.nx;
		*theHeight = LabViewBuffer.ny * LabViewBuffer.nf;
		return 1;
	}
	*theWidth  = 0;
	*theHeight = 0;
	return 0;
}

/// @param theHandle File handle from call to LabView_OpenIMX.
/// @param theArray Word array to be filled with image intensities.
extern "C" int EXPORT LabView_ReadIMX_u16( int theHandle, Word* theArray )
{
	theHandle;	// avoid warning

	int x,y,fr;
	if (LabViewBuffer.isFloat)
	{
		float* ptr = LabViewBuffer.floatArray;
		for (fr=0; fr<LabViewBuffer.nf; fr++)
		{
			for (y=0; y<LabViewBuffer.ny; y++)
			{
				for (x=0; x<LabViewBuffer.nx; x++, theArray++, ptr++)
				{
					*theArray = (Word) min( max(0,*ptr), 65535 );
				}
			}
		}
	}
	else
	{
		memcpy( theArray, LabViewBuffer.wordArray, sizeof(Word)*LabViewBuffer.nx*LabViewBuffer.ny*LabViewBuffer.nf );
	}
	return 0;
}

/// @param theHandle File handle from call to LabView_OpenIMX.
/// @param theArray Float array to be filled with image intensities.
extern "C" int EXPORT LabView_ReadIMX_f32( int theHandle, float* theArray )
{
	theHandle;	// avoid warning

	int x,y,fr;
	if (!LabViewBuffer.isFloat)
	{
		Word* ptr = LabViewBuffer.wordArray;
		for (fr=0; fr<LabViewBuffer.nf; fr++)
		{
			for (y=0; y<LabViewBuffer.ny; y++)
			{
				for (x=0; x<LabViewBuffer.nx; x++, theArray++, ptr++)
				{
					*theArray = *ptr;
				}
			}
		}
	}
	else
	{
		memcpy( theArray, LabViewBuffer.floatArray, sizeof(float)*LabViewBuffer.nx*LabViewBuffer.ny*LabViewBuffer.nf );
	}
	return 0;
}

/// @brief Close and finish reading of a IMG/IMX/IM7 file started via LabView_OpenIMX.
/// @param theHandle File handle from call to LabView_OpenIMX.
extern "C" int EXPORT LabView_CloseIMX( int theHandle )
{
	DestroyBuffer(&LabViewBuffer);

	// don't destroy attribute list for later call to Write functions, but destroy after Write
	if (theHandle==0)
	{
		DestroyAttributeList(&LabViewAttributeList);
		LabViewAttributeOwn = false;
	}

	return 0;
}

/// @brief Destroy or leave attribute list from last call to LabView_OpenIMX.
/// @param theSizeY If value is negative, then leave the list from last call to LabView_OpenIMX.
///                 Used to store a changed buffer with all old attributes.
///                 Otherwise (default case) destroy the list.
void LabView_CheckWriteAttr( int& theSizeY )
{
	if (theSizeY>=0)
	{	
		if (!LabViewAttributeOwn)
		{	// don't store attributes if they have not be changed by the user
			DestroyAttributeList(&LabViewAttributeList);

		}
	}
	else
	{	// leave attributes for storage
		theSizeY = -theSizeY;
	}
}

/// @brief Add a new attribute to the list or change the value of an existing attribute.
/// @param theHandle File handle from call to LabView_OpenIMX.
/// @param p_sAttributeName Name of the attribute.
/// @param p_sAttributeValue Value of the attribute.
extern "C" void EXPORT LabView_SetAttribute( int theHandle, const char* p_sAttributeName, const char* p_sAttributeValue )
{
	LabViewAttributeOwn = true;
	theHandle;	// avoid warning

	// search for existing attribute
	AttributeList* pItem = LabViewAttributeList;
	while (pItem)
	{
		if (strcmp(pItem->name,p_sAttributeName)==0)
		{	// attribute already exists, so just replace the value
			delete pItem->value;
			pItem->value = (char*) malloc( strlen(p_sAttributeValue)+1 );
			strcpy( pItem->value, p_sAttributeValue );
			return;
		}
		pItem = pItem->next;
	}

	// create new attribute
	SetAttribute( &LabViewAttributeList, p_sAttributeName, p_sAttributeValue );
}

extern "C" int EXPORT LabView_WriteIMX_u16( const char* theFileName, const Word* theArray, int theSizeX, int theSizeY )
{
	LabView_CheckWriteAttr(theSizeY);
	CreateBuffer( &LabViewBuffer, theSizeX, theSizeY, 1, 1, false, 1, BUFFER_FORMAT_IMAGE );
	memcpy( LabViewBuffer.wordArray, theArray, sizeof(Word)*LabViewBuffer.nx*LabViewBuffer.ny );

	int err = WriteIMGXAttr( theFileName, true, &LabViewBuffer, LabViewAttributeList );
	LabView_CloseIMX(0);
	return err;
}

extern "C" int EXPORT LabView_WriteIMXframes_u16( const char* theFileName, const Word* theArray, int theSizeX, int theSizeY, int theFrames )
{
	LabView_CheckWriteAttr(theSizeY);
	CreateBuffer( &LabViewBuffer, theSizeX, theSizeY, 1, theFrames, false, 1, BUFFER_FORMAT_IMAGE );
	memcpy( LabViewBuffer.wordArray, theArray, sizeof(Word)*LabViewBuffer.nx*LabViewBuffer.ny*LabViewBuffer.nf );

	int err = WriteIMGXAttr( theFileName, true, &LabViewBuffer, LabViewAttributeList );
	LabView_CloseIMX(0);
	return err;
}

extern "C" int EXPORT LabView_WriteIMX_f32( const char* theFileName, const float* theArray, int theSizeX, int theSizeY )
{
	LabView_CheckWriteAttr(theSizeY);
	CreateBuffer( &LabViewBuffer, theSizeX, theSizeY, 1, 1, true, 1, BUFFER_FORMAT_IMAGE );
	memcpy( LabViewBuffer.floatArray, theArray, sizeof(float)*LabViewBuffer.nx*LabViewBuffer.ny );

	int err = WriteIMGXAttr( theFileName, true, &LabViewBuffer, LabViewAttributeList );
	LabView_CloseIMX(0);
	return err;
}

extern "C" int EXPORT LabView_WriteIMXframes_f32( const char* theFileName, const float* theArray, int theSizeX, int theSizeY, int theFrames )
{
	LabView_CheckWriteAttr(theSizeY);
	CreateBuffer( &LabViewBuffer, theSizeX, theSizeY, 1, theFrames, true, 1, BUFFER_FORMAT_IMAGE );
	memcpy( LabViewBuffer.floatArray, theArray, sizeof(float)*LabViewBuffer.nx*LabViewBuffer.ny*LabViewBuffer.nf );

	int err = WriteIMGXAttr( theFileName, true, &LabViewBuffer, LabViewAttributeList );
	LabView_CloseIMX(0);
	return err;
}


/// @brief Read given file from source, add a new attribute and store to destination.
/// @param theFileName Source file name.
/// @param theResultFileName Destination file name.
extern "C" int EXPORT LabViewExample( const char* theFileName, const char* theResultFileName )
{
	int nWidth, nHeight;
	int hLVfile = LabView_OpenIMX( theFileName, &nWidth, &nHeight );
	LabView_SetAttribute( hLVfile, "LabView", "example attribute value" );
	if (LabViewBuffer.isFloat)
		LabView_WriteIMX_f32( theResultFileName, LabViewBuffer.floatArray, nWidth, nHeight );
	else
		LabView_WriteIMX_u16( theResultFileName, LabViewBuffer.wordArray, nWidth, nHeight );
	LabView_CloseIMX(hLVfile);
	return 0;
}
