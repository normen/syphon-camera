//
//  SyphonSender.m
//  SyphonNetCamera
//
//  Created by Normen Hansen on 17.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import "SyphonSender.h"
#import <OpenGL/CGLMacro.h>

@implementation SyphonSender


- (id)init{
    self = [super init];
    if(self != nil){
        finished = YES;
        jpeg = tjInitDecompress();
        client = [[NetCamClient alloc] init];
        client.timeout = 6.0;
        client.delegate = self;
    }
    return self;
}

- (id)initWithData:(NSDictionary *)dict{
    self = [self init];
    if(self != nil){
        client.name = [dict valueForKey:@"name"];
        client.url = [dict valueForKey:@"url"];
        client.user = [dict valueForKey:@"user"];
        client.password = [dict valueForKey:@"password"];
        self.enabled = [[dict valueForKey:@"enabled"] boolValue];
    }
    return self;
}

- (void)dealloc{
    client.delegate = nil;
    client = nil;
    tjDestroy(jpeg);
//    NSLog(@"Dealloc Sender");
}

- (NSDictionary *)getData{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          client.name, @"name",
                          client.url, @"url",
                          client.user, @"user",
                          client.password, @"password",
                          [NSNumber numberWithBool:self.enabled], @"enabled",
                          nil];
    return dict;
}

- (void)start {
    if(!finished) return;
    curWidth = 0;
    curHeight = 0;
    [self willChangeValueForKey:@"enabled"];
    finished = NO;
    [self didChangeValueForKey:@"enabled"];
    readThread = [[NSThread alloc] initWithTarget:self
                                                   selector:@selector(runLoop)
                                                     object:nil];
    [readThread start];
}

- (void) nop{
    //does nothing, for kicking the queue
    //TODO: replace with proper notify
}

- (void)stop {
    if(finished) return;
    [self willChangeValueForKey:@"enabled"];
    finished = YES;
    if(NSThread.currentThread != readThread){
        //make sure readThread does finish by kicking the queue
        [self performSelector:@selector(nop) onThread:readThread withObject:nil waitUntilDone:NO];
        while([readThread isExecuting]){
            [NSThread sleepForTimeInterval:0.01];
        }
    }
    [self didChangeValueForKey:@"enabled"];
}

- (void) cleanup{
    client.delegate = nil;
    client = nil;
}

- (void) cleanupGLContext{
    glContext = nil;
    if(server!=nil){
        [server removeObserver:self forKeyPath:@"hasClients"];
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
    cgl_ctx = [glContext CGLContextObj];
    
    // Enable GL multithreading
//    CGLError err = 0;
//    CGLContextObj ctx = CGLGetCurrentContext();
//    err =  CGLEnable( ctx, kCGLCEMPEngine);
//    if (err != kCGLNoError ) {
//        NSLog(@"Could not enable MP OpenGL");
//    }
    
    server = [[SyphonServer alloc] initWithName:self.name context:cgl_ctx options:nil];
    [server addObserver:self forKeyPath:@"hasClients" options:NSKeyValueObservingOptionNew context:nil];
}

- (void) cleanupOffScreenRenderer{
    if(texture != 0){
        glDeleteTextures(1, &texture);
        free(imageData);
        texture = 0;
    }
}

- (void) setupOffScreenRenderWithWidth:(NSInteger) width height:(NSInteger) height{
    [self cleanupOffScreenRenderer];

    glEnable(GL_TEXTURE_2D);
    
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, NULL);
    
    imageData = calloc(width * 4, height);
}

- (void)runLoop {
    //dummy input port for runloop to avoid 100% cpu
    NSPort *port = [NSMachPort port];
    [[NSRunLoop currentRunLoop] addPort:port forMode:NSDefaultRunLoopMode];
    [self setupGLContext];
    if(server.hasClients)
        [client start];
    //drain queue so callbacks are happening
    while(!finished) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }        
    [[NSRunLoop currentRunLoop] removePort:port forMode:NSDefaultRunLoopMode];
    [client stop];
    [server stop];
    [self cleanupOffScreenRenderer];
    [self cleanupGLContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)contex{
    if(server.hasClients && readThread != nil){
        //always enable/disable on main thread to maintain consistency
        [client performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
    }else{
        [client performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:NO];
    }
}

- (void) netCamClient:(NetCamClient*) client didReceiveImage:(NSData *) imagedata{
    if(server && ![server hasClients]){
        return;
    }
    int imageWidth, imageHeight, jpegsubsamp;
    tjDecompressHeader2(jpeg, (unsigned char*)[imagedata bytes], [imagedata length],
                        &imageWidth, &imageHeight, &jpegsubsamp);
    if(texture == 0 || curHeight != imageHeight || curWidth != imageWidth){
        [self setupOffScreenRenderWithWidth:imageWidth height:imageHeight];
        curWidth = imageWidth;
        curHeight = imageHeight;
    }
    tjDecompress2(jpeg, (unsigned char*)[imagedata bytes], [imagedata length], imageData, imageWidth, 0, imageHeight, TJPF_RGBX, 0);
    
    //TODO: guess this only works cause I leave states open, probably best to set these here again?
    glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, imageWidth, imageHeight, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8_REV, imageData);
    [server publishFrameTexture:texture
                    textureTarget:GL_TEXTURE_2D
                      imageRegion:NSMakeRect(0, 0, imageWidth, imageHeight)
              textureDimensions:(NSSize){imageWidth, imageHeight}
                          flipped:YES];
}

- (void) netCamClient:(NetCamClient*) client didReceiveError:(NSError*) error{
    NSAlert *alert = [[NSAlert alloc] init];
    NSString *message = [[NSString alloc] initWithFormat:@"%@ was disabled!\n%@", client.name, [error localizedDescription]];
    alert.messageText = message;
    alert.alertStyle =  NSCriticalAlertStyle;
    [alert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:NO];
    self.enabled = NO;
}

- (BOOL)enabled{
    return !finished;
}

- (void)setEnabled:(BOOL)enabled{
    if(enabled){
        //always enable/disable on main thread to maintain consistency
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
    }else{
        [self performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:NO];
    }
}

- (NSString *)url{
    return client.url;
}

- (void)setUrl:(NSString *)url{
    client.url = url;
}

- (NSString *)user{
    return client.user;
}

- (void)setUser:(NSString *)user{
    client.user = user;
}

- (NSString *)password{
    return client.password;
}

- (void)setPassword:(NSString *)password{
    client.password = password;
}

- (NSString *)name{
    return client.name;
}

- (void)setName:(NSString *)name{
    client.name = name;
}

@end
