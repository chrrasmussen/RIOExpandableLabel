//
//  ViewController.m
//  RIOExpandableLabelDemo
//
//  Created by Christian Rasmussen on 04.05.13.
//  Copyright (c) 2013 Rasmussen I/O. All rights reserved.
//

#import "ViewController.h"
#import "RIOExpandableLabel.h"


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.expandableLabel.delegate = self;
    NSLog(@"Setting text...");
    self.expandableLabel.text = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi elementum mi et justo venenatis a porttitor felis iaculis. Praesent et nibh velit, eu laoreet urna. Morbi feugiat rhoncus aliquet.";
    NSLog(@"Settings maxNumberOfLines...");
    self.expandableLabel.maxNumberOfLines = 2;
}


#pragma mark - Actions

- (IBAction)changeColorsAndFonts:(id)sender
{
    self.expandableLabel.textColor = [UIColor redColor];
    self.expandableLabel.textFont = [UIFont systemFontOfSize:15];
    self.expandableLabel.moreButtonFont = [UIFont boldSystemFontOfSize:15];
    self.expandableLabel.moreButtonColor = [UIColor blueColor];
}

- (IBAction)changeMaxNumberOfLines:(id)sender
{
    [UIView animateWithDuration:1 animations:^{
        self.expandableLabel.maxNumberOfLines = 5;
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - RIOExpandableLabelDelegate

- (void)expandableLabelDidLayout:(RIOExpandableLabel *)expandableLabel
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.heightConstraint.constant = expandableLabel.displayHeight;
}

- (void)expandableLabelWantsToRevealText:(RIOExpandableLabel *)expandableLabel
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [UIView animateWithDuration:0.3 animations:^{
        self.heightConstraint.constant = expandableLabel.displayHeight;
        [self.view layoutIfNeeded];
    }];
}

@end
