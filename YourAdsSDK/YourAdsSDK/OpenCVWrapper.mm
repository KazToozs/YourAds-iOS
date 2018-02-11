//
//  OpenCVWrapper.m
//  YourAdsSDK
//
//  Created by Cris Toozs on 11/02/2018.
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>

@implementation OpenCVWrapper

+(NSString *)openCVVersionString
{
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

@end
