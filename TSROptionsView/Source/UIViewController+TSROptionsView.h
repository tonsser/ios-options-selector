//
//  UIViewController+TSROptionsView.h
//  OptionsTest
//
//  Created by Nicolai Persson on 15/01/15.
//  Copyright (c) 2015 Tonsser. All rights reserved.
//

@import UIKit;

@class TSROptionsView;

@interface UIViewController (TSROptionsView)

- (void)presentOptionsView:(TSROptionsView *)optionsView;
- (void)dismissOptionsView;

@end
