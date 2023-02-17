//
//  LogTest.m
//  AOPTestProject
//
//  Created by chenliang on 02/11/2018.
//  Copyright © 2018 yypt. All rights reserved.
//

#import "LogTest.h"

@implementation LogTest

+(void)md:(NSString *)key props:(NSDictionary *)props{
    NSLog(@"LogTest key = %@ props = %@",key,props);
}

@end
