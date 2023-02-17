//
//  CLAspects.m
//  AOPTestProject
//
//  Created by chenliang on 02/11/2018.
//  Copyright © 2018 yypt. All rights reserved.
//

#import "CLAspects.h"
#import "Aspects.h"

@implementation CLAspects {
    BOOL _debug;
}

#pragma mark - public methods
- (void)aop {
    [self loadXml];
}

- (void)setDebug:(BOOL)d {
    _debug = d;
}

#pragma mark -
- (void)loadXml {
    //load xml
    if(self.fileName == nil || [@"" isEqualToString:self.fileName]){
        self.fileName = @"md.json";
    }
    NSData *data = [self loadConfigWithFileName:self.fileName];
    if(data){
        NSArray *points = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [self aspect:points];
        if(_debug){
            //            [[CLFormatJson new]printToConsole:points];
            //            [[CLFormatJson new]printToHtml:points];
        }
    }
}

- (void)aspect:(NSArray *)points {
    if(points && [points isKindOfClass:[NSArray class]] && points.count > 0){
        for (NSDictionary *point in points) {
            NSDictionary *md = [point objectForKey:@"md"];
            if(md && [md isKindOfClass:[NSDictionary class]] && md.count > 0){
                NSString *className = [md objectForKey:@"class"];
                NSString *method = [md objectForKey:@"method"];
                [self after:className method:method callback:^(id<AspectInfo> aspectInfo) {
                    NSDictionary *props = [self transferProps:point[@"eventLabels"] target:aspectInfo.instance];
                    //                    [LogTest md:point[@"eventId"] props:props];
                }];
            }
        }
    }
}

- (NSDictionary *)transferProps:(NSDictionary *)props target:(id)target {
    if(props == nil)return @{};
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:props.count];
    for (NSString *k in props.allKeys) {
        NSString *value = [props objectForKey:k];
        if ([value hasPrefix:@"$"]) {
            value = [value substringFromIndex:1];
            SEL sel = NSSelectorFromString(value);
            if ([target respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                NSString *temp = [target performSelector:sel];
                [result setValue:temp forKey:k];
#pragma clang diagnostic pop
            }
        }else{
            NSString *value = [props objectForKey:k];
            [result setValue:value forKey:k];
        }
    }
    return result;
}

#pragma mark - loadConfigWithFileName
- (NSData *)loadConfigWithFileName:(NSString *)fileName {
    NSString *path = [[NSBundle mainBundle]pathForResource:fileName ofType:nil];
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    return data;
}

#pragma mark - private aop methods
- (void)after:(NSString *)className method:(NSString *)methodName callback:(void(^)(id<AspectInfo> aspectInfo))callBack {
    [self class:className method:methodName options:AspectPositionAfter callback:callBack];
}

- (void)before:(NSString *)className method:(NSString *)methodName callback:(void(^)(id<AspectInfo> aspectInfo))callBack {
    [self class:className method:methodName options:AspectPositionBefore callback:callBack];
}

- (void)class:(NSString *)className method:(NSString *)methodName options:(AspectOptions)options callback:(void(^)(id<AspectInfo>))callBack {
    Class class = NSClassFromString(className);
    SEL method = NSSelectorFromString(methodName);
    if (class && method) {
        [class aspect_hookSelector:method withOptions:options usingBlock:^(id<AspectInfo> aspectInfo){
            if (callBack) {
                callBack(aspectInfo);
            }
        } error:nil];
    }
}

@end
