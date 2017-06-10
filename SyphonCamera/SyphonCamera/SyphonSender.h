//
//  SyphonSender.h
//  SyphonCamera
//
//  Created by Normen Hansen on 19.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import <Foundation/Foundation.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <Syphon/Syphon.h>
#import "QTKitHelper.h"


@interface SyphonSender : NSObject{
    NSOpenGLContext *glContext;
    CGLContextObj cgl_ctx;
    SyphonServer *server;
    
    NSString                            *_currentDevice;
	QTCaptureSession					*mCaptureSession;
	QTCaptureDeviceInput				*mCaptureDeviceInput;
	QTCaptureDecompressedVideoOutput	*mCaptureDecompressedVideoOutput;
	
    GLuint texture;
    NSInteger curWidth;
    NSInteger curHeight;
    
    BOOL running;
    NSString *_deviceName;
}

//when set to YES the video device called "deviceName" will be captured to syphon
@property (nonatomic) BOOL enabled;
//sets the video device name to be used for capturing
@property (nonatomic, retain) NSString *deviceName;

@end
