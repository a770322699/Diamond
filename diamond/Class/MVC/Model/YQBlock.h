//
//  YQBlock.h
//  diamond
//
//  Created by Yiquan Ma on 2017/4/14.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YQBlockType) {
    YQBlockType_none,      // 没有
    
    YQBlockType_min,
    YQBlockType_1 = YQBlockType_min,
    YQBlockType_2,
    YQBlockType_3,
    YQBlockType_4,
    YQBlockType_5,
    YQBlockType_6,
    YQBlockType_7,
    YQBlockType_8,
    YQBlockType_max = YQBlockType_8,
};

@interface YQBlock : NSObject

@property (nonatomic, readonly) YQBlockType type;

//- (instancetype)initWithType:(YQBlockType)type NS_DESIGNATED_INITIALIZER;
+ (instancetype)blockWithType:(YQBlockType)type;
+ (instancetype)block;

@end
