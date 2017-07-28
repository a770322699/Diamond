//
//  YQBoard.h
//  diamond
//
//  Created by Yiquan Ma on 2017/4/14.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YQBlock.h"

@interface YQBoard : NSObject<NSCopying>

@property (nonatomic, readonly) YQIntSize size;
@property (nonatomic, readonly) NSMutableArray *blocks;

- (instancetype)initWithSize:(YQIntSize)size;

- (void)setBlock:(YQBlock *)block atPoint:(YQIntPoint)point;
- (YQBlock *)blockAtPoint:(YQIntPoint)point;

// 添加count这么多行
- (void)addBlocksLineWithCount:(NSInteger)count;
// 删除某些行
- (void)removeBlocksLineAtIndex:(NSIndexSet *)indexs;

// 重置
- (void)reset;

@end
