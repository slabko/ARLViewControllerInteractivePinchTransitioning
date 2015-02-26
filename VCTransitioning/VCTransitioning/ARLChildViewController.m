#import "ARLChildViewController.h"

@interface ARLChildViewController() <UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIView *square;
@property (nonatomic, strong) ARLViewControllerInteractivePinchTransitioning *interactiveTransitioning;

@end

@implementation ARLChildViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UITapGestureRecognizer *recongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    recongnizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:recongnizer];
    
    UIView *sqare = [[UIView alloc] init];
    sqare.backgroundColor = [UIColor redColor];
    [self.view addSubview:sqare];
    self.square = sqare;

    CGFloat width = self.view.bounds.size.width;
    self.square.frame = CGRectMake(0, 0, width, width);
    self.square.center = self.view.center;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.square.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.square.hidden = NO;
    if (!self.interactiveTransitioning) {
        self.interactiveTransitioning = [[ARLViewControllerInteractivePinchTransitioning alloc] initWithViewController:self];
        self.interactiveTransitioning.dismissMode = YES;
    }
}

#pragma mark - PresentingViewController Implementation

- (BOOL)startTransitioningForGestureInLocation:(CGPoint)location
{
    self.square.hidden = YES;
    [UIView animateWithDuration:.25 animations:^{
        self.view.alpha = .6;
    }];
    
    self.transitioningDelegate = self;
    [self dismissViewControllerAnimated:YES completion:^{
        self.square.hidden = NO;
    }];
    
    return YES;
}

- (UIView *)viewForTransitioningAnimationInLocation:(CGPoint)location
{
    UIView *view = [[UIView alloc] initWithFrame:self.square.frame];
    view.backgroundColor = [UIColor redColor];
    return view;
}

- (void)onTap:(UITapGestureRecognizer *)recongnizer
{
    UIView *view = [self viewForTransitioningAnimationInLocation:CGPointZero];
    self.interactiveTransitioning.transitioningAnimationView = view;
    self.transitioningDelegate = self;
    
    self.square.hidden = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGRect)finalFrameForTransitioningViewOfViewController:(UIViewController *)viewContrller
{
    return self.square.frame;
}

- (void)restoreFromUnfinishedTransition
{
    self.view.alpha = 1;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.interactiveTransitioning;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator
{
    return self.interactiveTransitioning;
}

@end
