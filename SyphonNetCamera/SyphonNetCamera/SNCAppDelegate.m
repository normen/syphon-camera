//
//  CTSAppDelegate.m
//  SyphonNetCamera
//
//  Created by Normen Hansen on 17.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import "SNCAppDelegate.h"

@implementation SNCAppDelegate

@synthesize window = _window;
@synthesize table = _table;

- (id)init{
    self = [super init];
    if(self){
        senders = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

- (void)dealloc{
    senders = nil;
}

- (void) storeSettings{
    NSMutableArray *storeArray = [[NSMutableArray alloc] initWithCapacity:senders.count];
    for (NSInteger i=0; i<senders.count; i++) {
        SyphonSender *sender = [senders objectAtIndex:i];
        NSDictionary *dict = [sender getData];
        [storeArray addObject:dict];
    }
    [[NSUserDefaults standardUserDefaults] setValue:storeArray forKey:@"CameraList"];
}

- (void) loadSettings{
    NSArray *loadArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"CameraList"];
    if(loadArray != nil){
        for (NSInteger i=0; i<loadArray.count; i++) {
            SyphonSender *sender = [[SyphonSender alloc] initWithData:[loadArray objectAtIndex:i]];
            [senders addObject:sender];
        }
    }
    [self.table reloadData];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    [self loadSettings];
}

- (void)applicationWillTerminate:(NSNotification *)notification{
    [self storeSettings];
}

- (SyphonSender *)sender{
    if(senders.count > _selectedCam  && _selectedCam >= 0)
        return [senders objectAtIndex:_selectedCam];
    else
        return nil;
}

- (void)setSelectedCam:(NSIndexSet *)selectedCam {
    [self willChangeValueForKey:@"sender"];
    if([selectedCam count]>0)
        _selectedCam = [selectedCam firstIndex];
    else
        _selectedCam = -1;
    [self didChangeValueForKey:@"sender"];
}

- (NSIndexSet *)selectedCam{
    if(_selectedCam < 0){
        return [NSIndexSet indexSet];
    }
    return [NSIndexSet indexSetWithIndex:_selectedCam];
}

- (IBAction)addCam:(id)sendr{
    SyphonSender *sender = [[SyphonSender alloc] init];
    sender.url = @"http://192.168.2.3/mjpg/video.mjpg";
    sender.name = @"New NetCam";
    [senders addObject:sender];
    [self.table reloadData];
}

- (IBAction)deleteCam:(id)sendr{
    [self willChangeValueForKey:@"sender"];
    SyphonSender *sender = [senders objectAtIndex:_selectedCam];
    sender.enabled = NO;
    [sender cleanup];
    [senders removeObjectAtIndex:_selectedCam];
    if(_selectedCam >= senders.count){
        [self willChangeValueForKey:@"selectedCam"];
        _selectedCam = senders.count-1;
        [self didChangeValueForKey:@"selectedCam"];
    }
    [self didChangeValueForKey:@"sender"];
    [self.table reloadData];
}

- (IBAction)showWindow:(id)sendr{
    [_window makeKeyAndOrderFront:nil];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return senders.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if(senders.count > row){
        SyphonSender *sender = [senders objectAtIndex:row];
        return sender.name;
    }
    return @"?";
}

@end
