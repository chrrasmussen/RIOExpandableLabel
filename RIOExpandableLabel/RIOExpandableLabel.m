//
//  RIOExpandableLabel.m
//  RIOExpandableLabelDemo
//
//  Created by Christian Rasmussen on 04.05.13.
//  Copyright (c) 2013 Rasmussen I/O. All rights reserved.
//

#import "RIOExpandableLabel.h"


static CGSize const kTextViewInset = {-4, -8};


@interface RIOExpandableLabel ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *moreButton;

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

- (CGSize)intrinsicContentSize
{
    CGSize sizeThatFits = [self.textView sizeThatFits:CGSizeMake(self.textView.bounds.size.width, CGFLOAT_MAX)];
    CGFloat height = ceilf(sizeThatFits.height + 2 * kTextViewInset.height);
    
    return CGSizeMake(-1, height);
}

- (void)moreButtonAddTarget:(id)target action:(SEL)action
{
    [self.moreButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)moreButtonRemoveTarget:(id)target action:(SEL)action
{
    [self.moreButton removeTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Private methods

- (void)setUpView
{
    self.clipsToBounds = YES;
    
    [self addSubview:self.textView];
    
//    [self updateLayout];
    [self performSelector:@selector(updateLayout) withObject:nil afterDelay:0];
    
    // Default settings
    self.maxNumberOfLines = 4;
    
    self.textFont = [UIFont systemFontOfSize:17];
    self.textColor = [UIColor blackColor];
    
    self.moreButtonText = @"More ▼";
    self.moreButtonFont = [UIFont boldSystemFontOfSize:17];
    self.moreButtonColor = [UIColor blackColor];
}

- (void)updateLayout
{
    [self removeButton];
    
    [self invalidateIntrinsicContentSize];
    [self updateConstraintsIfNeeded];
    [self setNeedsLayout];
    
    [self performSelector:@selector(addButtonIfNeeded) withObject:nil afterDelay:0];
}

- (void)addButtonIfNeeded
{
    if ([self isTextTruncated] == YES) {
        [self addButton];
    }
}

- (void)removeButtonIfNotNeeded
{
    if ([self isTextTruncated] == NO) {
        [self removeButton];
    }
}

- (void)updateExclusionPath
{
    if (CGRectIsEmpty(self.moreButton.frame) == NO) {
        UIBezierPath *buttonPath = [UIBezierPath bezierPathWithRect:self.moreButton.frame];
        self.textView.textContainer.exclusionPaths = @[buttonPath];
    }
}

- (void)addButton {
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    UIButton *button = self.moreButton;
    
    [self addSubview:button];
    CGSize buttonSize = [self.moreButtonText sizeWithAttributes:@{NSFontAttributeName: self.moreButtonFont}];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[button]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(button)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(buttonHeight)]|" options:0 metrics:@{@"buttonHeight": @(buttonSize.height)} views:NSDictionaryOfVariableBindings(button)]];
    
    [self performSelector:@selector(updateExclusionPath) withObject:nil afterDelay:0];
//    [self updateExclusionPath];
}

- (void)removeButton {
    self.textView.textContainer.exclusionPaths = nil;
    
    [self.moreButton removeFromSuperview];
}


- (BOOL)isTextTruncated
{
    NSLayoutManager *layoutManager = self.textView.layoutManager;
    NSTextContainer *textContainer = self.textView.textContainer;
    
    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
    if (glyphRange.length == 0) {
        return NO;
    }
    
    NSUInteger lastGlyph = NSMaxRange(glyphRange) - 1;
    NSRange truncatedRange = [layoutManager truncatedGlyphRangeInLineFragmentForGlyphAtIndex:lastGlyph];
    
    return (truncatedRange.location != NSNotFound);
}

- (UIButton *)moreButton
{
    if (_moreButton == nil) {
        _moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [_moreButton setTitle:self.moreButtonText forState:UIControlStateNormal];
        [_moreButton setTitleColor:self.textColor forState:UIControlStateNormal];
        [_moreButton.titleLabel setFont:self.moreButtonFont];
    }
    
    return _moreButton;
}

- (UITextView *)textView
{
    if (_textView == nil) {
        _textView = [[UITextView alloc] initWithFrame:CGRectInset(self.bounds, kTextViewInset.width, kTextViewInset.height)];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.editable = NO;
        _textView.scrollEnabled = NO;
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _textView.translatesAutoresizingMaskIntoConstraints = YES;
        
        _textView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    
    return _textView;
}


#pragma mark - Getters and setters

- (NSUInteger)maxNumberOfLines
{
    return self.textView.textContainer.maximumNumberOfLines;
}

- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines
{
    self.textView.textContainer.maximumNumberOfLines = maxNumberOfLines;
    [self updateLayout];
}

- (NSString *)text
{
    return self.textView.text;
}

- (void)setText:(NSString *)text
{
    self.textView.text = [text copy];
    [self updateLayout];
}

- (UIFont *)textFont
{
    return self.textView.font;
}

- (void)setTextFont:(UIFont *)textFont
{
    self.textView.font = textFont;
    [self updateLayout];
}

- (UIColor *)textColor
{
    return self.textView.textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.textView.textColor = textColor;
}

- (NSString *)moreButtonText
{
    return [self.moreButton titleForState:UIControlStateNormal];
}

- (void)setMoreButtonText:(NSString *)moreButtonText
{
    [self.moreButton setTitle:[moreButtonText copy] forState:UIControlStateNormal];
    [self updateLayout];
}

- (UIFont *)moreButtonFont
{
    return self.moreButton.titleLabel.font;
}

- (void)setMoreButtonFont:(UIFont *)moreButtonFont
{
    self.moreButton.titleLabel.font = moreButtonFont;
    [self updateLayout];
}

- (UIColor *)moreButtonColor
{
    return [self.moreButton titleColorForState:UIControlStateNormal];
}

- (void)setMoreButtonColor:(UIColor *)moreButtonColor
{
    [self.moreButton setTitleColor:moreButtonColor forState:UIControlStateNormal];
}

@end
