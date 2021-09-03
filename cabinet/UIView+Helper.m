// Copyright © 2020 PeoGooCore. All rights reserved.

#import "UIView+Helper.h"
//#import "CGGeometry.h"

@implementation UIView (Helper)

//- (UIView *)closestViewInArray:(NSArray<UIView *> *)views toPoint:(CGPoint)point withinMaxDistance:(CGFloat)maxDistance {
//    // Always hit a button, to make it easier to tap.
//    UIView *closestView = nil;
//    CGFloat closestDistance = INFINITY;
//    for (UIView *view in views) {
//        CGRect rect = [view convertRect:view.bounds toView:self];
//        CGFloat distance = CGPointDistanceToRect(point, rect);
//        if (distance < closestDistance && distance <= maxDistance) {
//            closestView = view;
//            closestDistance = distance;
//        }
//    }
//    return closestView;
//}
//
//- (UIView *)firstDescendantSatisfying:(BOOL(^)(UIView *))predicate {
//    for (UIView *subview in self.subviews) {
//        if (predicate(subview)) { return subview; }
//        UIView *nestedResult = [subview firstDescendantSatisfying:predicate];
//        if (nestedResult) { return nestedResult; }
//    }
//    return nil;
//}
//
//- (UIView *)firstAncestorSatisfying:(BOOL(^)(UIView *))predicate {
//    if (predicate(self)) { return self; }
//    if (self.superview) {
//        return [self.superview firstAncestorSatisfying:predicate];
//    } else {
//        return nil;
//    }
//}

- (void)subview:(UIView *)subview constrainedToFillWithInsets:(UIEdgeInsets)insets {
    [NSLayoutConstraint activateConstraints:@[
        [subview.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:insets.left],
        [subview.topAnchor constraintEqualToAnchor:self.topAnchor constant:insets.top],
        [subview.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-insets.right],
        [subview.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-insets.bottom]
    ]];
}

- (void)addSubview:(UIView *)subview constrainedToFillWithInsets:(UIEdgeInsets)insets {
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:subview];
    [NSLayoutConstraint activateConstraints:@[
        [subview.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:insets.left],
        [subview.topAnchor constraintEqualToAnchor:self.topAnchor constant:insets.top],
        [subview.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-insets.right],
        [subview.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-insets.bottom]
    ]];
}

- (void)addSubview:(UIView *)subview constrainedToCenterWithOffset:(CGPoint)offset {
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:subview];
    [NSLayoutConstraint activateConstraints:@[
        [subview.centerXAnchor constraintEqualToAnchor:self.centerXAnchor constant:offset.x],
        [subview.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:offset.y]
    ]];
}

- (void)addSubview:(UIView *)subview constrainedToCenterYAndToFillWidthWithInsets:(UIEdgeInsets)insets {
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:subview];
    [NSLayoutConstraint activateConstraints:@[
                                              [subview.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:insets.left],
                                              [subview.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:-insets.right],
                                              [subview.centerYAnchor constraintEqualToAnchor:self.centerYAnchor constant:0]
                                              ]];
}

- (void)applyRoundCornerWithWidth:(CGFloat)width radius:(CGFloat)radius topLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br {
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0; // Holds the corner
        //Determine which corner(s) should be changed
        if (tl) { corner = corner | UIRectCornerTopLeft; }
        if (tr) { corner = corner | UIRectCornerTopRight; }
        if (bl) { corner = corner | UIRectCornerBottomLeft; }
        if (br) { corner = corner | UIRectCornerBottomRight; }
        CGRect bounds = CGRectMake(0, 0, width, self.bounds.size.height);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = bounds;
        maskLayer.path = maskPath.CGPath;
        self.layer.mask = maskLayer;
    }
}

- (UIViewController *)viewController {
    UIResponder *responder = self;
    while (responder) {
        responder = [responder nextResponder];
        if ([responder isKindOfClass:UIViewController.class]) {
            return (UIViewController *)responder;
        }
    }
    return nil;
}

+ (instancetype)loadFromNib {
    UINib *nib = [UINib nibWithNibName:[Global unqualifiedClassName:self.class] bundle:nil];
    return [nib instantiateWithOwner:nil options:nil].firstObject;
}

+ (UINib *)nib {
    return [UINib nibWithNibName:[Global unqualifiedClassName:self.class] bundle:nil];
}

@end
