//
//  YQBoardView.m
//  diamond
//
//  Created by maygolf on 17/4/21.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQBoardView.h"
#import "YQBlockView.h"

@interface YQBoardView ()

@property (nonatomic, assign) YQIntSize size;
@property (nonatomic, strong) NSArray *blocks;

@property (nonatomic, assign) CGSize blocksFrameFromSize;

@property (nonatomic, assign) CGSize gridSize;

@end

@implementation YQBoardView

- (instancetype)initWithSize:(YQIntSize)size frame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kYQColorClear;
        
        self.size = size;
        
        // 添加方块
        for (NSArray *line in self.blocks) {
            for (YQBlockView *view in line) {
                [self addSubview:view];
            }
        }
    }
    return self;
}

- (instancetype)initWithSize:(YQIntSize)size{
    return [self initWithSize:size frame:CGRectZero];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    [self upadateBlocksFrame];
}

- (void)didMoveToSuperview{
    [super didMoveToSuperview];
    
    [self reloadData];
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    if (!self.needGrid) {
        return;
    }
    
    CGFloat width = self.yq_width / self.size.width;
    CGFloat height = self.yq_height / self.size.height;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, self.yq_height);
    CGContextAddLineToPoint(context, self.yq_width, self.yq_height);
    CGContextAddLineToPoint(context, self.yq_width, 0);
    CGContextAddLineToPoint(context, 0, 0);
    [YQRGB(164, 203, 179) setStroke];
    CGContextSetLineWidth(context, 2);
    CGContextDrawPath(context, kCGPathStroke);
    
    for (int i = 1; i < self.size.width; i++) {
        CGPoint start = CGPointMake(i * width, 0);;
        CGPoint end = CGPointMake(i * width, self.yq_height);
        CGContextMoveToPoint(context, start.x, start.y);
        CGContextAddLineToPoint(context, end.x, end.y);
    }
    
    for (NSInteger i = self.size.height; i > 0; i--) {
        CGPoint start = CGPointMake(0, i * height);;
        CGPoint end = CGPointMake(self.yq_width, i * height);
        
        CGContextMoveToPoint(context, start.x, start.y);
        CGContextAddLineToPoint(context, end.x, end.y);
    }
    
    [[YQHexColor(0xAAAAAA) colorWithAlphaComponent:0.6] setStroke];
    CGContextSetLineWidth(context, 0.5);
    CGContextDrawPath(context, kCGPathStroke);
}

#pragma mark - getter
- (NSArray *)blocks{
    if (!_blocks) {
        NSMutableArray *blocks = [NSMutableArray array];
        for (int i = 0; i < self.size.height; i++) {
            NSMutableArray *line = [NSMutableArray array];
            for (int j = 0; j < self.size.width; j++) {
                [line addObject:[[YQBlockView alloc] init]];
            }
            [blocks addObject:line];
        }
        
        _blocks = blocks;
        
        // 更新格子的坐标
        [self upadateBlocksFrame];
    }
    return _blocks;
}

#pragma mark - private
// 更新格子的坐标
- (void)upadateBlocksFrame{
    if (CGSizeEqualToSize(self.bounds.size, self.blocksFrameFromSize)) {
        return;
    }
    
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        return;
    }
    
    self.blocksFrameFromSize = self.bounds.size;
    
    CGFloat width = self.bounds.size.width / self.size.width;
    CGFloat height = self.bounds.size.height / self.size.height;
    CGSize size = CGSizeMake(width, height);
    NSInteger i = self.size.height - 1;
    for (NSArray *line in self.blocks) {
        NSInteger j = 0;
        for (YQBlockView *view in line) {
            view.yq_size = size;
            view.yq_origin = CGPointMake(j * width, i * height);
            
            j++;
        }
        i--;
    }
    
    self.gridSize = CGSizeMake(width, height);
}

- (YQBlockType)blockTypeAtPoint:(YQIntPoint)point{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(boardView:blockTypeAtPoint:)]) {
        return [self.dataSource boardView:self blockTypeAtPoint:point];
    }
    
    return YQBlockType_none;
}

- (YQBlockView *)blockViewAtPoint:(YQValue *)point{
    YQIntPoint intPoint = [point intPoint];
    return [[self.blocks yq_objectOrNilAtIndex:intPoint.y] yq_objectOrNilAtIndex:intPoint.x];
}

#pragma mark - public
- (void)reloadData{
    NSInteger i = 0;
    for (NSArray *line in self.blocks) {
        NSInteger j = 0;
        for (YQBlockView *view in line) {
            view.type = [self blockTypeAtPoint:YQIntPointMake(j, i)];
            
            j++;
        }
        i++;
    }
}

- (void)reloadDataAtPoints:(NSArray<YQValue *> *)points{
    for (YQValue *point in points) {
        YQIntPoint intPoint = [point intPoint];
        
        YQBlockView *view = [self blockViewAtPoint:point];
        view.type = [self blockTypeAtPoint:intPoint];
    }
}

@end
