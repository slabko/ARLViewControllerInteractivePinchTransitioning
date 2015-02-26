#import "ARLViewControllerInteractivePinchTransitioning.h"
#import "UIGestureRecognizer+ResetOperation.h"

@interface ARLViewControllerInteractivePinchTransitioning() <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UIViewController<ARLPinchTransitioningViewController> *viewController;

@property (nonatomic, weak) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, weak) UIRotationGestureRecognizer *rotatinGestureRecognizer;

@property (nonatomic, assign, getter=isTransitionInAction) BOOL transitionIsInAction;
@property (nonatomic, assign, getter=isTransitionAnimating) BOOL transitionIsAnimating;

@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, readonly) UIViewController<ARLPinchTransitioningViewController> *fromViewController;
@property (nonatomic, readonly) UIViewController<ARLPinchTransitioningViewController> *toViewController;

@property (nonatomic, assign) CGPoint startTransitionLocation;

@end

@implementation ARLViewControllerInteractivePinchTransitioning

#pragma Properties

- (UIViewController<ARLPinchTransitioningViewController> *)fromViewController
{
    return (UIViewController<ARLPinchTransitioningViewController> *)[self.transitionContext
                                                        viewControllerForKey:UITransitionContextFromViewControllerKey];
}

- (UIViewController<ARLPinchTransitioningViewController> *)toViewController
{
    return (UIViewController<ARLPinchTransitioningViewController> *)[self.transitionContext
                                                        viewControllerForKey:UITransitionContextToViewControllerKey];
    
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark Lifecycle

- (instancetype)initWithViewController:(UIViewController<ARLPinchTransitioningViewController> *)viewController
{
    self = [super init];
    if (self) {
        _viewController = viewController;
        [self setupGestureRecongizersForViewController:viewController];
    }
    return self;
}

- (void)dealloc
{
    [self removeFromViewController];
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)context
{
    self.transitionContext = context;
    
    UIView *containerView = [context containerView];
    [containerView addSubview:self.transitioningAnimationView];
    
    if (self.dismissMode) {
        [containerView insertSubview:self.toViewController.view atIndex:0];
    }
    
    // Notify the presenting view controller
    if (self.dismissMode) {
        [[self class] notifyViewController:self.toViewController
                      willAppearAfterDismissingPresentedViewController:self.fromViewController];
    }
    
    // If we have plain call of `-presentViewController:animated:comletion:` or
    // `-dismissViewController:animated:comletion:` then `-startInteractiveTransition` will be called
    // and animation should be finished, beouse there is no interations
    if (!self.isTransitionInAction) {
        self.transitionIsInAction = YES;
        [self finishTransition];
    }
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)context
{
    return .25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)context
{
    [self startInteractiveTransition:context];
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark Animations

- (void)animateFinishingTransition:(id<UIViewControllerContextTransitioning>)context comletion:(void(^)())comletion
{
    UIView *containerView = [context containerView];
    UIViewController<ARLPinchTransitioningViewController> *toViewController = self.toViewController;
    UIViewController<ARLPinchTransitioningViewController> *fromViewController = self.fromViewController;
    
    CGRect transitioningAnimationViewFrame =
        [toViewController finalFrameForTransitioningViewOfViewController:self.fromViewController];

    
    if (self.dismissMode) {
        [containerView insertSubview:self.toViewController.view atIndex:0];
    }
    else {
        [containerView insertSubview:self.toViewController.view belowSubview:self.transitioningAnimationView];
        toViewController.view.alpha = 0;
    }
    
    [self animateComletingTransition:context animation:^{
        self.transitioningAnimationView.transform = CGAffineTransformIdentity;
        self.transitioningAnimationView.frame = transitioningAnimationViewFrame;
        toViewController.view.alpha = 1;
        if (self.dismissMode) {
            fromViewController.view.alpha = 0;
        }
    } comletion:comletion];
}

- (void)animateCancelingTransition:(id<UIViewControllerContextTransitioning>)context comletion:(void(^)())comletion
{
    [self animateComletingTransition:context animation:^{
        self.transitioningAnimationView.transform = CGAffineTransformIdentity;
        [self.class notifyViewControllerToRestoreFromTransition:self.fromViewController];
    } comletion:comletion];
}

- (void)animateComletingTransition:(id<UIViewControllerContextTransitioning>)context
                         animation:(void(^)())animation
                         comletion:(void(^)())comletion
{
    self.transitionIsAnimating = YES;
    [UIView animateWithDuration:[self transitionDuration:context]
                     animations:^{
                         if (animation) {
                             animation();
                         }
                     } completion:^(BOOL finished) {
                         [self.transitioningAnimationView removeFromSuperview];
                         self.transitioningAnimationView = nil;
                         self.transitionIsAnimating = NO;
                         if (comletion) {
                             comletion();
                         }
                     }];
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark Transistion Lifecycle

- (BOOL)beginTransitioningInLocation:(CGPoint)location
{
    if (self.transitionIsInAction) {
        return NO;
    }
    
    if ([self.viewController startTransitioningForGestureInLocation:location]) {
        self.transitionIsInAction = YES;
        self.transitioningAnimationView = [self.viewController viewForTransitioningAnimationInLocation:location];
        self.startTransitionLocation = location;
        return YES;
    }
    return NO;
}

- (void)finishTransition
{
    [self.transitionContext finishInteractiveTransition];
    if (self.isTransitionInAction && !self.isTransitionAnimating) {
        [self animateFinishingTransition:self.transitionContext comletion:^{
            [self.transitionContext completeTransition:YES];
            self.transitionIsInAction = NO;
            [[self class] notifyViewController:self.toViewController
                          didAppearAfterDismissingPresentedViewController:self.fromViewController];
        }];
    }
}

- (void)cancelTransition
{
    [self.transitionContext cancelInteractiveTransition];
    if (self.isTransitionInAction && !self.isTransitionAnimating) {
        [self animateCancelingTransition:self.transitionContext comletion:^{
            [self.transitionContext completeTransition:NO];
            self.transitionIsInAction = NO;
        }];
    }
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark Gesture

- (void)gestureIsRecognized:(UIGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.viewController.view];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan: {
            if (!self.isTransitionInAction && ![self beginTransitioningInLocation:location])
                [recognizer cancelCurrentGesture];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (recognizer.numberOfTouches > 1)
                [self applayRecognizersStateWithLocaiton:location];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self completeGestures];
            break;
        }
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStatePossible:
            break;
    }
}

- (void)applayRecognizersStateWithLocaiton:(CGPoint)location
{
    CGFloat scale = self.pinchGestureRecognizer.scale;
    CGFloat rotation = self.rotatinGestureRecognizer.rotation;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(location.x - self.startTransitionLocation.x,
                                                                   location.y - self.startTransitionLocation.y);
    transform = CGAffineTransformScale(transform, scale, scale);
    transform = CGAffineTransformRotate(transform, rotation);
    self.transitioningAnimationView.transform = transform;
}

- (void)completeGestures
{
    if ([self shouldFinishTransitionWithScale:self.pinchGestureRecognizer.scale]) {
        [self finishTransition];
    } else {
        [self cancelTransition];
    }
}

- (BOOL)shouldFinishTransitionWithScale:(CGFloat)scale
{
    return (self.dismissMode && scale < 0.8) || (!self.dismissMode && scale > 1.2);
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark Setup and Clear

- (void)setupGestureRecongizersForViewController:(UIViewController *)viewController
{
    UIPinchGestureRecognizer *pinchRecongizer =
    [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(gestureIsRecognized:)];
    UIRotationGestureRecognizer *rotationRecognizer =
    [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                 action:@selector(gestureIsRecognized:)];
    pinchRecongizer.delegate = self;
    rotationRecognizer.delegate = self;
    [self.viewController.view addGestureRecognizer:pinchRecongizer];
    [self.viewController.view addGestureRecognizer:rotationRecognizer];
    self.pinchGestureRecognizer = pinchRecongizer;
    self.rotatinGestureRecognizer = rotationRecognizer;
}

- (void)removeFromViewController
{
    [self.viewController.view removeGestureRecognizer:self.pinchGestureRecognizer];
    [self.viewController.view removeGestureRecognizer:self.rotatinGestureRecognizer];
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark - UIGestureRecongnizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [[NSSet setWithArray:@[gestureRecognizer, otherGestureRecognizer]]
            isEqualToSet:[NSSet setWithArray:@[self.pinchGestureRecognizer, self.rotatinGestureRecognizer]]];
}

//----------------------------------------------------------------------------------------------------------------------
#pragma mark Helpers

+ (void)notifyViewController:(UIViewController<ARLPinchTransitioningViewController> *)toViewController
        willAppearAfterDismissingPresentedViewController:(UIViewController *)fromViewController
{
    if ([toViewController respondsToSelector:@selector(viewWillAppearAfterDismissingPresentedViewController:)]) {
        [toViewController viewWillAppearAfterDismissingPresentedViewController:fromViewController];
    }
}

+ (void)notifyViewController:(UIViewController<ARLPinchTransitioningViewController> *)toViewController
         didAppearAfterDismissingPresentedViewController:(UIViewController *)fromViewController
{
    if ([toViewController respondsToSelector:@selector(viewDidAppearAfterDismissingPresentedViewController:)]) {
        [toViewController viewDidAppearAfterDismissingPresentedViewController:fromViewController];
    }
}

+ (void)notifyViewControllerToRestoreFromTransition:(UIViewController<ARLPinchTransitioningViewController> *)viewController
{
    if ([viewController respondsToSelector:@selector(restoreFromUnfinishedTransition)]) {
        [viewController restoreFromUnfinishedTransition];
    }
}

@end
