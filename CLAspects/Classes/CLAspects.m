//
//  CLAspects.m
//  AOPTestProject
//
//  Created by chenliang on 02/11/2018.
//  Copyright © 2018 yypt. All rights reserved.
//

#import "Aspects.h"
#import "CLAspects.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "BRAOfficeDocumentPackage.h"

@interface CLAWebViewController : UIViewController
@property(nonatomic, strong) WKWebView *webView;
@end

@interface CLAWebViewController () <WKNavigationDelegate>

@end
@implementation CLAWebViewController {
    UIActivityIndicatorView *_activityView;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_webView];
        _webView.navigationDelegate = self;
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:_webView.bounds];
        [_webView addSubview:_activityView];
    }
    return self;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [_activityView startAnimating];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [_activityView stopAnimating];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    [_activityView stopAnimating];
}

@end

typedef void (^ConfigBlock)(NSString *html);
typedef void (^Callback)(NSDictionary *result);
@implementation CLAspects {
    ConfigBlock _configBlock;
    Callback _block;
    NSString *_html;
}

// 单例
static CLAspects *instance = nil;
+ (id)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - public methods
- (void)aop:(void (^)(NSDictionary *result))block configBlock:(void (^)(NSString *html))configBlock {
    _block = block;
    _configBlock = configBlock;
    NSArray *points = [self loadConfigWithFileName];
    if (points) {
        [self aspect:points];
        if (CLAConfigOptions.debug) {
            [self printExampleJson];
        }
        [self printToHtml:points];
    }
}

#pragma mark -
- (void)printExampleJson {
    NSString *mdJson = @"\n \
    {\n \
      \"point\":[\n \
                {\n \
                    \"eventId\": \"Register_Begin_Button\",\n \
                    \"eventName\": \"点击立即注册\",\n \
                    \"props\": {\n \
                        \"Channel\": \"$channel\",\n \
                        \"Equipment\": \"$Equipment\",\n \
                        \"VersionNumber\": \"4.5.3\"\n \
                    },\n \
                    \"className\": \"TestViewController\",\n \
                    \"methodName\": \"viewDidLoad\"\n \
                    \"desc\": {\n \
                        \"remark\": \"渠道(Channel):微站、app标准版...\",\n \
                    },\n \
                }\n \
            ]\n \
    }";
    NSLog(@"Example for md.json : \n %@", mdJson);
}

/*
 {
   "eventId": "Register_Begin_Button",
   "eventName": "点击立",
   "props": {
     "Channel": "$channel",
     "Equipment": "$Equipment",
     "VersionNumber": "4.5.3"
   },
   "desc": {
     "Channel": "渠道:微站、app标准版、app关怀版、非营销人员老带新、营销人员老带新、web端、柜面扫码;",
     "Equipment": "设备:安卓(具体系统型号)、ios苹果(具体系统型号)、pc(具体系统型号)、平板(具体系统型号)",
     "VersionNumber": "版本号:当前事件对应的版本号"
   },
   "aop-class": "TestViewController",
   "aop-method": "viewDidLoad"
 }
 */
- (NSArray *)neatenArray:(NSArray *)array {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        NSDictionary *propsDict = [dict objectForKey:@"props"];
        NSString *eventId = [dict objectForKey:@"eventId"];
        NSString *eventName = [dict objectForKey:@"eventName"];
        NSString *props = [dict objectForKey:@"props"];
        NSString *class = [dict objectForKey:@"className"];
        NSString *method = [dict objectForKey:@"methodName"];
        [arr addObject:@[eventName, eventId, props, class, method]];
    }
    return arr;
}

- (void)printToHtml:(NSArray *)points {
    if (_configBlock && points) {
        NSArray *array = [self neatenArray:points];
        NSMutableString *string = [NSMutableString stringWithCapacity:0];
        [string appendString:@"<!DOCTYPE html>"];
        [string appendString:@"<html>"];
        [string appendString:@"<head>"];
        [string appendString:@"<meta charset='utf-8' />"];
        [string appendString:@"<meta name=\"viewport\" content=\"width=device-width,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no\"/>"];
        [string appendString:@"<style type=\"text/css\">"];
        [string appendString:@".xwtable { width: 800px; border-collapse: collapse; border: 1px solid #ccc; }"];
        [string appendString:@".xwtable thead td {font-size: 12px; color: #333333; text-align: center; border: 1px solid #ccc; font-weight: bold; }"];
        [string appendString:@".xwtable tbody tr { background: #fff; font-size: 12px; color: #666666; }"];
        [string appendString:@".xwtable tbody tr.alt-row { background: #f2f7fc; }"];
        [string appendString:@".xwtable td { word-break:break-word;max-width:150px;line-height: 20px; text-align: left; padding: 4px 10px 3px 10px; height: 18px; border: 1px solid #ccc;}"];
        [string appendString:@"</style>"];
        [string appendString:@"</head>"];
        [string appendString:@"<body>"];
        [string appendString:@"<div style=\"text-align:center\"><h1>埋点表格</h1></div>"];
        [string appendString:@"<table class=\"xwtable\">"];

        // eventName,eventId,props,class,method
        [string appendString:@"<thead> <tr> <td>事件名称</td> <td>事件ID</td> <td>事件属性</td> <td>类名</td> <td>方法名</td> </tr> </thead>"];
        [string appendString:@"<tbody>"];

        //
        for (NSArray *temp in array) {
            [string appendString:[NSString stringWithFormat:@"<tr> <td>%@</td> <td>%@</td> <td>%@</td> <td>%@</td> <td>%@</td> </tr>", temp[0], temp[1], temp[2], temp[3], temp[4]]];
        }

        [string appendString:@"</tbody>"];
        [string appendString:@"</table>"];
        [string appendString:@"</body>"];
        [string appendString:@"</html>"];
        _configBlock(string);

        if (CLAConfigOptions.debug) {
            _html = string;
            UIColor *color = [self colorWithHexString:@"209cf0"];
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(UIScreen.mainScreen.bounds.size.width - 45, UIScreen.mainScreen.bounds.size.height - 150, 35, 35)];
            [button setTitle:@"MD" forState:UIControlStateNormal];
            [button setTitleColor:color forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            button.layer.borderColor = color.CGColor;
            button.layer.borderWidth = 1;
            button.layer.cornerRadius = 5;
            button.layer.masksToBounds = YES;
            [UIApplication.sharedApplication.keyWindow addSubview:button];
            [button addTarget:self action:@selector(showWebVC) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (void)showWebVC {
    CLAWebViewController *vc = [[CLAWebViewController alloc] init];
    [vc.webView loadHTMLString:_html baseURL:nil];
    UINavigationController *navVC = (UINavigationController *)UIApplication.sharedApplication.keyWindow.rootViewController;
    [navVC pushViewController:vc animated:YES];
}

- (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) return [UIColor blackColor];
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString length] != 6) return [UIColor blackColor];
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:1];
}

#pragma mark -
- (void)aspect:(NSArray *)points {
    if (points && [points isKindOfClass:[NSArray class]] && points.count > 0) {
        for (NSDictionary *point in points) {
            NSString *className = [point objectForKey:@"className"];
            NSString *method = [point objectForKey:@"methodName"];
            [self after:className method:method callback:^(id<AspectInfo> aspectInfo) {
                NSDictionary *props = [self transferProps:point[@"props"] target:aspectInfo.instance];
                NSMutableDictionary *rs = [NSMutableDictionary dictionaryWithDictionary:point];
                [rs setObject:props forKey:@"props"];
                if (_block) _block(rs);
            }];
        }
    }
}

- (NSDictionary *)transferProps:(NSDictionary *)props target:(id)target {
    if (props == nil) return @{};
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
        } else {
            NSString *value = [props objectForKey:k];
            [result setValue:value forKey:k];
        }
    }
    return result;
}

#pragma mark - loadConfigWithFileName
- (NSArray *)loadConfigWithFileName {
    NSString *documentPath = [[NSBundle mainBundle] pathForResource:CLAConfigOptions.fileName ofType:@"xlsx"];
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:documentPath];
    BRAWorksheet *worksheet = spreadsheet.workbook.worksheets.firstObject;
    NSArray<BRARow *> *rows = worksheet.rows;
    
    NSArray *fieldNameArray = @[@"eventId",@"eventName",@"className",@"methodName",@"props",@"desc"];//fieldNameArray
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
    for (int i=1; i<rows.count; i++) {
        BRARow *row = rows[i];
        NSMutableDictionary *rowDict = [NSMutableDictionary dictionaryWithCapacity:0];
        for(int j=0;(j<fieldNameArray.count);j++){
            NSString *fieldName = fieldNameArray[j];
            if(j >= row.cells.count){
                [rowDict setObject:@"" forKey:fieldName];
            }else{
                BRACell *cell = row.cells[j];
                if([@"props" isEqualToString:fieldName]){
                    NSDictionary *props = [self objectFromJSONString:cell.stringValue];
                    if(props && [props isKindOfClass:[NSDictionary class]]){
                        NSDictionary *dict = @{fieldName : props};
                        [rowDict setObject:dict forKey:fieldName];
                    }
                }else{
                    [rowDict setObject:cell.stringValue forKey:fieldName];
                }
            }
        }
        [result addObject:rowDict];
    }
    NSLog(@"result = %@",result);
    return result;
}

- (NSDictionary *)objectFromJSONString:(NSString *)json{
    NSString *string = [json stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    if(data && [data isKindOfClass:[NSData class]] && data.length > 0){
        NSError *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        return result;
    }
    return nil;
}


#pragma mark - private aop methods
- (void)after:(NSString *)className method:(NSString *)methodName callback:(void (^)(id<AspectInfo> aspectInfo))callBack {
    [self class:className method:methodName options:AspectPositionAfter callback:callBack];
}

- (void)before:(NSString *)className method:(NSString *)methodName callback:(void (^)(id<AspectInfo> aspectInfo))callBack {
    [self class:className method:methodName options:AspectPositionBefore callback:callBack];
}

- (void)class:(NSString *)className method:(NSString *)methodName options:(AspectOptions)options callback:(void (^)(id<AspectInfo>))callBack {
    Class class = NSClassFromString(className);
    SEL method = NSSelectorFromString(methodName);
    if (class && method) {
        [class aspect_hookSelector:method withOptions:options usingBlock:^(id<AspectInfo> aspectInfo) {
            if (callBack) {
                callBack(aspectInfo);
            }
        } error:nil];
    }
}

@end
