//
//  OpenCVWrapper.m
//  YourAdsSDK
//
//  Created by Cris Toozs on 11/02/2018.
//

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

#include <opencv2/core/core.hpp>
#include "opencv2/highgui.hpp"
#import "OpenCVWrapper.h"

@implementation OpenCVWrapper

// We can use C++ code here

// ---------- OPENCV FUNCTIONS TAKEN DIRECTLY FROM LIBRARY TO AVOID COMPILATION CONFLICTS ----------
UIImage* MatToUIImage(const cv::Mat& image);
void UIImageToMat(const UIImage* image, cv::Mat& m, bool alphaExist);

UIImage* MatToUIImage(const cv::Mat& image) {
    
    NSData *data = [NSData dataWithBytes:image.data
                                  length:image.step.p[0] * image.rows];
    
    CGColorSpaceRef colorSpace;
    
    if (image.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Preserve alpha transparency, if exists
    bool alpha = image.channels() == 4;
    CGBitmapInfo bitmapInfo = (alpha ? kCGImageAlphaLast : kCGImageAlphaNone) | kCGBitmapByteOrderDefault;
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(image.cols,
                                        image.rows,
                                        8 * image.elemSize1(),
                                        8 * image.elemSize(),
                                        image.step.p[0],
                                        colorSpace,
                                        bitmapInfo,
                                        provider,
                                        NULL,
                                        false,
                                        kCGRenderingIntentDefault
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

void UIImageToMat(const UIImage* image,
                  cv::Mat& m, bool alphaExist) {
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = CGImageGetWidth(image.CGImage), rows = CGImageGetHeight(image.CGImage);
    CGContextRef contextRef;
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast;
    if (CGColorSpaceGetModel(colorSpace) == kCGColorSpaceModelMonochrome)
    {
        m.create(rows, cols, CV_8UC1); // 8 bits per component, 1 channel
        bitmapInfo = kCGImageAlphaNone;
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNone;
        else
            m = cv::Scalar(0);
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    else
    {
        m.create(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
        if (!alphaExist)
            bitmapInfo = kCGImageAlphaNoneSkipLast |
            kCGBitmapByteOrderDefault;
        else
            m = cv::Scalar(0);
        contextRef = CGBitmapContextCreate(m.data, m.cols, m.rows, 8,
                                           m.step[0], colorSpace,
                                           bitmapInfo);
    }
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows),
                       image.CGImage);
    CGContextRelease(contextRef);
}
// ---------- End of OpenCV functions ----------

// ---------- Functions using OpenCV methods ----------
+(NSString *)openCVVersionString
{
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

+(UIImage *)makeGrayFromImage:(UIImage *)image
{
    // Transform UIImage to cv::Mat
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);

    // If the image was already grayscale, return it
    if (imageMat.channels() == 1) return image;

    // Convert cv::Mat color image to gray
    cv::Mat grayMat;
    cv::cvtColor(imageMat, grayMat, cv::COLOR_BGR2GRAY);

    // Convert grayMat to UIImage and return
    return MatToUIImage(grayMat);
}
// ---------- End of functions using OpenCV methods ----------

@end



// ***
// ---------- Objective C class to serve as CvVideoCaptureDelegate because Swift cannot ----------
// ***

using namespace cv;
// Class extension to adopt the delegate protocol
@interface CvVideoCameraWrapper () <CvVideoCameraDelegate>
{
}
@end
@implementation CvVideoCameraWrapper
{
    YourAdsVideoCapture * videoCapture;
    UIImageView * imageView;
    CvVideoCamera * videoCamera;

    cv::CascadeClassifier face_cascade;
    String window_name;
    String face_cascade_name;

}

-(id)initWithVideoCapture:(YourAdsVideoCapture*)c andImageView:(UIImageView*)iv
{
    videoCapture = c;
    imageView = iv;
//    face_cascade_name = "/Users/kaztoozs/Documents/Projects/EIP/ModuleTests/OpenCVCompileTest/opencv/data/haarcascades/haarcascade_frontalface_alt.xml";
//    face_cascade_name = "haarcascade_frontalface_alt.xml";

    
    // get main app bundle
    NSBundle * appBundle = [NSBundle mainBundle];
    
    // constant file name
    NSString * cascadeName = @"haarcascade_frontalface_alt";
    NSString * cascadeType = @"xml";
    
    // get file path in bundle
    NSString * cascadePathInBundle = [appBundle pathForResource: cascadeName ofType: cascadeType];
    
    // convert NSString to std::string
    std::string cascadePath([cascadePathInBundle UTF8String]);
    
    String bob = "bob";

    // load cascade
    if (face_cascade.load(cascadePath)){
        printf("Load complete");
    }else{
        printf("Load error");
    }
    
    
//    if (!face_cascade.load(face_cascade_name)){ printf("--(!)Error loading face cascade\n"); return self; };

    
//    NSString * const TFCascadeFilename = @"haarcascade_frontalface_alt.xml";//Strings of haar file names

//        NSString * const TFCascadeFilename = @"Users/kaztoozs/Documents/Projects/EIP/YourAds/Apps/YourAdsPoC-Swift-OCVCocopod-11.7.18/PoC 2.0/Pods/OpenCV/haarcascade_frontalface_alt.xml";//Strings of haar file names
//
//    NSString * const TFCascadeFilename = @"Users/kaztoozs/Documents/Projects/EIP/ModuleTests/OpenCVCompileTest/opencv/data/haarcascades/haarcascade_frontalface_alt.xml";//Strings of haar file names
//
//
//    NSString *TF_cascade_name = [[NSBundle mainBundle] pathForResource:TFCascadeFilename ofType:@"xml"];
//
//    bool check = false;
//    //Load haar file, return error message if fail
//    if (!(check = face_cascade.load( [TF_cascade_name UTF8String] ))) {
//        NSLog(@"[Cascade File]: Could not load TF cascade!");
//    }
//    else{
//        NSLog(@"[Cascade File]: Successfully loaded!");
//    }
//    NSLog(@"[path]: %@\n", TF_cascade_name);
    
    
    videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    // ... set up the camera
    
    self->videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
    self->videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self->videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self->videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self->videoCamera.defaultFPS = 30;
    self->videoCamera.grayscaleMode = NO;
    
    
    videoCamera.delegate = self;
    
    return self;
}
// This #ifdef ... #endif is not needed except in special situations
#ifdef __cplusplus
-(void)processImage:(Mat&)image
{
    
    // Do some OpenCV stuff with the image
    Mat image_copy;
    cvtColor(image, image_copy, COLOR_BGRA2BGR);
    
    // invert image
//    bitwise_not(image_copy, image_copy);
//    cvtColor(image_copy, image, CV_BGR2BGRA);
//
    detectFaces(image_copy, face_cascade, face_cascade_name);
}


//cv::CascadeClassifier face_cascade;
//String window_name = "Face Detection";

/**
 * Detects faces and draws an ellipse around them
 */
void detectFaces(Mat frame, cv::CascadeClassifier face_cascade, String face_cascade_name) {
    
    std::vector<cv::Rect> faces;
    Mat frame_gray;
    cvtColor(frame, frame_gray, COLOR_BGR2GRAY);  // Convert to gray scale
    equalizeHist(frame_gray, frame_gray);       // Equalize histogram

    
//    String face_cascade_name = "/Users/kaztoozs/Documents/Projects/EIP/Try Again/PoC 2.0/Pods/OpenCV/ios/haarcascade_frontalface_alt.xml";
//        String face_cascade_name = "/Users/kaztoozs/Documents/Projects/EIP/ModuleTests/OpenCVCompileTest/opencv/data/haarcascades/haarcascade_frontalface_alt.xml";

//    String face_cascade_name = "haarcascade_frontalface_alt.xml";
//
//    if (!face_cascade.load(face_cascade_name)){ printf("--(!)Error loading face cascade\n"); return; };

    
//    cv::Mat img;
//    std::vector<cv::Rect> faceRects;
//    double scalingFactor = 1.1;
//    int minNeighbors = 2;
//    int flags = 0;
//    cv::Size minimumSize(30,30);
//    face_cascade.detectMultiScale(img, faceRects,
//                                  scalingFactor, minNeighbors, flags,
//                                  cv::Size(30, 30) );
    
    

    // Detect faces
    face_cascade.detectMultiScale(frame_gray, faces, 1.1, 3,
                                  0|CASCADE_SCALE_IMAGE, cv::Size(30, 30));

    // Iterate over all of the faces
    for( size_t i = 0; i < faces.size(); i++ ) {

        // Find center of faces
        cv::Point center(faces[i].x + faces[i].width/2, faces[i].y + faces[i].height/2);

        // Draw ellipse around face
        ellipse(frame, center, cv::Size(faces[i].width/2, faces[i].height/2),
                0, 0, 360, Scalar( 255, 0, 255 ), 4, 8, 0 );
    }
    String window_name = "Face Detection";

    imshow(window_name, frame);  // Display frame
}

#endif

-(void)actionStart
{
    [self->videoCamera start];
}

@end



