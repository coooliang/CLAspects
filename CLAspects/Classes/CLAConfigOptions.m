//// 
//  CLAConfigOptions.m
//  CLAspects
//  Created by ___ORGANIZATIONNAME___ on 2023/2/24
//

#import "CLAConfigOptions.h"

static NSString *kCLAFileName = @"md.json";
static BOOL kCLADebug = NO;

@implementation CLAConfigOptions

+ (NSString *)fileName {
    return kCLAFileName;
}
+ (void)setFileName:(NSString *)fileName{
    kCLAFileName = fileName;
}

+ (BOOL)debug{
    return kCLADebug;
}
+ (void)setDebug:(BOOL)debug{
    kCLADebug = debug;
}

@end
