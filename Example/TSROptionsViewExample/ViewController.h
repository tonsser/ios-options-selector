//
//  ViewController.h
//  TSROptionsViewExample
//
//  Created by Nicolai Persson on 22/01/15.
//  Copyright (c) 2015 Tonsser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property(nonatomic, weak) IBOutlet UISlider *redSlider, *greenSlider, *blueSlider;
@property(nonatomic, weak) IBOutlet UIView *previewView;
@end

