//
//  TSROptionsView.h
//  OptionsTest
//
//  Created by Nicolai Persson on 15/01/15.
//  Copyright (c) 2015 Tonsser. All rights reserved.
//

@import UIKit;

#import "UIViewController+TSROptionsView.h"

@protocol TSROptionsViewDelegate;

@interface TSROptionsView : UIViewController
+ (TSROptionsView *)withTitle:(NSString *)title delegate:(id<TSROptionsViewDelegate>)delegate otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

+ (TSROptionsView *)withTitle:(NSString *)title delegate:(id<TSROptionsViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)addOptionWithTitle:(NSString *)title;
- (void)addOptionWithTitle:(NSString *)title icon:(UIImage *)icon;
- (void)addOptionWithTitle:(NSString *)title icon:(UIImage *)icon selected:(BOOL)selected;

- (NSString *)titleForButtonWithIndex:(NSInteger)index;

@property(nonatomic, weak) id<TSROptionsViewDelegate> delegate;
@property(nonatomic, readwrite) NSString *cancelButtonTitle;
@property(nonatomic, strong) UIColor *textColor, *tintColor, *checkmarkColor;
@property(nonatomic, strong) UIFont *titleFont;
@property(nonatomic, strong) UIFont *choicesFont;
@property(nonatomic, assign) CGFloat tintColorAlphaModifier, animationDuration, animationDelay, startOffsetPercentage;
@end

@protocol TSROptionsViewDelegate <NSObject>
@optional
- (void)willPresentOptionsView:(TSROptionsView *)optionsView;
- (void)didPresentOptionsView:(TSROptionsView *)optionsView;
- (void)optionsView:(TSROptionsView *)optionsView willDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)optionsView:(TSROptionsView *)optionsView didDismissWithButtonIndex:(NSInteger)buttonIndex;
@end