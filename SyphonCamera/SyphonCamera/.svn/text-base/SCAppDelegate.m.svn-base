//
//  SCAppDelegate.m
//  SyphonCamera
//
//  Created by Normen Hansen on 19.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import "SCAppDelegate.h"

@implementation SCAppDelegate

@synthesize window = _window;

- (id)init{
    self = [super init];
    if(self){
        _selectedDevice = -1;
        runningDevices = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)dealloc{
    [runningDevices release];
    [super dealloc];
}

- (void) startDeviceWithName:(NSString*)name{
    if([runningDevices objectForKey:name]!=nil){
        return;
    }
    SyphonSender *sender = [[SyphonSender alloc] init];
    sender.deviceName = name;
    sender.enabled = YES;
    [runningDevices setObject:sender forKey:name];
    [sender release];
}

- (void) stopDeviceWithName:(NSString*)name{
    SyphonSender *sender = [runningDevices objectForKey:name];
    sender.enabled = NO;
    [runningDevices removeObjectForKey:name];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    // Insert code here to initialize your application
    NSArray *devices = [QTKitHelper getVideoDeviceList];
    
    for (NSInteger i=0; i < devices.count; i++) {
        QTCaptureDevice *mydevice = [devices objectAtIndex:i];
        if([[[NSUserDefaults standardUserDefaults] valueForKey:mydevice.description] boolValue]){
            [self willChangeValueForKey:@"deviceEnabled"];
            [self startDeviceWithName:mydevice.description];
            [self didChangeValueForKey:@"deviceEnabled"];
        }
    }
}

- (BOOL)deviceEnabled{
    if(selectedDeviceName == nil) return NO;
    return [[[NSUserDefaults standardUserDefaults] valueForKey:selectedDeviceName] boolValue];
}

- (void)setDeviceEnabled:(BOOL)deviceEnabled{
    if(selectedDeviceName == nil) return;
    [self willChangeValueForKey:@"deviceEnabled"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:deviceEnabled] forKey:selectedDeviceName];
    if(deviceEnabled)
        [self startDeviceWithName:selectedDeviceName];
    else
        [self stopDeviceWithName:selectedDeviceName];
    [self didChangeValueForKey:@"deviceEnabled"];
}

- (void)setSelectedDevice:(NSIndexSet *)selectedCam {
    [self willChangeValueForKey:@"selectedDevice"];
    [self willChangeValueForKey:@"deviceEnabled"];
    if(selectedCam.count > 0)
        _selectedDevice = selectedCam.firstIndex;
    else
        _selectedDevice = -1;
    
    NSArray *devices = [QTKitHelper getVideoDeviceList];
    
    if (devices.count > _selectedDevice) {
        QTCaptureDevice *mydevice = [devices objectAtIndex:_selectedDevice];
            selectedDeviceName = mydevice.description;
    }
    
    [self didChangeValueForKey:@"selectedDevice"];
    [self didChangeValueForKey:@"deviceEnabled"];
}

- (NSIndexSet *)selectedDevice{
    if(_selectedDevice < 0){
        return [NSIndexSet indexSet];
    }
    return [NSIndexSet indexSetWithIndex:_selectedDevice];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    NSArray *devices = [QTKitHelper getVideoDeviceList];
    return devices.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSArray *devices = [QTKitHelper getVideoDeviceList];
    if(devices.count > row){
        return [[devices objectAtIndex:row] description];
    }
    return @"?";
}

- (IBAction)showWindow:(id)sendr{
    [_window makeKeyAndOrderFront:nil];
}


@end
