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

//单例
static CLAspects *instance = nil;
+ (id)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
#pragma mark - public methods
- (void)aop {
    [self loadXml];
}


#define __cl_aspects_example_md_json__(x) #x
    static NSString *exampleMDJson = @__cl_aspects_example_md_json__(
         ([
           {
               "eventName": "点击立即注册",
               "eventId": "Register_Begin_Button",
               "eventLabels": {
                   "Channel": "$channel",
                   "Equipment": "$Equipment",
                   "VersionNumber": "4.5.3"
               },
               "md": {
                   "class": "TestViewController",
                   "method": "viewDidLoad"
               },
               "desc": "渠道(Channel):微站、app标准版、app关怀版、非营销人员老带新、营销人员老带新、web端、柜面扫码;设备(Equipment):安卓(具体系统型号)、ios苹果(具体系统型号)、pc(具体系统型号)、平板(具体系统型号);版本号(VersionNumber):当前事件对应的版本号"
           }
       ])
    );
#undef __cl_aspects_example_md_json__
- (void)setDebug:(BOOL)d {
    _debug = d;
    if(d){
        NSLog(@"md.json For Example : \n %@",exampleMDJson);
    }
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

- (NSString *)stringByReplaceUnicode:(NSString *)printString {
    NSMutableString *convertedString = [printString mutableCopy];
    [convertedString replaceOccurrencesOfString:@"\\U"
                                     withString:@"\\u"
                                        options:0
                                          range:NSMakeRange(0, convertedString.length)];
    
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    return convertedString;
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
