#import <UIKit/UIKit.h>
#import "ARLPinchTransitioningViewController.h"

@interface ARLViewControllerInteractivePinchTransitioning : NSObject <UIViewControllerInteractiveTransitioning,
                                                              UIViewControllerAnimatedTransitioning>

@property (nonatomic, strong) UIView *transitioningAnimationView;
@property (nonatomic, assign) BOOL dismissMode;

- (instancetype)init __unavailable ;
- (instancetype)initWithViewController:(UIViewController<ARLPinchTransitioningViewController> *)viewController;

- (void)removeFromViewController;

@end
