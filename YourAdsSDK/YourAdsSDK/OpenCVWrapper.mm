//
//  OpenCVWrapper.m
//  YourAdsSDK
//
//  Created by Cris Toozs on 11/02/2018.
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/videoio/cap_ios.h>

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
    cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);

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
}

-(id)initWithVideoCapture:(YourAdsVideoCapture*)c andImageView:(UIImageView*)iv
{
    videoCapture = c;
    imageView = iv;
    
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
    cvtColor(image, image_copy, CV_BGRA2BGR);
    
    // invert image
    bitwise_not(image_copy, image_copy);
    cvtColor(image_copy, image, CV_BGR2BGRA);
}
#endif

-(void)actionStart
{
    [self->videoCamera start];
}

@end



