#ifdef __OBJC__
#import "OpenCVWrapper.h"
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "YourAdsSDK.h"

FOUNDATION_EXPORT double YourAdsSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char YourAdsSDKVersionString[];
