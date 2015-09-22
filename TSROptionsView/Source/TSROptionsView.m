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
#import "TSRPresentationManager.h"

@interface UIViewController (Properties)
@property (nonatomic, readwrite) TSROptionsView *presentingOptionsView;
@end

@interface TSROptionsViewOption : NSObject
@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) UIImage *icon;
@property(nonatomic, assign) BOOL selected;
@property(nonatomic, assign) BOOL disclosureIndicator;
@end

@implementation TSROptionsViewOption
@synthesize title, icon;
@end

@interface TSROptionsView() <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, assign) BOOL didConfigure, isVisible;
@property(nonatomic, assign) NSInteger buttonIndexPressed;

@property(nonatomic, strong) NSMutableArray *options;

@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic, strong) UIButton *cancelButton;

@property(nonatomic, strong) UIColor *textColorFromTint;
@property(nonatomic, strong) TSRPresentationManager *presentationManager;
@end

@implementation TSROptionsView
@synthesize textColor = _textColor;

+ (TSROptionsView *)withTitle:(NSString *)title delegate:(id<TSROptionsViewDelegate>)delegate {
    TSROptionsView *result = [[TSROptionsView alloc] init];
    result.title = title;
    result.delegate = delegate;
    return result;
}

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
    self.presentationManager = [[TSRPresentationManager alloc] init];

    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self.presentationManager;
    
    self.didConfigure = YES;
    self.isVisible    = NO;
    
    self.animationDuration = .35f;
    self.animationDelay    = .1f;
    
    self.startOffsetPercentage = .5f;
    
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

    [self.contentView addSubview:self.tableView];
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.cancelButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.isVisible = YES;
    
    [self reloadData];
    
    self.tableView.contentInset  = UIEdgeInsetsMake(CGRectGetHeight(self.view.bounds) * self.startOffsetPercentage, 0, 50, 0);
    self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentOptionsView:)]) {
        [self.delegate willPresentOptionsView:self];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.frame = self.view.frame;
    }];
    
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
    
    self.tableView.frame         = self.view.bounds;

    self.cancelButton.frame = CGRectMake(0, height - 50.f, width, 50.f);
    
    self.tableView.contentInset  = UIEdgeInsetsMake(height * self.startOffsetPercentage, 0, ((self.cancelButton.hidden) ? 50.f : 100.f), 0);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)cancelButtonPressed:(UIButton *)button {
    self.buttonIndexPressed = 0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(optionsView:willDismissWithButtonIndex:)]) {
        [self.delegate optionsView:self willDismissWithButtonIndex:self.buttonIndexPressed];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
            
            if (option.disclosureIndicator) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            if (option.selected) {
                cell.tintColor     = self.checkmarkColor;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
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
            return [TSROptionsViewCell heightWithText:self.title withImage:nil selected:NO usingFont:self.titleFont maintainingWidth:width];
        }
            
        default: {
            TSROptionsViewOption *option = self.options[indexPath.row];
            
            return [TSROptionsViewCell heightWithText:option.title withImage:option.icon selected:option.selected usingFont:self.choicesFont maintainingWidth:width];
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
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
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
}

#pragma mark - Public methods

- (void)addOptionWithTitle:(NSString *)title {
    [self addOptionWithTitle:title icon:nil disclosureIndicator:NO selected:NO];
}

- (void)addOptionWithTitle:(NSString *)title icon:(UIImage *)icon {
    [self addOptionWithTitle:title icon:icon disclosureIndicator:NO selected:NO];
}

- (void)addOptionWithTitle:(NSString *)title icon:(UIImage *)icon disclosureIndicator:(BOOL)disclosureIndicator {
    [self addOptionWithTitle:title icon:icon disclosureIndicator:disclosureIndicator selected:NO];
}

- (void)addOptionWithTitle:(NSString *)title icon:(UIImage *)icon disclosureIndicator:(BOOL)disclosureIndicator selected:(BOOL)selected {
    TSROptionsViewOption* option = [TSROptionsViewOption new];
    
    option.title               = title;
    option.icon                = icon;
    option.selected            = selected;
    option.disclosureIndicator = disclosureIndicator;
    
    [self.options addObject:option];
    
    if (self.isVisible) {
        [self reloadData];
    }
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

- (void)setStartOffsetPercentage:(CGFloat)startOffsetPercentage {
    if (startOffsetPercentage < .1f) {
        startOffsetPercentage = .1f;
    }
    
    if (startOffsetPercentage > .9f) {
        startOffsetPercentage = .9f;
    }
    
    _startOffsetPercentage = startOffsetPercentage;
}

- (void)setTintColor:(UIColor *)tintColor {
    if (!tintColor) {
        tintColor = [UIColor blackColor];
    }
    
    CGFloat r, g, b, a;
    
    [tintColor getRed:&r green:&g blue:&b alpha:&a];
    
    BOOL isDarkColor = sqrt((r * r * 0.241) + (g * g * 0.691) + (b * b * 0.068)) < 0.42;
    
    if (isDarkColor) {
        self.textColorFromTint = [UIColor whiteColor];
    } else {
        self.textColorFromTint = [UIColor blackColor];
    }
    
    _tintColor = tintColor;
    
    self.view.backgroundColor = self.tintColor;
    
    self.cancelButton.backgroundColor = [UIColor clearColor];
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

- (UIColor *)checkmarkColor {
    if (!_checkmarkColor) {
        return self.textColor;
    } else {
        return _checkmarkColor;
    }
}

- (UIColor *)textColor {
    if (!_textColor) {
        return self.textColorFromTint;
    } else {
        return _textColor;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.tintColor = self.tintColor;
}

@end
