//
//  TSRPresentationManager.m
//  Pods
//
//  Created by Karlo Kristensen on 22/09/15.
//
//

#import "TSRPresentationManager.h"
#import "TSRTransitionDismissingAnimator.h"
#import "TSRTransitionPresentationAnimator.h"
#import "TSROptionViewPresentationController.h"

@implementation TSRPresentationManager

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return [[TSRTransitionPresentationAnimator alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[TSRTransitionDismissingAnimator alloc] init];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source {

    TSROptionViewPresentationController *optionsPresenter = [[TSROptionViewPresentationController alloc] initWithPresentedViewController:presented presentingViewController:source];
    return optionsPresenter;
}

@end
