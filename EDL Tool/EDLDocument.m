//
//  EDLDocument.m
//  EDL Tool
//
//  Created by Tashi Trieu on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EDLDocument.h"
#import "Timecode.h"

@implementation EDLDocument
@synthesize edl = _edl;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"EDLDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    
    // Mark as unsaved to prevent saving over old edls.
    [self updateChangeCount:NSChangeDone];

}

+ (BOOL)autosavesInPlace
{
    return NO;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    if ([typeName isEqualToString:@"Edit Decision List"]) {
        return [self.edl dataRepresentation];
    }
    else if ([typeName isEqualToString:@"Edit Decision Exchange"]) {
        return [self.edl xmlDataRepresentation];
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    if ([typeName isEqualToString:@"Edit Decision List"]) {
        self.edl = [EDL edlWithData:data];
    }
    else if ([typeName isEqualToString:@"Edit Decision Exchange"]) {
        self.edl = [EDL edlWithXMLData:data];
    }
    if (self.edl) {
        return YES;
    }

    return NO;
}

@end
