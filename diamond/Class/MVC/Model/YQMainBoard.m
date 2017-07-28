//
//  YQMainBoard.m
//  diamond
//
//  Created by Yiquan Ma on 2017/4/15.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQMainBoard.h"

@implementation YQMainBoard

#pragma mark - private
// 某一行是否已经全部填充
- (BOOL)isFullAtLine:(NSInteger)index{
    NSArray *blocks = [self.blocks yq_objectOrNilAtIndex:index];
    return ![blocks containsObject:[YQBlock block]];
}

#pragma mark - public
- (void)addBlocks:(NSArray<YQValue *> *)blocks withType:(YQBlockType)type{
    
    NSMutableIndexSet *indexs = [NSMutableIndexSet indexSet];
    for (YQValue *block in blocks) {
        YQIntPoint point = [block intPoint];
        
        // 设置方块
        [self setBlock:[YQBlock blockWithType:type] atPoint:point];
        
        // 将已经满的索引加入到集合中
        if ([self isFullAtLine:point.y]) {
            [indexs addIndex:point.y];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainBoard:didAddBlocks:)]) {
        [self.delegate mainBoard:self didAddBlocks:blocks];
    }
    
    // 删除已经满了的行
    if ([indexs count]) {
        [self removeBlocksLineAtIndex:indexs];
        [self addBlocksLineWithCount:[indexs count]];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(mainBoard:didRemoveLines:)]) {
            [self.delegate mainBoard:self didRemoveLines:indexs];
        }
    }
    
}

@end
