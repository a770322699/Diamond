//
//  YQBlock.m
//  diamond
//
//  Created by Yiquan Ma on 2017/4/14.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQBlock.h"

@interface YQBlock ()

@property (nonatomic, assign) YQBlockType type;

@end

@implementation YQBlock

- (instancetype)init{
    return [self initWithType:YQBlockType_none];
}

- (instancetype)initWithType:(YQBlockType)type{
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

+ (instancetype)blockWithType:(YQBlockType)type{
    
    static NSMutableDictionary *blocks = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        blocks = [NSMutableDictionary dictionary];
    });
    
    NSNumber *key = @(type);
    YQBlock *block = [blocks objectForKey:key];
    if (!block) {
        block = [(YQBlock *)[self alloc] initWithType:type];
        [blocks setObject:block forKey:key];
    }
    
    return block;
}

+ (instancetype)block{
    return [self blockWithType:YQBlockType_none];
}

@end
