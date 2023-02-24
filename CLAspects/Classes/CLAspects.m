//
//  CLAspects.m
//  AOPTestProject
//
//  Created by chenliang on 02/11/2018.
//  Copyright © 2018 yypt. All rights reserved.
//

#import "CLAspects.h"
#import "Aspects.h"

typedef void (^DebugBlock)(NSDictionary *result);
@implementation CLAspects{
    DebugBlock _debugBlock;
    CLAConfigOptions *_configOptions;
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
- (void)aop:(CLAConfigOptions *)configOptions block:(void(^)(NSDictionary *result))block {
    _configOptions = configOptions;
    _debugBlock = block;
    if(configOptions == nil){
        configOptions = [[CLAConfigOptions alloc]init];
    }
    if(configOptions.fileName == nil || [@"" isEqualToString:configOptions.fileName]){
        configOptions.fileName = @"md.json";
    }
    NSData *data = [self loadConfigWithFileName:configOptions.fileName];
    if(data){
        NSArray *points = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        [self aspect:points];
        if(configOptions.enableLog){
            [self printExampleJson];
        }
        [self printToHtml:points];
    }
}
- (void)aop {
    [self aop:nil block:nil];
}

#pragma mark - 
- (void)printExampleJson {
    NSString *mdJson = @"\n \
    [\n \
        {\n \
            \"eventName\": \"点击立即注册\",\n \
            \"eventId\": \"Register_Begin_Button\",\n \
            \"eventLabels\": {\n \
                \"Channel\": \"$channel\",\n \
                \"Equipment\": \"$Equipment\",\n \
                \"VersionNumber\": \"4.5.3\"\n \
            },\n \
            \"md\": {\n \
                \"class\": \"TestViewController\",\n \
                \"method\": \"viewDidLoad\"\n \
            },\n \
            \"desc\":\ \"渠道(Channel)\"\n \
        }\n \
    ]";
    NSLog(@"md.json For Example : \n %@",mdJson);
}

/*
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
 */
-(NSArray *)neatenArray:(NSArray *)array{
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        NSDictionary *eventLabelsDict = [dict objectForKey:@"eventLabels"];
        NSDictionary *md = [dict objectForKey:@"md"];
        NSString *eventName = [dict objectForKey:@"eventName"];
        NSString *eventId = [dict objectForKey:@"eventId"];
        NSString *eventLabels = @"";
        if(eventLabelsDict){
            eventLabels = [eventLabelsDict.allKeys componentsJoinedByString:@","];
        }
        NSString *class = [md objectForKey:@"class"];
        NSString *method = [md objectForKey:@"method"];
        [arr addObject:@[eventName,eventId,eventLabels,class,method]];
    }
    return arr;
}

-(void)printToHtml:(NSArray *)points{
    if(_debugBlock && points){
        NSArray *array = [self neatenArray:points];
        NSMutableString *string = [NSMutableString stringWithCapacity:0];
        [string appendString:@"<html>"];
        [string appendString:@"<head>"];
        [string appendString:@"<style type=\"text/css\">.xwtable { width: 100%; border-collapse: collapse; border: 1px solid #ccc; } .xwtable thead td { font-size: 12px; color: #333333; text-align: center; background: url(table_top.jpg) repeat-x top center; border: 1px solid #ccc; font-weight: bold; } .xwtable tbody tr { background: #fff; font-size: 12px; color: #666666; } .xwtable tbody tr.alt-row { background: #f2f7fc; } .xwtable td { line-height: 20px; text-align: left; padding: 4px 10px 3px 10px; height: 18px; border: 1px solid #ccc; }</style>"];
        [string appendString:@"</head>"];
        
        [string appendString:@"<body>"];
        [string appendString:@"<center><h1>埋点表格</h1></center>"];
        [string appendString:@"<table class=\"xwtable\">"];
        
        //eventName,eventId,eventLabels,class,method
        [string appendString:@"<thead> <tr> <td>事件名称</td> <td>事件ID</td> <td>事件属性</td> <td>类名</td> <td>方法名</td> </tr> </thead>"];
        
        [string appendString:@"<tbody>"];

        //
        for (NSArray *temp in array) {
            [string appendString:[NSString stringWithFormat:@"<tr> <td>%@</td> <td>%@</td> <td>%@</td> <td>%@</td> <td>%@</td> </tr>",temp[0],temp[1],temp[2],temp[3],temp[4]]];
        }
        
        [string appendString:@"</tbody>"];
        [string appendString:@"</table>"];
        [string appendString:@"</body>"];
        [string appendString:@"</html>"];
        _debugBlock(@{@"html":string});
    }
}

#pragma mark -
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
