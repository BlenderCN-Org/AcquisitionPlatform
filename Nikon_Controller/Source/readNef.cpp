#include "libraw/libraw.h"
#include "mex.h"
//call this function with 1 string: name of the image, for getting the image without the exif
//call this function with 2 strings: name of the image + 'exif' for getting the image with the exif 

//compile this file on matlab doing: mex readNef.cpp libraw/libraw.lib. The resulting mex should be used along with the libraw dll, which is already compiled. 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
        if(nrhs>2) mexErrMsgTxt("Number of inputs incorrect. Please enter one input indicating the filename, and one optional parameter indicating if you want the exif.");
        if(nlhs!=1) mexErrMsgTxt("One output is expected, in order to store the nef file");
        mxArray *exif[1];
        char nameImage[128];        
        mxGetString(prhs[0], nameImage, sizeof(nameImage));
        
        mxArray *input[1];
        input[0]=mxCreateString(nameImage);
        if(nrhs>1) mexCallMATLAB(1,exif,1, input, "getexif");
        
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
        if(nrhs>1) mxSetFieldByNumber(plhs[0],0,0, exif[0]);
        mxSetFieldByNumber(plhs[0],0,1, imageArray);
        delete[] buffer;

        
        return;
    
 
    
}