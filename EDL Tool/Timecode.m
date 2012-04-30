//
//  Timecode.m
//  EDL Tool
//
//  Created by Tashi Trieu on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Timecode.h"

@implementation Timecode

@synthesize frameRate = _frameRate;
@synthesize frames = _frames;
@synthesize seconds = _seconds;
@synthesize minutes = _minutes;
@synthesize hours = _hours;

#pragma mark Initializers
#pragma mark -

+(Timecode *)timecodeFromString:(NSString *)string framerate:(float)framerate {
    @try {
        Timecode *timecode = [[Timecode alloc] init];
        timecode.stringRepresentation = string;
        timecode.frameRate = framerate;
        return timecode;
    }
    @catch (NSException *exception) {
        
    }
    return nil;
}

+(Timecode *)timecodeWithFrameNumber:(int)frameNumber framerate:(float)framerate {
    Timecode *timecode = [[Timecode alloc] init];
    timecode.frameRate = framerate;
    timecode.frameNumber = frameNumber;
    return timecode;
}

#pragma mark Math
#pragma mark -
-(void)addFrames:(int)frames {
    self.frameNumber = self.frameNumber + frames;
}

-(void)subtractFrames:(int)frames {
    self.frameNumber = self.frameNumber - frames;
}

-(Timecode *)timecodeByAddingFrames:(int)frames {
    Timecode *copy = [self copy];
    [copy addFrames:frames];
    return copy;
}

-(Timecode *)timecodeBySubtractingFrames:(int)frames {
    Timecode *copy = [self copy];
    [copy subtractFrames:frames];
    return copy;
}

-(BOOL)isEqualToTimecode:(Timecode *)otherTimecode {
    return [self absoluteTime] == [otherTimecode absoluteTime];
}

-(BOOL)isGreaterThanTimecode:(Timecode *)otherTimecode {
    return [self absoluteTime] > [otherTimecode absoluteTime];
}

-(BOOL)isGreaterThanOrEqualToTimecode:(Timecode *)otherTimecode {
    return [self absoluteTime] >= [otherTimecode absoluteTime];
}

-(BOOL)isLessThanTimecode:(Timecode *)otherTimecode {
    return [self absoluteTime] < [otherTimecode absoluteTime];
}

-(BOOL)isLessThanOrEqualToTimecode:(Timecode *)otherTimecode {
    return [self absoluteTime] <= [otherTimecode absoluteTime];
}

-(long)absoluteTime {
    return (long)self.frameNumber / (long)self.frameRate;
}

#pragma mark Frame Number
#pragma mark -

-(void)setFrameNumber:(int)frameNumber {
    self.frames  =    frameNumber % (int)self.frameRate;
    self.seconds =   (frameNumber / (int)self.frameRate) % 60;
    self.minutes =  ((frameNumber / (int)self.frameRate) / 60) % 60;
    self.hours   = (((frameNumber / (int)self.frameRate) / 60) / 60) % 24;
}

-(int)frameNumber {
    int frameNumber = self.frames +
                      self.seconds * self.frameRate +
                      self.minutes * self.frameRate * 60 +
                      self.hours   * self.frameRate * 60 * 60;
    return frameNumber;
}

#pragma mark Strings
#pragma mark -

-(NSString *)stringRepresentation {
    return [NSString stringWithFormat:@"%02i:%02i:%02i:%02i", self.hours, self.minutes, self.seconds, self.frames];
}

-(void)setStringRepresentation:(NSString *)stringRepresentation {
    NSArray *split = [stringRepresentation componentsSeparatedByString:@":"];
    if (split.count == 4) {
        self.hours = [[split objectAtIndex:0] intValue];
        self.minutes = [[split objectAtIndex:1] intValue];
        self.seconds = [[split objectAtIndex:2] intValue];
        self.frames = [[split objectAtIndex:3] intValue];
    }
    else {
        NSException *exception = [NSException exceptionWithName:@"TimecodeInvalid" reason:@"Timecode string wasn't four pairs." userInfo:nil];
        @throw exception;
    }
}

-(NSString *)description {
    return self.stringRepresentation;
}

#pragma mark NSCopying
#pragma mark -

-(id)copyWithZone:(NSZone *)zone {
    Timecode *copy = [[[self class] allocWithZone: zone] init];
    copy.frameRate   = self.frameRate;
    copy.frameNumber = self.frameNumber;
    return copy;
}

@end
