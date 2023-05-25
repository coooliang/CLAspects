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

- (void)aop:(void(^)(NSDictionary *result))block configBlock:(void(^)(NSString *html))configBlock;

@end

    
