//
//  SyphonSender.m
//  SyphonCamera
//
//  Created by Normen Hansen on 19.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import "SyphonSender.h"
#import <OpenGL/CGLMacro.h>

@implementation SyphonSender

@synthesize deviceName = _deviceName;

- (id)init {
    self = [super init];
    if(self){
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(_devicesDidChange:) 
													 name:QTCaptureDeviceWasConnectedNotification 
												   object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(_devicesDidChange:) 
													 name:QTCaptureDeviceWasDisconnectedNotification 
												   object:nil];
    }
    return self;
}

- (void)dealloc{
    [_deviceName release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void) cleanupGLContext{
    [glContext release];
    glContext = nil;
    if(server != nil){
        [server removeObserver:self forKeyPath:@"hasClients"];
        [server release];
        server = nil;
    }
}

- (void) setupGLContext{
    NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFADepthSize, 32,
        0
    };
    NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    glContext = [[NSOpenGLContext alloc] initWithFormat:format shareContext:nil];
    [format release];
    cgl_ctx = [glContext CGLContextObj];
// Enable GL multithreading
//    CGLError err = 0;
//    CGLContextObj ctx = CGLGetCurrentContext();
//    err =  CGLEnable( ctx, kCGLCEMPEngine);
//    if (err != kCGLNoError ) {
//        NSLog(@"Could not enable MP OpenGL");
//    }
    
    server = [[SyphonServer alloc] initWithName:_deviceName context:cgl_ctx options:nil];
    [server addObserver:self forKeyPath:@"hasClients" options:NSKeyValueObservingOptionNew context:nil];
}

- (void) cleanupOffScreenRenderer{
    if(texture != 0){
        glDeleteTextures(1, &texture);
        texture = 0;
        curWidth = 0;
        curHeight = 0;
    }
}

- (void) setupOffScreenRenderWithWidth:(NSInteger) width height:(NSInteger) height
{
    [self cleanupOffScreenRenderer];
    
    glEnable(GL_TEXTURE_2D);
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, NULL);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)contex{
    if(![[[NSUserDefaults standardUserDefaults] valueForKey:@"KeepCamsHot"] boolValue]){
        if(server.hasClients && ![mCaptureSession isRunning] && running){
            [self performSelectorOnMainThread:@selector(startCaptureSession) withObject:nil waitUntilDone:NO];
        }else if(!server.hasClients && [mCaptureSession isRunning]){
            [self performSelectorOnMainThread:@selector(pauseCaptureSession) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)startCaptureSession{
	if ( !mCaptureSession || _currentDevice != self.deviceName){
        NSError *error = nil;
        BOOL success;
		
        QTCaptureDevice *device = [QTKitHelper getVideoDeviceWithName:self.deviceName];
        
        if(device == nil){
            NSLog(@"Could not open device %@", _deviceName);
            return;
        }
        
        server.name = device.description;
        success = [device open:&error];
        if (!success) {
            NSLog(@"Could not open device %@", device);
            return;
        } 
        NSLog(@"Opened device successfully");
		
        [mCaptureSession release];
        mCaptureSession = [[QTCaptureSession alloc] init];
		
        [mCaptureDeviceInput release];
        mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];

        [QTKitHelper disableAudioForInput:mCaptureDeviceInput];
		
        success = [mCaptureSession addInput:mCaptureDeviceInput error:&error];
		
        if (!success) {
            NSLog(@"Failed to add Input");
            if (mCaptureSession) {
                [mCaptureSession release];
                mCaptureSession= nil;
            }
            if (mCaptureDeviceInput) {
                [mCaptureDeviceInput release];
                mCaptureDeviceInput= nil;
				
            }
            return;
        }
		
        NSLog(@"Adding output");
		
        [mCaptureDecompressedVideoOutput release];
        mCaptureDecompressedVideoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
		
        [mCaptureDecompressedVideoOutput setPixelBufferAttributes:
         //TODO: allow resizing of cam image
         [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:YES], kCVPixelBufferOpenGLCompatibilityKey,
          [NSNumber numberWithLong:k32BGRAPixelFormat], kCVPixelBufferPixelFormatTypeKey, nil]];
        //		  [NSNumber numberWithUnsignedInt: self.inputWidth], kCVPixelBufferWidthKey,
        //		  [NSNumber numberWithUnsignedInt: self.inputHeight], kCVPixelBufferHeightKey,
		
        [mCaptureDecompressedVideoOutput setDelegate:self];
        success = [mCaptureSession addOutput:mCaptureDecompressedVideoOutput error:&error];
		
        if (!success) {
            NSLog(@"Failed to add output");
            if (mCaptureSession) {
                [mCaptureSession release];
                mCaptureSession= nil;
            }
            if (mCaptureDeviceInput) {
                [mCaptureDeviceInput release];
                mCaptureDeviceInput= nil;
            }
            if (mCaptureDecompressedVideoOutput) {
                [mCaptureDecompressedVideoOutput release];
                mCaptureDecompressedVideoOutput= nil;
            }
            return;
        }
		if(server.hasClients || [[[NSUserDefaults standardUserDefaults] valueForKey:@"KeepCamsHot"] boolValue])
            [mCaptureSession startRunning];
        _currentDevice = self.deviceName;
    } else if(![mCaptureSession isRunning] && server.hasClients){
        [mCaptureSession startRunning];
    }    
}

- (void)stopCaptureSession{
    if (mCaptureSession) {
        [mCaptureSession stopRunning];
        [mCaptureSession release];
        mCaptureSession= nil;
    }
    if (mCaptureDeviceInput) {
        [mCaptureDeviceInput release];
        mCaptureDeviceInput= nil;
    }
    if (mCaptureDecompressedVideoOutput) {
        [mCaptureDecompressedVideoOutput release];
        mCaptureDecompressedVideoOutput= nil;
    }
    [self cleanupOffScreenRenderer];
}

- (void) pauseCaptureSession{
    [mCaptureSession stopRunning];
}

- (void)captureOutput:(QTCaptureOutput *)captureOutput  didOutputVideoFrame:(CVImageBufferRef)videoFrame 
     withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection{    
    size_t imageWidth = CVPixelBufferGetWidth(videoFrame);
    size_t imageHeight = CVPixelBufferGetHeight(videoFrame);
    
    if(texture == 0 || curWidth != imageWidth || curHeight != imageHeight){
        [self setupOffScreenRenderWithWidth:imageWidth height:imageHeight];
        curWidth = imageWidth;
        curHeight = imageHeight;
    }
    
    CVPixelBufferLockBaseAddress(videoFrame, 0);
    
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, imageWidth, imageHeight, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, CVPixelBufferGetBaseAddress(videoFrame));
    
    [server publishFrameTexture:texture
                  textureTarget:GL_TEXTURE_2D
                    imageRegion:NSMakeRect(0, 0, imageWidth, imageHeight)
              textureDimensions:(NSSize){imageWidth, imageHeight}
                        flipped:YES];
    
    CVPixelBufferUnlockBaseAddress(videoFrame, 0);
}


- (void)_devicesDidChange:(NSNotification *)aNotification {
	NSLog(@"Devices changed");
}

- (void) start{
    if(running) return;
    [self willChangeValueForKey:@"enabled"];
    running = true;
    [self setupGLContext];
    [self startCaptureSession];
    [self didChangeValueForKey:@"enabled"];
}

- (void) stop{
    if(!running) return;
    [self willChangeValueForKey:@"enabled"];
    running = false;
    [self stopCaptureSession];
    [self cleanupGLContext];
    [self didChangeValueForKey:@"enabled"];
}

- (BOOL)enabled{
    return running;
}

- (void)setEnabled:(BOOL)enabled{
    if(enabled){
        //always enable/disable on main thread to maintain consistency
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
    }else{
        [self performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:NO];
    }
}

@end
