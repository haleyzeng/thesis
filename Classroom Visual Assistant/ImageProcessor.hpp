#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;

class ImageProcessor {
    
public:
    
    /*
     Takes a color image and a vector of filter names.
     Returns image with filters applied.
     */
    static Mat applyFilters(Mat image, std::vector<std::string> filters);
    
    /*
     Takes a color image.
     Returns grayscale image.
     */
    static Mat getGrayscale(Mat image);

    /*
     Takes a grayscale image.
     Returns image processed with Gaussian adaptive thresholding algorithm.
     */
    static Mat binarize(Mat image);
    
    /*
     Takes a grayscale image.
     Returns edges determined by Canny algorithm.
     */
    static Mat cannyEdgeDetect(Mat image);

    /*
     Takes an image.
     Returns image processed with colors inverted.
     */
    static Mat colorInvert(Mat image);

    /* Takes a grayscale image.
     Returns blurred image.
     */
    static Mat gaussianBlur(Mat image);
    
    /*
     Takes a grayscale image.
     Returns image processed with histogram equalization.
     */
    static Mat histogramEqualize(Mat image);
    
    /*
     Takes a grayscale image.
     Isolates the board in the image and returns an image of just the board.
     */
    static Mat isolateBoard(Mat image);
    
    /*
     Takes a grayscale image.
     Returns image processed with simple thresholding algorithm.
     */
    static Mat simpleThreshold(Mat image);
    
private:
    
};

