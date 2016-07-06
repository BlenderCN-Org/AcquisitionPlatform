#pragma once
#include	"maid3.h"
#include	"maid3d1.h"
#include	"CtrlSample.h"
#include	<stdlib.h>
#include	<stdio.h>
#include    "windows.h"
#include "matrix.h"
#include "mex.h"

const int MAX_ATTRIBUTTEVALUE_LENGHT = 200;
const int MAX_ATTRIBUTTENAME_LENGHT = 50;
const int MAX_RANGE_SINGLEPARAMETER_LENGHT = 1000; 
const int MAX_RANGE_ALLPARAMETERS_LENGHT= 8000;

typedef struct fileBuffer
{
	//Here we save the reference to the buffer Image
	ULONG		ulType;				// one of eNkMAIDArrayType
	ULONG		ulElements;			// total size
	ULONG		width;			// size of first dimention 
	ULONG		height;			// size of second dimention, zero for 1 dim
	ULONG		ulDimSize3;			// size of third dimention, zero for 1 or 2 dim
	ULONG		wPhysicalBytes;		// bytes per element
	UWORD		wLogicalBits;		// must be <= wPhysicalBytes * 8
	LPVOID		pData;				// pointer to the data
	unsigned char JpegOrNef; // 0 for Jpeg, 1 for Nef or Tiff, 2 for unknown
} fileBuffer, FAR* LPfileBuffer;

extern fileBuffer bufferImage;
extern NkMAIDArray	liveViewImage;
extern const char *attributeNames[];

class NikonManager
{
public:
	NikonManager();

	bool capture(); //return 1 if capture is done perfectly. 0 if there has been any problem.
	bool getLiveViewImage(int liveViewStatus);
	void getLastCapture(); 
	bool managerStatus(); //return the current status of the manager.
	void getAttribute(int atributteID, char *attribute_Info); //return true if the attibute was easy to get
	void getAll(char** attributes_Info);
	bool setAttribute(int atributteID, int value);

	void range(int attribute_id, char* range_Info);
	void getAllRange(char* range_Info);
    int fromStringToValue(int attributeID, char *value);
	int getNumberAttributes();
	bool convertAttributeString(char* nameAttribute,  int *nAttribute);
	void readJpegToArray(unsigned char* buffer);
	void readNefToArray(unsigned short* buffer);
    void closeBufferFile();
	void closeManager();
    int getShutterSpeed();
    
private:
	
	void refreshSizeBufferImage(LPRefObj obj, ULONG ulItemID);
	bool AcquireImage(LPRefObj pRefItm, ULONG ulDatID);
	bool AcquireItem(LPRefObj pRefSrc, ULONG ulItmID);


	const int N_ATTRIBUTES = 23;
	char	ModulePath[MAX_PATH];
	char	_Attribute_Info[MAX_ATTRIBUTTEVALUE_LENGHT];
	LPRefObj	pRefMod = NULL, pRefSrc = NULL, RefItm = NULL, pRefDat = NULL;
	LPMAIDEntryPointProc	g_pMAIDEntryPoint = NULL;
	UCHAR	g_bFileRemoved = false;
	ULONG	g_ulCameraType = 0;	// CameraType
	HINSTANCE	g_hInstModule = NULL;
	int n_LastPossibleValues;
	char	buf[256];
	ULONG	ulModID = 0, ulSrcID = 0, ulItemID = 0;
	UWORD	wSel;
	BOOL	bRet;
	BOOL    healthyManager;
    bool    retryCapture;

};


