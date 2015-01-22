//
//  TSROptionsViewCell.h
//  OptionsTest
//
//  Created by Nicolai Persson on 22/01/15.
//  Copyright (c) 2015 Tonsser. All rights reserved.
//

@import UIKit;

extern NSString *TSROptionsViewCellIdentifier;

@interface TSROptionsViewCell : UITableViewCell

+ (CGFloat)heightWithText:(NSString *)text withImage:(UIImage *)image selected:(BOOL)selected usingFont:(UIFont *)font maintainingWidth:(CGFloat)width;

@property(nonatomic, readwrite) BOOL showsSeparator;
@end
