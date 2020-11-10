#ifdef __OBJC__
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

#import "SEGFirebaseIntegration.h"
#import "SEGFirebaseIntegrationFactory.h"

FOUNDATION_EXPORT double Segment_FirebaseVersionNumber;
FOUNDATION_EXPORT const unsigned char Segment_FirebaseVersionString[];

