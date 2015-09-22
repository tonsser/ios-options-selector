//
//  TSRTransitionPresentationAnimator.m
//  Pods
//
//  Created by Karlo Kristensen on 22/09/15.
//
//

#import "TSRTransitionPresentationAnimator.h"

@implementation TSRTransitionPresentationAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
//    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    
    toViewController.view.alpha = 0.0;
    [containerView addSubview:toViewController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animationEnded:(BOOL)transitionCompleted {
    
}

@end
