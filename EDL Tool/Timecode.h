//
//  Timecode.h
//  EDL Tool
//
//  Created by Tashi Trieu on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Timecode : NSObject <NSCopying>

@property (assign) float frameRate;

@property (assign) int frameNumber;
@property (assign) int frames;
@property (assign) int seconds;
@property (assign) int minutes;
@property (assign) int hours;

@property (assign) NSString *stringRepresentation;

+(Timecode *)timecodeFromString:(NSString *)string framerate:(float)framerate;
+(Timecode *)timecodeWithFrameNumber:(int)frameNumber framerate:(float)framerate;

// Modify the receiver
-(void)addFrames:(int)frames;
-(void)subtractFrames:(int)frames;

// Returns new instances with calculations applied.
-(Timecode *)timecodeByAddingFrames:(int)frames;
-(Timecode *)timecodeBySubtractingFrames:(int)frames;

// Comparisons
// These comparisons depend on the frame rate.
-(BOOL)isEqualToTimecode:(Timecode *)otherTimecode;
-(BOOL)isGreaterThanTimecode:(Timecode *)otherTimecode;
-(BOOL)isGreaterThanOrEqualToTimecode:(Timecode *)otherTimecode;
-(BOOL)isLessThanTimecode:(Timecode *)otherTimecode;
-(BOOL)isLessThanOrEqualToTimecode:(Timecode *)otherTimecode;

// The time in seconds this timecode represents. Depends on frame rate.
-(long)absoluteTime;

@end
