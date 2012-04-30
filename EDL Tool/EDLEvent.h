//
//  EDLEvent.h
//  EDL Tool
//
//  Created by Tashi Trieu on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Timecode.h"

typedef enum {
    EDLEventUnknownTrackType,
    EDLEventVideoTrackType,
    EDLEventAudioTrackType
} EDLEventTrackType;


@interface EDLEvent : NSObject

@property (retain) NSString *eventIdentifier;
@property (retain) NSString *tapeName;
@property (assign) EDLEventTrackType trackType;
@property (retain) NSString *transitionType;
@property (retain) NSNumber *transitionDuration;
@property (readonly) NSString *transitionDescription;

@property (retain) Timecode *sourceIn;
@property (retain) Timecode *sourceOut;
@property (retain) Timecode *recordIn;
@property (retain) Timecode *recordOut;
@property (retain) NSMutableArray *comments;

-(NSString *)edlTextRepresentation;
-(NSXMLNode *)xmlNode;

@end
