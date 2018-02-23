//
//  OpenCVWrapper.m
//  YourAdsSDK
//
//  Created by Cris Toozs on 11/02/2018.
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>

@implementation OpenCVWrapper

// We can use C++ code here



//public Mat onCameraFrame(CameraBridgeViewBase.CvCameraViewFrame inputFrame) {
//
//    mRgba = inputFrame.rgba();
//    mGray = inputFrame.gray();
//
//    if (mAbsoluteFaceSize == 0) {
//        int height = mGray.rows();
//        if (Math.round(height * mRelativeFaceSize) > 0) {
//            mAbsoluteFaceSize = Math.round(height * mRelativeFaceSize);
//        }
//        mNativeDetector.setMinFaceSize(mAbsoluteFaceSize);
//    }
//
//    MatOfRect faces = new MatOfRect();
//
//    if (mDetectorType == JAVA_DETECTOR) {
//        if (mJavaDetector != null)
//            mJavaDetector.detectMultiScale(mGray, faces, 1.1, 2, 2, // TODO: objdetect.CV_HAAR_SCALE_IMAGE
//                                           new Size(mAbsoluteFaceSize, mAbsoluteFaceSize), new Size());
//    }
//    else if (mDetectorType == NATIVE_DETECTOR) {
//        if (mNativeDetector != null)
//            mNativeDetector.detect(mGray, faces);
//    }
//    else {
//        Log.e(TAG, "Detection method is not selected!");
//    }
//
//    Rect[] facesArray = faces.toArray();
//    if (facesArray.length > 0 && !myVideoView.isPlaying()) {
//        myVideoView.start();
//    } else if (facesArray.length == 0 && myVideoView.isPlaying()){
//        nb_pause++;
//        myVideoView.pause();
//    }
//
//    for (int i = 0; i < facesArray.length; i++)
//        Imgproc.rectangle(mRgba, facesArray[i].tl(), facesArray[i].br(), FACE_RECT_COLOR, 3);
//
//    return mRgba;
//}





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

@end
