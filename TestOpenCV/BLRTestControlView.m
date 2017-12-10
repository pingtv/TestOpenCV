//
//  BLRTestControlView.m
//  TestOpenCV
//
//  Created by Ping Chen on 12/9/17.
//  Copyright © 2017 Ping Chen. All rights reserved.
//

#import "BLRTestControlView.h"

@implementation BLRTestControlView

- (BLRTestControlView *)init {
    BLRTestControlView *result = nil;
    NSArray* elements = [[NSBundle mainBundle] loadNibNamed: NSStringFromClass([self class]) owner:self options: nil];
    for (id anObject in elements)
    {
        if ([anObject isKindOfClass:[self class]])
        {
            result = anObject;
            break;
        }
    }
    
    [result.gaussianSlider setContinuous:NO];
    [result.thresholdSlider setContinuous:NO];
    [result.thresholdSlider setMaximumValue:kThresholdMax];
    [result.thresholdSlider setMinimumValue:kThresholdMin];
    [result.gaussianSlider setMaximumValue:kBlurDimensionMax];
    [result.gaussianSlider setMinimumValue:kBlurDimensionMin];
    
    
    return result;
}

#pragma mark - UISliderDelegate

- (IBAction)sliderChange:(id)sender {
    int discreteValue = roundl([(UISlider *)sender value]);
    [(UISlider *)sender setValue:(float)discreteValue];
    
    if (sender == self.gaussianSlider) {
        [self.gaussianBlur setText:[NSString stringWithFormat:@"Gaussian Blur: %d", discreteValue]];
    }
    
    if (sender == self.thresholdSlider) {
        [self.threshold setText:[NSString stringWithFormat:@"Threshold: %d", discreteValue]];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField != self.threshold) {
        return YES;
    }
    
    int thres = textField.text.intValue;
    
    if (thres > kThresholdMax || thres < kThresholdMin) {
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    int thres = textField.text.intValue;
    
    if (thres <= kThresholdMax && thres >= kThresholdMin) {
        [self.thresholdSlider setValue:(float)thres];
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
