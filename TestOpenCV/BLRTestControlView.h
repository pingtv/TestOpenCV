//
//  BLRTestControlView.h
//  TestOpenCV
//
//  Created by Ping Chen on 12/9/17.
//  Copyright © 2017 Ping Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

const int kThresholdMin = 5;
const int kThresholdMax = 75;
const int kBlurDimensionMin = 1;
const int kBlurDimensionMax = 25;
const int kAccAlphaMin = 0.01;
const int kAccAlphaMax = 1;


@interface BLRTestControlView : UIView <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UILabel *gaussianBlur;
@property (weak, nonatomic) IBOutlet UITextField *threshold;
@property (weak, nonatomic) IBOutlet UITextField *accumulateAlpha;

@property (weak, nonatomic) IBOutlet UISlider *gaussianSlider;
@property (weak, nonatomic) IBOutlet UISlider *thresholdSlider;
@property (weak, nonatomic) IBOutlet UISlider *alphaSlider;

@end
