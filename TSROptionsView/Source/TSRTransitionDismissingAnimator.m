//
//  TSRTransitionDismissingAnimator.m
//  Pods
//
//  Created by Karlo Kristensen on 22/09/15.
//
//

#import "TSRTransitionDismissingAnimator.h"

@implementation TSRTransitionDismissingAnimator

- (void)animationEnded:(BOOL)transitionCompleted {
    
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
//    UIView *containerView = [transitionContext containerView];
    
    fromViewController.view.alpha = 1.0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [fromViewController.view removeFromSuperview];
        [transitionContext completeTransition:finished];
    }];

}

@end
