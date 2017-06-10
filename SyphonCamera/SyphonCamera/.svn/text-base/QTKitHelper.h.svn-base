//
//  QTKitHelper.h
//  SyphonCamera
//
//  Created by Normen Hansen on 20.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

@interface QTKitHelper : NSObject

//gets array of all qtkit video devices (video and muxed)
+ (NSArray *)getVideoDeviceList;
//gets a video device by name
+ (QTCaptureDevice *)getVideoDeviceWithName:(NSString *)name;
//disables audio for a muxed video device
+ (void)disableAudioForInput:(QTCaptureDeviceInput *)input;

@end
