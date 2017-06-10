//
//  CTSAppDelegate.h
//  SyphonNetCamera
//
//  Created by Normen Hansen on 17.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "SyphonSender.h"

@interface SNCAppDelegate : NSObject <NSApplicationDelegate>{
    NSMutableArray *senders;
    NSInteger _selectedCam;
}
//show main window
- (IBAction)showWindow:(id)sendr;
//add a new net camera to the list
- (IBAction)addCam:(id)sender;
//remove selected net camera from list
- (IBAction)deleteCam:(id)sender;

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *table;
//accessor for currently selected net camera (for UI bindings)
@property (readonly) SyphonSender *sender;
//index of currently selected net camera
@property (nonatomic, assign) NSIndexSet *selectedCam;

@end
