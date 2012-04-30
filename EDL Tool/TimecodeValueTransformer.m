#import "TimecodeValueTransformer.h"
#import "Timecode.h"

@implementation TimecodeValueTransformer


+ (void) initialize
{
    [NSValueTransformer setValueTransformer:[[self alloc] init] forName:@"TimecodeValueTransformer"];
}

+ (Class)transformedValueClass
{
	return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
	return NO;
}

- (id)transformedValue:(id)value
{
    return (value == nil) ? nil : [value description];
}


@end
