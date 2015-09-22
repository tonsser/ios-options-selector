//
//  TSROptionViewPresentationController.m
//  Pods
//
//  Created by Karlo Kristensen on 22/09/15.
//
//

#import "TSROptionViewPresentationController.h"

@interface TSROptionViewPresentationController()
@property(nonatomic, strong) UIView *dimmingView;
@property(nonatomic, strong) UIVisualEffectView *blurEffectView;
@end

@implementation TSROptionViewPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        [self setupDimmingView];
    }
    
    return self;
}


- (void) setupDimmingView {
    self.dimmingView = [[UIView alloc] initWithFrame:self.presentingViewController.view.bounds];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    [self.dimmingView addSubview:self.blurEffectView];

}

- (void)presentationTransitionWillBegin {
    
    self.dimmingView.alpha = 0.0;
    self.dimmingView.frame = self.containerView.bounds;
    self.blurEffectView.frame = self.containerView.bounds;
    [self.containerView addSubview:self.dimmingView];
    
    
    [[self.presentingViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 1.0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.frame = self.containerView.bounds;
        self.blurEffectView.frame = self.containerView.bounds;
    }];
}

- (void)dismissalTransitionWillBegin {
    [[self.presentedViewController transitionCoordinator] animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.dimmingView.alpha = 0.0;
    } completion:nil];
}

@end
