

#import "NSObject+Helper.h"

@implementation NSObject (Helper)

- (id)as:(Class)clss {
    return [self isKindOfClass:clss] ? self : nil;
}

@end
