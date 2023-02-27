//// 
//  CLAConfigOptions.h
//  CLAspects
//  Created by ___ORGANIZATIONNAME___ on 2023/2/24
//

#import <Foundation/Foundation.h>

@interface CLAConfigOptions : NSObject

- (instancetype)initWithFileName:(NSString *)fileName;

@property (nonatomic,strong)NSString *fileName;
@property (nonatomic,assign)BOOL debug;

@end

