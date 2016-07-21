#include "class_handle.hpp"
#include "NikonManager.h"
#include "mat.h"
#include "libraw/libraw.h"
void setDefaultParameters(NikonManager* nikon)
{
    MATFile *pmat;
    pmat = matOpen("defaultParameters.mat", "r");
    if (pmat == NULL) 
    {
        printf("Default Parameters not found.");
        return;
    }

    mxArray *structParameters;
    const char *name;
    structParameters = matGetNextVariable(pmat, &name);

    int numberOfFields= mxGetNumberOfFields(structParameters);
    int attributeNumber;
    int newValue;
    char fieldName[MAX_ATTRIBUTTENAME_LENGHT];
    char fieldValue[MAX_ATTRIBUTTEVALUE_LENGHT];
    mwIndex index= 0;
    for (int i = 0; i <numberOfFields; i++)
    {
        //first we get the attribute
        strcpy(fieldName, mxGetFieldNameByNumber(structParameters,i));
        nikon->convertAttributeString(fieldName,&attributeNumber);
        //then we get the value
         mxGetString(mxGetField(structParameters,index,fieldName),fieldValue,1+mxGetN(mxGetField(structParameters,index,fieldName)));
         newValue= nikon->fromStringToValue(attributeNumber,fieldValue);
         nikon->setAttribute(attributeNumber,newValue);
     }

}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{	
    // Get the command string
    char function[64];
    int nAttribute; //in this pointer we will store the value of the attribute, if entered any.

	if (nrhs < 1 || mxGetString(prhs[0], function, sizeof(function))) mexErrMsgTxt("First input should be a command string less than 64 characters long.");
    
    if (!strcmp("new", function)) 
    {
        // Check parameters
        if (nlhs != 1) mexErrMsgTxt("New: One output expected.");
        // Return a handle to a new C++ instance
        NikonManager *nikon = new NikonManager();
        if (!(nikon->managerStatus())) mexErrMsgTxt("Camera not detected properly. Please, check if it is connected.");
        
        plhs[0] = convertPtr2Mat<NikonManager>(nikon);
        
        if( nrhs>1)
        {
            setDefaultParameters(nikon);
        }
        
        return;
    }
    
    // Check there is a second input, which should be the class instance handle
    if (nrhs < 2)
		mexErrMsgTxt("Second input should be a class instance handle.");
      
    NikonManager *nikon = convertMat2Ptr<NikonManager>(prhs[1]);
    
    // Delete
    if (!strcmp("delete", function)) 
    {
        // Destroy the C++ object
        nikon->closeManager();
        destroyObject<NikonManager>(prhs[1]);
        // Warn if other commands were ignored
        if (nlhs != 0 || nrhs != 2)
            mexWarnMsgTxt("Delete: Unexpected arguments ignored.");
        return;
    }
    
    
//     char exposureMode[20];
//     nikon->getAttribute(17,exposureMode);
//     if(strcmp("Manual",exposureMode))
//     {
//         char errorCode[100];
//         strcpy(errorCode,"Please be sure the camera is in Manual exposure Mode. The current mode is: ");
//         strcat(errorCode,exposureMode);
//         mexErrMsgTxt(errorCode);
//         return;
//     }
    
    if(!strcmp("setDefault",function))
    {
        //set Default parameters
        setDefaultParameters(nikon);
        return;
    }
    //CaptureMethod
    if (!strcmp("capture", function)) 
    {
        // Check parameters
        if (nlhs < 0 || nrhs < 2)
            mexErrMsgTxt("Capture: Unexpected arguments.");

		/*First of everything, we have to make sure output variables matches with the Compression Level. 
		If the compression level is set to NEF + BASIC, the output has to be two matrix, one of them with RAW data,
		and the other one with JPEG data (Basic Quality).
		*/

		//First, we need to know the compression Level set in the camera
            
		char* attribute_info;
		int compressionInfo;
		attribute_info = new char[MAX_ATTRIBUTTEVALUE_LENGHT];
		nikon->getAttribute(1, attribute_info);
        compressionInfo= nikon->fromStringToValue(1, attribute_info);
		//mexPrintf("%d", compressionInfo);
		delete[]attribute_info;
            
        int imagesToRead;
        int imagesRead = 0;
	
            
		if (compressionInfo == 1 || compressionInfo == 2 || compressionInfo == 3 || compressionInfo == 4)
		{
			//case of 1 output (JPEG or RAW)
			if (nlhs > 1)
			{
                    
				mexErrMsgTxt("The camera is set to deliver one file (JPEG or RAW), so one output is expected. Check Compression Level.");
				return;
			}
            imagesToRead= 1;
		}
		else if (compressionInfo == 5 || compressionInfo == 6 || compressionInfo == 7)
		{
			//case of 2 output( JPEG + RAW)
			if (nlhs > 2)
			{
                    
				mexErrMsgTxt("The camera is set to deliver two files (JPEG + RAW), so two outputs are expected as maximum. Check Compression Level.");
				return;
			}
            imagesToRead= 2;
					
		}
            				
            
        // Call the method
        if(!(nikon->capture()))
            mexErrMsgTxt("Image not captured correctly. Possibly the camera couldn't focus. Please try again, and try to change the focus mode or the camera pose.");
	

        //wait a given time for the file to be in SDRAM of the camera. This has to be controlled here.
        switch(compressionInfo)
        {
            case 1:
                //Jpeg Basic
                Sleep(200);
                break;
            case 2:
                //Jpeg Normal
                Sleep(350);
                break;
            case 3:
                //Jpeg Fine
                Sleep(500);
                break;
            case 4:
                //RAw
                Sleep(300);
                break;
            case 5:
                //RAW+ Jpeg Basic
                Sleep(500);
                break;
            case 6:
                //RAW + Jpeg normal
                Sleep(650);
                break;
            case 7:
                //RAW + Jpeg Fine
                Sleep(800);
                break;
                
        }
        
        for (int i = 0; i< nlhs; i++)
        {
            //create struct for storing exif data and image data.
            const char** fieldnames; //array for storing the fieldnames of the struct
            fieldnames =(const char**) new char*[2]; //allocate memory with C memory manager for the number of parameters required. Note that in the following line,
                                                            //memory is allocated with Matlab memory manager, this way Matlab can free the memory when it is needed.
            mwSize size= (mwSize)MAX_ATTRIBUTTENAME_LENGHT;
            fieldnames[0]= (char*)mxMalloc(size); 
            memcpy((void*)fieldnames[0],"Exif",strlen("Exif")+1);
            fieldnames[1]= (char*)mxMalloc(size); 
            memcpy((void*)fieldnames[1],"Image",strlen("Image")+1);    
            plhs[i]=  mxCreateStructMatrix(1,1,2,fieldnames);
        }


		for (int i = 0; i < nlhs; i++)
		{
			nikon->getLastCapture();
            
            imagesRead++;
            mxArray* imageArray;

			if (bufferImage.JpegOrNef == 0)//case of jpeg
			{	
                mxArray *exif[1];

                if(nrhs >= 3)
                {
                    char inputParameter[128];
                    mxGetString(prhs[2], inputParameter, sizeof(inputParameter));
                    if (!strcmp("exif", inputParameter))
                    {
                        FILE* pFile;
                        pFile= fopen("tmp.jpeg","wb");
                        fwrite(bufferImage.pData,bufferImage.wPhysicalBytes,bufferImage.ulElements,pFile);
                        fclose(pFile);
                        mxArray *input[1];
                        input[0]=mxCreateString("tmp.jpeg");
                        mexCallMATLAB(1,exif,1, input, "getexif");
                        remove("tmp.jpeg");
                    }
                    else 
                    {
                        char nameImage[128];
                        mxGetString(prhs[2], nameImage, sizeof(nameImage));
                        FILE* pFile;
                        pFile= fopen(nameImage,"wb");
                        fwrite(bufferImage.pData,bufferImage.wPhysicalBytes,bufferImage.ulElements,pFile);
                        fclose(pFile); 
                    }
                    
                    if(nrhs==4)
                    {
                        char nameImage[128];
                        mxGetString(prhs[3], nameImage, sizeof(nameImage));
                        FILE* pFile;
                        pFile= fopen(nameImage,"wb");
                        fwrite(bufferImage.pData,bufferImage.wPhysicalBytes,bufferImage.ulElements,pFile);
                        fclose(pFile); 
                    }
                }
                
                
                if((imagesToRead == 2 && nlhs==2) || (imagesToRead == 1 && nlhs == 1))
                {
                    //case of one image taken(jpeg) and one output variable. Or case of 2 images to read and 2 outputs requested.
                    mwSize nDim= 3;
                    mwSize dims[3];
                    dims[0] = (mwSize)bufferImage.height;
                    dims[1] = (mwSize)bufferImage.width;
                    dims[2] = (mwSize)bufferImage.ulDimSize3;
                    unsigned char* matrix;
                    
                    imageArray = mxCreateNumericArray(nDim, dims, mxUINT8_CLASS, mxREAL);
                    matrix = (unsigned char*)mxGetData(imageArray);
                

                    
                    long int elements = bufferImage.height* bufferImage.width * bufferImage.ulDimSize3;

                
                    unsigned char* image;
                    image = new unsigned char[elements];
                    nikon->readJpegToArray(image);

                    mwIndex colourElements = dims[0] * dims[1];

					mwIndex a=0,b=0,c=0;

                    for (mwIndex i = 0; i<dims[2]; i++)//colour
                    {
                        b=i*colourElements;
                        for (mwIndex j = 0; j< dims[1]; j++,b++) //matlab column
                        {
                            for (mwIndex k = 0,c=0; k < dims[0]; k++,a++,c+=dims[1]) //matlab row
                            {
                                matrix[a] = image[b + c]; //optimized way of looping over all the elements.
                                //matrix[i*colourElements + j*dims[0] + k] = image[i*colourElements + j + k*dims[1]];
                                
                            }
                        }
                    }

                    if(nlhs == 1)
                    {
                        if(nrhs == 3) mxSetFieldByNumber(plhs[0],0,0, exif[0]);
                        mxSetFieldByNumber(plhs[0],0,1, imageArray);
                    }
                 
                    if(nlhs == 2)
                    {
                        if(nrhs == 3) mxSetFieldByNumber(plhs[1],0,0, exif[0]);
                        mxSetFieldByNumber(plhs[1],0,1, imageArray);
                    }
                    

                    delete[] image;
                   
                }    
                else
                {
             
                    //this is the case when we need to eliminate the jpeg from RAM, we only want the NEF (RAW).
                    nikon->closeBufferFile();
                    nikon->getLastCapture();
                    imagesRead++;
                      
                }
             
			} 
			if (bufferImage.JpegOrNef == 1)
			{
				//case of nef or tiff (for getting values of Bayer pattern)
                mxArray *exif[1];
                if(nrhs== 3)
                {
                    FILE* pFile;
                    char name[10]= "tmp.nef";
                    pFile= fopen("tmp.nef","wb");
                    fwrite(bufferImage.pData,1,bufferImage.ulElements,pFile);
                    fclose(pFile);
                    mxArray *input[1];
                    input[0]=mxCreateString("tmp.nef");                    
                    mexCallMATLAB(1,exif,1, input, "getexif");
                    remove("tmp.nef");
                }

				mwSize dims[2];
				dims[0] = 4020; //height
				dims[1] = 6036;  //width

				imageArray = mxCreateNumericArray(2, dims, mxUINT16_CLASS, mxREAL);

				unsigned short* buffer = new unsigned short[dims[0] * dims[1]];

				nikon->readNefToArray(buffer);

				unsigned short* matrix = (unsigned short*)mxGetData(imageArray);

				int colourElements = dims[0] * dims[1];


                mwIndex a= 0, b= 0, c= 0;
                
				for (int j = 0; j< dims[1]; j++, b++) //matlab column
				{
                    c= 0;
					for (int k = 0; k < dims[0]; k++, a++, c+=dims[1]) //matlab row
					{
                        matrix[a]= buffer[b + c]; //This is another try of optimizing the code. For the raw images, this doesnt work as well as with JPEG.
                        //matrix[j*dims[0] + k] = buffer[j + k*dims[1]]; 
					}
				}

                
                if(nrhs==3)mxSetFieldByNumber(plhs[0],0,0, exif[0]);
                mxSetFieldByNumber(plhs[0],0,1, imageArray);
                
				delete[] buffer;

			}
            
            nikon->closeBufferFile();
                
		}
            
        if( imagesRead < imagesToRead)
        {
            //be sure of freeing the memory of the images the user didn't acquire.
            nikon->getLastCapture();
            nikon->closeBufferFile(); 

        }
            
		return;
    }
    
    
    
    // Set method    
    if (!strcmp("set", function)) 
    {
            
        if(nrhs == 3)
        {
        //the user is passing (hopefully) a struct
            if(mxIsStruct(prhs[2]))
            {
                int numberOfFields= mxGetNumberOfFields(prhs[2]);
                int attributeNumber;
                int newValue;
                char fieldName[MAX_ATTRIBUTTENAME_LENGHT];
                char fieldValue[MAX_ATTRIBUTTEVALUE_LENGHT];
                mxArray* tmp; 
                mwIndex index= 0;
                for (int i = 0; i <numberOfFields; i++)
                {
                    //first we get the attribute
                    strcpy(fieldName, mxGetFieldNameByNumber(prhs[2],i));
                        
                    nikon->convertAttributeString(fieldName,&attributeNumber);
                        
                    //then we get the value
                        
                    mxGetString(mxGetField(prhs[2],index,fieldName),fieldValue,1+mxGetN(mxGetField(prhs[2],index,fieldName)));
                    newValue= nikon->fromStringToValue(attributeNumber,fieldValue);

                    nikon->setAttribute(attributeNumber,newValue);
     
                }
                return; 
            }
            else
            {
                mexErrMsgTxt("Struct was expected as input. Please check if you passed a struct to the function.");
                return;
            }
        }
             
        if(nrhs == 4)
        {
            if(mxIsChar(prhs[2]))
            {
                char attributeName[MAX_ATTRIBUTTENAME_LENGHT];
                mxGetString(prhs[2], attributeName, sizeof(attributeName));
                if(!nikon->convertAttributeString(attributeName,&nAttribute))
                    {
                        //if the Attribute isn't a valid one, send error and exit.
                        mexErrMsgTxt("The attribute indicated is not valid. Please, check again.");
                        return;
                    }
            }
            else if(mxIsDouble(prhs[2]))
            {
                nAttribute = (int)* mxGetPr(prhs[2]);
            }

            //the user is passing an attribute, and a user Value for it.
            nikon->setAttribute(nAttribute,(int)* mxGetPr(prhs[3]));
            return;
        }
    }
    //Capture to disk method
    
    if(!strcmp("captureToDisk",function))
    {
                // Check parameters
        if ( nrhs < 3)
            mexErrMsgTxt("captureToDisk: Unexpected arguments. Please enter the name of the image as a parameter.");
		/*First of everything, we have to make sure output variables matches with the Compression Level. 
		If the compression level is set to NEF + BASIC, the output has to be two matrix, one of them with RAW data,
		and the other one with JPEG data (Basic Quality).
		*/

		//First, we need to know the compression Level set in the camera
            
		char* attribute_info;
		int compressionInfo;
		attribute_info = new char[MAX_ATTRIBUTTEVALUE_LENGHT];
		nikon->getAttribute(1, attribute_info);
        compressionInfo= nikon->fromStringToValue(1, attribute_info);
		//mexPrintf("%d", compressionInfo);
		delete[]attribute_info;
            
        int imagesToRead;
        int imagesRead = 0;
	
            
		if (compressionInfo == 1 || compressionInfo == 2 || compressionInfo == 3 || compressionInfo == 4)
		{
			//case of 1 output (JPEG or RAW)
			if (nrhs > 3)
			{
                    
				mexErrMsgTxt("The camera is set to deliver one file (JPEG or RAW), so one output is expected. Check Compression Level.");
				return;
			}
            imagesToRead= 1;
		}
		else if (compressionInfo == 5 || compressionInfo == 6 || compressionInfo == 7)
		{
			//case of 2 output( JPEG + RAW)
			if (nlhs > 4)
			{
                    
				mexErrMsgTxt("The camera is set to deliver two files (JPEG + RAW), so two outputs are expected as maximum. Check Compression Level.");
				return;
			}
            imagesToRead= 2;
					
		}
            				
            
        // Call the method
        if(!(nikon->capture()))
            mexErrMsgTxt("Image not captured correctly. Possibly the camera couldn't focus. Please try again, and try to change the focus mode or the camera pose.");
	

        //wait a given time for the file to be in SDRAM of the camera. This has to be controlled here.
        switch(compressionInfo)
        {
            //THIS COULD BE OPTIMIZED!!!!!!!!!!!!!
            case 1:
                //Jpeg Basic
                Sleep(400);
                break;
            case 2:
                //Jpeg Normal
                Sleep(550);
                break;
            case 3:
                //Jpeg Fine
                Sleep(700);
                break;
            case 4:
                //RAw
                Sleep(1000);
                break;
            case 5:
                //RAW+ Jpeg Basic
                Sleep(1200);
                break;
            case 6:
                //RAW + Jpeg normal
                Sleep(1400);
                break;
            case 7:
                //RAW + Jpeg Fine
                Sleep(1700);
                break;
                
        }
        

		for (int i = 0; i < (nrhs-2); i++)
		{
			nikon->getLastCapture();
            
            imagesRead++;
            mxArray* imageArray;

			if (bufferImage.JpegOrNef == 0)//case of jpeg
			{	
                Sleep(300);
                mxArray *exif[1];
                
                if((imagesToRead == 2 && nrhs==4) || (imagesToRead == 1 && nrhs == 3))
                {
                    char nameImage[128];
                    FILE* pFile;
                    if(nrhs == 3)
                    {
                        mxGetString(prhs[2], nameImage, sizeof(nameImage)); 
                        
                    }
                    else if(nrhs == 4)
                    {
                        mxGetString(prhs[3], nameImage, sizeof(nameImage));
                    }
                    else
                    {
                        mexErrMsgTxt("Number of inputs incorrect");
                    }
                    
                    try
                    {
                            pFile= fopen(nameImage,"wb");
                            fwrite(bufferImage.pData,bufferImage.wPhysicalBytes,bufferImage.ulElements,pFile);
                            fclose(pFile); 
                    }
                    catch (int e) 
                    {
                        mexErrMsgTxt("Something went wrong writing the image to disk. Probably the path doesn't exist.");
                        if (pFile) fclose(pFile); 
                    }
                }    
                else
                {
             
                    //this is the case when we need to eliminate the jpeg from RAM, we only want the NEF (RAW).
                    nikon->closeBufferFile();
                    nikon->getLastCapture();
                    
                      
                }
                
			} 
			if (bufferImage.JpegOrNef == 1)
			{
				//case of nef or tiff (for getting values of Bayer pattern)
                if(nrhs >= 3)
                {
                    
                    char nameImage[128];
                    mxGetString(prhs[2], nameImage, sizeof(nameImage));
                    FILE* pFile;
                    try
                    {
                            pFile= fopen(nameImage,"wb");
                            fwrite(bufferImage.pData,1,bufferImage.ulElements,pFile);
                            fclose(pFile); 
                    }
                    catch (int e) 
                    {
                        mexErrMsgTxt("Something went wrong writing the image to disk. Probably the path doesn't exist.");
                        if (pFile) fclose(pFile); 
                    }
                }
                

			}
            imagesRead++;
            nikon->closeBufferFile(); 
		}
            
        if( imagesRead < imagesToRead)
        {
            //be sure of freeing the memory of the images the user didn't acquire.
            nikon->getLastCapture();
            nikon->closeBufferFile(); 

        }
            
		return;

    }
    
    if(!strcmp("captureFromDisk",function))
    {
        
        if(nrhs!=3) mexErrMsgTxt("Number of inputs incorrect. Please enter one input indicating the filename");
        if(nlhs!=1) mexErrMsgTxt("One output is expected, in order to store the nef file");
        mxArray *exif[1];
        char nameImage[128];        
        mxGetString(prhs[2], nameImage, sizeof(nameImage));
        
        mxArray *input[1];
        input[0]=mxCreateString(nameImage);                    
        mexCallMATLAB(1,exif,1, input, "getexif");
        
        mxArray* imageArray;

        //create struct for storing exif data and image data.
        const char** fieldnames; //array for storing the fieldnames of the struct
        
        fieldnames =(const char**) new char*[2]; //allocate memory with C memory manager for the number of parameters required. Note that in the following line,
                                                            //memory is allocated with Matlab memory manager, this way Matlab can free the memory when it is needed.
        mwSize size= (mwSize)MAX_ATTRIBUTTENAME_LENGHT;
        fieldnames[0]= (char*)mxMalloc(size); 
        memcpy((void*)fieldnames[0],"Exif",strlen("Exif")+1);
        fieldnames[1]= (char*)mxMalloc(size); 
        memcpy((void*)fieldnames[1],"Image",strlen("Image")+1);    
        plhs[0]=  mxCreateStructMatrix(1,1,2,fieldnames);

        mwSize dims[2];
		dims[0] = 4020; //height
		dims[1] = 6036;  //width

		imageArray = mxCreateNumericArray(2, dims, mxUINT16_CLASS, mxREAL);

		unsigned short* buffer = new unsigned short[dims[0] * dims[1]];

		int i, ret,width, height, colours, bits;
        // Creation of image processing object
        LibRaw RawProcessor;

        // Let us define variables for convenient access to fields of RawProcessor

        ret = RawProcessor.open_file(nameImage);
        if(ret!=0) mexErrMsgTxt("The file indicated does not exist. Please check it.");
        
        ret = RawProcessor.unpack();


        RawProcessor.get_mem_image_format(&width, &height, &colours, &bits);

        for (i = 0; i<width*height; i++)
        {
            buffer[i] = (unsigned short)RawProcessor.imgdata.rawdata.raw_image[i];
        }
		
        unsigned short* matrix = (unsigned short*)mxGetData(imageArray);
		int colourElements = dims[0] * dims[1];
        mwIndex a= 0, b= 0, c= 0;
                
		for (int j = 0; j< dims[1]; j++, b++) //matlab column
		{
            c= 0;
			for (int k = 0; k < dims[0]; k++, a++, c+=dims[1]) //matlab row
			{
                matrix[a]= buffer[b + c]; //This is another try of optimizing the code. For the raw images, this doesnt work as well as with JPEG.
                //matrix[j*dims[0] + k] = buffer[j + k*dims[1]]; 
			}
		}
        mxSetFieldByNumber(plhs[0],0,0, exif[0]);
        mxSetFieldByNumber(plhs[0],0,1, imageArray);
        delete[] buffer;

        
        return;
    }
    
    // Get method    
    if (!strcmp("get", function)) 
    {
            if (nrhs == 2 )
            {
                // if there is no attribute parameter, the function has to get the value for all the parameters.
            
                int numberParameters= nikon->getNumberAttributes();
                Sleep(200);
                
                char **all_Attributes; //this is array of string for storing attributes info (Names and values of all attributes)
                all_Attributes = new char*[numberParameters];
            
                for (int i = 0; i<numberParameters; i++)
                {
                    all_Attributes[i]=new char[MAX_ATTRIBUTTEVALUE_LENGHT];
                }
                
                
                nikon->getAll(all_Attributes); 
                
                const char** fieldnames; //array for storing the fieldnames of the struct
                fieldnames =(const char**) new char*[numberParameters]; //allocate memory with C memory manager for the number of parameters required. Note that in the following line,
                                                            //memory is allocated with Matlab memory manager, this way Matlab can free the memory when it is needed.      

                mwSize size= (mwSize)MAX_ATTRIBUTTENAME_LENGHT;
                for (int i = 0; i<numberParameters; i++)
                {
                    fieldnames[i]= (char*)mxMalloc(size); //20 characters for each parameter name is more than enough.
                    memcpy((void*)fieldnames[i],attributeNames[i],strlen(attributeNames[i])+1);
                    
                }
                
                mwSize size2= (mwSize)numberParameters;
                plhs[0]=  mxCreateStructMatrix(1,1,size2,fieldnames);
                
                
                mxArray **mxStringAttributeValues;
                mxStringAttributeValues= new mxArray*[numberParameters];
                
                for (int i =0; i< numberParameters; i++)
                {
                    mxStringAttributeValues[i]= mxCreateString(all_Attributes[i]);
                    delete [] all_Attributes[i];
                    mxFree((void*)fieldnames[i]);
                    mxSetFieldByNumber(plhs[0],0,i, mxStringAttributeValues[i]);
                }
                delete []mxStringAttributeValues;
                delete []all_Attributes;
            }
            else if(nrhs == 3)
            {
                if(mxIsChar(prhs[2]))
                {
                    char attributeName[MAX_ATTRIBUTTENAME_LENGHT];
                    mxGetString(prhs[2], attributeName, sizeof(attributeName));
                    if(!nikon->convertAttributeString(attributeName,&nAttribute))
                    {
                        //if the Attribute isn't a valid one, send error and exit.
                        mexErrMsgTxt("The attribute indicated is not valid. Please, check again.");
                        return;
                    }
                }
                // if there is a, then try to get the current value of the parameter indicated.
                
                if(mxIsDouble(prhs[2]))
                {
                    nAttribute = (int)* mxGetPr(prhs[2]);
                }
                
                char* attribute_info;
                attribute_info = new char [MAX_ATTRIBUTTEVALUE_LENGHT];
            
                nikon->getAttribute(nAttribute, attribute_info);
            
                const char** fieldnames; //array for storing the fieldnames of the struct
                fieldnames =(const char**) new char*[1]; //allocate memory with C memory manager for the number of parameters required. Note that in the following line,
                                                            //memory is allocated with Matlab memory manager, this way Matlab can free the memory when it is needed.      
                
                
                fieldnames[0]= (char*)mxMalloc(MAX_ATTRIBUTTENAME_LENGHT); //20 characters for each parameter name is more than enough.
                memcpy((void*)fieldnames[0],attributeNames[nAttribute-1],strlen(attributeNames[nAttribute-1])+1);
                    
                
                plhs[0]=  mxCreateStructMatrix(1,1,1,fieldnames);
                
                mxArray *mxStringAttributeValue;
                
                mxStringAttributeValue= mxCreateString(attribute_info);
                mxFree((void*)fieldnames[0]);
                mxSetFieldByNumber(plhs[0],0,0, mxStringAttributeValue);
                
                
                delete []attribute_info;
            }
        
            return;
    }

    //Range method
    if(!strcmp("range", function))
    {
            if (nrhs <2 || nrhs >3)
                mexErrMsgTxt("Test: Unexpected arguments.");
            if (nrhs == 2)
            {
                // if there is no attribute parameter, the function has to get the range of all the parameters.
                char allrange[MAX_RANGE_ALLPARAMETERS_LENGHT];
                nikon->getAllRange(allrange);
                mexPrintf("%s",allrange);
            }
            else if(nrhs == 3)
            {

                if(mxIsChar(prhs[2]))
                {
                    char attributeName[MAX_ATTRIBUTTENAME_LENGHT];
                    mxGetString(prhs[2], attributeName, sizeof(attributeName));
                    if(!nikon->convertAttributeString(attributeName,&nAttribute))
                    {
                        //if the Attribute isn't a valid one, send error and exit.
                        mexErrMsgTxt("The attribute indicated is not valid. Please, check again.");
                        return;
                    }
                }
                if(mxIsDouble(prhs[2]))
                {
                    nAttribute = (int)* mxGetPr(prhs[2]);
                }

                // if there is parameter info, then try to get the range of the parameter indicated.
                char range[MAX_RANGE_SINGLEPARAMETER_LENGHT];
                nikon->range(nAttribute, range);
                mexPrintf("%s",range);
            }
            return;
    }

    if(!strcmp("liveView", function))
    {
        if( nrhs<2 || nlhs != 1) mexErrMsgTxt("Test: Unexpected arguments.");

        if( nikon->getLiveViewImage(1))
        {
            
            mwSize dims[3];
            dims[0] = 424;
            dims[1] = 640;
            dims[2] = 3;
            unsigned char* matrix;
            if(nlhs == 1)
            {
                plhs[0] = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);
                matrix = (unsigned char*)mxGetData(plhs[0]);
            }
            
            

            long int elements = dims[0]* dims[1] * dims[2];

            unsigned char* image;
            image = new unsigned char[elements];

            nikon->readJpegToArray(image);


            mwIndex colourElements = (mwIndex) dims[0] * dims[1];


            for (mwIndex i = 0; i<dims[2]; i++)//colour
            {
                for (mwIndex j = 0; j< dims[1]; j++) //matlab column
                {
                    for (mwIndex k= 0; k < dims[0]; k++) //matlab row
                    {
                        matrix[i*colourElements + j*dims[0] + k] = image[i*colourElements + j + k*dims[1]];
                    }
                }
            }
           
            
            delete[] image;

            return;
        }
        else
        {
            mexErrMsgTxt("Error getting live image");
            return;
        }
    }
    if(!strcmp("endLiveView", function))
    {
        if( nrhs<2 || nlhs != 0) mexErrMsgTxt("Test: Unexpected arguments.");

        if( nikon->getLiveViewImage(0))
        {

            return;
        }
        else
        {
            mexErrMsgTxt("Error closing Live Image");
            return;
        }
    }
    
    if(!strcmp("flush",function))
    {
        for (int i= 0;i<10;i++)
        {
            nikon->getLastCapture();
            nikon->closeBufferFile(); 
        }
        return;
    }
    // Got here, so command not recognized
    mexErrMsgTxt("Command not recognized.");
}

