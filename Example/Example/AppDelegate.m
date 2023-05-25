//// 
//  AppDelegate.m
//  
//  Created by ___ORGANIZATIONNAME___ on 2023/2/17
//

#import "AppDelegate.h"
#import "CLAspects.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ViewController *viewController = [[ViewController alloc]init];
    UINavigationController *root = [[UINavigationController alloc]initWithRootViewController:viewController];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window setRootViewController:root];
    [self.window makeKeyAndVisible];
    
    [self md];
    return YES;
}

- (void)md {
    CLAConfigOptions.debug = YES;
    [[CLAspects sharedInstance]aop:^(NSDictionary *result) {
        NSLog(@"result = %@",result);
    } configBlock:^(NSString *html) {
        NSLog(@"html = %@",html);
    }];
}

@end
