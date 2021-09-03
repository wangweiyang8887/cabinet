// Copyright © 2020 PeoGooCore. All rights reserved.

#import "UIViewController+Helper.h"
#import "Navigation+Utilities.h"
#import "NSObject+Helper.h"


@implementation UIViewController (Helper)

// MARK: General
- (void)showViewController:(UIViewController *)viewControllerToShow animated:(BOOL)animated {
    if (!([self.navigationController.viewControllers.lastObject isEqual:self] || [self.navigationController.viewControllers.lastObject isEqual:self.parentViewController])) {
    } else {
        viewControllerToShow.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewControllerToShow animated:animated];
    }
}

+ (instancetype)loadFromNib {
    NSString *name = [Global unqualifiedClassName:self.class];
    UINib *nib = [UINib nibWithNibName:name bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:nil options:nil];
    NSAssert(objects.count == 1, @"More than one top-level object found in nib \"%@\".", name);
    NSAssert([objects.firstObject isKindOfClass:self], @"Top-level object has unexpected class %@ (expected %@). Note that [UIViewController loadFromNib] expects the VC as top-level object, not file owner.", NSStringFromClass([objects.firstObject class]), name);
    return objects.firstObject;
}

// MARK: Navigation
- (IBAction)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

+ (UIViewController *)findBestViewController:(UIViewController *)vc {

    if (vc.presentedViewController) {

        // Return presented view controller
        return [UIViewController findBestViewController:vc.presentedViewController];

    } else if ([vc isKindOfClass:UISplitViewController.class]) {

        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;

    } else if ([vc isKindOfClass:UINavigationController.class]) {

        // Return top view
        UINavigationController *svc = (UINavigationController *) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.topViewController];
        else
            return vc;

    } else if ([vc isKindOfClass:UITabBarController.class]) {

        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.selectedViewController];
        else
            return vc;

    } else {
        // Unknown view controller type, return last child view controller
        return vc;

    }
}

+ (UIViewController *)currentViewController {
    // Find best view controller
    UIViewController *viewController = [[UIApplication sharedApplication].delegate window].rootViewController;
    return [UIViewController findBestViewController:viewController];
}

- (void)navigateToViewController:(UIViewController *)viewController {
    self.navigationController.navigationBarHidden = NO; // Do this now, because navigation might nil self.navigationController
    // Navigate to VC
    [UIApplication.sharedApplication.delegate.window navigateToViewController:viewController animated:YES];
    // Pop the current nav controller to root as well (if we didn't do anything yet) as it might stick around (e.g. under a different tab) and maintain its stack.
    UIViewController *newNavigationController = viewController.navigationController ?: [viewController as:UIViewController.class];
    if (self.navigationController != newNavigationController) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

@end
