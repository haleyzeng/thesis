#include "ImageProcessor.hpp"
#include "math.h"

using namespace cv;
using namespace std;

typedef Mat (*filterFunc)(Mat);
std::map<std::string, filterFunc> filterNameFuncMap = {
    {"BINARIZE", ImageProcessor::binarize},
    {"CANNY_EDGE_DETECT",ImageProcessor::cannyEdgeDetect},
    {"COLOR_INVERT", ImageProcessor::colorInvert},
    {"GAUSSIAN_BLUR", ImageProcessor::gaussianBlur},
    {"HISTOGRAM_EQUALIZE", ImageProcessor::histogramEqualize},
    {"ISOLATE_BOARD", ImageProcessor::isolateBoard},
    {"SIMPLE_THRESHOLD", ImageProcessor::simpleThreshold},
    {"GREYSCALE", ImageProcessor::getGrayscale},
};

Mat ImageProcessor::applyFilters(Mat image, std::vector<std::string> filters) {
    if (filters.size() == 0) return image;
    Mat processedImage = getGrayscale(image);
    for (int i = 0; i < filters.size(); i++) {
        if (filterNameFuncMap.find(filters[i]) != filterNameFuncMap.end()) {
            processedImage = filterNameFuncMap[filters[i]](processedImage);
        } else {
            cout << "ImageProcessor::applyFilters could not find filter: "<< filters[i] << "\n";
        }
    }
    return processedImage;
}

Mat ImageProcessor::getGrayscale(Mat image) {
    if (image.channels() == 1) {
        return image;
    }
    Mat processedImage;
    cvtColor(image, processedImage, COLOR_RGB2GRAY);
    return processedImage;
}

Mat ImageProcessor::binarize(Mat image) {
    Mat processedImage;
    medianBlur(image, processedImage, 3);
    adaptiveThreshold(processedImage, processedImage, 255, ADAPTIVE_THRESH_GAUSSIAN_C, THRESH_BINARY, 25, 12);
    return processedImage;
}

Mat ImageProcessor::cannyEdgeDetect(Mat image) {
    Mat edges;
    Canny(image, edges, 75, 200);
    return edges;
}

Mat ImageProcessor::colorInvert(Mat image) {
    Mat processedImage;
    bitwise_not(image, processedImage);
    return processedImage;
}

vector<Point> getContoursConvexHull( vector<vector<Point>> contours )
{
    vector<Point> result;
    vector<Point> pts;
    for ( size_t i = 0; i< contours.size(); i++)
    for ( size_t j = 0; j< contours[i].size(); j++)
    pts.push_back(contours[i][j]);
    convexHull( pts, result );
    return result;
}

bool compareContourAreas(std::vector<cv::Point> contour1, std::vector<cv::Point> contour2) {
    double i = fabs( contourArea(cv::Mat(contour1)) );
    double j = fabs( contourArea(cv::Mat(contour2)) );
    return ( i > j );
}

double distance(Point a, Point b) {
    double diffX = b.x - a.x;
    double diffY = b.y - a.y;
    double dist_sq = pow(diffX, 2.0) + pow(diffY, 2.0);
    return sqrt(dist_sq);
}

bool comparePointsY (Point2f p1, Point2f p2) {
    return p1.y < p2.y;
}

bool comparePointsX (Point2f p1, Point2f p2) {
    return p1.x < p2.x;
}

// Orders points of rect as [bottom_left, bottom_right, top_right, top_left];
std::vector<Point2f> orderRectPoints(std::vector<Point2f> points) {
    if (points.size() != 4) {
        cout << "orderRectPoints: too many points";
        assert(false);
    }
    sort(points.begin(), points.end(), comparePointsY);
    std::vector<Point> bottom;
    bottom.push_back(points[0]);
    bottom.push_back(points[1]);
    
    std::vector<Point> top;
    top.push_back(points[2]);
    top.push_back(points[3]);
    
    sort(bottom.begin(), bottom.end(), comparePointsX);
    sort(top.begin(), top.end(), comparePointsX);
    
    std::vector<Point2f> sorted;
    sorted.push_back(bottom[0]);
    sorted.push_back(bottom[1]);
    sorted.push_back(top[1]);
    sorted.push_back(top[0]);
    
    return sorted;
}

double getWidthForRectPoints(std::vector<Point2f> pts) {
    std::vector<Point2f> orderedPts = orderRectPoints(pts);
    
    Point2f bl = orderedPts[0];
    Point2f br = orderedPts[1];
    Point2f tr = orderedPts[2];
    Point2f tl = orderedPts[3];
    
    double widthBottom = distance(bl, br);
    double widthTop = distance(tl, tr);
    return max(widthBottom, widthTop);
}

double getHeightForRectPoints(std::vector<Point2f> pts) {
    std::vector<Point2f> orderedPts = orderRectPoints(pts);
    
    Point2f bl = orderedPts[0];
    Point2f br = orderedPts[1];
    Point2f tr = orderedPts[2];
    Point2f tl = orderedPts[3];
    
    double height_left = distance(tl, bl);
    double height_right = distance(tr, br);
    return max(height_left, height_right);
}

double getAreaRatioRectToImage(std::vector<Point2f> pts, Mat image) {
    if (pts.size() != 4) {
        return false;
    } else {
        int imageWidth = image.cols;
        int imageHeight = image.rows;
        double imageArea = imageWidth * imageHeight;
        double rectWidth = getWidthForRectPoints(pts);
        double rectHeight = getHeightForRectPoints(pts);
        double rectArea = rectWidth * rectHeight;
        return rectArea / imageArea;
    }
}

Mat ImageProcessor::isolateBoard(Mat image) {
    Mat preppedImage = cannyEdgeDetect(gaussianBlur(binarize(image)));

    // Find the contours
    std::vector<std::vector<cv::Point>> contours;
    findContours(preppedImage, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);

    // Draw the contours onto a new image
    Mat contourImage(image.size(), CV_8UC1, Scalar(0,0,0));
    drawContours(contourImage, contours, -1, Scalar(255, 255, 255));

    // Do morphological closing to fill in gaps in contours
    Mat closedImage;
    morphologyEx(contourImage, closedImage, MORPH_CLOSE, getStructuringElement(MORPH_RECT, Size(5, 5)), Point(-1,-1), 5);

    // Do morphological erosion to decrease contour thickness and remove noise
    Mat erodedImage;
    erode(closedImage, erodedImage, getStructuringElement(MORPH_RECT, Size(5,5)));

    // Convert color from white-on-black to black-on-white to prepare for second contour detection
    preppedImage = colorInvert(erodedImage);

    // Find contours of morpholically processed image
    std::vector<std::vector<cv::Point>> finalContours;
    findContours(preppedImage, finalContours, RETR_LIST, CHAIN_APPROX_SIMPLE);

    // Sort contours by area in descending order
    std::sort(finalContours.begin(), finalContours.end(), compareContourAreas);

    // Find the largest contour that reasonably represents the board.
    // Reasonable means that it approximates to a quadrangle and that the amount of area
    // that it covers in the image is not trivially little or great.
    int contourIndex = -1;
    std::vector<Point2f> srcPts;
    for (int i = 0; i < finalContours.size(); i++) {
        int perimeter = arcLength(finalContours[i], true);

        // Give more leeway in quadrangle approximation, but exclude the rect that is
        // just the whole image by checking that its area is not too big
        approxPolyDP(finalContours[i], srcPts, 0.05 * perimeter, true);
        if (srcPts.size() == 4) {
            double areaRatio = getAreaRatioRectToImage(srcPts, image);
            if (areaRatio < 0.05) { // too small; rest of contours will be smaller so stop looking
                break;
            } else if (areaRatio < 0.95) { // good size
                contourIndex = i;
                break;
            } else { // too big; keep looking
                continue;
            }
        }
    }


    if (contourIndex == -1) {
        return image;
    } else {
        srcPts = orderRectPoints(srcPts);

        Point2f bl = srcPts[0];
        Point2f br = srcPts[1];
        Point2f tr = srcPts[2];
        Point2f tl = srcPts[3];

        double width_bottom = distance(bl, br);
        double width_top = distance(tl, tr);
        double finalWidth = max(width_bottom, width_top);

        double height_left = distance(tl, bl);
        double height_right = distance(tr, br);
        double finalHeight = max(height_left, height_right);

        std::vector<Point2f> dstPts;
        dstPts.push_back(Point2f(0,0));
        dstPts.push_back(Point2f(finalWidth, 0));
        dstPts.push_back(Point2f(finalWidth, finalHeight));
        dstPts.push_back(Point2f(0,finalHeight));

        Mat matrix = getPerspectiveTransform(srcPts, dstPts);

        Mat transformedImage;

        warpPerspective(image, transformedImage, matrix, Size(finalWidth, finalHeight));

        return transformedImage;
    }
}

Mat ImageProcessor::gaussianBlur(Mat image) {
    Mat processedImage;
    GaussianBlur(image, processedImage, Size(11,11), 255);
    return processedImage;
}

Mat ImageProcessor::histogramEqualize(Mat image) {
    Mat processedImage;
    equalizeHist(image, processedImage);
    return processedImage;
}

Mat ImageProcessor::simpleThreshold(Mat image) {
    Mat processedImage;
    threshold(image, processedImage, 127, 255, THRESH_BINARY);
    return processedImage;
}
