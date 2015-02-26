#import "UIGestureRecognizer+ResetOperation.h"

@implementation UIGestureRecognizer (ResetOperation)

- (void)cancelCurrentGesture
{
    self.enabled = NO;
    self.enabled = YES;
}

@end
