// Copyright © 2020 PeoGooCore. All rights reserved.

#import <UIKit/UIKit.h>

@interface UIViewController (Helper)

// General
- (void)showViewController:(UIViewController *)vc animated:(BOOL)animated;

+ (instancetype)loadFromNib;
- (IBAction)dismiss __attribute__((deprecated("Use -dismissSelf() instead.")));
+ (UIViewController *)currentViewController;
- (void)navigateToViewController:(UIViewController *)viewController;

@end
