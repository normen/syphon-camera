//
//  QTKitHelper.m
//  SyphonCamera
//
//  Created by Normen Hansen on 20.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import "QTKitHelper.h"

@implementation QTKitHelper

+ (NSArray *)getVideoDeviceList {
    NSArray *videoDevices= [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeVideo];
    NSArray *muxedDevices= [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed];
    
    NSMutableArray *mutableArrayOfDevice = [[NSMutableArray alloc] init ];
    [mutableArrayOfDevice addObjectsFromArray:videoDevices];
    [mutableArrayOfDevice addObjectsFromArray:muxedDevices];
    
    NSArray *devices = [NSArray arrayWithArray:mutableArrayOfDevice];
    [mutableArrayOfDevice release];
    return devices;
}

+ (QTCaptureDevice *)getVideoDeviceWithName:(NSString *)name{
    NSArray *devices = [QTKitHelper getVideoDeviceList];
    QTCaptureDevice *device = nil;
    for (NSInteger i=0; i < devices.count; i++) {
        QTCaptureDevice *mydevice = [devices objectAtIndex:i];
        if([mydevice.description isEqualToString:name]){
            device = mydevice;
        }
    }
    return device;
}

+ (void)disableAudioForInput:(QTCaptureDeviceInput *)input{
    NSArray *muxedDevices= [QTCaptureDevice inputDevicesWithMediaType:QTMediaTypeMuxed];
    if ([muxedDevices containsObject:input.device]) {
        NSArray *ownedConnections = [input connections];
        for (QTCaptureConnection *connection in ownedConnections) {
            if ( [[connection mediaType] isEqualToString:QTMediaTypeSound]) {
                [connection setEnabled:NO];
            }
        }
    }
}

@end
