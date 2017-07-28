//
//  YQComponentBoard.h
//  diamond
//
//  Created by Yiquan Ma on 2017/4/15.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQBoard.h"
#import "YQMainBoard.h"

// 组件的形状
typedef NS_ENUM(NSInteger, YQComponentShape) {
    YQComponentShape_none,
    
    YQComponentShape_min,
    /*
            0000
     */
    YQComponentShape_line = YQComponentShape_min,
    /*
            00
            00
     */
    YQComponentShape_grid,
    /*       0
            000
     */
    YQComponentShape_bulge,
    /*
             0
           000
     */
    YQComponentShape_leftFolded,
    /*
            0
            000
     */
    YQComponentShape_rightFolded,
    /*
            00
             00
     */
    YQComponentShape_leftSlipped,
    /*
             00
            00
     */
    YQComponentShape_rightSlipped,
    
    YQComponentShape_max = YQComponentShape_rightSlipped,
};

typedef NS_ENUM(NSInteger, YQComponentBlockChangePattern) { // 方块改变方式
    YQComponentBlockChangePattern_none,
    YQComponentBlockChangePattern_reset,                // 重置
    YQComponentBlockChangePattern_moveToLeft,           // 左移
    YQComponentBlockChangePattern_moveToRight,          // 右移
    YQComponentBlockChangePattern_moveToDown,           // 下移
    YQComponentBlockChangePattern_moveToBottom,         // 移到底部
    YQComponentBlockChangePattern_rotate,               // 旋转
};

@class YQComponentBoard;
@protocol YQComponentBoardDelegate <NSObject>

// 有效方块发生变化
- (void)componentBoard:(YQComponentBoard *)componentBoard validBlocks:(NSArray *)oldBlocks didChange:(NSArray *)newBlocks;

@end

@interface YQComponentBoard : YQBoard

@property (nonatomic, readonly) YQComponentShape shape;   // 形状
@property (nonatomic, readonly) YQBlockType blockType;    // 方块类型
@property (nonatomic, weak) id<YQComponentBoardDelegate> delegate;
@property (nonatomic, weak) YQMainBoard *mainBoard;         // 主面板

@property (nonatomic, readonly) NSArray *validBlockPoints;     // 有效的方块所在的位置

// 判断是否已经到达底部
- (BOOL)didArriveBottom;
// 判断是否已经重叠
- (BOOL)isGameOver;
// 重置方块
- (void)resetBlocksWithShape:(YQComponentShape)shape blockType:(YQBlockType)blockType;
// 改变方块
- (BOOL)changeBlocksWithPattern:(YQComponentBlockChangePattern)pattern;

@end
