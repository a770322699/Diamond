//
//  YQMainBoard.h
//  diamond
//
//  Created by Yiquan Ma on 2017/4/15.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQBoard.h"

@class YQMainBoard;
@protocol YQMainBoardDelegate <NSObject>

// 消除完成
- (void)mainBoard:(YQMainBoard *)board didRemoveLines:(NSIndexSet *)indexs;
// 添加格子完成
- (void)mainBoard:(YQMainBoard *)board didAddBlocks:(NSArray<YQValue *> *)blocks;

@end

@interface YQMainBoard : YQBoard

@property (nonatomic, weak) id<YQMainBoardDelegate> delegate;

- (void)addBlocks:(NSArray<YQValue *> *)blocks withType:(YQBlockType)type;

@end
