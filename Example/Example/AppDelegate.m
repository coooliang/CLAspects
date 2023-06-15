//// 
//  AppDelegate.m
//  
//  Created by ___ORGANIZATIONNAME___ on 2023/2/17
//

#import "AppDelegate.h"
#import "CLAspects.h"
#import "ViewController.h"
#import "BRAOfficeDocumentPackage.h"

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
    
//    [self readXLS];
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

-(void)readXLS{
    NSString *documentPath = [[NSBundle mainBundle] pathForResource:@"MD" ofType:@"xlsx"];
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:documentPath];
    BRAWorksheet *worksheet = spreadsheet.workbook.worksheets.firstObject;
    NSArray<BRARow *> *rows = worksheet.rows;
    
    for (int i=0; i<rows.count; i++) {
        BRARow *row = rows[i];
        NSLog(@"------------------------- %d -----------------------------",i);
        for (BRACell *cell in row.cells) {
            NSLog(@"cell.stringValue = %@",cell.stringValue);
        }
    }
}

@end
