//
//  help1.m
//  SystemHyperlinkDemo
//
//  Created by hawk on 16/3/7.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "help1.h"

@implementation help1

+ (void)helper:(UILabel *)label  withSuperView:(UIView *)sView withResutlBlock:(TT)block{
    helper2 * hp = [[helper2 alloc] initWithLabel:label withSView:sView withResult:block];
}

@end
