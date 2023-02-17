//
//  TestViewController.m
//  AOPTestProject
//
//  Created by chenliang on 06/11/2018.
//  Copyright © 2018 yypt. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@property (nonatomic,strong)NSString *channel;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.channel = @"channel 123";
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.mdParam1 = @{@"cid":@"123321"};
    
    [self login];
}


-(void)login{
    self.mdParam2 = @{@"cid":@"2222"};
}

@end
