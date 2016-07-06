/*
*Victor Moyano - 14/06/2016
*/

#include "NikonManager.h"
#include <sys/stat.h>

/*Global variables that Function.cpp and Callback.cpp may use*/
LPMAIDEntryPointProc	g_pMAIDEntryPoint = NULL;
UCHAR	g_bFileRemoved = false;
ULONG	g_ulCameraType = 0;	// CameraType
HINSTANCE	g_hInstModule = NULL;

fileBuffer bufferImage;

const char *attributeNames[]= {"Compression Level","Image Size","White Balance Mode","Sensitivity","Aperture","Metering Mode","Shutter Speed",
								"Flash Sync Mode","Active D Lighting","Auto-Distorsion","Image Color Space","HDR Mode","Continuous AF Area Priority",
								"AF AreaPoint", "EV Steps for Exposure Control", "Focus Preferred Area","Exposure Mode","Enable Bracketing",
								"ISO Control","Af Sub Light","Exposure Comp.","Internal Flash Comp","Focus Mode"};


#include "jpeg/jpeglib.h"
#include "libraw/libraw.h"

/*--------------------------NIKON MANAGER METHODS-------------------------*/
NikonManager::NikonManager()
{
	healthyManager = true;
	// Busca el modulo que contiene drivers de la camara "Type0009.md3".
	bRet = Search_Module(ModulePath);

	if (bRet == false)
	{
		printf("\"Modulo Type0009 \" no encontrado.\n");
		healthyManager = false;
	}
	// Carga el modulo.
	bRet = Load_Module(ModulePath);

	// Allocate memory for reference to Module object.

	pRefMod = (LPRefObj)malloc(sizeof(RefObj));
	if (pRefMod == NULL) {
		printf("There is not enough memory.");
		healthyManager = false;
	}

	InitRefObj(pRefMod);

	// Allocate memory for Module object.
	pRefMod->pObject = (LPNkMAIDObject)malloc(sizeof(NkMAIDObject));
	if (pRefMod->pObject == NULL) {
		printf("There is not enough memory.");
		if (pRefMod != NULL)	free(pRefMod);
		healthyManager = false;
	}

	//	Open Module object
	pRefMod->pObject->refClient = (NKREF)pRefMod;
	bRet = Command_Open(NULL,					// When Module_Object will be opend, "pParentObj" is "NULL".
		pRefMod->pObject,	// Pointer to Module_Object 
		ulModID);			// Module object ID set by Client

	if (bRet == false) {
		printf("Module object can't be opened.\n");
		if (pRefMod->pObject != NULL)	free(pRefMod->pObject);
		if (pRefMod != NULL)	free(pRefMod);
		healthyManager = false;
	}

	//	Enumerate Capabilities that the Module has.
	bRet = EnumCapabilities(pRefMod->pObject, &(pRefMod->ulCapCount), &(pRefMod->pCapArray), NULL, NULL);
	if (bRet == false) {
		printf("Failed in enumeration of capabilities.");
		if (pRefMod->pObject != NULL)	free(pRefMod->pObject);
		if (pRefMod != NULL)	free(pRefMod);
		healthyManager = false;
	}

	//	Set the callback functions(ProgressProc, EventProc and UIRequestProc).
	bRet = SetProc(pRefMod);
	if (bRet == false) {
		printf("Failed in setting a call back function.");
		if (pRefMod->pObject != NULL)	free(pRefMod->pObject);
		if (pRefMod != NULL)	free(pRefMod);
		healthyManager = false;
	}

	//	Set the kNkMAIDCapability_ModuleMode.
	if (CheckCapabilityOperation(pRefMod, kNkMAIDCapability_ModuleMode, kNkMAIDCapOperation_Set)){
		bRet = Command_CapSet(pRefMod->pObject, kNkMAIDCapability_ModuleMode, kNkMAIDDataType_Unsigned,
			(NKPARAM)kNkMAIDModuleMode_Controller, NULL, NULL);
		if (bRet == false)
		{
			printf("Failed in setting kNkMAIDCapability_ModuleMode.");
			healthyManager = false;
		}
	}


    
	if (healthyManager)
	{
		if (healthyManager = SelectSource(pRefMod, &ulSrcID))
		{
			pRefSrc = GetRefChildPtr_ID(pRefMod, ulSrcID);
			if (pRefSrc == NULL)
			{
				// Create Source object and RefSrc structure.
				bRet = AddChild(pRefMod, ulSrcID);
				pRefSrc = GetRefChildPtr_ID(pRefMod, ulSrcID);
			}

			// Get CameraType
			Command_CapGet(pRefSrc->pObject, kNkMAIDCapability_CameraType, kNkMAIDDataType_UnsignedPtr, (NKPARAM)&g_ulCameraType, NULL, NULL);
            if(healthyManager) healthyManager= bRet;
		}
	}
    
	bufferImage.height = 0;
	bufferImage.width = 0;
	bufferImage.ulDimSize3 = 0;
	bufferImage.pData = NULL;
	bufferImage.ulElements = 0;
	bufferImage.wPhysicalBytes = 0;
	bufferImage.ulType = 0;
	bufferImage.JpegOrNef = 0;
    retryCapture= false;
    

}

void NikonManager::closeManager()
{
	healthyManager = RemoveChild(pRefMod, ulSrcID);

	// Close Module_Object
	healthyManager = Close_Module(pRefMod);

	// Unload Module

	FreeLibrary(g_hInstModule);
	g_hInstModule = NULL;


	// Free memory blocks allocated in this function.
	if (pRefMod->pObject != NULL)	free(pRefMod->pObject);
	if (pRefMod != NULL)	free(pRefMod);

}

bool NikonManager::capture()
{
	//Captures the image/s and stores it in the DRAM of the camera. For getting the data the function getLastCapture() needs to be called.  
    do
    {
        
        healthyManager = IssueProcess(pRefSrc, kNkMAIDCapability_Capture);
        Command_Async(pRefSrc->pObject);
        
    }while(!healthyManager && retryCapture);
    

	return healthyManager;

}

bool NikonManager::getLiveViewImage(int liveViewStatus)
{
	ULONG	ulValue;
	LPNkMAIDCapInfo pCapInfo = GetCapInfo( pRefSrc, kNkMAIDCapability_LiveViewStatus );
	if ( pCapInfo == NULL ) return false;
	// check if this capability suports CapGet operation.
	if ( !CheckCapabilityOperation(pRefSrc,  kNkMAIDCapability_LiveViewStatus, kNkMAIDCapOperation_Get ) ) return false;
	bRet = Command_CapGet( pRefSrc->pObject, kNkMAIDCapability_LiveViewStatus, kNkMAIDDataType_UnsignedPtr, (NKPARAM)&ulValue, NULL, NULL );
	if( bRet == false ) return false;
	// show current value of this capability

	if(ulValue == 0 && liveViewStatus == 1)
	{
		if ( CheckCapabilityOperation( pRefSrc, kNkMAIDCapability_LiveViewStatus, kNkMAIDCapOperation_Set ) ) 
		{
			// This capablity can be set.
			ulValue = liveViewStatus;
			bRet = Command_CapSet( pRefSrc->pObject, kNkMAIDCapability_LiveViewStatus, kNkMAIDDataType_Unsigned, (NKPARAM)ulValue, NULL, NULL );
			if( bRet == false ) return false;
		} else 
		{
			// This capablity is read-only.
			return false;
		}
	}

	if( ulValue == 1 && liveViewStatus == 0)
	{
		if ( CheckCapabilityOperation( pRefSrc, kNkMAIDCapability_LiveViewStatus, kNkMAIDCapOperation_Set ) ) 
		{
			// This capablity can be set.
			ulValue = liveViewStatus;
			bRet = Command_CapSet( pRefSrc->pObject, kNkMAIDCapability_LiveViewStatus, kNkMAIDDataType_Unsigned, (NKPARAM)ulValue, NULL, NULL );
			if( bRet == false ) return false;
			return true;
		} else 
		{
			// This capablity is read-only.
			return false;
		}
	}

	ULONG	ulHeaderSize = 0;		//The header size of LiveView
	int sizeLiveViewImage;
	NkMAIDArray	stArray;
	// Set header size of LiveView
	if ( g_ulCameraType == kNkMAIDCameraType_D5200 )
	{
		ulHeaderSize = 384;
	}

	if(bufferImage.pData!= NULL)
	{
		//move the pointer back to the header to delete all files.
		free(bufferImage.pData);
		bufferImage.pData = NULL;
	}

	memset( &stArray, 0, sizeof(stArray) );		
	

	bRet = GetArrayCapability( pRefSrc, kNkMAIDCapability_GetLiveViewImage, &stArray );
	if ( bRet == false ) return false;
	//move the pointer to the start of the image

	sizeLiveViewImage = stArray.ulElements-ulHeaderSize;

	bufferImage.pData = malloc(sizeLiveViewImage);
	memcpy((unsigned char*)bufferImage.pData,(unsigned char*)stArray.pData + ulHeaderSize, sizeLiveViewImage);
	bufferImage.ulElements = sizeLiveViewImage;
	
	free(stArray.pData);

	//everything OK
	return true;

}

void NikonManager::getLastCapture()
{
	LPRefObj	pRefItm = NULL;

	if (healthyManager)
	{
		if (healthyManager = SelectItem(pRefSrc, &ulItemID))
		{

			healthyManager = bRet = AcquireItem(pRefSrc, ulItemID);

		}

		if (pRefItm != NULL)
		{
			// If the item object remains, close it and remove from parent link.
			bRet = RemoveChild(pRefSrc, ulItemID);

		}
	}

}

void NikonManager::refreshSizeBufferImage(LPRefObj obj, ULONG ulItemID)
{
/*
 *This function refresh the width, height and dimension values of the 
 */
	LPRefObj	pRefItm = NULL;
	NkMAIDSize	stSize;

	pRefItm = GetRefChildPtr_ID(pRefSrc, ulItemID);
	if (pRefItm == NULL) {
		// Create Item object and RefSrc structure.
		bRet = AddChild(pRefSrc, ulItemID);
		pRefItm = GetRefChildPtr_ID(pRefSrc, ulItemID);
	}


	pRefDat = GetRefChildPtr_ID(pRefItm, 1); //considering Images in this case. 1--> indicates the file type is an image.
	if (pRefDat == NULL)
	{
		// Create Image object and RefSrc structure.
		bRet = AddChild(pRefItm, 1);
		pRefDat = GetRefChildPtr_ID(pRefItm, 1);
	}

	SetSizeCapability(pRefDat, kNkMAIDCapability_Pixels, &stSize);


	bufferImage.width = stSize.w;
	bufferImage.height = stSize.h;
	bufferImage.ulDimSize3 = 3; //PROVISIONAL
    
    healthyManager= bRet;
}

void NikonManager::readJpegToArray(unsigned char* buffer)
{
/*
Use this function for reading the info in the file buffer to an array. 

INPUT: 
 - *buffer = pointer to the array where the data is saved. This array has to be of dimesions width*height*colourDimensions.
	The data will be stored in RRRRRR...GGGG.....BBBBB order
*/
    if(healthyManager) //before doing the descompresion, check the status of the controller. 
                       //If any error has happened, be sure of not trying to decompress.
    {
	int rc;

	// Variables for the decompressor itself
	struct jpeg_decompress_struct cinfo;
	struct jpeg_error_mgr jerr;

	// Variables for the output buffer, and how long each row is
	unsigned long bmp_size;
	unsigned char *bmp_buffer;

	int row_stride, width, height, pixel_size;


	// Load the jpeg data from a file into a memory buffer for 
	// the purpose of this demonstration.
	// Normally, if it's a file, you'd use jpeg_stdio_src, but just
	// imagine that this was instead being downloaded from the Internet
	// or otherwise not coming from disk


	// Allocate a new decompress struct, with the default error handler.
	// The default error handler will exit() on pretty much any issue,
	// so it's likely you'll want to replace it or supplement it with
	// your own.
	cinfo.err = jpeg_std_error(&jerr);
	jpeg_create_decompress(&cinfo);



	// Configure this decompressor to read its data from a memory 
	// buffer starting at unsigned char *jpg_buffer, which is jpg_size
	// long, and which must contain a complete jpg already.
	//
	// If you need something fancier than this, you must write your 
	// own data source manager, which shouldn't be too hard if you know
	// what it is you need it to do. See jpeg-8d/jdatasrc.c for the 
	// implementation of the standard jpeg_mem_src and jpeg_stdio_src 
	// managers as examples to work from.
    jpeg_mem_src(&cinfo, (unsigned char*)bufferImage.pData, bufferImage.ulElements);

	// Have the decompressor scan the jpeg header. This won't populate
	// the cinfo struct output fields, but will indicate if the
	// jpeg is valid.
	rc = jpeg_read_header(&cinfo, TRUE);

	if (rc != 1) {
		printf("Error reading header. +\n");
	}

	// By calling jpeg_start_decompress, you populate cinfo
	// and can then allocate your output bitmap buffers for
	// each scanline.
	jpeg_start_decompress(&cinfo);

	width = cinfo.output_width;
	height = cinfo.output_height;
	pixel_size = cinfo.output_components;



	bmp_size = width * height * pixel_size;

	bmp_buffer = (unsigned char*)malloc(bmp_size);

	// The row_stride is the total number of bytes it takes to store an
	// entire scanline (row). 
	row_stride = width * pixel_size;



	//
	// Now that you have the decompressor entirely configured, it's time
	// to read out all of the scanlines of the jpeg.
	//
	// By default, scanlines will come out in RGBRGBRGB...  order, 
	// but this can be changed by setting cinfo.out_color_space
	//
	// jpeg_read_scanlines takes an array of buffers, one for each scanline.
	// Even if you give it a complete set of buffers for the whole image,
	// it will only ever decompress a few lines at a time. For best 
	// performance, you should pass it an array with cinfo.rec_outbuf_height
	// scanline buffers. rec_outbuf_height is typically 1, 2, or 4, and 
	// at the default high quality decompression setting is always 1.
	while (cinfo.output_scanline < cinfo.output_height) {
		unsigned char *buffer_array[1];
		buffer_array[0] = bmp_buffer + (cinfo.output_scanline) * row_stride;

		jpeg_read_scanlines(&cinfo, buffer_array, 1);

	}



	// Once done reading *all* scanlines, release all internal buffers,
	// etc by calling jpeg_finish_decompress. This lets you go back and
	// reuse the same cinfo object with the same settings, if you
	// want to decompress several jpegs in a row.
	//
	// If you didn't read all the scanlines, but want to stop early,
	// you instead need to call jpeg_abort_decompress(&cinfo)
	jpeg_finish_decompress(&cinfo);



	// At this point, optionally go back and either load a new jpg into
	// the jpg_buffer, or define a new jpeg_mem_src, and then start 
	// another decompress operation.

	// Once you're really really done, destroy the object to free everything
	jpeg_destroy_decompress(&cinfo);
	// And free the input buffer
	closeBufferFile();

	int elementsPerColour = width*height;
	int p = 0;
	int c = 0;
	

	while (c < (elementsPerColour))
	{
		buffer[c] = bmp_buffer[p];
		buffer[c + elementsPerColour] = bmp_buffer[p + 1];
		buffer[c + 2 * elementsPerColour] = bmp_buffer[p + 2];
		p += 3;
		c++;

	}

    free(bmp_buffer);
    }
}

void NikonManager::readNefToArray(unsigned short* buffer)
{
	int  i, ret;

	int width, height, colours, bits;
	// Creation of image processing object
	LibRaw RawProcessor;

	// Let us define variables for convenient access to fields of RawProcessor

	ret = RawProcessor.open_buffer((void*)bufferImage.pData,(size_t)bufferImage.ulElements);
	ret = RawProcessor.unpack();


	RawProcessor.get_mem_image_format(&width, &height, &colours, &bits);

	for (i = 0; i<width*height; i++)
	{
		buffer[i] = (unsigned short)RawProcessor.imgdata.rawdata.raw_image[i];
	}

}


void NikonManager::closeBufferFile()
{
/*
Use this function when the temporal file containing image info has already been used.
*/
	if (bufferImage.pData != NULL)
	{
		free(bufferImage.pData);
		bufferImage.pData = NULL;
	}
		

}

bool NikonManager::AcquireItem(LPRefObj pRefSrc, ULONG ulItmID)
{
	ULONG	ulDataType = 0;
	LPRefObj	pRefItm = NULL;
	char	buf[256];
	UWORD	wSel;
	BOOL	bRet = true;

	pRefItm = GetRefChildPtr_ID(pRefSrc, ulItmID);
	if (pRefItm == NULL) {
		// Create Item object and RefSrc structure.
		bRet = AddChild(pRefSrc, ulItmID);
        //!!!
		pRefItm = GetRefChildPtr_ID(pRefSrc, ulItmID);
	}


	if (bRet)
	{
		ulDataType = 0;
		bRet = SelectData(pRefItm, &ulDataType);
        
		if (bRet == false)	return false;
		if (ulDataType == kNkMAIDDataObjType_Image)
		{
            if (bRet) refreshSizeBufferImage(pRefSrc,ulItemID); //if capture succesfull, refresh Size on buffer image.
			// reset file removed flag
			g_bFileRemoved = false;
			bRet = AcquireImage(pRefItm, ulDataType);
            
			// If the image data was stored in DRAM, the item has been removed after reading image.
			if (g_bFileRemoved) {
				RemoveChild(pRefSrc, ulItmID);
				pRefItm = NULL;
			}
		}
        
		if (pRefItm != NULL) {
			// If the item object remains, close it and remove from parent link.
			bRet = RemoveChild(pRefSrc, ulItmID);
		}
       
	}
    
    healthyManager= bRet;


	return bRet;
}

bool NikonManager::AcquireImage(LPRefObj pRefItm, ULONG ulDatID)
{
	LPRefObj	pRefDat = NULL;
	char	buf[256];
	UWORD	wSel;
	BOOL	bRet = true;

	pRefDat = GetRefChildPtr_ID(pRefItm, ulDatID);

	if (pRefDat == NULL)
	{
		// Create Image object and RefSrc structure.
		bRet = AddChild(pRefItm, ulDatID);
		pRefDat = GetRefChildPtr_ID(pRefItm, ulDatID);
	}

	
	bRet = IssueAcquire(pRefDat);
	
    
	// Close Image_Object
	bRet = RemoveChild(pRefItm, ulDatID);
    
    healthyManager= bRet;
    
	return bRet;
}

bool NikonManager::managerStatus()
{
	return healthyManager;
}

void NikonManager::getAttribute(int atributteID, char* attribute_Info)
/*

*/
{
	switch (atributteID)
	{
    //The -1 and 0 cases are special cases for knowing parameters not from the camera, but from the controller.
    case -1://Parameter retryCapture, for knowing which behaviour must have the controller when the capture has not been completed.
        if(retryCapture) strcpy(_Attribute_Info, "The camera will keep trying to capture until a capture has been done.\n");
        else strcpy(_Attribute_Info, "The camera wont try again after a capture has not been completed.\n");
        break;
    case 0://Status of the controller (For knowing if any problem such as capture incomplete has happened.)
        if(healthyManager) strcpy(_Attribute_Info, "The camera Nikon seems to be working fine.\n");
        else strcpy(_Attribute_Info, "The camera Nikon had a problem.\n");
        break;    
	case 1: //CompressionLvl 
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_CompressionLevel, 0, false, _Attribute_Info);
		break;
	case 2: //ImageSize
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_ImageSize, 0, false, _Attribute_Info);
		break;
	case 3: //WBMode		
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_WBMode, 0, false, _Attribute_Info);
		break;
	case 4: //Sensivity
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_Sensitivity, 0, false, _Attribute_Info);
		break;
	case 5: //Aperture
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_Aperture, 0, false, _Attribute_Info);
		break;
	case 6: //Metering Methods
		bRet = SetUnsignedCapability(pRefSrc, kNkMAIDCapability_MeteringMode, 0, false,_Attribute_Info);
		break;
	case 7: //Shutter Speed
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_ShutterSpeed, 0, false,  _Attribute_Info);
		break;
	case 8: //Flash Mode
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_FlashMode, 0, false, _Attribute_Info);
		break;
    case 9: //D-Lighting
        bRet = SetUnsignedCapability(pRefSrc, kNkMAIDCapability_Active_D_Lighting, 0, false,_Attribute_Info);
		break;
    case 10: //Auto-Distorsion
    	bRet= SetUnsignedCapability(pRefSrc, kNkMAIDCapability_AutoDistortion, 0, false,_Attribute_Info);
        break;
    case 11: // SpaceColor
    	bRet= SetUnsignedCapability(pRefSrc, kNkMAIDCapability_ImageColorSpace, 0, false,_Attribute_Info);
    	break;
   	case 12: //High Dynamic Range
   		bRet= SetUnsignedCapability(pRefSrc, kNkMAIDCapability_HDRMode, 0, false,_Attribute_Info);
    	break;
    case 13: //AFc Priority
    	bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_AFcPriority, 0, false, _Attribute_Info);
		break; 
	case 14: //AF AreaPoint
		bRet= SetUnsignedCapability(pRefSrc, kNkMAIDCapability_AFAreaPoint, 0, false,_Attribute_Info);
    	break;
    case 15: //EV interval
    	bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_EVInterval, 0, false, _Attribute_Info);
		break; 
	case 16: //FocusPreferedArea
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_FocusPreferredArea, 0, false, _Attribute_Info);
		break;
	case 17: //ExposureMode
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_ExposureMode, 0, false, _Attribute_Info);
		break;
	case 18: //Bracketing
		bRet = SetBoolCapability(pRefSrc,kNkMAIDCapability_EnableBracketing, 0, false, _Attribute_Info);
		break;
	case 19: //IsoControl
		bRet = SetBoolCapability(pRefSrc, kNkMAIDCapability_IsoControl, 0, false, _Attribute_Info);
		break;
	case 20: //AF SubLight
		bRet = SetBoolCapability(pRefSrc, kNkMAIDCapability_AfSubLight, 0, false, _Attribute_Info);
		break;
	case 21: //ExposureCompensation
		bRet= SetRangeCapability(pRefSrc,kNkMAIDCapability_ExposureComp, float(0), false, _Attribute_Info);
		break;
	case 22: //Flash Compensation
		bRet= SetRangeCapability(pRefSrc,kNkMAIDCapability_InternalFlashComp , float(0), false, _Attribute_Info);
		break;
    case 23: //Get Focus Mode
        bRet= SetUnsignedCapability(pRefSrc, kNkMAIDCapability_AFMode, 0, false,_Attribute_Info);
        break;
	default:
		strcpy(_Attribute_Info, "Attribute requested not found.");
		return;	
	}
    
	if (bRet == false)
	{
		strcpy(_Attribute_Info, "Attribute requested not disponible at this moment.");
	}
    
	strcpy(attribute_Info, _Attribute_Info);
}

void NikonManager::getAll(char** attributes_Info)
{

	for (int i = 0; i < N_ATTRIBUTES; i++)
	{
		getAttribute(i+1, attributes_Info[i]);
	}


}

bool NikonManager::setAttribute(int atributteID, int value)
/*
Returns true if the attribute was set correctly. False if there has been any problem.
NOTE: In order to have access to most of the attibutes of this camera, camera mode has to be MANUAL.
If the camera is set in Auto Mode, most of the attributes wont be modifiable.
*/
{
	switch (atributteID)
	{
    case -1://Parameter retryCapture, for knowing which behaviour must have the controller when the capture has not been completed.
        if (value== 1) retryCapture= true;
        if (value== 0) retryCapture = false;
        break; 
	case 1: //CompressionLvl 
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_CompressionLevel, value, true, _Attribute_Info);
		break;
	case 2: //ImageSize
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_ImageSize, value, true, _Attribute_Info);
		break;
	case 3: //WBMode
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_WBMode, value, true, _Attribute_Info);
		break;
	case 4: //Sensivity
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_Sensitivity, value, true,_Attribute_Info);
		break;
	case 5: //Aperture
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_Aperture, value, true, _Attribute_Info);
		break;
	case 6: //Metering Mode
		bRet = SetUnsignedCapability(pRefSrc, kNkMAIDCapability_MeteringMode, value, true, _Attribute_Info);
		break;
	case 7: //Shutter Speed
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_ShutterSpeed, value, true, _Attribute_Info);
		break;
	case 8: // Flash Mode
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_FlashMode, value, true, _Attribute_Info);
		break;
	case 9: //D-Lighting
        bRet = SetUnsignedCapability(pRefSrc, kNkMAIDCapability_Active_D_Lighting, value, true,_Attribute_Info);
		break;
    case 10: //Auto-Distorsion
    	bRet= SetUnsignedCapability(pRefSrc, kNkMAIDCapability_AutoDistortion, value, true,_Attribute_Info);
        break;
    case 11: // SpaceColor
    	bRet= SetUnsignedCapability(pRefSrc, kNkMAIDCapability_ImageColorSpace, value, true,_Attribute_Info);
    	break;
   	case 12: //High Dynamic Range
   		bRet= SetUnsignedCapability(pRefSrc, kNkMAIDCapability_HDRMode, value, true,_Attribute_Info);
    	break;
    case 13: //AFc Priority
    	bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_AFcPriority, value, true, _Attribute_Info);
		break; 
	case 14: //AF AreaPoint
		bRet= SetUnsignedCapability(pRefSrc, kNkMAIDCapability_AFAreaPoint, value, true,_Attribute_Info);
    	break;
    case 15: //EV interval
    	bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_EVInterval, value, true, _Attribute_Info);
		break; 
	case 16: //FocusPreferedArea
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_FocusPreferredArea, value, true, _Attribute_Info);
		break;
	case 17: //ExposureMode
		bRet = SetEnumCapability(pRefSrc, kNkMAIDCapability_ExposureMode, value, true, _Attribute_Info);
		break;
	case 18: //Bracketing
		bRet = SetBoolCapability(pRefSrc,kNkMAIDCapability_EnableBracketing, value, true, _Attribute_Info);
		break;
	case 19: //IsoControl
		bRet = SetBoolCapability(pRefSrc,kNkMAIDCapability_IsoControl, value, true, _Attribute_Info);
		break;
	case 20: //AF SubLight
		bRet = SetBoolCapability(pRefSrc,kNkMAIDCapability_AfSubLight, value, true, _Attribute_Info);
		break;
	case 21: //ExposureCompensation
		bRet= SetRangeCapability(pRefSrc,kNkMAIDCapability_ExposureComp, double(0), true, _Attribute_Info);
		break;
	case 22: //Flash Compensation
		bRet= SetRangeCapability(pRefSrc,kNkMAIDCapability_InternalFlashComp , double(0), true, _Attribute_Info);
		break;
    case 23: //Set Focus Mode
        bRet= SetUnsignedCapability(pRefSrc, kNkMAIDCapability_AFMode, value, true,_Attribute_Info);
        break;
	default:
		strcpy(_Attribute_Info, "Attribute requested not found.");
	}

	return bRet;
}

int NikonManager::getNumberAttributes()
{
	return N_ATTRIBUTES;
}

int NikonManager::getShutterSpeed()
{
	char value[20];
	getAttribute(7,value);

 	if(strcmp("Bulb",value) == 0) return 0;
    else if(strcmp("30",value) == 0) return 30000;
    else if(strcmp("25",value) == 0) return 25000;
    else if(strcmp("20",value) == 0) return 20000;
    else if(strcmp("15",value) == 0) return 15000;
    else if(strcmp("13",value) == 0) return 13000;
    else if(strcmp("10",value) == 0) return 10000;
    else if(strcmp("8",value) == 0) return 8000;
    else if(strcmp("6",value) == 0) return 6000;
    else if(strcmp("5",value) == 0) return 5000;
    else if(strcmp("4",value) == 0) return 4000;
    else if(strcmp("3",value) == 0) return 3000;
    else if(strcmp("2.5",value) == 0) return 2500;
    else if(strcmp("2",value) == 0) return 2000;
    else if(strcmp("1.6",value) == 0) return 1600;
    else if(strcmp("1.3",value) == 0) return 1300;
    else if(strcmp("1",value) == 0) return 1000;
    else if(strcmp("1/1.3",value) == 0) return 770;
    else if(strcmp("1/1.6",value) == 0) return 625;
    else if(strcmp("1/2",value) == 0) return 500;
    else if(strcmp("1/2.5",value) == 0) return 400;
    else if(strcmp("1/3",value) == 0) return 333;
    else if(strcmp("1/4",value) == 0) return 225;
    else if(strcmp("1/5",value) == 0) return 200;
    else if(strcmp("1/6",value) == 0) return 166;
    else if(strcmp("1/8",value) == 0) return 125;
    else if(strcmp("1/10",value) == 0) return 100;
    else if(strcmp("1/13",value) == 0) return 76;
    else if(strcmp("1/15",value) == 0) return 66;
    else if(strcmp("1/20",value) == 0) return 50;
    else if(strcmp("1/25",value) == 0) return 40;
    else if(strcmp("1/30",value) == 0) return 33;
    else if(strcmp("1/40",value) == 0) return 25;
    else if(strcmp("1/50",value) == 0) return 20;
    else if(strcmp("1/60",value) == 0) return 17;
    else if(strcmp("1/80",value) == 0) return 13;
    else if(strcmp("1/100",value) == 0) return 10;
    else if(strcmp("1/125",value) == 0) return 8;
    else if(strcmp("1/160",value) == 0) return 6;
    else if(strcmp("1/200",value) == 0) return 5;
    else if(strcmp("1/250",value) == 0) return 4;
    else if(strcmp("1/320",value) == 0) return 3;
    else if(strcmp("1/400",value) == 0) return 2;
    else if(strcmp("1/500",value) == 0) return 2;
    else if(strcmp("1/640",value) == 0) return 2;
    else if(strcmp("1/800",value) == 0) return 1;
    else if(strcmp("1/1000",value) == 0) return 1;
    else if(strcmp("1/1250",value) == 0) return 0;
    else if(strcmp("1/1600",value) == 0) return 0;
    else if(strcmp("1/2000",value) == 0) return 0;
    else if(strcmp("1/2500",value) == 0) return 0;
    else if(strcmp("1/3200",value) == 0) return 0;
    else if(strcmp("1/4000",value) == 0) return 0;
    else return -1;
	
}

int NikonManager::fromStringToValue(int attributeID, char *value)
{
/*Function to obtain the value of a given attribute, given its value in a string format
 *output: integer representing the value of the attribute.
 *inputs:
 * - int attributeID: integer representing a given attribute.
 * - char *value: pointer to the string representing the value of the attribute. 
 */
 
 int attributeValue;
 
 switch (attributeID)
	{
	case 1: //CompressionLvl 
        if(strcmp("JPEG Basic",value) == 0) attributeValue= 1;
        else if(strcmp("JPEG Normal",value) == 0) attributeValue= 2;
        else if(strcmp("JPEG Fine",value) == 0) attributeValue= 3;
        else if(strcmp("RAW",value) == 0) attributeValue= 4;
        else if(strcmp("RAW + JPEG Basic",value) == 0) attributeValue= 5;
        else if(strcmp("RAW + JPEG Normal",value) == 0) attributeValue= 6;
        else if(strcmp("RAW + JPEG Fine",value) == 0) attributeValue= 7;
        else attributeValue = -1;
        break;
	case 2: //ImageSize
        if(strcmp("L(6000*4000)",value) == 0) attributeValue= 1;
        else if(strcmp("M(4496*3000)",value) == 0) attributeValue= 2;
        else if(strcmp("S(2992*2000)",value) == 0) attributeValue= 3;
        else attributeValue = -1;
		break;
	case 3: //WBMode
        if(strcmp("Auto",value) == 0) attributeValue= 1;
        else if(strcmp("Incandescent",value) == 0) attributeValue= 2;
        else if(strcmp("Fluorescent",value) == 0) attributeValue= 3;
        else if(strcmp("Sunny",value) == 0) attributeValue= 4;
        else if(strcmp("Flash",value) == 0) attributeValue= 5;
        else if(strcmp("Shade",value) == 0) attributeValue= 6;
        else if(strcmp("Cloudy",value) == 0) attributeValue= 7;
        else if(strcmp("Measure",value) == 0) attributeValue= 8;
        else if(strcmp("Use Photo",value) == 0) attributeValue= 9;
        else attributeValue = -1;
        break;
	case 4: //Sensivity
		if(strcmp("100",value) == 0) attributeValue= 1;
        else if(strcmp("125",value) == 0) attributeValue= 2;
        else if(strcmp("160",value) == 0) attributeValue= 3;
        else if(strcmp("200",value) == 0) attributeValue= 4;
        else if(strcmp("250",value) == 0) attributeValue= 5;
        else if(strcmp("320",value) == 0) attributeValue= 6;
        else if(strcmp("400",value) == 0) attributeValue= 7;
        else if(strcmp("500",value) == 0) attributeValue= 8;
        else if(strcmp("640",value) == 0) attributeValue= 9;
        else if(strcmp("800",value) == 0) attributeValue= 10;
        else if(strcmp("1000",value) == 0) attributeValue= 11;
        else if(strcmp("1250",value) == 0) attributeValue= 12;
        else if(strcmp("1600",value) == 0) attributeValue= 13;
        else if(strcmp("2000",value) == 0) attributeValue= 14;
        else if(strcmp("2500",value) == 0) attributeValue= 15;
        else if(strcmp("3200",value) == 0) attributeValue= 16;
        else if(strcmp("4000",value) == 0) attributeValue= 17;
        else if(strcmp("5000",value) == 0) attributeValue= 18;
        else if(strcmp("6400",value) == 0) attributeValue= 19;
        else if(strcmp("Hi-0.3",value) == 0) attributeValue= 20;
        else if(strcmp("Hi-0.7",value) == 0) attributeValue= 21;
        else if(strcmp("Hi-1.0",value) == 0) attributeValue= 22;
        else if(strcmp("Hi-2.0",value) == 0) attributeValue= 23;
        else attributeValue = -1;
		break;
	case 5: //Aperture
        if(strcmp("5",value) == 0) attributeValue= 1;
        else if(strcmp("5.6",value) == 0) attributeValue= 2;
        else if(strcmp("6.3",value) == 0) attributeValue= 3;
        else if(strcmp("7.1",value) == 0) attributeValue= 4;
        else if(strcmp("8",value) == 0) attributeValue= 5;
        else if(strcmp("9",value) == 0) attributeValue= 6;
        else if(strcmp("10",value) == 0) attributeValue= 7;
        else if(strcmp("11",value) == 0) attributeValue= 8;
        else if(strcmp("13",value) == 0) attributeValue= 9;
        else if(strcmp("14",value) == 0) attributeValue= 10;
        else if(strcmp("16",value) == 0) attributeValue= 11;
        else if(strcmp("18",value) == 0) attributeValue= 12;
        else if(strcmp("20",value) == 0) attributeValue= 13;
        else if(strcmp("22",value) == 0) attributeValue= 14;
        else if(strcmp("25",value) == 0) attributeValue= 15;
        else if(strcmp("29",value) == 0) attributeValue= 16;
        else if(strcmp("32",value) == 0) attributeValue= 17;
        else attributeValue = -1;
		break;

	case 6: //Metering Mode
        if(strcmp("Matrix",value) == 0) attributeValue= 1;
        else if(strcmp("CenterWeighted",value) == 0) attributeValue= 2;
        else if(strcmp("Spot",value) == 0) attributeValue= 3;
        else attributeValue =-1;
		break;
	case 7: //Shutter Speed
        if(strcmp("Bulb",value) == 0) attributeValue= 1;
        else if(strcmp("30",value) == 0) attributeValue= 2;
        else if(strcmp("25",value) == 0) attributeValue= 3;
        else if(strcmp("20",value) == 0) attributeValue= 4;
        else if(strcmp("15",value) == 0) attributeValue= 5;
        else if(strcmp("13",value) == 0) attributeValue= 6;
        else if(strcmp("10",value) == 0) attributeValue= 7;
        else if(strcmp("8",value) == 0) attributeValue= 8;
        else if(strcmp("6",value) == 0) attributeValue= 9;
        else if(strcmp("5",value) == 0) attributeValue= 10;
        else if(strcmp("4",value) == 0) attributeValue= 11;
        else if(strcmp("3",value) == 0) attributeValue= 12;
        else if(strcmp("2.5",value) == 0) attributeValue= 13;
        else if(strcmp("2",value) == 0) attributeValue= 14;
        else if(strcmp("1.6",value) == 0) attributeValue= 15;
        else if(strcmp("1.3",value) == 0) attributeValue= 16;
        else if(strcmp("1",value) == 0) attributeValue= 17;
        else if(strcmp("1/1.3",value) == 0) attributeValue= 18;
        else if(strcmp("1/1.6",value) == 0) attributeValue= 19;
        else if(strcmp("1/2",value) == 0) attributeValue= 20;
        else if(strcmp("1/2.5",value) == 0) attributeValue= 21;
        else if(strcmp("1/3",value) == 0) attributeValue= 22;
        else if(strcmp("1/4",value) == 0) attributeValue= 23;
        else if(strcmp("1/5",value) == 0) attributeValue= 24;
        else if(strcmp("1/6",value) == 0) attributeValue= 25;
        else if(strcmp("1/8",value) == 0) attributeValue= 26;
        else if(strcmp("1/10",value) == 0) attributeValue= 27;
        else if(strcmp("1/13",value) == 0) attributeValue= 28;
        else if(strcmp("1/15",value) == 0) attributeValue= 29;
        else if(strcmp("1/20",value) == 0) attributeValue= 30;
        else if(strcmp("1/25",value) == 0) attributeValue= 31;
        else if(strcmp("1/30",value) == 0) attributeValue= 32;
        else if(strcmp("1/40",value) == 0) attributeValue= 33;
        else if(strcmp("1/50",value) == 0) attributeValue= 34;
        else if(strcmp("1/60",value) == 0) attributeValue= 35;
        else if(strcmp("1/80",value) == 0) attributeValue= 36;
        else if(strcmp("1/100",value) == 0) attributeValue= 37;
        else if(strcmp("1/125",value) == 0) attributeValue= 38;
        else if(strcmp("1/160",value) == 0) attributeValue= 39;
        else if(strcmp("1/200",value) == 0) attributeValue= 40;
        else if(strcmp("1/250",value) == 0) attributeValue= 41;
        else if(strcmp("1/320",value) == 0) attributeValue= 42;
        else if(strcmp("1/400",value) == 0) attributeValue= 43;
        else if(strcmp("1/500",value) == 0) attributeValue= 44;
        else if(strcmp("1/640",value) == 0) attributeValue= 45;
        else if(strcmp("1/800",value) == 0) attributeValue= 46;
        else if(strcmp("1/1000",value) == 0) attributeValue= 47;
        else if(strcmp("1/1250",value) == 0) attributeValue= 48;
        else if(strcmp("1/1600",value) == 0) attributeValue= 49;
        else if(strcmp("1/2000",value) == 0) attributeValue= 50;
        else if(strcmp("1/2500",value) == 0) attributeValue= 51;
        else if(strcmp("1/3200",value) == 0) attributeValue= 52;
        else if(strcmp("1/4000",value) == 0) attributeValue= 53;
        else attributeValue= -1;
		break;
	case 8: // Flash Mode
        if(strcmp("Normal",value) == 0) attributeValue= 1;
        else if(strcmp("Rear-sync",value) == 0) attributeValue= 2;
        else if(strcmp("Red Eye Reduction",value) == 0) attributeValue= 3;
        else attributeValue=-1;
		break;
	case 9: //Active D Lighting
        if(strcmp("High",value) == 0) attributeValue= 0;
        else if(strcmp("Normal",value) == 0) attributeValue= 1;
        else if(strcmp("Low",value) == 0) attributeValue= 2;
        else if(strcmp("Off",value) == 0) attributeValue= 3;
        else if(strcmp("Extra High",value) == 0) attributeValue= 5;
        else if(strcmp("Auto",value) == 0) attributeValue= 6;
        else attributeValue= -1;
        break;
    case 10: //AutoDistorsion
    	if(strcmp("Off",value) == 0) attributeValue= 0;
        else if(strcmp("On",value) == 0) attributeValue= 1;
        else attributeValue= -1;
        break;
    case 11: //Image Color Space
    	if(strcmp("sRGB",value) == 0) attributeValue=0;
   		else if(strcmp("AdobeRGB",value) == 0) attributeValue= 1;
        else attributeValue= -1;
        break;
    case 12: //HDR Mode
    	if(strcmp("Off",value) == 0) attributeValue= 0;
        else if(strcmp("Low",value) == 0) attributeValue= 1;
        else if(strcmp("Normal",value) == 0) attributeValue= 2;
        else if(strcmp("High",value) == 0) attributeValue= 3;
        else if(strcmp("Extra High",value) == 0) attributeValue= 4;
        else if(strcmp("Auto",value) == 0) attributeValue= 5;
        else attributeValue= -1;
        break;
    case 13: //AfAreaPriority
    	if(strcmp("AF-C Focus",value) == 0) attributeValue=1;
   		else if(strcmp("AF-C Shutter",value) == 0) attributeValue= 2;
        else attributeValue= -1;
        break;
    case 14: //AfAreaPoint
    	if(strcmp("11 points",value) == 0) attributeValue=1;
   		else if(strcmp("39 points",value) == 0) attributeValue= 2;
        else attributeValue= -1;
        break;
    case 15: //EV Steps 
    	if(strcmp("1/3 Step",value) == 0) attributeValue=1;
   		else if(strcmp("1/2 Step",value) == 0) attributeValue= 2;
        else attributeValue= -1;
        break;
    case 16: //Focus Prefered Area
    	if(strcmp("0",value) == 0) attributeValue= 1;
        else if(strcmp("1",value) == 0) attributeValue= 2;
        else if(strcmp("2",value) == 0) attributeValue= 3;
        else if(strcmp("3",value) == 0) attributeValue= 4;
        else if(strcmp("4",value) == 0) attributeValue= 5;
        else if(strcmp("5",value) == 0) attributeValue= 6;
        else if(strcmp("6",value) == 0) attributeValue= 7;
        else if(strcmp("7",value) == 0) attributeValue= 8;
        else if(strcmp("8",value) == 0) attributeValue= 9;
        else if(strcmp("9",value) == 0) attributeValue= 10;
        else if(strcmp("10",value) == 0) attributeValue= 11;
        else if(strcmp("11",value) == 0) attributeValue= 12;
        else if(strcmp("12",value) == 0) attributeValue= 13;
        else if(strcmp("13",value) == 0) attributeValue= 14;
        else if(strcmp("14",value) == 0) attributeValue= 15;
        else if(strcmp("15",value) == 0) attributeValue= 16;
        else if(strcmp("16",value) == 0) attributeValue= 17;
        else if(strcmp("17",value) == 0) attributeValue= 18;
        else if(strcmp("18",value) == 0) attributeValue= 19;
        else if(strcmp("19",value) == 0) attributeValue= 20;
        else if(strcmp("20",value) == 0) attributeValue= 21;
        else if(strcmp("21",value) == 0) attributeValue= 22;
        else if(strcmp("22",value) == 0) attributeValue= 23;
        else if(strcmp("23",value) == 0) attributeValue= 24;
        else if(strcmp("24",value) == 0) attributeValue= 25;
        else if(strcmp("25",value) == 0) attributeValue= 26;
        else if(strcmp("26",value) == 0) attributeValue= 27;
        else if(strcmp("27",value) == 0) attributeValue= 28;
        else if(strcmp("28",value) == 0) attributeValue= 29;
        else if(strcmp("29",value) == 0) attributeValue= 30;
        else if(strcmp("30",value) == 0) attributeValue= 31;
        else if(strcmp("31",value) == 0) attributeValue= 32;
        else if(strcmp("32",value) == 0) attributeValue= 33;
        else if(strcmp("33",value) == 0) attributeValue= 34;
        else if(strcmp("34",value) == 0) attributeValue= 35;
        else if(strcmp("35",value) == 0) attributeValue= 36;
        else if(strcmp("36",value) == 0) attributeValue= 37;
        else if(strcmp("37",value) == 0) attributeValue= 38;
        else if(strcmp("38",value) == 0) attributeValue= 39;
        else if(strcmp("39",value) == 0) attributeValue= 40;
        else attributeValue = -1;
        break;
    case 17://Exposure Mode 	
    	if(strcmp("Program",value) == 0) attributeValue= 1;
        else if(strcmp("Aperture",value) == 0) attributeValue= 2;
        else if(strcmp("Speed",value) == 0) attributeValue= 3;
        else if(strcmp("Manual",value) == 0) attributeValue= 4;
        else if(strcmp("Auto",value) == 0) attributeValue= 5;
        else if(strcmp("Portrait",value) == 0) attributeValue= 6;
        else if(strcmp("Landscape",value) == 0) attributeValue= 7;
        else if(strcmp("Closeup",value) == 0) attributeValue= 8;
        else if(strcmp("Sports",value) == 0) attributeValue= 9;
        else if(strcmp("Child",value) == 0) attributeValue= 10;
        else if(strcmp("FlashOff",value) == 0) attributeValue= 11;
        else if(strcmp("Scene",value) == 0) attributeValue= 12;
        else if(strcmp("Effects",value) == 0) attributeValue= 13;
        else attributeValue= -1;
        break;
    case 18: //Bracketing
    	if(strcmp("On",value) == 0) attributeValue= 1;
    	else if(strcmp("Off",value) == 0) attributeValue= 2;
    	else attributeValue= -1;
    	break;
    case 19: //IsoControl
    	if(strcmp("Used",value) == 0) attributeValue= 1;
    	else if(strcmp("Not Used",value) == 0) attributeValue= 2;
    	else attributeValue= -1;
    	break;
    case 20: //AF SubLight
		if(strcmp("On",value) == 0) attributeValue= 1;
    	else if(strcmp("Off",value) == 0) attributeValue= 2;
    	else attributeValue= -1;
    case 23: //FocusMode
        if(strcmp("AF-S",value) == 0) attributeValue= 0;
        else if(strcmp("AF-C",value) == 0) attributeValue= 1;
        else if(strcmp("AF-A",value) == 0) attributeValue= 2;
        else if(strcmp("MF Fixed",value) == 0) attributeValue= 3;
        else if(strcmp("MF Selected",value) == 0) attributeValue= 4;
   	default:
		attributeValue = -1;
	}
 return attributeValue;
}

void NikonManager::range(int attribute_id, char* range_Info)
/*
This functions gives information about all the possibles values (integer number) of one attribute, and their related real value.

PARAM: 
	-range_Info: Matrix of chars where all possible values are stored. Each row correspond to each value. 
	-attribute_id: id of the attribute we want to obtain all the possible values.
*/
{
	
	switch (attribute_id)
	{
		
	case 1: //CompressionLvl 
		bRet = GetRangeEnumCapability(pRefSrc, kNkMAIDCapability_CompressionLevel, range_Info);
		break;
	case 2: //ImageSize
		bRet = GetRangeEnumCapability(pRefSrc, kNkMAIDCapability_ImageSize,range_Info);
		break;
	case 3: //WBMode
		bRet = GetRangeEnumCapability(pRefSrc, kNkMAIDCapability_WBMode, range_Info);
		break;
	case 4: //Sensivity
		bRet = GetRangeEnumCapability(pRefSrc, kNkMAIDCapability_Sensitivity, range_Info);
		break;
	case 5: //Aperture
		bRet = GetRangeEnumCapability(pRefSrc, kNkMAIDCapability_Aperture, range_Info);
		break;
	case 6: //Metering Mode
		bRet = GetRangeUnsignedCapability(pRefSrc, kNkMAIDCapability_MeteringMode, range_Info);
		break;
	case 7: //Shutter Speed
		bRet = GetRangeEnumCapability(pRefSrc, kNkMAIDCapability_ShutterSpeed,range_Info);
		break;
	case 8: // Flash Mode
		bRet = GetRangeEnumCapability(pRefSrc, kNkMAIDCapability_FlashMode, range_Info);
		break;
	case 9: //D-Lighting
        bRet = GetRangeUnsignedCapability(pRefSrc, kNkMAIDCapability_Active_D_Lighting,range_Info);
		break;
    case 10: //Auto-Distorsion
    	bRet= GetRangeUnsignedCapability(pRefSrc, kNkMAIDCapability_AutoDistortion ,range_Info);
        break;
    case 11: // SpaceColor
    	bRet= GetRangeUnsignedCapability(pRefSrc, kNkMAIDCapability_ImageColorSpace,range_Info);
    	break;
   	case 12: //High Dynamic Range
   		bRet= GetRangeUnsignedCapability(pRefSrc, kNkMAIDCapability_HDRMode,range_Info);
    	break;
    case 13: //AFc Priority
    	bRet = GetRangeEnumCapability(pRefSrc, kNkMAIDCapability_AFcPriority, range_Info);
		break; 
	case 14: //AF AreaPoint
		bRet= GetRangeUnsignedCapability(pRefSrc, kNkMAIDCapability_AFAreaPoint,range_Info);
    	break;
    case 15: //EV interval
    	bRet = GetRangeEnumCapability(pRefSrc, kNkMAIDCapability_EVInterval, range_Info);
		break; 
	case 16: //FocusPreferedArea
		bRet = GetRangeEnumCapability(pRefSrc, kNkMAIDCapability_FocusPreferredArea, range_Info);
		break;
	case 17: //ExposureMode
		bRet = GetRangeEnumCapability(pRefSrc, kNkMAIDCapability_ExposureMode, range_Info);
		break;
	case 18: //Bracketing
		bRet= GetRangeBoolCapability(pRefSrc, kNkMAIDCapability_EnableBracketing, range_Info);
		break;
	case 19: //IsoControl
		bRet= GetRangeBoolCapability(pRefSrc, kNkMAIDCapability_IsoControl, range_Info);
		break;
	case 20: //AfSubLight
		bRet= GetRangeBoolCapability(pRefSrc, kNkMAIDCapability_AfSubLight, range_Info);
		break;
    case 21: //ExposureCompensation
        bRet= GetRangeRangeCapability(pRefSrc, kNkMAIDCapability_ExposureComp, range_Info);
        break;
    case 22: //Flash Compensation
        bRet= GetRangeRangeCapability(pRefSrc, kNkMAIDCapability_InternalFlashComp, range_Info);
        break;  
    case 23: //AutoFocusMode
        bRet= GetRangeUnsignedCapability(pRefSrc, kNkMAIDCapability_AFMode,range_Info);
    	break;
	default:
		strcpy(range_Info, "Attribute requested not found.\n");
		return;
		
	}
	
	if (bRet == false)
	{
		strcpy(_Attribute_Info, "Attribute requested not disponible at this moment.");
	}
}

void NikonManager::getAllRange(char* range_Info)
{
	char tmp[MAX_RANGE_SINGLEPARAMETER_LENGHT];
	range(1, tmp);
	strcpy(range_Info, tmp);

	for (int i = 1; i < N_ATTRIBUTES; i++)
	{
		range(i+1, tmp);
		strcat(range_Info, tmp);
	}
}


bool NikonManager::convertAttributeString(char *nameAttribute,  int *nAttribute)
/*
 *This function is for allowing the user to enter the name of the attribute 
 *instead of the number of the attribute. For example, "Aperture" instead of
 *5.
 *
 *INPUTS:
 *char* nameAttribute = pointer to the array containing the attribute name.
 *int *nAttribute= pointer to the integer containing the number of the attribute.
 *
 *OUTPUT:
 *returns True if the attribute is valid. False if it isn't. 
 */
{	
	if(!strcmp("Status",nameAttribute))
    {   
        *nAttribute = 0;
        return true;
    }
    else if(!strcmp("retryCapture",nameAttribute))
   	{   
        *nAttribute = -1;
        return true;
   	}

	for (int i= 0; i<N_ATTRIBUTES; i++)
	{
		if(!strcmp(attributeNames[i],nameAttribute))
		{
			*nAttribute= i+1;
			return true;
		}

	}
    
    return false;
}
