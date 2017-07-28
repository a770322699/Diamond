//
//  YQOperationView.m
//  diamond
//
//  Created by maygolf on 17/5/23.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQOperationView.h"

@implementation YQOperationView

- (instancetype)init{
    return [self initWithTypes:YQOperationType_left | YQOperationType_right | YQOperationType_bottom | YQOperationType_rotate];
}

- (instancetype)initWithTypes:(YQOperationType)types{
    if (self = [super init]) {
        
        UIView *contentView = nil;
        UIView *beforView = nil;
        for (int i = YQOperationType_min; i <= YQOperationType_max; i = i << 1) {
            if ((types & i) == 0) {
                continue;
            }
            
            UIView *view = [self operationButtonWithType:i];
            if (!contentView) {
                contentView = [[YQIntrinsicContentSizeView alloc] init];
            }
            [contentView addSubview:view];
            
            if (beforView) {
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.and.centerY.mas_equalTo(beforView);
                    make.leading.mas_equalTo(beforView.mas_trailing).offset(10);
                }];
            }else{
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(44, 44));
                    make.leading.mas_equalTo(@0);
                    make.centerY.mas_equalTo(contentView);
                    make.height.mas_lessThanOrEqualTo(contentView);
                }];
            }
            
            beforView = view;
        }
        
        if (beforView) {
            [beforView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(@0);
            }];
        }
        
        [self addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self);
            make.size.mas_lessThanOrEqualTo(self);
        }];
    }
    return self;
}

#pragma mark - private
- (UIButton *)operationButtonWithType:(YQOperationType)type{
    UIButton *buttong = [UIButton buttonWithType:UIButtonTypeCustom];
    buttong.backgroundColor = kYQColorClear;
    buttong.translatesAutoresizingMaskIntoConstraints = NO;
    buttong.tag = type;
    [buttong addTarget:self action:@selector(operationAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *imageName = nil;
    switch (type) {
        case YQOperationType_left:
            imageName = @"left";
            break;
            
        case YQOperationType_rotate:
            imageName = @"rotate";
            break;
            
        case YQOperationType_bottom:
            imageName = @"bottom";
            break;
            
        case YQOperationType_right:
            imageName = @"right";
            break;
            
        default:
            break;
    }
    [buttong setImage:YQImage(imageName) forState:UIControlStateNormal];
    
    return buttong;
}

#pragma mark - action
- (void)operationAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(operationView:didClickType:)]) {
        [self.delegate operationView:self didClickType:sender.tag];
    }
}

@end
