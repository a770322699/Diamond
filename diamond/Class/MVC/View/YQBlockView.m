//
//  YQBlockView.m
//  diamond
//
//  Created by maygolf on 17/4/21.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQBlockView.h"

@implementation YQBlockView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kYQColorClear;
        self.type = YQBlockType_none;
    }
    return self;
}

- (void)setType:(YQBlockType)type{
    _type = type;
    NSString *imageName = [NSString stringWithFormat:@"BLOCK%d", (int)type];
    self.image = YQImage(imageName);
}

@end
