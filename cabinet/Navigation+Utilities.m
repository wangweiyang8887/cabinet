
#import "Navigation+Utilities.h"

@implementation UIWindow (Navigation)

- (UIViewController *)firstViewControllerMatching:(ETViewControllerPredicate)predicate {
    UIViewController *rootViewController = self.rootViewController;
    while (rootViewController) {
        if (predicate(rootViewController)) { return rootViewController; }
        UIViewController *matchingDescendant = [rootViewController firstDescendantMatching:predicate];
        if (matchingDescendant) { return matchingDescendant; }
        rootViewController = rootViewController.presentedViewController;
    }
    return nil;
}

- (void)navigateToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController.presentedViewController) {
        [viewController dismissViewControllerAnimated:animated completion:nil];
    }
    while (viewController.parentViewController) {
        UIViewController *parentViewController = viewController.parentViewController;
        if ([parentViewController isKindOfClass:UITabBarController.class]) {
            UITabBarController *tabBarController = (UITabBarController *)parentViewController;
            tabBarController.selectedViewController = viewController;
        } else if ([parentViewController isKindOfClass:UINavigationController.class]) {
            UINavigationController *navigationController = (UINavigationController *)parentViewController;
            [navigationController popToViewController:viewController animated:animated];
        }
        viewController = parentViewController;
    }
}

@end

@implementation UIViewController (Navigation)

- (UIViewController *)firstDescendantMatching:(ETViewControllerPredicate)predicate {
    for (UIViewController *child in self.childViewControllers) {
        if (predicate(child)) { return child; }
        UIViewController *matchingDescendant = [child firstDescendantMatching:predicate];
        if (matchingDescendant) { return matchingDescendant; }
    }
    return nil;
}

@end
