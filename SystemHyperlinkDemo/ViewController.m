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

- (void)configLogic{
    
//    _detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];

    
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((http{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
     _urlMatches = [regex matchesInString:link options:kNilOptions range:NSMakeRange(0, link.length)];

    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]
                                                        initWithString:link];
    
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName
                                 value:paragraphStyle
                                 range:NSMakeRange(0, [link length])];
    [lab setAttributedText:attributedString];
    
    [lab sizeToFit];

    [self highlightLinksWithIndex:NSNotFound];

}

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range
{
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [lab.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        
//        if ([match resultType] == NSTextCheckingTypeLink || [match resultType] == NSTextCheckingTypeReplacement) {
        
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            }
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            }
            
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
//        }
    }
    
    lab.attributedText = attributedString;
}

//- (CFIndex)characterIndexAtPoint:(CGPoint)p {
//    if (!CGRectContainsPoint(lab.bounds, p)) {
//        return NSNotFound;
//    }
//    
//    CGRect textRect = [lab textRectForBounds:lab.bounds limitedToNumberOfLines:lab.numberOfLines];
//    if (!CGRectContainsPoint(textRect, p)) {
//        return NSNotFound;
//    }
//    // Adjust pen offset for flush depending on text alignment
//    CGFloat flushFactor = TTTFlushFactorForTextAlignment(lab.textAlignment);
//    
//    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
//    p = CGPointMake(p.x - textRect.origin.x, p.y - textRect.origin.y);
//    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
//    p = CGPointMake(p.x, textRect.size.height - p.y);
//    
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, NULL, textRect);
//    CTFrameRef frame = CTFramesetterCreateFrame([self framesetter], CFRangeMake(0, (CFIndex)[lab.attributedText length]), path, NULL);
//    if (frame == NULL) {
//        CFRelease(path);
//        return NSNotFound;
//    }
//    
//    CFArrayRef lines = CTFrameGetLines(frame);
//    NSInteger numberOfLines = lab.numberOfLines > 0 ? MIN(lab.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
//    if (numberOfLines == 0) {
//        CFRelease(frame);
//        CFRelease(path);
//        return NSNotFound;
//    }
//    
//    CFIndex idx = NSNotFound;
//    
//    CGPoint lineOrigins[numberOfLines];
//    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
//    
//    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
//        CGPoint lineOrigin = lineOrigins[lineIndex];
//        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
//        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, textRect.size.width);
//        
//        // Get bounding information of line
//        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
//        CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
//        CGFloat yMin = (CGFloat)floor(lineOrigin.y - descent);
//        CGFloat yMax = (CGFloat)ceil(lineOrigin.y + ascent);
//        
//        // Check if we've already passed the line
//        if (p.y > yMax) {
//            break;
//        }
//        // Check if the point is within this line vertically
//        if (p.y >= yMin) {
//            // Check if the point is within this line horizontally
//            if (p.x >= penOffset && p.x <= penOffset + width) {
//                // Convert CT coordinates to line-relative coordinates
//                CGPoint relativePoint = CGPointMake(p.x - penOffset, p.y - lineOrigin.y);
//                idx = CTLineGetStringIndexForPosition(line, relativePoint);
//                break;
//            }
//        }
//    }
//    
//    CFRelease(frame);
//    CFRelease(path);
//    
//    return idx;
//}

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

//
//- (CFIndex)characterIndexAtPoint:(CGPoint)point
//{
//    NSMutableAttributedString* optimizedAttributedText = [lab.attributedText mutableCopy];
//    
//    // use label's font and lineBreakMode properties in case the attributedText does not contain such attributes
//    [lab.attributedText enumerateAttributesInRange:NSMakeRange(0, [lab.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
//        
//        if (!attrs[(NSString*)kCTFontAttributeName])
//        {
//            [optimizedAttributedText addAttribute:(NSString*)kCTFontAttributeName value:lab.font range:NSMakeRange(0, [lab.attributedText length])];
//        }
//        
//        if (!attrs[(NSString*)kCTParagraphStyleAttributeName])
//        {
//            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//            [paragraphStyle setLineBreakMode:lab.lineBreakMode];
//            
//            [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
//        }
//    }];
//    
//    // modify kCTLineBreakByTruncatingTail lineBreakMode to kCTLineBreakByWordWrapping
//    [optimizedAttributedText enumerateAttribute:(NSString*)kCTParagraphStyleAttributeName inRange:NSMakeRange(0, [optimizedAttributedText length]) options:0 usingBlock:^(id value, NSRange range, BOOL *stop)
//     {
//         NSMutableParagraphStyle* paragraphStyle = [value mutableCopy];
//         
//         if ([paragraphStyle lineBreakMode] == NSLineBreakByTruncatingTail) {
//             [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
//         }
//         
//         [optimizedAttributedText removeAttribute:(NSString*)kCTParagraphStyleAttributeName range:range];
//         [optimizedAttributedText addAttribute:(NSString*)kCTParagraphStyleAttributeName value:paragraphStyle range:range];
//     }];
//    
//    if (!CGRectContainsPoint(self.view.bounds, point)) {
//        return NSNotFound;
//    }
//    
//    CGRect textRect = lab.frame;
//    
//    if (!CGRectContainsPoint(textRect, point)) {
//        return NSNotFound;
//    }
//    
//    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
//    point = CGPointMake(point.x - textRect.origin.x, point.y - textRect.origin.y);
//    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
//    point = CGPointMake(point.x, textRect.size.height - point.y);
//    
//    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)optimizedAttributedText);
//    
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGPathAddRect(path, NULL, textRect);
//    
//    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [lab.attributedText length]), path, NULL);
//    
//    if (frame == NULL) {
//        CFRelease(path);
//        return NSNotFound;
//    }
//    
//    CFArrayRef lines = CTFrameGetLines(frame);
//    
//    NSInteger numberOfLines = lab.numberOfLines > 0 ? MIN(lab.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
//    
//    //NSLog(@"num lines: %d", numberOfLines);
//    
//    if (numberOfLines == 0) {
//        CFRelease(frame);
//        CFRelease(path);
//        return NSNotFound;
//    }
//    
//    NSUInteger idx = NSNotFound;
//    
//    CGPoint lineOrigins[numberOfLines];
//    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
//    
//    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
//        
//        CGPoint lineOrigin = lineOrigins[lineIndex];
//        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
//        
//        // Get bounding information of line
//        CGFloat ascent, descent, leading, width;
//        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
//        CGFloat yMin = floor(lineOrigin.y - descent);
//        CGFloat yMax = ceil(lineOrigin.y + ascent);
//        
//        // Check if we've already passed the line
//        if (point.y > yMax) {
//            break;
//        }
//        
//        // Check if the point is within this line vertically
//        if (point.y >= yMin) {
//            
//            // Check if the point is within this line horizontally
//            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
//                
//                // Convert CT coordinates to line-relative coordinates
//                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
//                idx = CTLineGetStringIndexForPosition(line, relativePoint);
//                
//                break;
//            }
//        }
//    }
//    
//    CFRelease(frame);
//    CFRelease(path);
//    
//    return idx;
//}

-(void)bubbleViewPressed:(id)sender
{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint point = [tap locationInView:self.view];
    CFIndex charIndex = [self characterIndexAtPoint:point];
    [self highlightLinksWithIndex:charIndex];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        
//        if ([match resultType] == NSTextCheckingTypeLink) {
        
            NSRange matchRange = [match range];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                NSLog(@"matchUrl = %@",[link substringWithRange:matchRange]);
//                [self routerEventWithName:kRouterEventTextURLTapEventName userInfo:@{@"message":lab, @"url":match.URL}];
                break;
            }
//        } else if ([match resultType] ==  NSTextCheckingTypeReplacement) {
//            
//            NSRange matchRange = [match range];
//            
//            if ([self isIndex:charIndex inRange:matchRange]) {
//                
//                [self routerEventWithName:kRouterEventMenuTapEventName userInfo:@{@"message":lab, @"text":match.replacementString}];
//                break;
//            }
//        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
