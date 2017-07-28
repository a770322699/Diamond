//
//  YQBoard.m
//  diamond
//
//  Created by Yiquan Ma on 2017/4/14.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQBoard.h"

@interface YQBoard ()

@property (nonatomic, assign) YQIntSize size;
@property (nonatomic, strong) NSMutableArray *blocks;

@end

@implementation YQBoard

- (instancetype)initWithSize:(YQIntSize)size{
    if (size.width <= 0 || size.height <= 0) {
        return nil;
    }
    
    if (self = [super init]) {
        self.size = size;
    }
    return self;
}

#pragma mark - getter
- (NSMutableArray *)blocks{
    if (!_blocks) {
        _blocks = [NSMutableArray array];
        
        for (int i = 0; i < self.size.height; i++) {
            NSMutableArray *blocks = [NSMutableArray array];
            for (int j = 0; j < self.size.width; j++) {
                [blocks addObject:[YQBlock block]];
            }
            [_blocks addObject:blocks];
        }
    }
    return _blocks;
}

#pragma mark public
// 添加count这么多行
- (void)addBlocksLineWithCount:(NSInteger)count{
    for (int i = 0; i < count; i++) {
        if (self.blocks.count >= self.size.height) {
            return;
        }
        NSMutableArray *blocks = [NSMutableArray array];
        for (int i = 0; i < self.size.width; i++) {
            [blocks addObject:[YQBlock block]];
        }
        [self.blocks addObject:blocks];
    }
}
// 删除某些行
- (void)removeBlocksLineAtIndex:(NSIndexSet *)indexs{
    [self.blocks removeObjectsAtIndexes:indexs];
}

- (void)setBlock:(YQBlock *)block atPoint:(YQIntPoint)point{
    NSMutableArray *blocks = [self.blocks yq_objectOrNilAtIndex:point.y];
    [blocks replaceObjectAtIndex:point.x withObject:block];
}
- (YQBlock *)blockAtPoint:(YQIntPoint)point{
    return [[self.blocks yq_objectOrNilAtIndex:point.y] yq_objectOrNilAtIndex:point.x];
}

// 重置
- (void)reset{
    self.blocks = nil;
}

#pragma mark - NSCopying
- (id)copyWithZone:(nullable NSZone *)zone{
    YQBoard *board = [(YQBoard *)[[self class] alloc] initWithSize:self.size];
    board.blocks = [self.blocks mutableCopy];
    
    return board;
}

@end
