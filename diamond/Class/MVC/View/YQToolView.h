//
//  YQToolView.h
//  diamond
//
//  Created by maygolf on 17/5/13.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "YQComponentBoard.h"

typedef NS_OPTIONS(NSInteger, YQToolViewItemType) {
    YQToolViewItemType_min      = 1 << 1,
    
    YQToolViewItemType_topMin   = YQToolViewItemType_min,
    YQToolViewItemType_next     = YQToolViewItemType_topMin,           // 下一个
    YQToolViewItemType_scores   = 1 << 2,           // 得分
    YQToolViewItemType_topMax   = YQToolViewItemType_scores,
    
    YQToolViewItemType_bottomMin    = 1 << 3,
    YQToolViewItemType_play     = YQToolViewItemType_bottomMin,           // 开始、暂停按钮
    YQToolViewItemType_bottomMax = YQToolViewItemType_play,
    
    YQToolViewItemType_max  = YQToolViewItemType_bottomMax,
};

@class YQToolView;
@protocol YQToolViewDelegate <NSObject>

- (void)toolView:(YQToolView *)view didClickPlayButton:(UIButton *)playButton;

@end

@interface YQToolView : UIView

@property (nonatomic, weak) id<YQToolViewDelegate> delegate;

- (instancetype)initWithTypes:(YQToolViewItemType)types;

- (void)updateNextWithShap:(YQComponentShape)shape blockType:(YQBlockType)type;
- (void)updateScores:(NSInteger)scores;

@end
