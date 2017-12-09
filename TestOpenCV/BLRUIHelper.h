//
//  BLRUIHelper.h
//  BallerApp
//
//  Created by Ping Chen on 1/6/17.
//  Copyright © 2017 Baller, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BLRUIHelper : NSObject

+(void)addViews:(NSArray *)views toLeftRightEdgesOfSuperview:(UIView *)superview withGap:(CGFloat)gap;
+(NSArray *)stackViews:(NSArray *)views withGap:(CGFloat)gap;

+(void)addView:(UIView *)view1 toLeftRightEdgesOfSuperview:(UIView *)superview withGap:(CGFloat)gap;
+(NSLayoutConstraint *)constrainView:(UIView *)view1 onTopOfSuperviewWithGap:(CGFloat)gap;
+(NSLayoutConstraint *)constrainView:(UIView *)view1 onBottomOfSuperviewWithGap:(CGFloat)gap;
+(NSLayoutConstraint *)constrainView1:(UIView *)view1 toView2:(UIView *)view2;

@end
