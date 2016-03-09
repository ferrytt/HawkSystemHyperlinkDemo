//
//  helper2.m
//  SystemHyperlinkDemo
//
//  Created by hawk on 16/3/7.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "helper2.h"
#import <CoreText/CoreText.h>

@interface helper2()

@property (nonatomic,copy)NSString * kUrl;
@property (nonatomic,strong)NSArray * kUrlArray;
@property (nonatomic,strong)UILabel * kLabel;
@property (nonatomic,strong)TT  kBlock;
@property (nonatomic,strong)UILabel * kContentLabel;
@property (nonatomic,strong)UIView * kSView;
@property(nonatomic,strong)NSArray * urlMatches;
@end

@implementation helper2

- (id)initWithLabel:(UILabel *)contentLabel withSView:(UIView *)sView withResult:(TT)block{
    if (self = [super init]) {
        NSCAssert(contentLabel,@"contentLabel must be unnull ! ");
        _kContentLabel = contentLabel;
        _kBlock = block;
        _kSView = sView;
        _kContentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        _kContentLabel.numberOfLines = 0;
        _kContentLabel.userInteractionEnabled = YES;
        _kContentLabel.font = [UIFont systemFontOfSize:14];
        [self configLogic];
        [self addSelfTap];
        return self;
    }
    return nil;
}
- (void)addSelfTap{
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMathch:)];
    
    [_kContentLabel addGestureRecognizer:tap];
}

- (void)configLogic{
    
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"((http{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)" options:NSRegularExpressionCaseInsensitive error:nil];
    _urlMatches = [regex matchesInString:_kContentLabel.text options:kNilOptions range:NSMakeRange(0, _kContentLabel.text.length)];
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]
                                                    initWithString:_kContentLabel.text];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:5];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [_kContentLabel.text length])];
    
    [_kContentLabel setAttributedText:attributedString];
    
    [_kContentLabel sizeToFit];
    
    [self highlightLinksWithIndex:NSNotFound];
    
}

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range
{
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [_kContentLabel.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        
        NSRange matchRange = [match range];
        
        if ([self isIndex:index inRange:matchRange]) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
        }
        else {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
        }
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
    }
    
    _kContentLabel.attributedText = attributedString;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)point
{
    NSMutableAttributedString* optimizedAttributedText = [_kContentLabel.attributedText mutableCopy];
    
    // use label's font and lineBreakMode properties in case the attributedText does not contain such attributes
    [_kContentLabel.attributedText enumerateAttributesInRange:NSMakeRange(0, [_kContentLabel.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        if (!attrs[(NSString*)kCTFontAttributeName])
        {
            [optimizedAttributedText addAttribute:(NSString*)kCTFontAttributeName value:_kContentLabel.font range:NSMakeRange(0, [_kContentLabel.attributedText length])];
        }
        
        if (!attrs[(NSString*)kCTParagraphStyleAttributeName])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:_kContentLabel.lineBreakMode];
            
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
    
    if (!CGRectContainsPoint(_kContentLabel.frame, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = _kContentLabel.frame;
    
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
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [_kContentLabel.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = _kContentLabel.numberOfLines > 0 ? MIN(_kContentLabel.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
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


- (void)tapMathch:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    CGPoint point = [tap locationInView:_kSView];
    CFIndex charIndex = [self characterIndexAtPoint:point];
    [self highlightLinksWithIndex:charIndex];
    
    for (NSTextCheckingResult *match in _urlMatches) {
        NSRange matchRange = [match range];
        if ([self isIndex:charIndex inRange:matchRange]) {
            NSString * touchURl = [_kContentLabel.text substringWithRange:matchRange];
            _kBlock(touchURl,_urlMatches,_kContentLabel);
            break;
        }
    }
    
    
}


@end
