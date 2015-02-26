#import "ARLAppDelegate.h"
#import "ARLParentViewController.h"

@interface ARLAppDelegate ()

@end

@implementation ARLAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    self.window = [[UIWindow alloc] initWithFrame:mainScreen.bounds];
    self.window.rootViewController = [[ARLParentViewController alloc] init];
    self.window.backgroundColor = [UIColor blueColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
