//
//  TSROptionsView.m
//  OptionsTest
//
//  Created by Nicolai Persson on 15/01/15.
//  Copyright (c) 2015 Tonsser. All rights reserved.
//

#import "TSROptionsView.h"
#import "UIImage+ImageEffects.h"
#import "TSROptionsViewCell.h"

@interface UIViewController (Properties)
@property (nonatomic, readwrite) TSROptionsView *presentingOptionsView;
@end

@interface TSROptionsViewOption : NSObject
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) UIImage *icon;
@end

@implementation TSROptionsViewOption
@synthesize title, icon;
@end

@interface TSROptionsView() <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, assign) BOOL didConfigure, isVisible;
@property(nonatomic, assign) NSInteger buttonIndexPressed;

@property(nonatomic, strong) NSMutableArray *options;

@property(nonatomic, strong) UIViewController *openerViewController;
@property(nonatomic, strong) UIImage *snapshotImage;

@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) CAGradientLayer *gradientTop, *gradientBottom;
@property(nonatomic, strong) UIImageView *snapshotImageView, *blurredImageView;

@property(nonatomic, strong) UIColor *textColor;
@end

@implementation TSROptionsView
@synthesize snapshotImage = _snapshotImage;

+ (TSROptionsView *)withTitle:(NSString *)title delegate:(id<TSROptionsViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    TSROptionsView *result = [[TSROptionsView alloc] init];
    
    result.title    = title;
    result.delegate = delegate;
    result.cancelButtonTitle = cancelButtonTitle;
    
    va_list titles;
    va_start(titles, otherButtonTitles);
    
    for (NSString *otherButtonTitle = otherButtonTitles; otherButtonTitle != nil; otherButtonTitle = va_arg(titles, NSString *)) {
        if (![otherButtonTitle isEqualToString:@""]) {
            [result addOptionWithTitle:otherButtonTitle];
        }
    }
    
    va_end(titles);
    
    return result;
}

+ (TSROptionsView *)withTitle:(NSString *)title delegate:(id<TSROptionsViewDelegate>)delegate otherButtonTitles:(NSString *)otherButtonTitles, ... {
    TSROptionsView *result = [[TSROptionsView alloc] init];
    
    result.title    = title;
    result.delegate = delegate;
    
    va_list args;
    va_start(args, otherButtonTitles);
    for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString *)) {
        if (arg && ![arg isEqualToString:@""]) {
            [result addOptionWithTitle:arg];
        }
    }
    va_end(args);
    
    return result;
}

#pragma mark - Lifecycle

- (void)configure {
    if (self.didConfigure) {
        return;
    }
    
    self.didConfigure = YES;
    self.isVisible    = NO;
    
    self.gradientTop = [CAGradientLayer layer];
    self.gradientTop.locations = @[[NSNumber numberWithFloat:.3f], [NSNumber numberWithFloat:1.f]];
    
    self.gradientBottom = [CAGradientLayer layer];
    self.gradientBottom.locations = @[@(0.0f), @(1.0f)];
    
    self.options           = [NSMutableArray new];
    self.cancelButtonTitle = nil;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque          = NO;
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator   = NO;
    
    self.snapshotImageView = [[UIImageView alloc] init];
    self.snapshotImageView.backgroundColor = [UIColor clearColor];
    
    self.blurredImageView  = [[UIImageView alloc] init];
    self.blurredImageView.backgroundColor = [UIColor clearColor];
    
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.hidden = YES;
    [self.cancelButton addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tableView registerClass:[TSROptionsViewCell class] forCellReuseIdentifier:TSROptionsViewCellIdentifier];
    
    self.titleFont = nil;
    self.choicesFont = nil;
    
    self.tintColor = [UIColor blackColor];
    self.tintColorAlphaModifier = 0.85f;
}

- (instancetype)init {
    if (self = [super init]) {
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self configure];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self configure];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.snapshotImageView];
    [self.view addSubview:self.blurredImageView];
    
    [self.contentView addSubview:self.tableView];
    
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.cancelButton];
    
    [self.view.layer addSublayer:self.gradientTop];
    [self.view.layer addSublayer:self.gradientBottom];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.isVisible = YES;
    
    [self reloadData];
    
    self.tableView.contentInset  = UIEdgeInsetsMake(CGRectGetHeight(self.view.bounds) * 0.5, 0, 50, 0);
    self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentOptionsView:)]) {
        [self.delegate willPresentOptionsView:self];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentOptionsView:)]) {
        [self.delegate didPresentOptionsView:self];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.isVisible = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(optionsView:didDismissWithButtonIndex:)]) {
        [self.delegate optionsView:self didDismissWithButtonIndex:self.buttonIndexPressed];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds), height = CGRectGetHeight(self.view.bounds);
    
    self.snapshotImageView.frame = self.view.bounds;
    self.blurredImageView.frame  = self.view.bounds;
    self.tableView.frame         = self.view.bounds;
    
    self.cancelButton.frame = CGRectMake(0, height - 50.f, width, 50.f);
    
    self.tableView.contentInset  = UIEdgeInsetsMake(height * 0.5, 0, ((self.cancelButton.hidden) ? 50.f : 100.f), 0);
    
    self.gradientTop.frame       = CGRectMake(0, 0, width, 50.f);
    self.gradientBottom.frame    = CGRectMake(0, height - ((self.cancelButton.hidden) ? 50.f : 100.f), width, 50.f);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)cancelButtonPressed:(UIButton *)button {
    self.buttonIndexPressed = 0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(optionsView:willDismissWithButtonIndex:)]) {
        [self.delegate optionsView:self willDismissWithButtonIndex:self.buttonIndexPressed];
    }
    
    [self.openerViewController dismissOptionsView];
}

#pragma mark - Methods

- (void)reloadData {
    if (!self.isVisible)
        return;
    
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; // 0 == Title, 1 == Options
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return (self.title) ? 1 : 0;
            
        default:
            return self.options.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TSROptionsViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TSROptionsViewCellIdentifier];
    
    cell.textLabel.numberOfLines = 0;
    
    switch (indexPath.section) {
        case 0: {
            cell.textLabel.text = self.title;
            cell.textLabel.font = self.titleFont;
            cell.userInteractionEnabled = NO;
            break;
        }
            
        default: {
            TSROptionsViewOption *option = self.options[indexPath.row];
            
            cell.textLabel.text  = option.title;
            cell.imageView.image = option.icon;
            cell.textLabel.font  = self.choicesFont;
            cell.showsSeparator  = YES;
            
            break;
        }
    }
    
    if (cell.imageView.image && (cell.imageView.image.size.width > 40.f || cell.imageView.image.size.height > 40.f)) {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        cell.imageView.contentMode = UIViewContentModeCenter;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor     = [UIColor clearColor];
    cell.textLabel.textColor = (indexPath.section != 0) ? [self.textColor colorWithAlphaComponent:.75f] : self.textColor;
    
    cell.selectedBackgroundView = [UIView new];
    cell.selectedBackgroundView.backgroundColor = [self.textColor colorWithAlphaComponent:.1f];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = CGRectGetWidth(self.tableView.bounds);
    
    switch (indexPath.section) {
        case 0: {
            return [TSROptionsViewCell heightWithText:self.title withImage:nil usingFont:self.titleFont maintainingWidth:width];
        }
            
        default: {
            TSROptionsViewOption *option = self.options[indexPath.row];
            
            return [TSROptionsViewCell heightWithText:option.title withImage:option.icon usingFont:self.choicesFont maintainingWidth:width];
        }
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.userInteractionEnabled = NO;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.buttonIndexPressed = indexPath.row + 1;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(optionsView:willDismissWithButtonIndex:)]) {
        [self.delegate optionsView:self willDismissWithButtonIndex:self.buttonIndexPressed];
    }
    
    [self.openerViewController dismissOptionsView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y + scrollView.contentInset.top;
    
    CGFloat alpha = 1.f;
    
    if (offsetY < 0.f) {
        alpha = 1.f - (1.f / (CGRectGetHeight(self.view.bounds) * .25f) * ABS(offsetY));
        
        if (alpha < 0.f) {
            alpha = 0.f;
        } else if (alpha > 1.f) {
            alpha = 1.f;
        }
    }
    
    self.blurredImageView.alpha = alpha;
}

#pragma mark - Public methods

- (void)addOptionWithTitle:(NSString *)title {
    TSROptionsViewOption* option = [TSROptionsViewOption new];
    
    option.title = title;
    
    [self.options addObject:option];
    [self reloadData];
}

- (void)addOptionWithTitle:(NSString *)title icon:(UIImage *)icon {
    TSROptionsViewOption* option = [TSROptionsViewOption new];
    
    option.title = title;
    option.icon  = icon;
    
    [self.options addObject:option];
    [self reloadData];
}

- (NSString *)titleForButtonWithIndex:(NSInteger)index {
    if (index == 0) {
        return self.cancelButtonTitle;
    } else {
        index--;
        
        if (index >= 0 && index < self.options.count) {
            TSROptionsViewOption *option = self.options[index];
            return option.title;
        }
    }
    
    return nil;
}

#pragma mark - Properties

- (void)setTintColor:(UIColor *)tintColor {
    if (!tintColor) {
        tintColor = [UIColor blackColor];
    }
    
    CGFloat r, g, b, a;
    
    [tintColor getRed:&r green:&g blue:&b alpha:&a];
    
    BOOL isDarkColor = sqrt((r * r * 0.241) + (g * g * 0.691) + (b * b * 0.068)) < 0.42;
    
    if (isDarkColor) {
        self.textColor = [UIColor whiteColor];
    } else {
        self.textColor = [UIColor blackColor];
    }
    
    _tintColor = tintColor;
    
    self.view.backgroundColor = self.tintColor;
    
    CGColorRef tintColorOne = self.view.backgroundColor.CGColor;
    CGColorRef tintColorTwo = [self.view.backgroundColor colorWithAlphaComponent:0.f].CGColor;
    
    self.gradientTop.colors    = @[(__bridge id)tintColorOne, (__bridge id)tintColorTwo];
    self.gradientBottom.colors = @[(__bridge id)tintColorTwo, (__bridge id)tintColorOne];
    
    self.snapshotImage = self.snapshotImage; // Regenerate the blurred image
    
    self.cancelButton.backgroundColor = self.view.backgroundColor;
    [self.cancelButton setTitleColor:self.textColor forState:UIControlStateNormal];
    
    if (self.isVisible) {
        [self reloadData];
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    if (!titleFont) {
        titleFont = [UIFont boldSystemFontOfSize:17.f];
    }
    
    _titleFont = titleFont;
    
    if (self.isVisible) {
        [self reloadData];
    }
    
}

- (void)setChoicesFont:(UIFont *)choicesFont {
    if (!choicesFont) {
        choicesFont = [UIFont systemFontOfSize:17.f];
    }
    
    _choicesFont = choicesFont;
    
    [self.cancelButton.titleLabel setFont:choicesFont];
    
    if (self.isVisible) {
        [self reloadData];
    }
}

- (NSString *)cancelButtonTitle {
    return self.cancelButton.titleLabel.text;
}

- (void)setCancelButtonTitle:(NSString *)cancelButtonTitle {
    if (cancelButtonTitle && [cancelButtonTitle isEqualToString:@""]) {
        cancelButtonTitle = nil;
    }
    
    self.cancelButton.hidden = cancelButtonTitle == nil;
    [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    
    [self reloadData];
}

- (UIImage *)snapshotImage {
    return _snapshotImage;
}

- (void)setSnapshotImage:(UIImage *)snapshotImage {
    _snapshotImage = snapshotImage;
    
    self.snapshotImageView.image = snapshotImage;
    
    if (self.snapshotImageView.image) {
        UIColor *tintColor = [self.tintColor colorWithAlphaComponent:self.tintColorAlphaModifier];
        
        self.blurredImageView.image = [snapshotImage applyBlurWithRadius:30.f
                                                               tintColor:tintColor
                                                   saturationDeltaFactor:1.8f
                                                               maskImage:nil];
        
        self.snapshotImageView.image = [snapshotImage applyBlurWithRadius:0.f
                                                                tintColor:tintColor
                                                    saturationDeltaFactor:1.8f
                                                                maskImage:nil];
    }
}

@end