//
//  YQOperationView.h
//  diamond
//
//  Created by maygolf on 17/5/23.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, YQOperationType) {
    YQOperationType_min     = 1 << 1,
    YQOperationType_left    = YQOperationType_min,
    YQOperationType_rotate  = 1 << 2,
    YQOperationType_bottom  = 1 << 3,
    YQOperationType_right   = 1 << 4,
    YQOperationType_max     = YQOperationType_right,
};

@class YQOperationView;
@protocol YQOperationViewDelegate <NSObject>

- (void)operationView:(YQOperationView *)view didClickType:(YQOperationType)type;

@end

@interface YQOperationView : UIView

@property (nonatomic, weak) id<YQOperationViewDelegate> delegate;

- (instancetype)initWithTypes:(YQOperationType)types;

@end
