//
//  NetCamClient.h
//  SyphonNetCamera
//
//  Created by Hao Hu on 28.06.11.
//  Adapted by Normen Hansen
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.

#import <Foundation/Foundation.h>
#import "Base64.h"


typedef enum {
    ERROR_AUTH
    
} NSMJPEGErrorCode;

@class NetCamClient;

@protocol NetCamClientDelegate <NSObject>
//a whole jpeg image has been received
- (void) netCamClient:(NetCamClient*) client didReceiveImage:(NSData*) imageData;
//a network error has occurred, client will stop after calling this
- (void) netCamClient:(NetCamClient*) client didReceiveError:(NSError*) error;
@end

@interface NetCamClient : NSObject {
    NSString * _name;
    NSString * _url;
    NSMutableData * recvData;
    NSString * _user;
    NSString *_password;
    id<NetCamClientDelegate> _delegate;
    NSURLConnection *_urlConn;
    NSTimeInterval _timeout;
    int timeoutCount;
}

//the delegate (MJPEGClientDelegate) to which the image data and errors are being sent
@property (nonatomic, retain) id<NetCamClientDelegate> delegate;

//the net camera connection info
@property(nonatomic,retain) NSString* name;
@property (nonatomic, retain) NSString *url;
@property (nonatomic,retain)  NSString *user;
@property (nonatomic, retain) NSString *password;
@property (nonatomic) NSTimeInterval timeout;

//the current state of the receiver (doesn't set the state, use start/stop)
@property(nonatomic) BOOL running;

//start/stop the connection on the current thread
- (void) start;
- (void) stop;

@end

