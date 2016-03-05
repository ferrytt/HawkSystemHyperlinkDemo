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

NSString *const kRouterEventMenuTapEventName = @"kRouterEventMenuTapEventName";
NSString *const kRouterEventTextURLTapEventName = @"kRouterEventTextURLTapEventName";

@interface ViewController ()
{
    UILabel * lab;
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
    
    lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 320, 80)];
    
    lab.lineBreakMode = NSLineBreakByCharWrapping;
    
    lab.numberOfLines = 0;
    
    lab.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewPressed:)];
    
    [lab addGestureRecognizer:tap];
    
    lab.font = [UIFont systemFontOfSize:14];
    
    [self.view addSubview:lab];
    
    [self configLogic];
    
    // Do any additional setup after loading the view, typically from a nib.
}


//显示要显示的内容
- (void)configLogic{
    
//    _detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];

    
    //规定一个匹配规则
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((http{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                            error:nil];
    //在整个字符处中进行匹配查找,返回查询的结果数组
     _urlMatches = [regex matchesInString:link options:kNilOptions range:NSMakeRange(0, link.length)];

    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]
                                                        initWithString:link];
    
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName
                                 value:paragraphStyle
                                 range:NSMakeRange(0, [link length])];
    //给label赋值
    [lab setAttributedText:attributedString];
    
    [lab sizeToFit];

    [self highlightLinksWithIndex:NSNotFound];

}

//判断点击的那个字符是不是在连接内
- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range
{
    return index > range.location && index < range.location+range.length;
}

//给链接绘制成不同的颜色,正常状态下是蓝色+ 下划线, 点击状态下是灰色加下划线
- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [lab.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        
//        if ([match resultType] == NSTextCheckingTypeLink || [match resultType] == NSTextCheckingTypeReplacement) {
        
            NSRange matchRange = [match range];
            //点击状态下
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            }
            //正常状态下
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            }
            //改变超链接颜色后重新赋值
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
//        }
    }
    
    lab.attributedText = attributedString;
}

//用coretext把点击的位置转换为点击到的位置在字符串中的位置
- (CFIndex)characterIndexAtPoint:(CGPoint)point
{
    NSMutableAttributedString* optimizedAttributedText = [lab.attributedText mutableCopy];
    
    // use label's font and lineBreakMode properties in case the attributedText does not contain such attributes
    [lab.attributedText enumerateAttributesInRange:NSMakeRange(0, [lab.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        if (!attrs[(NSString*)kCTFontAttributeName])
        {
            [optimizedAttributedText addAttribute:(NSString*)kCTFontAttributeName value:lab.font range:NSMakeRange(0, [lab.attributedText length])];
        }
        
        if (!attrs[(NSString*)kCTParagraphStyleAttributeName])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:lab.lineBreakMode];
            
            [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
        }
    }];
    
    // modify kCTLineBreakByTruncatingTail lineBreakMode to kCTLineBreakByWordWrapping
    [optimizedAttributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
     {
         NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
         
         if ([paragraphStyle lineBreakMode] == NSLineBreakByTruncatingTail) {
             [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
         }
         
         [optimizedAttributedText removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
         [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
     }];
    
    if (!CGRectContainsPoint(lab.frame, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = lab.frame;
    
    if (!CGRectContainsPoint(textRect, point)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, textRect.size.height - point.y);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, textRect);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [lab.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = lab.numberOfLines > 0 ? MIN(lab.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
    //NSLog(@"num lines: %d", numberOfLines);
    
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        // Check if we've already passed the line
        if (point.y > yMax) {
            break;
        }
        
        // Check if the point is within this line vertically
        if (point.y >= yMin) {
            
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}

//点击label时候进行监听
-(void)bubbleViewPressed:(id)sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint point = [tap locationInView:self.view];
    CFIndex charIndex = [self characterIndexAtPoint:point];
    //在此处添加点击链接的效果
    [self highlightLinksWithIndex:charIndex];
    
    for (NSTextCheckingResult *match in _urlMatches) {
                    NSRange matchRange = [match range];
            //判断点击的位置是否在超链接内
            if ([self isIndex:charIndex inRange:matchRange]) {
                //如果在,则打印出结果,substringWithRange 方法可以截取出完整的链接
                NSLog(@"matchUrl = %@",[link substringWithRange:matchRange]);
                break;
            }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
