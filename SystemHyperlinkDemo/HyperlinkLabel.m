//
//  HyperlinkLabel.m
//  SystemHyperlinkDemo
//
//  Created by hawk on 16/3/6.
//  Copyright © 2016年 鹰. All rights reserved.
//

#import "HyperlinkLabel.h"
#import <CoreText/CoreText.h>

@interface HyperlinkLabel()

@property(nonatomic,strong)TouchAt kTouchAt;

@property(nonatomic,copy)NSString * kRegex;

@property(nonatomic,copy)NSString * kContent;

@property(nonatomic,strong)NSArray * urlMatches;

@property(nonatomic,strong)UIView * kSView;

@end

@implementation HyperlinkLabel


- (id)initWithFrame:(CGRect)frame withContent:(NSString *)content withRegex:(NSString *)regex withSuperView:(UIView *)sView andTouchUrlAt:(TouchAt)touchAt{
    if (self = [super initWithFrame:frame]) {
        NSCAssert(self, @"init fail");
        _kContent = content;
        _kRegex = regex;
        _kTouchAt = touchAt;
        _kSView = sView;
        self.lineBreakMode = NSLineBreakByCharWrapping;
        self.numberOfLines = 0;
        self.userInteractionEnabled = YES;
        self.font = [UIFont systemFontOfSize:14];
        [self configLogic];
        [self addSelfTap];
        return self;
    }
    return nil;
}

- (void)addSelfTap{
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMathch:)];
    
    [self addGestureRecognizer:tap];
}

- (void)configLogic{
    
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:_kRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    _urlMatches = [regex matchesInString:_kContent options:kNilOptions range:NSMakeRange(0, _kContent.length)];
    
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]
                                                    initWithString:_kContent];
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:5];
    
    [attributedString addAttribute:NSParagraphStyleAttributeName
                             value:paragraphStyle
                             range:NSMakeRange(0, [_kContent length])];
    
    [self setAttributedText:attributedString];
    
    [self sizeToFit];
    
    [self highlightLinksWithIndex:NSNotFound];
    
}

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range
{
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [self.attributedText mutableCopy];
    
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
    
    self.attributedText = attributedString;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)point
{
    NSMutableAttributedString* optimizedAttributedText = [self.attributedText mutableCopy];
    
    // use label's font and lineBreakMode properties in case the attributedText does not contain such attributes
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, [self.attributedText length]) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        
        if (!attrs[(NSString*)kCTFontAttributeName])
        {
            [optimizedAttributedText addAttribute:(NSString*)kCTFontAttributeName value:self.font range:NSMakeRange(0, [self.attributedText length])];
        }
        
        if (!attrs[(NSString*)kCTParagraphStyleAttributeName])
        {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            [paragraphStyle setLineBreakMode:self.lineBreakMode];
            
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
    
    if (!CGRectContainsPoint(self.frame, point)) {
        return NSNotFound;
    }
    
    CGRect textRect = self.frame;
    
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
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attributedText length]), path, NULL);
    
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    
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
            NSString * touchURl = [_kContent substringWithRange:matchRange];
            NSCAssert(touchURl, @"touchUrl is nil");
            NSCAssert(_kTouchAt, @"kTouch must be unnull");
            _kTouchAt(touchURl);
            break;
        }
    }

    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
