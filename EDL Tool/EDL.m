//
//  EDL.m
//  EDL Tool
//
//  Created by Tashi Trieu on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EDL.h"
#import "EDLEvent.h"
#import "Timecode.h"

@implementation EDL

@synthesize metadata, events;

+(EDL *)edlWithData:(NSData *)data {
    NSString *documentString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [EDL edlWithString:documentString];
}

+(EDL *)edlWithString:(NSString *)string {
    
    EDL *edl = [[EDL alloc] init];
    
    BOOL doneWithHeader = NO;
    
    for (NSString *line in [string componentsSeparatedByString:@"\n"]) {
        NSString *trimmedLine = [line stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        BOOL blank = NO;
        if ([line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
            blank = YES;
        }
        if (blank) {
            doneWithHeader = YES;
        }
        else {
            if (doneWithHeader) {
                
                if ([[trimmedLine substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"*"]) {
                    // Parse as a comment
                    EDLEvent *lastEvent = [edl.events lastObject];
                    if (lastEvent) {
                        [lastEvent.comments addObject:[trimmedLine substringFromIndex:1]];
                    }
                    
                }
                else {
                    
                    // parse events
                    EDLEvent *thisEvent = [[EDLEvent alloc] init];
                    
                    NSString *eventNumberString = [trimmedLine substringWithRange:NSMakeRange(0, 3)];
                    thisEvent.eventIdentifier = eventNumberString;
                    
                    NSString *tapeNameString = [trimmedLine substringWithRange:NSMakeRange(5,8)];
                    thisEvent.tapeName = tapeNameString;
                    
                    NSString *trackTypeString = [trimmedLine substringWithRange:NSMakeRange(14, 1)];
                    if ([trackTypeString isEqualToString:@"V"]) {
                        thisEvent.trackType = EDLEventVideoTrackType;
                    }
                    else {
                        thisEvent.trackType = EDLEventAudioTrackType;
                    }
                    
                    NSString *eventTransitionString = [trimmedLine substringWithRange:NSMakeRange(20, 4)];
                    thisEvent.transitionType = [eventTransitionString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    NSString *eventTransitionDurationString = [trimmedLine substringWithRange:NSMakeRange(25, 3)];
                    if ([eventTransitionDurationString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
                        thisEvent.transitionDuration = [NSNumber numberWithInt:[eventTransitionDurationString intValue]];
                    }
                    
                    NSString *eventSourceInString = [trimmedLine substringWithRange:NSMakeRange(29, 11)];
                    thisEvent.sourceIn = [Timecode timecodeFromString:eventSourceInString framerate:24];
                    
                    NSString *eventSourceOutString = [trimmedLine substringWithRange:NSMakeRange(41, 11)];
                    thisEvent.sourceOut = [Timecode timecodeFromString:eventSourceOutString framerate:24];
                    
                    NSString *eventRecordInString = [trimmedLine substringWithRange:NSMakeRange(53, 11)];
                    thisEvent.recordIn = [Timecode timecodeFromString:eventRecordInString framerate:24];
                    
                    NSString *eventRecordOutString = [trimmedLine substringWithRange:NSMakeRange(65, 11)];
                    thisEvent.recordOut = [Timecode timecodeFromString:eventRecordOutString framerate:24];
                      
                    if(thisEvent.eventIdentifier.intValue > 0) {
                        [edl.events addObject:thisEvent];
                    }
                }

            }
            else {
                // parse header
                NSArray *headerSplit = [trimmedLine componentsSeparatedByString:@": "];
                NSString *key = [headerSplit objectAtIndex:0];
                NSString *value = [headerSplit objectAtIndex:1];
                [edl.metadata setObject:value forKey:key];
            }
        }

    }

    return edl;
}

+(EDL *)edlWithXMLData:(NSData *)xmlData {
    EDL *edl = [[EDL alloc] init];
    NSXMLDocument *xmlDocument = [[NSXMLDocument alloc] initWithData:xmlData options:NSXMLDocumentTidyXML error:nil];
    
    for (NSXMLElement *element in xmlDocument.rootElement.children) {
        
        if ([element.name isEqualToString:@"header"]) {
            for (NSXMLElement *headerElement in element.children) {
                
                NSString *key = headerElement.name;

                NSString *preprocessedName = [key stringByReplacingOccurrencesOfString:@"edl:custom:" withString:@"edl:*"];

                NSArray *split = [preprocessedName componentsSeparatedByString:@":"];
                if (split.count == 2) {
                    if ([[split objectAtIndex:0] isEqualToString:@"edl"]) {
                        key = [split objectAtIndex:1];
                    }
                }
                
                [edl.metadata setObject:headerElement.stringValue forKey:key];

            }
        }
        else if ([element.name isEqualToString:@"events"]) {
            for (NSXMLElement *eventElement in element.children) {
                EDLEvent *thisEvent = [[EDLEvent alloc] init];

                for (NSXMLElement *eventAttributeElement in eventElement.children) {
                    NSString *name = eventAttributeElement.name;
                    NSString *value = eventAttributeElement.stringValue;
                    
                    if ([name isEqualToString:@"id"]) {
                        thisEvent.eventIdentifier = value;
                    }
                    else if ([name isEqualToString:@"kind"]) {
                        if ([value isEqualToString:@"video"]) {
                            thisEvent.trackType = EDLEventVideoTrackType;
                        }
                        else if ([name isEqualToString:@"audio"]) {
                            thisEvent.trackType = EDLEventAudioTrackType;
                        }
                        else {
                            thisEvent.trackType = EDLEventUnknownTrackType;
                        }
                    }
                    else if ([name isEqualToString:@"tape-name"]) {
                        thisEvent.tapeName = value;
                    }
                    else if ([name isEqualToString:@"edl:transition-type"]) {
                        thisEvent.transitionType = value;
                    }
                    else if ([name isEqualToString:@"edl:transition-duration"]) {
                        thisEvent.transitionDuration = [NSNumber numberWithInteger:value.integerValue];
                    }
                    else if ([name isEqualToString:@"edl:comment"]) {
                        [thisEvent.comments addObject:value];
                    }
                    else if ([name isEqualToString:@"source"]) {
                        for (NSXMLElement *tcElement in eventAttributeElement.children) {
                            if ([tcElement.name isEqualToString:@"timecode-in"]) {
                                thisEvent.sourceIn = [Timecode timecodeFromString:tcElement.stringValue framerate:24];
                            }
                            else if ([tcElement.name isEqualToString:@"timecode-out"]) {
                                thisEvent.sourceOut = [Timecode timecodeFromString:tcElement.stringValue framerate:24];
                            }
                        }
                    }
                    else if ([name isEqualToString:@"record"]) {
                        for (NSXMLElement *tcElement in eventAttributeElement.children) {
                            if ([tcElement.name isEqualToString:@"timecode-in"]) {
                                thisEvent.recordIn = [Timecode timecodeFromString:tcElement.stringValue framerate:24];
                            }
                            else if ([tcElement.name isEqualToString:@"timecode-out"]) {
                                thisEvent.recordOut = [Timecode timecodeFromString:tcElement.stringValue framerate:24];
                            }
                        }
                    }

                }
                
                if(thisEvent.eventIdentifier.intValue > 0) {
                    [edl.events addObject:thisEvent];
                }

            }
        }
        

    }
    
    
    return edl;
}


-(id)init {
    self = [super init];
    if (self) {
        self.metadata = [NSMutableDictionary dictionary];
        self.events   = [NSMutableArray array];
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<EDL metadata=%@ events=%@>", self.metadata, self.events];
}

-(NSString *)stringRepresentation {
    NSMutableString *outputString = [NSMutableString string];
    
    // Metadata
    for (NSString *key in self.metadata) {
        id value = [self.metadata objectForKey:key];
        [outputString appendString:[NSString stringWithFormat:@"%@: %@", key, value]];
        [outputString appendString:@"\n"];
    }
    
    // Separator
    [outputString appendString:@"\n"];

    // Events
    EDLEvent *previousEvent;
    for (EDLEvent *event in self.events) {
        
        // TODO
        // We want a blank line between events unless the two events
        // have the same identifier.
//        if (previousEvent){
//            if (previousEvent.eventIdentifier != event.eventIdentifier) {
//                [outputString appendString:@"\n"];
//            }
//        }

        // Add the actual EDL line.
        [outputString appendString:[event edlTextRepresentation]];
        [outputString appendString:@"\n"];
        
        // Save the previous event to check against later.
        previousEvent = event;
    }
    
    return [outputString copy];
}

-(NSData *)dataRepresentation {
    return [[self stringRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSXMLDocument *)xmlDocumentRepresentation {

    NSXMLElement *root = (NSXMLElement *)[NSXMLNode elementWithName:@"edx"];

    //set up generic XML doc data (<?xml version="1.0" encoding="UTF-8"?>)
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithRootElement:root];
    [xmlDoc setVersion:@"1.0"];
    [xmlDoc setCharacterEncoding:@"UTF-8"];
    
    // Metadata
    NSXMLElement *headerNode = [NSXMLNode elementWithName:@"header"];
	[root addChild:headerNode];
    
    for (NSString *key in self.metadata) {
        id value = [self.metadata objectForKey:key];
        NSString *newKey = [key stringByReplacingOccurrencesOfString:@"*" withString:@"custom:"];
        [headerNode addChild:[NSXMLNode elementWithName:[NSString stringWithFormat:@"edl:%@", newKey] stringValue:value]];
    }

    // Events
    NSXMLElement *eventsNode = [NSXMLNode elementWithName:@"events"];
	[root addChild:eventsNode];

    for (EDLEvent *event in self.events) {
        [eventsNode addChild:[event xmlNode]];
    }

    return xmlDoc;
}

-(NSData *)xmlDataRepresentation {
    return [[self xmlDocumentRepresentation] XMLDataWithOptions:NSXMLNodePrettyPrint];
}

@end
