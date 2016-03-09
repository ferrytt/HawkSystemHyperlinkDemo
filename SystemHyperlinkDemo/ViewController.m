//
//  ViewController.m
//  SystemHyperlinkDemo
//
//  Created by Hawk on 16/3/3.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>
#import "UIResponder+Router.h"
#import "HyperlinkLabel.h"
#import "help1.h"

NSString *const kRouterEventMenuTapEventName = @"kRouterEventMenuTapEventName";
NSString *const kRouterEventTextURLTapEventName = @"kRouterEventTextURLTapEventName";

@interface ViewController ()
{
    HyperlinkLabel * lab;
    NSString * link;
}

@property (nonatomic,strong)NSDataDetector *detector;
@property (nonatomic,strong)NSArray *urlMatches;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"SystemHyperlinkDemo";
    
    link = @"使用球友圈点击这里:http://www.qiuyouzone.cc使用球友圈点击这里:www.qiuyou.cn";
    
//    lab = [[HyperlinkLabel alloc] initWithFrame:CGRectMake(0, 100, 320, 80) withContent:link withRegex:@"((http{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" withSuperView:self.view andTouchUrlAt:^(NSString *url) {
//        NSLog(@"url = %@",url);
//    }];
    
    
    [self.view addSubview:lab];
        
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
