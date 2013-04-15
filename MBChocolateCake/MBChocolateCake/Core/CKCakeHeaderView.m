//
//  CKCakeHeaderView.m
//  MBChocolateCake
//
//  Created by Moshe Berman on 4/14/13.
//  Copyright (c) 2013 Moshe Berman. All rights reserved.
//

#import "CKCakeHeaderView.h"

#import "UIView+Border.h"

#import "CKCakeHeaderColors.h"

#import "CKCakeViewModes.h"

#import "MBPolygonView.h"

@interface CKCakeHeaderView ()
{
    NSUInteger _columnCount;
    CGFloat _columnTitleHeight;
}

@property (nonatomic, strong) UILabel *monthTitle;

@property (nonatomic, strong) NSMutableArray *columnTitles;
@property (nonatomic, strong) NSMutableArray *columnLabels;

@property (nonatomic, strong) MBPolygonView *forwardButton;
@property (nonatomic, strong) MBPolygonView *backwardButton;

@end

@implementation CKCakeHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _monthTitle = [UILabel new];
        [_monthTitle setTextColor:kCakeColorHeaderMonth];
        [_monthTitle setShadowColor:kCakeColorHeaderMonthShadow];
        [_monthTitle setShadowOffset:CGSizeMake(0, 1)];
        [_monthTitle setBackgroundColor:[UIColor clearColor]];
        [_monthTitle setTextAlignment:NSTextAlignmentCenter];
        [_monthTitle setFont:[UIFont boldSystemFontOfSize:22]];
        
        _columnTitles = [NSMutableArray new];
        _columnLabels = [NSMutableArray new];
        
        _columnTitleHeight = 10;
        
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
        [self addGestureRecognizer:_tapGesture];
    }
    return self;
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self layoutSubviews];
    [super willMoveToSuperview:newSuperview];
    [self setBackgroundColor:kCakeColorHeaderGradientDark];
}

- (void)layoutSubviews
{
    
    /* Show & position the title Label */
    
    CGFloat upperRegionHeight = [self frame].size.height - _columnTitleHeight;
    CGFloat titleLabelHeight = 27;
    
    if ([[self dataSource] numberOfColumnsForHeader:self] == 0) {
        titleLabelHeight = [self frame].size.height;
        upperRegionHeight = titleLabelHeight;
    }
    
    CGFloat yOffset = upperRegionHeight/2 - titleLabelHeight/2;
    
    CGRect frame = CGRectMake(0, yOffset, [self frame].size.width, titleLabelHeight);
    [[self monthTitle] setFrame:frame];
    [self addSubview:[self monthTitle]];
    
    /* Update the month title. */
    
    NSString *title = [[self dataSource] titleForHeader:self];
    [[self monthTitle] setText:title];
    
    /* Show the forward and back buttons */

        CGRect backFrame = CGRectMake(yOffset, yOffset, titleLabelHeight, titleLabelHeight);
        CGRect forwardFrame = CGRectMake([self frame].size.width-titleLabelHeight-yOffset, yOffset, titleLabelHeight, titleLabelHeight);
    
    if ([self forwardButton]) {
        [[self forwardButton] removeFromSuperview];
        [self setForwardButton:nil];
    }
    
    if ([self backwardButton]) {
        [[self backwardButton] removeFromSuperview];
        [self setBackwardButton:nil];
    }
    
    _forwardButton = [[MBPolygonView alloc] initWithFrame:forwardFrame numberOfSides:3 andRotation:90.0 andScale:10.0];
    _backwardButton = [[MBPolygonView alloc] initWithFrame:backFrame numberOfSides:3 andRotation:30.0 andScale:10.0];
    
    [self addSubview:[self backwardButton]];
    [self addSubview:[self forwardButton]];
    
    /*  Check for a data source for the header to be installed */
    if (![self dataSource]) {
        @throw [NSException exceptionWithName:@"CKCakeViewHeaderException" reason:@"Header can't be installed without a data source" userInfo:@{@"Header": self}];
    }
    
    /* Query the data source for the number of columns. */
    _columnCount = [[self dataSource] numberOfColumnsForHeader:self];
    
    
    /* Remove old labels */
    
    for (UILabel *label in [self columnLabels]) {
        [label removeFromSuperview];
    }
    
    [[self columnLabels] removeAllObjects];
    
    /* Query the datasource for the titles.*/
    [[self columnTitles] removeAllObjects];
    
    for (NSUInteger column = 0; column < _columnCount; column++) {
        NSString *title = [[self dataSource] header:self titleForColumnAtIndex:column];
        [[self columnTitles] addObject:title];
    }
    
    /* Convert title strings into labels and lay them out */
    
    if(_columnCount > 0){
        CGFloat labelWidth = [self frame].size.width/_columnCount;
        CGFloat labelHeight = _columnTitleHeight;
        
        for (NSUInteger i = 0; i < [[self columnTitles] count]; i++) {
            NSString *title = [self columnTitles][i];
            
            UILabel *label = [self _columnLabelWithTitle:title];
            [[self columnLabels] addObject:label];
            
            CGRect frame = CGRectMake(i*labelWidth, [self frame].size.height-labelHeight, labelWidth, labelHeight);
            [label setFrame:frame];
            
            [self addSubview:label];
        }
    }
}

#pragma mark - Convenience Methods

/* Creates and configures a label for a column title */

- (UILabel *)_columnLabelWithTitle:(NSString *)title
{
    UILabel *l = [UILabel new];
    [l setBackgroundColor:[UIColor clearColor]];
    [l setTextColor:kCakeColorHeaderWeekdayTitle];
    [l setShadowColor:kCakeColorHeaderWeekdayShadow];
    [l setTextAlignment:NSTextAlignmentCenter];
    [l setFont:[UIFont boldSystemFontOfSize:10]];
    [l setShadowOffset:CGSizeMake(0, 1)];
    [l setText:title];
    
    return l;
}

#pragma mark - Touch Handling

- (void)tapHandler:(UITapGestureRecognizer *)gesture
{
    
    CGPoint location = [gesture locationInView:self];
    
    if ([gesture state] != UIGestureRecognizerStateEnded) {
        return;
    }
    
    if (CGRectContainsPoint([[self forwardButton] frame], location))\
    {
        [self forwardButtonTapped];
    }
    
    else if(CGRectContainsPoint([[self backwardButton] frame],location))
    {
        [self backwardButtonTapped];
    }
}

#pragma mark - Button Handling

- (void)forwardButtonTapped
{
    if ([[self delegate] respondsToSelector:@selector(forwardTapped)]) {
        [[self delegate] forwardTapped];
    }
}

- (void)backwardButtonTapped
{
    if ([[self delegate] respondsToSelector:@selector(backwardTapped)]) {
        [[self delegate] backwardTapped];
    }
}

@end
