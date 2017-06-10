//
//  NetCamClient.m
//  SyphonNetCamera
//
//  Created by Hao Hu on 28.06.11.
//  Adapted by Normen Hansen
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.

#import "NetCamClient.h"
#import <Syphon/Syphon.h>


@implementation NetCamClient

@synthesize url = _url;
@synthesize user = _user;
@synthesize password = _password;
@synthesize delegate = _delegate;
@synthesize timeout = _timeout;
@synthesize name = _name;
@synthesize running;


- (void) stop {
    if(!self.running) return;
    self.running = NO;
    if (_urlConn){
        [_urlConn cancel];
        _urlConn = nil;
//        NSLog(@"Stopped URLConnection");
    }
}

- (void) start {
    if(self.running) return;
    self.running = YES;
    if (_url) {
        NSURL * nsUrl = [[NSURL alloc] initWithString:_url];
        NSMutableURLRequest * request = [[NSMutableURLRequest alloc] initWithURL:nsUrl];
        
        [request setTimeoutInterval:_timeout];
        if (self.user != nil && self.password != nil) {
            NSString *authString = [[NSString alloc] initWithFormat:@"%@:%@",self.user,self.password];
            //NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
            NSString *authedString = [Base64 encodePlaintText:authString];
            
            NSString *value = [[NSString alloc] initWithFormat:@"Basic %@",authedString];
            [request addValue:value forHTTPHeaderField:@"Authorization"];  
        }
        
        _urlConn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (_urlConn)
            recvData = [NSMutableData data];
        
        [_urlConn start];
//        NSLog(@"Started URLConnection");
    }
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = nil;
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        httpResponse = (NSHTTPURLResponse *) response;
    }
    
    if (httpResponse) {
        NSInteger statusCode = [httpResponse statusCode];
        if (statusCode < 200 || statusCode >= 300) {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc]init];
            [userInfo setObject:@"Non 200 response code!" forKey:NSLocalizedDescriptionKey];
            NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:statusCode userInfo:userInfo];
            if (self.delegate) {
                [self.delegate netCamClient:self didReceiveError:error];
            }
            _urlConn = nil;
        }
    }
    
    if ([recvData length] != 0) {
        //remove /r/n (0xFF,0x0D, 0x0A)
        [recvData setLength:(recvData.length - 3)];
        timeoutCount = 0;
        if (self.delegate)
            [self.delegate netCamClient:self didReceiveImage:recvData];
    }
    [recvData setLength:0];
    
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [recvData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Network Error: %@", error.localizedDescription);
    _urlConn = nil;
    if (self.delegate)
        [self.delegate netCamClient:self didReceiveError:error];
    self.running = NO;
}

-(void) connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    NSLog(@"Authentication requested.");
    _urlConn = nil;
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setObject:@"Authentication Error!" forKey:NSLocalizedDescriptionKey];
    NSError* error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:ERROR_AUTH userInfo:userInfo];
    if (self.delegate) {
        [self.delegate netCamClient:self didReceiveError:error];
    }
    self.running = NO;
}

-(void) dealloc {
    recvData = nil;
    _name = nil;
    _url = nil;
    _user = nil;
    _password = nil;
    _delegate = nil;
//    NSLog(@"Dealloc NetCam Client");
}
@end
