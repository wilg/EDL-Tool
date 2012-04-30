//
//  EDLEvent.m
//  EDL Tool
//
//  Created by Tashi Trieu on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EDLEvent.h"

@implementation EDLEvent

@synthesize eventIdentifier, tapeName, trackType, transitionType, transitionDuration, sourceIn, sourceOut, recordIn, recordOut, comments;

-(id)init {
    self = [super init];
    if (self) {
        self.comments = [NSMutableArray array];
    }
    return self;
}

-(NSString *)transitionDescription {
   NSString *typeName = self.transitionType;
    if ([self.transitionType isEqualToString:@"C"]) {
        typeName = @"Cut";
    }
    else if ([self.transitionType isEqualToString:@"D"]) {
        typeName = @"Dissolve";
    }
    if (self.transitionDuration.floatValue > 0) {
        typeName = [NSString stringWithFormat:@"%@ (%@)", typeName, self.transitionDuration];
    }
    return typeName;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<EDLEvent: eventIdentifier=%@ tapeName=%@ trackType=%i transitionType=%@ transitionDuration=%@ sourceIn=%@ sourceOut=%@ recordIn=%@ recordOut=%@ comments=%@>",
            self.eventIdentifier,
            self.tapeName,
            self.trackType, 
            self.transitionType, 
            self.transitionDuration, 
            self.sourceIn,
            self.sourceOut, 
            self.recordIn,
            self.recordOut,
            self.comments,
            nil];
}

- (NSString *)edlTextRepresentation {
    NSMutableString *outputString = [NSMutableString string];

    [outputString appendString:
     [NSString stringWithFormat:@"%-3.3@", self.eventIdentifier]];

    // Two spaces
    [outputString appendString:@"  "];

    [outputString appendString:
     [NSString stringWithFormat:@"%-8.8@", self.tapeName]];

    // One space
    [outputString appendString:@" "];

    [outputString appendString:
    [@"V" stringByPaddingToLength:5 withString:@" " startingAtIndex:0]
    ];

    // One space
    [outputString appendString:@" "];

    [outputString appendString:
        [self.transitionType stringByPaddingToLength:4 withString:@" " startingAtIndex:0]
     ];


    // One space
    [outputString appendString:@" "];

    if (self.transitionDuration.intValue > 0) {
        [outputString appendString:
         [NSString stringWithFormat:@"%03i", self.transitionDuration.intValue]];
    }
    else {
        [outputString appendString:@"   "];
    }

    // One space
    [outputString appendString:@" "];

    [outputString appendString:self.sourceIn.stringRepresentation];

    // One space
    [outputString appendString:@" "];

    [outputString appendString:self.sourceOut.stringRepresentation];

    // One space
    [outputString appendString:@" "];

    [outputString appendString:self.recordIn.stringRepresentation];

    // One space
    [outputString appendString:@" "];

    [outputString appendString:self.recordOut.stringRepresentation];

    for (NSString *comment in self.comments) {
        [outputString appendString:
         [NSString stringWithFormat:@"\n*%@", comment]];
    }

    return [outputString copy];
}

-(NSXMLNode *)xmlNode {
    NSXMLElement *eventNode = [NSXMLNode elementWithName:@"event"];

    [eventNode addChild:[NSXMLNode elementWithName:@"id" stringValue:self.eventIdentifier]];
    [eventNode addChild:[NSXMLNode elementWithName:@"kind" stringValue:@"video"]];
    [eventNode addChild:[NSXMLNode elementWithName:@"tape-name" stringValue:self.tapeName]];
    [eventNode addChild:[NSXMLNode elementWithName:@"edl:transition-type" stringValue:self.transitionType]];
    [eventNode addChild:[NSXMLNode elementWithName:@"edl:transition-duration" stringValue:[self.transitionDuration stringValue]]];

    NSXMLElement *sourceNode = [NSXMLNode elementWithName:@"source"];
    [eventNode addChild:sourceNode];

    [sourceNode addChild:[NSXMLNode elementWithName:@"timecode-in" stringValue:self.sourceIn.stringRepresentation]];
    [sourceNode addChild:[NSXMLNode elementWithName:@"timecode-out" stringValue:self.sourceOut.stringRepresentation]];

    NSXMLElement *recordNode = [NSXMLNode elementWithName:@"record"];
    [eventNode addChild:recordNode];

    [recordNode addChild:[NSXMLNode elementWithName:@"timecode-in" stringValue:self.recordIn.stringRepresentation]];
    [recordNode addChild:[NSXMLNode elementWithName:@"timecode-out" stringValue:self.recordOut.stringRepresentation]];

    for (NSString *comment in self.comments) {
        [eventNode addChild:[NSXMLNode elementWithName:[NSString stringWithFormat:@"edl:comment"] stringValue:comment]];
    }

    return eventNode;
}

@end
