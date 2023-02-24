//// 
//  CLAConfigOptions.m
//  CLAspects
//  Created by ___ORGANIZATIONNAME___ on 2023/2/24
//

#import "CLAConfigOptions.h"

@implementation CLAConfigOptions

- (instancetype)initWithFileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        _fileName = fileName;
    }
    return self;
}

@end
