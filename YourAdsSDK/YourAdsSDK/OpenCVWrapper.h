//
//  OpenCVWrapper.h
//  YourAdsSDK
//
//  Created by Cris Toozs on 11/02/2018.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

// Define here interface with OpenCV

// Function to get OpenCV version
+(NSString *) openCVVersionString;

// Function to convert image to greyscale
+(UIImage *) makeGrayFromImage:(UIImage *) image;

@end
