#import "ARLParentViewController.h"
#import "ARLChildViewController.h"

@interface ARLParentViewController() <UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIView *square;
@property (nonatomic, strong) ARLViewControllerInteractivePinchTransitioning *interactiveTransitioning;

@end

@implementation ARLParentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *square = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    square.backgroundColor = [UIColor redColor];
    [self.view addSubview:square];
    self.square = square;
    
    self.interactiveTransitioning =
        [[ARLViewControllerInteractivePinchTransitioning alloc] initWithViewController:self];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.square.center = self.view.center;
}

- (void)viewWillAppearAfterDismissingPresentedViewController:(UIViewController *)viewController
{
    self.square.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.square.hidden = NO;
}

- (void)onTap:(UITapGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self.view];
    if (CGRectContainsPoint(self.square.frame, location)) {
        self.interactiveTransitioning.transitioningAnimationView = [self viewForTransitioningAnimationInLocation:CGPointZero];
        ARLChildViewController *vc = [[ARLChildViewController alloc] init];
        self.square.hidden = YES;
        vc.transitioningDelegate = self;
        [self presentViewController:vc animated:YES completion:^{
            self.square.hidden = NO;
        }];
    }
}

#pragma mark - PresentingViewController Implementation

- (BOOL)startTransitioningForGestureInLocation:(CGPoint)location
{
    if (CGRectContainsPoint(self.square.frame, location)) {
        ARLChildViewController *vc = [[ARLChildViewController alloc] init];
        vc.transitioningDelegate = self;
        self.square.hidden = YES;
        [self presentViewController:vc animated:YES completion:^{
            self.square.hidden = NO;
        }];
        return YES;
    }
    return NO;
}

- (UIView *)viewForTransitioningAnimationInLocation:(CGPoint)location
{
    UIView *view = [[UIView alloc] initWithFrame:self.square.frame];
    view.backgroundColor = self.square.backgroundColor;
    return view;
}

- (CGRect)finalFrameForTransitioningViewOfViewController:(UIViewController *)viewContrller
{
    return self.square.frame;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return self.interactiveTransitioning;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveTransitioning;
}

@end
