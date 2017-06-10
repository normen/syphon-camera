//
//  SCAppDelegate.h
//  SyphonCamera
//
//  Created by Normen Hansen on 19.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "QTKitHelper.h"
#import "SyphonSender.h"

@interface SCAppDelegate : NSObject <NSApplicationDelegate>{
    NSWindow *_window;
    NSInteger _selectedDevice;
    NSString *selectedDeviceName;
    NSMutableDictionary *runningDevices;
}

//show main window
- (IBAction)showWindow:(id)sendr;

@property (nonatomic, assign) IBOutlet NSWindow *window;
//set/get capture state of the currently selected video device
@property (nonatomic) BOOL deviceEnabled;
//index of the currently selected video device
@property (nonatomic, assign) NSIndexSet *selectedDevice;

@end
