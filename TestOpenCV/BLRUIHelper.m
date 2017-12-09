//
//  BLRUIHelper.m
//  BallerApp
//
//  Created by Ping Chen on 1/6/17.
//  Copyright © 2017 Baller, Inc. All rights reserved.
//

#import "BLRUIHelper.h"

@implementation BLRUIHelper

+(void)addViews:(NSArray *)views toLeftRightEdgesOfSuperview:(UIView *)superview withGap:(CGFloat)gap {
    for (id Obj in views) {
        if (![Obj isKindOfClass:[UIView class]]) {
            continue;
        }
        
        UIView *view = (UIView *)Obj;
        [BLRUIHelper addView:view toLeftRightEdgesOfSuperview:superview withGap:gap];
    }
}

// stack views in the NSArray in order from top to bottom. index 0 is top most view
+(NSArray *)stackViews:(NSArray *)views withGap:(CGFloat)gap {
    NSMutableArray *verticalConstraints = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < views.count; i++) {
        
        // find the first view
        id Obj1 = views[i];
        if (![Obj1 isKindOfClass:[UIView class]]) {
            continue;
        }
        UIView *view1 = (UIView *)Obj1;
        
        // for very first view, constrain to top of superview
        if (i == 0) {
            NSLayoutConstraint *c = [BLRUIHelper constrainView:view1 onTopOfSuperviewWithGap:0];
            [verticalConstraints addObject:c];
        }
        
        // find the second view
        UIView *view2;
        for (int j = i + 1; j < views.count; j++) {
            id Obj2 = views[j];
            if (![Obj2 isKindOfClass:[UIView class]]) {
                continue;
            }
            if (Obj2) {
                view2 = (UIView *)Obj2;
                break;
            }
        }
        
        // couldn't find 2nd view meaning this is last view
        if (!view2) {
            NSLog(@"couldn't find 2nd view to stack");
            NSLayoutConstraint *c = [BLRUIHelper constrainView:view1 onBottomOfSuperviewWithGap:0];
            [verticalConstraints addObject:c];
            
        } else {
        
            [verticalConstraints addObject:[BLRUIHelper stackView:view1 onTopOfView:view2 withGap:gap]];
        }
    }
    
    return verticalConstraints;
}

+(void)addView:(UIView *)view1 toLeftRightEdgesOfSuperview:(UIView *)superview withGap:(CGFloat)gap {
    [superview addSubview:view1];
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:view1
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:superview
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1
                                                                          constant:gap];
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:view1
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:superview
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1
                                                                           constant:-gap];
    [superview addConstraints:@[leadingConstraint, trailingConstraint]];
}

+(NSLayoutConstraint *)stackView:(UIView *)view1 onTopOfView:(UIView *)view2 withGap:(CGFloat)gap {
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view1
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:view2
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1
                                                                         constant:gap];
    [view1.superview addConstraint:bottomConstraint];
    return bottomConstraint;
}

+(NSLayoutConstraint *)constrainView:(UIView *)view1 onTopOfSuperviewWithGap:(CGFloat)gap {
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:view1
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:view1.superview
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1
                                                                         constant:gap];
    [view1.superview addConstraint:topConstraint];
    return topConstraint;
}

+(NSLayoutConstraint *)constrainView:(UIView *)view1 onBottomOfSuperviewWithGap:(CGFloat)gap {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view1
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:view1.superview
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:gap];
    [view1.superview addConstraint:constraint];
    return constraint;
}

// make sure view1 and view2 are both subviews of the same superview
+(NSLayoutConstraint *)constrainView1:(UIView *)view1 toView2:(UIView *)view2 {
    if (view1.superview != view2.superview) {
        return nil;
    }
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:view1
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:view2
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:0];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view1
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:view2
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:0];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:view1
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:view2
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1
                                                                         constant:0];
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:view1
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:view2
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1
                                                                         constant:0];
    
    [view1.superview addConstraints:@[topConstraint, bottomConstraint, leftConstraint, rightConstraint]];
    return topConstraint;
}

@end
