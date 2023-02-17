//
//  CLAspects.h
//  AOPTestProject
//
//  Created by chenliang on 02/11/2018.
//  Copyright © 2018 yypt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLAspects : NSObject

+ (CLAspects *)sharedInstance;

- (void)aop;

- (void)setDebug:(BOOL)d;

@property (nonatomic,strong)NSString *fileName;

@end

NS_ASSUME_NONNULL_END
