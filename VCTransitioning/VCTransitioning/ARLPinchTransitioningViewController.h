#import <UIKit/UIKit.h>

@protocol ARLPinchTransitioningViewController <NSObject>

@required
- (BOOL)startTransitioningForGestureInLocation:(CGPoint)location;
- (UIView *)viewForTransitioningAnimationInLocation:(CGPoint)location;
- (CGRect)finalFrameForTransitioningViewOfViewController:(UIViewController *)viewContrller;

@optional
- (void)viewWillAppearAfterDismissingPresentedViewController:(UIViewController *)viewController;
- (void)viewDidAppearAfterDismissingPresentedViewController:(UIViewController *)viewController;
- (void)restoreFromUnfinishedTransition;

@end
