#include "libraw/libraw.h"
#include "mex.h"
#include <stdio.h>
#include <string.h>

///readNef2 --> function to read Nef files in matlab. 
///EXAMPLES OF USE in Matlab:
///image= readNef('Images/testImage.nef'); --> This will return the bayern pattern values (raw image) without the exif info.
///image= readNef('Images/testImage.nef','exif') --> This will return the bayern pattern values (raw image) and the exif info.
///image= readNef('Images/testImage.nef','processed') --> This will return the bayern patter values (raw image), with the white balance applied. Exif info not returned.
///image= readNef('Images/testImage.nef','processed','exif') --> This will return the bayern patter values (raw image), with the white balance applied. Exif info also returned.

//compile this file on matlab doing: mex readNef.cpp libraw/libraw.lib. The resulting mex should be used along with the libraw dll, which is already compiled. 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
        if(nrhs>3) mexErrMsgTxt("Number of inputs incorrect. Please enter one input indicating the filename, and one optional parameter indicating if you want the exif.");
        if(nlhs!=1) mexErrMsgTxt("One output is expected, in order to store the nef file");
        mxArray *exif[1];
        char nameImage[128]; 
        char returnType[64];

        mxGetString(prhs[0], nameImage, sizeof(nameImage));
        if(nrhs>=2) mxGetString(prhs[1], returnType, sizeof(returnType));

        mxArray *input[1];
        input[0]=mxCreateString(nameImage);
        if(nrhs>2 ) mexCallMATLAB(1,exif,1, input, "getexif");

        mxArray* imageArray;
        //create struct for storing exif data and image data.
        const char** fieldnames; //array for storing the fieldnames of the struct
        
        fieldnames =(const char**) new char*[2]; //allocate memory with C memory manager for the number of parameters required. Note that in the following line,
                                                            //memory is allocated with Matlab memory manager, this way Matlab can free the memory when it is needed.
        mwSize size= (mwSize)50;
        fieldnames[0]= (char*)mxMalloc(size); 
        memcpy((void*)fieldnames[0],"Exif",strlen("Exif")+1);
        fieldnames[1]= (char*)mxMalloc(size); 
        memcpy((void*)fieldnames[1],"Image",strlen("Image")+1);    
        plhs[0]=  mxCreateStructMatrix(1,1,2,fieldnames);
        




        int i,j, ret,width, height, colours, bits;


        // Creation of image processing object
        LibRaw RawProcessor;

        // Let us define variables for convenient access to fields of RawProcessor

        ret = RawProcessor.open_file(nameImage);
        if(ret!=0) mexErrMsgTxt("The file indicated does not exist. Please check it.");
            
        ret = RawProcessor.unpack();
        if(ret!=0) mexErrMsgTxt("Some error has happened unpacking the image. Possibly the image is corrupted.");

        RawProcessor.get_mem_image_format(&width, &height, &colours, &bits);

        mwSize dims[3];
        dims[0] = height; //height
        dims[1] = width;  //width

        unsigned short* buffer;
        if(!strcmp(returnType,"raw") || nrhs == 1)
        {    

            imageArray = mxCreateNumericArray(2, dims, mxUINT16_CLASS, mxREAL);
            unsigned short* buffer = new unsigned short[dims[0] * dims[1]];


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
            if(nrhs>2) mxSetFieldByNumber(plhs[0],0,0, exif[0]);
            mxSetFieldByNumber(plhs[0],0,1, imageArray);
            delete[] buffer;

        }   
        else if(!strcmp(returnType,"processed") )
        {

            //RawProcessor.imgdata.params.use_camera_wb= 1;
            RawProcessor.imgdata.params.output_tiff = 1;
            RawProcessor.imgdata.params.use_auto_wb= 1;

            ret= RawProcessor.dcraw_process();
            if(ret!=0) mexErrMsgTxt("Some error happened while processing the image. Possibly the image is corrupted.");
            
            dims[2]= 3;
            imageArray = mxCreateNumericArray(3, dims, mxUINT16_CLASS, mxREAL);
            unsigned short* buffer = new unsigned short[dims[0] * dims[1] * dims[2]];


            int elements= width*height;
            for (i = 0; i<elements; i++)
            {
                for (j= 0; j<dims[2]; j++)
                {
                    buffer[i+j*elements] = (unsigned short)RawProcessor.imgdata.image[i][j];
                }
            }
            
            unsigned short* matrix = (unsigned short*)mxGetData(imageArray);

            mwIndex a= 0, b= 0, c= 0;

            for (mwIndex i = 0; i<dims[2]; i++)//colour
            {
                b=i*elements;
                for (mwIndex j = 0; j< dims[1]; j++,b++) //matlab column
                {
                    for (mwIndex k = 0,c=0; k < dims[0]; k++,a++,c+=dims[1]) //matlab row
                    {
                        //multiply per 4 to compensate the 2 bits of difference. 
                        matrix[a] = buffer[b + c]; //optimized way of looping over all the elements.
                        //matrix[i*colourElements + j*dims[0] + k] = image[i*colourElements + j + k*dims[1]];
                                
                    }
                }
            }

            if(nrhs== 2 && strcmp(returnType,"exif")) mexCallMATLAB(1,exif,1, input, "getexif");


            if(nrhs>2 || (nrhs==2 &&strcmp(returnType,"exif"))) mxSetFieldByNumber(plhs[0],0,0, exif[0]);
            mxSetFieldByNumber(plhs[0],0,1, imageArray);
            delete[] buffer;



        }

        return;
    
 
    
}