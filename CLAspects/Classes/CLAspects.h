//
//  CLAspects.h
//  AOPTestProject
//
//  Created by chenliang on 02/11/2018.
//  Copyright © 2018 yypt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLAConfigOptions.h"

@interface CLAspects : NSObject

+ (CLAspects *)sharedInstance;

- (void)aop;
- (void)aop:(CLAConfigOptions *)configOptions block:(void(^)(NSDictionary *result))block;

@end

    
