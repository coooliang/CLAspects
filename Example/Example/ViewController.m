//// 
//  ViewController.m
//  
//  Created by ___ORGANIZATIONNAME___ on 2023/2/17
//

#import "ViewController.h"
#import "TestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 40)];
    [button setTitle:@"click" forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClick {
    TestViewController *vc = [[TestViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
