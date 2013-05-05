//
//  RIOExpandableLabel.m
//  RIOExpandableLabelDemo
//
//  Created by Christian Rasmussen on 04.05.13.
//  Copyright (c) 2013 Rasmussen I/O. All rights reserved.
//

#import "RIOExpandableLabel.h"
#import "RIOExpandableLabelDelegate.h"


static CGFloat const kTextViewPaddingOffset = -8;

static NSString * const kEllipsis = @"...";


@interface RIOExpandableLabel ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *moreButton;

@property (nonatomic) BOOL expanded;
@property (nonatomic, strong) NSString *displayText;

@end


@implementation RIOExpandableLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpView];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setUpView];
}

- (NSString *)displayText
{
    return self.textView.text;
}

- (void)setDisplayText:(NSString *)displayText
{
    self.textView.text = displayText;
}

- (CGFloat)displayHeight
{
    if (self.expanded == NO) {
        CGFloat allowedInitialHeight = CGFLOAT_MAX;
        if (self.maxNumberOfLines > 0) {
            allowedInitialHeight = [self.textFont lineHeight] * self.maxNumberOfLines;
        }
//        NSLog(@"%f %f %f", [self wantedHeight], allowedInitialHeight, MIN([self wantedHeight], allowedInitialHeight));
        return MIN([self wantedHeight], allowedInitialHeight);
    }
    else {
        return [self wantedHeight];
    }
}

- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines
{
    _maxNumberOfLines = maxNumberOfLines;
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text
{
    _text = [text copy];
    [self setNeedsLayout];
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    self.textView.font = textFont;
    [self setNeedsLayout];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.textView.textColor = textColor;
}

- (void)setMoreButtonText:(NSString *)moreButtonText
{
    _moreButtonText = [moreButtonText copy];
    [self.moreButton setTitle:moreButtonText forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setMoreButtonFont:(UIFont *)moreButtonFont
{
    _moreButtonFont = moreButtonFont;
    [self.moreButton.titleLabel setFont:moreButtonFont];
    [self setNeedsLayout];
}

- (void)setMoreButtonColor:(UIColor *)moreButtonColor
{
    _moreButtonColor = moreButtonColor;
    [self.moreButton setTitleColor:moreButtonColor forState:UIControlStateNormal];
}



#pragma mark - UIView subclass

- (CGSize)intrinsicContentSize
{
    return [self.text sizeWithFont:self.textFont];
}

- (void)layoutSubviews
{
    NSLog(@"width:%f", self.displayHeight);
    if ([self wantedHeight] > self.displayHeight) {
        self.displayText = [[self class] stringByTruncatingText:self.text withFont:self.textFont constrainedToSize:CGSizeMake(self.bounds.size.width, self.displayHeight) skippingButtonWidth:self.moreButton.bounds.size.width];
        self.moreButton.hidden = NO;
    }
    else {
        self.displayText = self.text;
        self.moreButton.hidden = YES;
    }
    
    [self.delegate expandableLabelDidLayout:self];
}


#pragma mark - Private methods

- (void)setUpView
{
    self.clipsToBounds = YES;
    
    // Default settings
    _maxNumberOfLines = 4;
    
    _textFont = [UIFont systemFontOfSize:17];
    _textColor = [UIColor blackColor];
    
    _moreButtonText = @"More ▼";
    _moreButtonFont = [UIFont boldSystemFontOfSize:17];
    _moreButtonColor = [UIColor blackColor];
    
    [self setUpTextView];
    [self setUpButton];
}

- (void)setUpTextView
{
    // Set up dimensions
    self.textView = [[UITextView alloc] initWithFrame:CGRectInset(self.bounds, kTextViewPaddingOffset, kTextViewPaddingOffset)];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.userInteractionEnabled = NO;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.translatesAutoresizingMaskIntoConstraints = YES;
    
    // Set styles
    self.textView.font = self.textFont;
    self.textView.textColor = self.textColor;
    
    [self addSubview:self.textView];
}

- (void)setUpButton
{
    CGSize buttonSize = [self.moreButtonText sizeWithFont:self.moreButtonFont];
    
    // Set up dimensions
    self.moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.moreButton.frame = CGRectMake(self.bounds.size.width - buttonSize.width, self.bounds.size.height - buttonSize.height, buttonSize.width, buttonSize.height);
    self.moreButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    self.moreButton.translatesAutoresizingMaskIntoConstraints = YES;
    [self.moreButton addTarget:self action:@selector(revealText) forControlEvents:UIControlEventTouchUpInside];
    
    // Set styles
    [self.moreButton setTitle:self.moreButtonText forState:UIControlStateNormal];
    [self.moreButton.titleLabel setFont:self.moreButtonFont];
    [self.moreButton setTitleColor:self.textColor forState:UIControlStateNormal];
    
    [self addSubview:self.moreButton];
}

- (void)revealText
{
    self.expanded = YES;
    [self.delegate expandableLabelWantsToRevealText:self];
}

- (CGFloat)wantedHeight
{
    CGSize wantedSize = [self.text sizeWithFont:self.textFont constrainedToSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
    return wantedSize.height;
}


#pragma mark - Helper methods

+ (NSString *)stringByTruncatingText:(NSString *)text withFont:(UIFont *)font constrainedToSize:(CGSize)constrainedSize skippingButtonWidth:(CGFloat)buttonWidth
{
    CGSize unconstrainedHeightSize = CGSizeMake(constrainedSize.width, CGFLOAT_MAX);
    
    // Find truncated row
    NSMutableString *lineString = [text mutableCopy];
    CGSize initialSize = [lineString sizeWithFont:font constrainedToSize:unconstrainedHeightSize];
    
    CGFloat rowEndValue = initialSize.height;
    while (rowEndValue > constrainedSize.height) {
        [self removeLastWordFromString:lineString];
        rowEndValue = [lineString sizeWithFont:font constrainedToSize:unconstrainedHeightSize].height;
    }
    NSUInteger rowEndPosition = lineString.length;
    
    CGFloat rowStartValue = initialSize.height;
    while (rowStartValue > constrainedSize.height - [font lineHeight]) {
        [self removeLastWordFromString:lineString];
        rowStartValue = [lineString sizeWithFont:font constrainedToSize:unconstrainedHeightSize].height;
    }
    NSUInteger rowStartPosition = lineString.length + 1;
    
    // Find truncated column
    NSMutableString *rowText = [[text substringWithRange:NSMakeRange(rowStartPosition, rowEndPosition - rowStartPosition)] mutableCopy];
    CGFloat columnEnd = initialSize.width;
    while (columnEnd > constrainedSize.width - buttonWidth - [kEllipsis sizeWithFont:font].width) {
        [rowText deleteCharactersInRange:NSMakeRange(rowText.length - 1, 1)];
        columnEnd = [rowText sizeWithFont:font constrainedToSize:constrainedSize].width;
    }
    NSUInteger columnEndPosition = rowText.length;
    
    // Truncate and add ellipsis
    NSString *truncatedString = [text substringWithRange:NSMakeRange(0, rowStartPosition + columnEndPosition)];
    NSString *truncatedStringWithEllipsis = [truncatedString stringByAppendingString:kEllipsis];
    
    return truncatedStringWithEllipsis;
}

+ (void)removeLastWordFromString:(NSMutableString *)string
{
    NSRange range = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] options:NSBackwardsSearch];
    if (range.location != NSNotFound) {
        [string deleteCharactersInRange:NSMakeRange(range.location - 1, (string.length - range.location))];
    }
}

@end
