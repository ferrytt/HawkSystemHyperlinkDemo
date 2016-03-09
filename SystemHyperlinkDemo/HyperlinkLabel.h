//
//  HyperlinkLabel.h
//  SystemHyperlinkDemo
//
//  Created by hawk on 16/3/6.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TouchAt)(NSString * url);

@interface HyperlinkLabel : UILabel

- (id)initWithFrame:(CGRect)frame withContent:(NSString *)content withRegex:(NSString *)regex withSuperView:(UIView *)sView andTouchUrlAt:(TouchAt)at;

@end
