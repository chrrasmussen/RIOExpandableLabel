//
//  ViewController.h
//  RIOExpandableLabelDemo
//
//  Created by Christian Rasmussen on 04.05.13.
//  Copyright (c) 2013 Rasmussen I/O. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIOExpandableLabelDelegate.h"


@interface ViewController : UIViewController <RIOExpandableLabelDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;
@property (nonatomic, weak) IBOutlet RIOExpandableLabel *expandableLabel;

@end
