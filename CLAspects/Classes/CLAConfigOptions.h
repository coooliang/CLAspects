//// 
//  CLAConfigOptions.h
//  CLAspects
//  Created by ___ORGANIZATIONNAME___ on 2023/2/24
//

#import <Foundation/Foundation.h>

@interface CLAConfigOptions : NSObject

+ (NSString *)fileName;
+ (void)setFileName:(NSString *)fileName;

+ (BOOL)debug;
+ (void)setDebug:(BOOL)debug;

@end

