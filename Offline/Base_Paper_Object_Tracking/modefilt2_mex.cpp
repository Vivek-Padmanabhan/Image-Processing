/*********************************************************************
 * filtered = modefilt2_mex(img,win,ignore)
 * 
 * Each pixel in the output gets the mode of its neighbors in the input.
 * The local neighborhood is defined by <win>. Also, numbers below ignore
 * are not considered when computing the modes.
 * 
 * Inputs: 
 *   > img: 2D double matrix holding only positive integers (I know)
 *   > win: [x_window_radius, y_window_radius]
 *   > ignore: minimum value of pixels to consider (0 to consider all pixels)
 * 
 * Outputs: 
 *   > filtered: 2D double matrix size(img) with filter result.
 *
 * 
 * Coded by: Shawn Lankton, April 2008, (www.shawnlankton.com)
 *
 ********************************************************************/

#include <matrix.h>
#include <mex.h>   

/* Definitions to keep compatibility with earlier versions of ML */
#ifndef MWSIZE_MAX
typedef int mwSize;
typedef int mwIndex;
typedef int mwSignedIndex;

#if (defined(_LP64) || defined(_WIN64)) && !defined(MX_COMPAT_32)
/* Currently 2^48 based on hardware limitations */
# define MWSIZE_MAX    281474976710655UL
# define MWINDEX_MAX   281474976710655UL
# define MWSINDEX_MAX  281474976710655L
# define MWSINDEX_MIN -281474976710655L
#else
# define MWSIZE_MAX    2147483647UL
# define MWINDEX_MAX   2147483647UL
# define MWSINDEX_MAX  2147483647L
# define MWSINDEX_MIN -2147483647L
#endif
#define MWSIZE_MIN    0UL
#define MWINDEX_MIN   0UL
#endif

double max(double a,double b){ if(a>b) return a; return b;}
double min(double a,double b){ if(a<b) return a; return b;}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

//declare variables
    mxArray *img_in_m, *win_in_m, *ignore_in_m, *f_out_m;
    const mwSize *dims;
    double *img, *win, *ignore, *f;
    int dimx, dimy, numdims,idx,ign;
    int i,j,k,l,m,cl,cu,rl,ru;
    double pen[256];
    double mode,penmax;

//associate inputs
    img_in_m = mxDuplicateArray(prhs[0]);
    win_in_m = mxDuplicateArray(prhs[1]);
    ignore_in_m = mxDuplicateArray(prhs[2]);

//figure out dimensions
    dims = mxGetDimensions(prhs[0]);
    numdims = mxGetNumberOfDimensions(prhs[0]);
    dimy = (int)dims[0]; dimx = (int)dims[1];

//associate outputs
    f_out_m = plhs[0] = mxCreateDoubleMatrix(dimy,dimx,mxREAL);

//associate pointers
    img = mxGetPr(img_in_m);
    win = mxGetPr(win_in_m);
    ignore = mxGetPr(ignore_in_m);

    f = mxGetPr(f_out_m);

//main program
    ign = int(ignore[0]);      // ignore pixels below this value

    for(i=0;i<dimx;i++)        // for every pixel
    {
        for(j=0;j<dimy;j++)
        {
            for(m=0;m<256; m++) pen[m]=0;  // zero out bins
            mode = 0; penmax = 0;          // clear mode and max bin count

            rl = max(0,i-win[0]);          // set up local windows
            ru = min(dimx,i+win[0]);
            cl = max(0,j-win[1]);
            cu = min(dimy,j+win[1]);

            for(k=rl;k<ru;k++)             // for every pixel in local window
            {
                for(l=cl;l<cu;l++)
                {
                    idx = int(img[k*dimy+l]);  // get bin number

                    if(idx<ign) continue;      // assume bad pixels if below ign

                    pen[idx]++;                // increment bin count
                    if(pen[idx]>penmax)       // if its a new mode
                    {
                        penmax = pen[idx];    // update bin count max
                        mode = idx;            // update mode
                    }
                }
            }
            f[i*dimy+j]=mode;              // set output pixel to mode from window
        }
    }
    return;
}


