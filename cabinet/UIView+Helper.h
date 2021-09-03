// Copyright © 2020 PeoGooCore. All rights reserved.

#import <UIKit/UIKit.h>

@interface UIView (Helper)

//- (UIView *_Nullable)closestViewInArray:(NSArray<UIView *> *_Nonnull)views toPoint:(CGPoint)point withinMaxDistance:(CGFloat)maxDistance;
//
//- (UIView *_Nullable)firstDescendantSatisfying:(BOOL(^_Nonnull)(UIView *_Nonnull))predicate;
//- (UIView *_Nullable)firstAncestorSatisfying:(BOOL(^_Nonnull)(UIView *_Nonnull))predicate;

- (void)subview:(UIView *_Nonnull)subview constrainedToFillWithInsets:(UIEdgeInsets)insets;
- (void)addSubview:(UIView *_Nonnull)subview constrainedToFillWithInsets:(UIEdgeInsets)insets;
- (void)addSubview:(UIView *_Nonnull)subview constrainedToCenterWithOffset:(CGPoint)offset;
- (void)addSubview:(UIView *_Nonnull)subview constrainedToCenterYAndToFillWidthWithInsets:(UIEdgeInsets)insets;

/// Custom method to apply round corners to a view that was loaded from a xib. Used to fix a bug in iOS view auto layout.
- (void)applyRoundCornerWithWidth:(CGFloat)width radius:(CGFloat)radius topLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br;

/// Returns the UIViewController object that manages the receiver.
@property (strong, nonatomic, nullable, readonly) UIViewController *viewController;

+ (_Nonnull instancetype)loadFromNib;
+ (UINib *_Nonnull)nib;

@end
