//
//  helper2.h
//  SystemHyperlinkDemo
//
//  Created by hawk on 16/3/7.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^TT)(NSString * url ,NSArray * urlArray ,UILabel * label);
@interface helper2 : NSObject

- (id)initWithLabel:(UILabel *)contentLabel withSView:(UIView *)sView withResult:(TT)block;
@end
