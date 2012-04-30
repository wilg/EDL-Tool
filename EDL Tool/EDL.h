//
//  EDL.h
//  EDL Tool
//
//  Created by Tashi Trieu on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDL : NSObject

@property (retain) NSMutableArray *events;
@property (retain) NSMutableDictionary *metadata;

// Parse an EDL.
+(EDL *)edlWithData:(NSData *)data;
+(EDL *)edlWithString:(NSString *)string;

// Parse an EDX.
+(EDL *)edlWithXMLData:(NSData *)xmlData;

// Write an EDL formatted-string.
-(NSString *)stringRepresentation;
-(NSData *)dataRepresentation;

// Write an XML formatted-string.
-(NSData *)xmlDataRepresentation;

@end
