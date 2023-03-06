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
    
    [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self md];
    }];
    return YES;
}

- (void)md {
    CLAConfigOptions *options = [[CLAConfigOptions alloc]init];
    options.debug = YES;
    [[CLAspects sharedInstance]aop:options block:^(NSDictionary *result) {
        NSLog(@"result = %@",result);
    } configBlock:^(NSString *html) {
        NSLog(@"config = %@",html);
    }];
}

- (NSString *)stringByReplaceUnicode:(NSString *)printString {
    NSMutableString *convertedString = [printString mutableCopy];
    [convertedString replaceOccurrencesOfString:@"\\U"
                                     withString:@"\\u"
                                        options:0
                                          range:NSMakeRange(0, convertedString.length)];
    
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    return convertedString;
}

@end
