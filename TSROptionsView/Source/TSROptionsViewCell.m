//
//  TSROptionsViewCell.m
//  OptionsTest
//
//  Created by Nicolai Persson on 22/01/15.
//  Copyright (c) 2015 Tonsser. All rights reserved.
//

#import "TSROptionsViewCell.h"

NSString *TSROptionsViewCellIdentifier = @"TSROptionsViewCellIdentifier";

static CGFloat TSROptionsViewCellSidePadding  = 16.f;
static CGFloat TSROptionsViewCellImageSpacing = 10.f;

@interface TSROptionsViewCell()
@property(nonatomic, strong) UIView *separator;
@property(nonatomic, assign) BOOL didConfigure;
@end

@implementation TSROptionsViewCell

+ (CGFloat)heightWithText:(NSString *)text withImage:(UIImage *)image selected:(BOOL)selected usingFont:(UIFont *)font maintainingWidth:(CGFloat)width {
    if (!font) {
        font = [UIFont systemFontOfSize:17.f];
    }
    
    if (!text) {
        text = @"";
    }
    
    CGFloat height = [text boundingRectWithSize:CGSizeMake(width - TSROptionsViewCellSidePadding * 2 - ((image != nil) ? TSROptionsViewCellImageSpacing : 0.f) - ((selected) ? 44.f : 0.f), CGFLOAT_MAX)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName: font}
                                        context:nil].size.height + TSROptionsViewCellSidePadding * 2 /* 2x 8px padding */;
    
    return height;
}

- (void)configure {
    if (self.didConfigure) {
        return;
    }
    
    self.didConfigure = YES;
    
    self.textLabel.font = [UIFont systemFontOfSize:17.f];
    self.separator = [UIView new];
    self.separator.hidden = YES;
    [self addSubview:self.separator];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configure];
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect labelRect = CGRectInset(self.contentView.bounds, TSROptionsViewCellSidePadding, 0.f);
    
    self.imageView.hidden = !self.imageView.image;
    
    if (!self.imageView.hidden) {
        self.imageView.frame = CGRectMake(TSROptionsViewCellSidePadding, TSROptionsViewCellSidePadding, 40.f, 40.f);
        
        labelRect.origin.x   += CGRectGetMaxX(self.imageView.frame) + TSROptionsViewCellImageSpacing;
        labelRect.size.width -= CGRectGetMaxX(self.imageView.frame) + TSROptionsViewCellImageSpacing;
    } else {
        self.imageView.frame  = CGRectZero;
    }
    
    self.textLabel.numberOfLines = 0;
    self.textLabel.frame = labelRect;
    
    CGFloat onePixel = 1.f / [[UIScreen mainScreen] scale];
    
    self.separator.backgroundColor = [self.textLabel.textColor colorWithAlphaComponent:.25f];
    self.separator.frame = CGRectMake(TSROptionsViewCellSidePadding, 0, CGRectGetWidth(self.bounds) - TSROptionsViewCellSidePadding * 2, onePixel);
    
    self.selectedBackgroundView.frame = CGRectMake(0.f, (self.separator.hidden) ? 0 : onePixel, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - ((self.separator.hidden) ? 0 : onePixel));
}

- (BOOL)showsSeparator {
    return self.separator.hidden;
}

- (void)setShowsSeparator:(BOOL)showsSeparator {
    self.separator.hidden = !showsSeparator;
    
    [self setNeedsLayout];
}

@end
