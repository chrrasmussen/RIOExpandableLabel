//
//  RIOExpandableLabelDelegate.h
//  RIOExpandableLabelDemo
//
//  Created by Christian Rasmussen on 04.05.13.
//  Copyright (c) 2013 Rasmussen I/O. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RIOExpandableLabel;


@protocol RIOExpandableLabelDelegate <NSObject>

- (void)expandableLabelDidLayout:(RIOExpandableLabel *)expandableLabel;
- (void)expandableLabelWantsToRevealText:(RIOExpandableLabel *)expandableLabel;

@end
