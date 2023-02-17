//// 
//  CLFormatJson.m
//  AOPTestProject
//  Created by yypt on 2023/2/15
//

#import "CLFormatJson.h"
#import <UIKit/UIKit.h>

@implementation CLFormatJson

-(void)printToConsole:(NSArray *)array{
    
    //format
    NSArray *arr = [self neatenArray:array];
    
    //common
    NSMutableArray *wa = [NSMutableArray arrayWithCapacity:0];
    for (int i=0; i<((NSArray *)arr.firstObject).count; i++) {
        NSMutableArray *ra = [NSMutableArray arrayWithCapacity:0];
        for (NSArray *row in arr) {
            [ra addObject:[NSNumber numberWithInteger:[self calcFieldWidth:row[i]]]];
        }
        [wa addObject:ra];
    }
    NSLog(@"wa = %@",wa);//[@[14,30,30],@[23,29,29]...]
    NSMutableArray *rs = [NSMutableArray arrayWithCapacity:0];
    for (NSArray *ra in wa) {
        [rs addObject:[ra valueForKeyPath:@"@max.intValue"]];
    }
    NSLog(@"rs = %@",rs);//@[30,29,33,20,13]
    int totalWidth  = 0;
    for (NSNumber *n in rs) {
        totalWidth += n.intValue;
    }
    
    NSMutableString *str = [NSMutableString stringWithCapacity:0];
    [str appendString:@"\n"];
    [str appendString:@" "];
    for (int i=0;i<totalWidth;i++) {
        [str appendString:@"-"];
    }
    [str appendString:@" "];
    [str appendString:@"\n"];
    
    for (int i=0;i<arr.count;i++) {
        for (int j=0;j<rs.count;j++) {
            [str appendString:@"| "];
            NSString *text = [[arr objectAtIndex:i]objectAtIndex:j];
            [str appendString:[self completeSpace:text width:rs[j]]];
            [str appendString:@" "];
        }
        [str appendString:@" |"];
        [str appendString:@"\n"];
        
        
        if(i==0){
            [str appendString:@"| "];
            for (int j=0;j<rs.count;j++) {
                [str appendString:@" -------- "];
                [str appendString:@"|"];
            }
            [str appendString:@"\n"];
        }
    }
    
    [str appendString:@"\n"];
    for (int i=0;i<totalWidth;i++) {
        [str appendString:@"-"];
    }
    NSLog(@"markdown str = %@",str);
}
-(void)printToHtml:(NSArray *)array{
    NSArray *arr = [self neatenArray:array];
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *htmlFilePath = [docsdir stringByAppendingPathComponent:@"md.html"]; // 在指定目录下创建 "head" 文件夹
    BOOL isDir = NO;
    BOOL existed = [[NSFileManager defaultManager]fileExistsAtPath:htmlFilePath isDirectory:&isDir];
    if (!(isDir && existed)) {
        [[NSFileManager defaultManager]createFileAtPath:htmlFilePath contents:nil attributes:nil];
    }
    
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
    for (NSArray *temp in arr) {
        [string appendString:[NSString stringWithFormat:@"<tr> <td>%@</td> <td>%@</td> <td>%@</td> <td>%@</td> <td>%@</td> </tr>",temp[0],temp[1],temp[2],temp[3],temp[4]]];
    }
    
    [string appendString:@"</tbody>"];
    [string appendString:@"</table>"];
    [string appendString:@"</body>"];
    [string appendString:@"</html>"];
    
    [string writeToFile:htmlFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"htmlFilePath = \n%@",htmlFilePath);
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

#pragma mark -
- (NSString *)completeSpace:(NSString *)string width:(NSNumber *)width{
    float w = [self calcChineseFieldWidth:string];
    int sw = (width.intValue-w) > 0 ? (width.intValue-w)/2 : 0;
    NSMutableString *rs = [NSMutableString stringWithCapacity:0];
    for (int i=0;i<sw;i++) {
        [rs appendString:@" "];
    }
    [rs appendString:string];
    for (int i=0;i<sw;i++) {
        [rs appendString:@" "];
    }
    return rs;
}
- (float)calcChineseFieldWidth:(NSString *)string{
    float length = 0;
    for(int i=0;i<string.length;i++){
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        if([self isChinese:s]){
            length += 1.66;
        }else{
            length += 1;
        }
    }
    
    length += 2;
    
    if(length > 120){
        length = 120;
    }
    return length;
}
- (int)calcFieldWidth:(NSString *)string {
    int length = 0;
    for(int i=0;i<string.length;i++){
        NSString *s = [string substringWithRange:NSMakeRange(i, 1)];
        if([self isChinese:s]){
            length += 2;
        }else{
            length += 1;
        }
    }
    
    length += 2;
    
    if(length > 120){
        length = 120;
    }
    return length;
}
- (BOOL)isChinese:(NSString *)string {
    NSString *regex =@"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:string];
}

@end
