//
//  ViewController.m
//  TSROptionsViewExample
//
//  Created by Nicolai Persson on 22/01/15.
//  Copyright (c) 2015 Tonsser. All rights reserved.
//

#import "ViewController.h"

#import <TSROptionsView/TSROptionsView.h>

@interface ViewController() <TSROptionsViewDelegate>
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self sliderValueChanged:nil];
}

- (IBAction)sliderValueChanged:(id)sender {
    self.previewView.backgroundColor = [UIColor colorWithRed:self.redSlider.value / 255.f green:self.greenSlider.value / 255.f blue:self.blueSlider.value / 255.f alpha:1.f];
}

- (IBAction)previewPressed:(id)sender {
    TSROptionsView *optionsView = [TSROptionsView withTitle:@"Will it blend?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", @"No", @"Maybe", nil];
    
    optionsView.tintColor = self.previewView.backgroundColor;
    optionsView.animationDuration     = .20f;
    optionsView.animationDelay        = .15f;
    optionsView.startOffsetPercentage = 0.f;
    
    [optionsView addOptionWithTitle:@"test" icon:nil disclosureIndicator:nil selected:YES];
    [self presentViewController:optionsView animated:YES completion:nil];
}

#pragma mark - TSROptionsViewDelegate

- (void)optionsView:(TSROptionsView *)optionsView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *title = [optionsView titleForButtonWithIndex:buttonIndex];
    
    [[[UIAlertView alloc] initWithTitle:@"Dismissed!" message:[NSString stringWithFormat:@"You chose '%@'", title, nil] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

@end
