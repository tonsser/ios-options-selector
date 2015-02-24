//
//  UIViewController+TSROptionsView.m
//  OptionsTest
//
//  Created by Nicolai Persson on 15/01/15.
//  Copyright (c) 2015 Tonsser. All rights reserved.
//

@import QuartzCore;

#import <objc/runtime.h>

#import "UIViewController+TSROptionsView.h"
#import "TSROptionsView.h"

@interface TSROptionsView (Forwarded)
@property(nonatomic, strong) UIViewController *openerViewController;
@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, readwrite) UIImage *snapshotImage;
@end

@interface UIViewController (Properties)
@property (nonatomic, readwrite) TSROptionsView *presentingOptionsView;
@end

@implementation UIViewController (TSROptionsView)

- (TSROptionsView *)presentingOptionsView {
    return objc_getAssociatedObject(self, @selector(presentingOptionsView));
}

- (void)setPresentingOptionsView:(TSROptionsView *)presentingOptionsView {
    objc_setAssociatedObject(self, @selector(presentingOptionsView), presentingOptionsView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)presentOptionsView:(TSROptionsView *)optionsView {
    UIWindow *window = [[[UIApplication sharedApplication] windows] firstObject];
    
    if (window) {
        UIGraphicsBeginImageContextWithOptions(window.rootViewController.view.frame.size, NO, window.screen.scale); {
            [window.rootViewController.view drawViewHierarchyInRect:window.rootViewController.view.frame afterScreenUpdates:NO];
            
            optionsView.snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        } UIGraphicsEndImageContext();
        
        
        self.presentingOptionsView = optionsView;
        optionsView.openerViewController = self;
        
        CGFloat height = CGRectGetHeight(window.rootViewController.view.frame), width = CGRectGetWidth(window.rootViewController.view.frame);
        
        optionsView.view.frame = CGRectMake(0, 0, width, height);
        optionsView.contentView.frame = CGRectMake(0, height, width, 0);
        optionsView.view.alpha = 0.f;
        
        [window.rootViewController.view insertSubview:optionsView.view atIndex:NSIntegerMax];
        
        [optionsView viewWillAppear:YES];
        
        CGFloat duration = optionsView.animationDuration, delay = optionsView.animationDelay;
        
        [UIView animateWithDuration:duration*1.4f animations:^{
            optionsView.view.alpha = 1.f;
        }];
        
        [UIView animateWithDuration:duration*1.4f delay:delay*2.f options:UIViewAnimationOptionShowHideTransitionViews animations:^{
            optionsView.contentView.frame = CGRectMake(0, 0, width, height);
        } completion:^(BOOL finished) {
            [optionsView viewDidAppear:YES];
        }];
    }
}

- (void)dismissOptionsView {
    TSROptionsView *optionsView = self.presentingOptionsView;
    UIWindow *window            = [[[UIApplication sharedApplication] windows] firstObject];
    
    if (window && optionsView) {
        self.presentingOptionsView = nil;
        
        optionsView.view.userInteractionEnabled = NO;
        
        CGFloat height = CGRectGetHeight(window.rootViewController.view.frame), width = CGRectGetWidth(window.rootViewController.view.frame);
        
        [window.rootViewController.view insertSubview:optionsView.view atIndex:NSIntegerMax];
        
        [optionsView viewWillDisappear:YES];
        
        CGFloat duration = optionsView.animationDuration, delay = optionsView.animationDelay;
        
        [UIView animateWithDuration:duration animations:^{
            optionsView.view.alpha = 0.f;
        }];
        
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionShowHideTransitionViews animations:^{
            optionsView.contentView.frame = CGRectMake(0, height, width, 0);
        } completion:^(BOOL finished) {
            [optionsView.view removeFromSuperview];
            [optionsView removeFromParentViewController];
        }];
    }
}

@end
