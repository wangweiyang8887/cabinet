//
//  Navigation+Utilities.h
//  ETCloud
//
//  Created by evan on 2020/8/17.
//  Copyright © 2020 PHBJ03-0364. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL (^ETViewControllerPredicate)(UIViewController *);

@interface UIWindow (Navigation)

- (UIViewController *)firstViewControllerMatching:(ETViewControllerPredicate)predicate;
- (void)navigateToViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end

@interface UIViewController (Navigation)

- (UIViewController *)firstDescendantMatching:(ETViewControllerPredicate)predicate;

@end
