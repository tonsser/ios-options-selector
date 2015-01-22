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
    self.previewView.backgroundColor = [UIColor colorWithRed:self.redSlider.value green:self.greenSlider.value blue:self.blueSlider.value alpha:1.f];
}

- (IBAction)previewPressed:(id)sender {
    TSROptionsView *optionsView = [TSROptionsView withTitle:@"Will it blend?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", @"No", @"Maybe", nil];
    
    optionsView.tintColor = self.previewView.backgroundColor;
    
    [self presentOptionsView:optionsView];
}

#pragma mark - TSROptionsViewDelegate

- (void)optionsView:(TSROptionsView *)optionsView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSString *title = [optionsView titleForButtonWithIndex:buttonIndex];
    
    [[[UIAlertView alloc] initWithTitle:@"Dismissed!" message:[NSString stringWithFormat:@"You chose '%@'", title, nil] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

@end
