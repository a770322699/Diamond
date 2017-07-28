//
//  YQBoardView.h
//  diamond
//
//  Created by maygolf on 17/4/21.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YQBlock.h"

@class YQBoardView;
@protocol YQBoardViewDelegate <NSObject>


@end

@protocol YQBoardViewDataSource <NSObject>

// 获取数据源
- (YQBlockType)boardView:(YQBoardView *)view blockTypeAtPoint:(YQIntPoint)point;

@end

@interface YQBoardView : UIView

@property (nonatomic, weak) id<YQBoardViewDelegate> delegate;
@property (nonatomic, weak) id<YQBoardViewDataSource> dataSource;
@property (nonatomic, assign) BOOL needGrid;                        // 是否需要网格背景
@property (nonatomic, readonly) CGSize gridSize; 

- (instancetype)initWithSize:(YQIntSize)size frame:(CGRect)frame;
- (instancetype)initWithSize:(YQIntSize)size;

- (void)reloadData;
- (void)reloadDataAtPoints:(NSArray<YQValue *> *)points;

@end
