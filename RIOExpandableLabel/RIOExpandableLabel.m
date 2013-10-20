//
//  RIOExpandableLabel.m
//  RIOExpandableLabelDemo
//
//  Created by Christian Rasmussen on 04.05.13.
//  Copyright (c) 2013 Rasmussen I/O. All rights reserved.
//

#import "RIOExpandableLabel.h"
#import "RIOExpandableLabelDelegate.h"


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

- (void)setMaxNumberOfLines:(NSUInteger)maxNumberOfLines
{
    _maxNumberOfLines = maxNumberOfLines;
    self.textView.textContainer.maximumNumberOfLines = maxNumberOfLines;
    [self updateLayout];
}

- (void)setText:(NSString *)text
{
    _text = [text copy];
    self.textView.text = _text;
    [self updateLayout];
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    self.textView.font = textFont;
    [self updateLayout];
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.textView.textColor = textColor;
}

- (void)setMoreButtonText:(NSString *)moreButtonText
{
    _moreButtonText = [moreButtonText copy];
    [self.moreButton setTitle:_moreButtonText forState:UIControlStateNormal];
    [self updateLayout];
}

- (void)setMoreButtonFont:(UIFont *)moreButtonFont
{
    _moreButtonFont = moreButtonFont;
    [self.moreButton.titleLabel setFont:moreButtonFont];
    [self updateLayout];
}

- (void)setMoreButtonColor:(UIColor *)moreButtonColor
{
    _moreButtonColor = moreButtonColor;
    [self.moreButton setTitleColor:moreButtonColor forState:UIControlStateNormal];
}


#pragma mark - Private methods

- (void)setUpView
{
    // Default settings
    _maxNumberOfLines = 4;
    
    _textFont = [UIFont systemFontOfSize:17];
    _textColor = [UIColor blackColor];
    
    _moreButtonText = @"More ▼";
    _moreButtonFont = [UIFont boldSystemFontOfSize:17];
    _moreButtonColor = [UIColor blackColor];
    
    [self setUpTextView];
}

- (void)setUpTextView
{
    // Set up dimensions
    self.textView = [[UITextView alloc] initWithFrame:CGRectInset(self.bounds, kTextViewInset.width, kTextViewInset.height)];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.editable = NO;
    self.textView.scrollEnabled = NO;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.translatesAutoresizingMaskIntoConstraints = YES;
    
    // Set up text container
    NSTextContainer *textContainer = self.textView.textContainer;
    textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    
    // Set styles
    self.textView.font = self.textFont;
    self.textView.textColor = self.textColor;
    
    [self addSubview:self.textView];
}

- (void)revealText
{
    [self removeButton];
    self.textView.textContainer.maximumNumberOfLines = 0;
    
    [self.delegate expandableLabelWantsToRevealText:self];
}

- (void)updateLayout
{
    [self removeButton];
    
    if (self.bounds.size.height != [self displayHeight]) {
        [self.delegate expandableLabelDidLayout:self];
    }
    
    [self addButtonIfNeeded];
}

- (void)addButtonIfNeeded
{
    BOOL shouldAddButton = ([self isTextTruncated] == YES && self.moreButton == nil);
    if (shouldAddButton) {
        [self addButton];
    }
    
    [self performSelector:@selector(updateExclusionPath) withObject:nil afterDelay:0];
}

- (void)updateExclusionPath
{
    if (self.moreButton != nil && CGRectIsEmpty(self.moreButton.frame) == NO) {
        UIBezierPath *buttonPath = [UIBezierPath bezierPathWithRect:self.moreButton.frame];
        self.textView.textContainer.exclusionPaths = @[buttonPath];
    }
}

- (void)addButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(revealText) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:self.moreButtonText forState:UIControlStateNormal];
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button.titleLabel setFont:self.moreButtonFont];
    
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:button];
    CGSize buttonSize = [self.moreButtonText sizeWithAttributes:@{NSFontAttributeName: self.moreButtonFont}];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[button]|" options:NSLayoutFormatDirectionLeadingToTrailing metrics:nil views:NSDictionaryOfVariableBindings(button)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(buttonHeight)]|" options:0 metrics:@{@"buttonHeight": @(buttonSize.height)} views:NSDictionaryOfVariableBindings(button)]];
    
    self.moreButton = button;
}

- (void)removeButton {
    self.textView.textContainer.exclusionPaths = nil;
    
    [self.moreButton removeFromSuperview];
    
    self.moreButton = nil;
}

- (CGFloat)displayHeight
{
    CGSize sizeThatFits = [self.textView sizeThatFits:CGSizeMake(self.textView.bounds.size.width, CGFLOAT_MAX)];
    return ceilf(sizeThatFits.height + 2 * kTextViewInset.height);
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

@end
