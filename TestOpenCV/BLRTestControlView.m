//
//  BLRTestControlView.m
//  TestOpenCV
//
//  Created by Ping Chen on 12/9/17.
//  Copyright © 2017 Ping Chen. All rights reserved.
//

#import "BLRTestControlView.h"

@implementation BLRTestControlView

- (void)commonSetup {
    [self addSubview:self.inputView];
    
    [self.gaussianSlider setContinuous:NO];
    [self.thresholdSlider setContinuous:NO];
    [self.alphaSlider setContinuous:NO];
    [self.thresholdSlider setMaximumValue:kThresholdMax];
    [self.thresholdSlider setMinimumValue:kThresholdMin];
    [self.gaussianSlider setMaximumValue:kBlurDimensionMax];
    [self.gaussianSlider setMinimumValue:kBlurDimensionMin];
    [self.alphaSlider setMaximumValue:logf(kAccAlphaMax)];
    [self.alphaSlider setMinimumValue:logf(kAccAlphaMin)];
    
    [self.accumulateAlpha setDelegate:self];
    [self.threshold setDelegate:self];
    
}

- (id)initWithFrame:(CGRect)frame {
    
    if ((self = [super initWithFrame:frame])) {
        self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] lastObject];
        [self commonSetup];
    }
    return self;
}



#pragma mark - UISliderDelegate

- (IBAction)sliderChange:(id)sender {
    
    
    if (sender == self.gaussianSlider) {
        int discreteValue = roundl([(UISlider *)sender value]);
        [(UISlider *)sender setValue:(float)discreteValue];
        
        [self.gaussianBlur setText:[NSString stringWithFormat:@"Gaussian Blur: %d", discreteValue]];
    }
    
    if (sender == self.thresholdSlider) {
        int discreteValue = roundl([(UISlider *)sender value]);
        [(UISlider *)sender setValue:(float)discreteValue];
        
        [self.threshold setText:[NSString stringWithFormat:@"Threshold: %d", discreteValue]];
    }
    
    if (sender == self.alphaSlider) {
        float logValue = powf(10.0, self.alphaSlider.value);
        
        [self.accumulateAlpha setText:[NSString stringWithFormat:@"Alpha: %.2f", logValue]];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.threshold) {
        int thres = textField.text.intValue;
        
        if (thres > kThresholdMax || thres < kThresholdMin) {
            return NO;
        }
    }
    
    if (textField == self.accumulateAlpha) {
        float alphaValue = textField.text.floatValue;
        
        if (alphaValue > kAccAlphaMax || alphaValue < kAccAlphaMin) {
            return NO;
        }
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.threshold) {
        int thres = textField.text.intValue;
        
        if (thres <= kThresholdMax && thres >= kThresholdMin) {
            [self.thresholdSlider setValue:(float)thres];
        }
    }
    
    if (textField == self.accumulateAlpha) {
        float alphaValue = textField.text.floatValue;
        
        if (alphaValue <= kAccAlphaMax || alphaValue >= kAccAlphaMin) {
            
            [self.alphaSlider setValue:logf(alphaValue)];
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
