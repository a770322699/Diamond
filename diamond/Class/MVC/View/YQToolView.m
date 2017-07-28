//
//  YQToolView.m
//  diamond
//
//  Created by maygolf on 17/5/13.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQToolView.h"
#import "YQBoardView.h"

#import "YQComponentBoard.h"

static const CGFloat kTitleContentSpacing   = 10;

@interface YQToolView ()<YQBoardViewDataSource, YQBoardViewDelegate>

@property (nonatomic, strong) YQBoardView *nextView;
@property (nonatomic, strong) UILabel *scoresLabel;  // 得分
@property (nonatomic, strong) UIButton *playButton;  // 开始、暂停按钮

@property (nonatomic, strong) YQComponentBoard *nextBoard;

@property (nonatomic, assign) YQToolViewItemType types;

@end

@implementation YQToolView

- (instancetype)initWithTypes:(YQToolViewItemType)types{
    if (self = [super initWithFrame:CGRectZero]) {
        _types = types;
        
        UIView *topView = [self combinationViewWithMinType:YQToolViewItemType_topMin maxType:YQToolViewItemType_topMax];
        UIView *bottomView = [self combinationViewWithMinType:YQToolViewItemType_bottomMin maxType:YQToolViewItemType_bottomMax];
        YQCombinationView *contentView = [[YQCombinationView alloc] initWithLeadingView:topView trailingView:bottomView];
        contentView.pattern = YQCombinationViewPattern_Vertical;
        contentView.space = 100;
        
        [self addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_lessThanOrEqualTo(self);
            make.centerX.mas_equalTo(self);
            make.top.and.bottom.mas_equalTo(self);
        }];
    }
    return self;
}

#pragma mark - getter
- (YQBoardView *)nextView{
    if (!_nextView) {
        _nextView = [[YQBoardView alloc] initWithSize:YQIntSizeMake(4, 4)];
        _nextView.translatesAutoresizingMaskIntoConstraints = NO;
        _nextView.delegate = self;
        _nextView.dataSource = self;
        _nextView.userInteractionEnabled = NO;
        [_nextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
    }
    return _nextView;
}

- (UILabel *)scoresLabel{
    if (!_scoresLabel) {
        _scoresLabel = [[UILabel alloc] init];
        _scoresLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _scoresLabel.backgroundColor = kYQColorClear;
        _scoresLabel.font = [UIFont boldSystemFontOfSize:20];
        _scoresLabel.textColor = kYQColorRed;
    }
    return _scoresLabel;
}

- (UIButton *)playButton{
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _playButton.backgroundColor = kYQColorClear;
        _playButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_playButton setImage:YQRenderingOriginalImage(@"start") forState:UIControlStateNormal];
        [_playButton setImage:YQRenderingOriginalImage(@"stop")  forState:UIControlStateSelected];
        [_playButton addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
        
        [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
    }
    return _playButton;
}

- (YQComponentBoard *)nextBoard{
    if (!_nextBoard) {
        _nextBoard = [[YQComponentBoard alloc] initWithSize:YQIntSizeMake(4, 4)];
    }
    return _nextBoard;
}

#pragma mark - private
- (UILabel *)titleLabelWithName:(NSString *)name{
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = kYQColorClear;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = kYQColorYellow;
    label.text = name;
    
    return label;
}

- (UIView *)combinationWithTitleLabel:(UILabel *)titleLabel contentView:(UIView *)contentView{
    YQIntrinsicContentSizeView *view = [[YQIntrinsicContentSizeView alloc] init];
    [view addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.top.mas_equalTo(@0);
        make.width.mas_lessThanOrEqualTo(view);
    }];
    [view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(@0);
        make.centerX.mas_equalTo(view);
        make.width.mas_lessThanOrEqualTo(view);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(kTitleContentSpacing);
    }];
    
    return view;
}

- (UIView *)combinationViewWithType:(YQToolViewItemType)type{
    switch (type) {
        case YQToolViewItemType_next:
            return [self combinationWithTitleLabel:[self titleLabelWithName:@"下一个"] contentView:self.nextView];
            
        case YQToolViewItemType_scores:
            return [self combinationWithTitleLabel:[self titleLabelWithName:@"得分"] contentView:self.scoresLabel];
            
        case YQToolViewItemType_play:
            return self.playButton;
            
        default:
            break;
    }
    
    return nil;
}

- (UIView *)combinationViewWithMinType:(YQToolViewItemType)min maxType:(YQToolViewItemType)max{
    YQIntrinsicContentSizeView *topView = nil;
    UIView *beforView = nil;
    for (int i = min; i <= max; i = i << 1) {
        if ((self.types & i) == 0) {
            continue;
        }
        
        UIView *view = [self combinationViewWithType:i];
        if (view) {
            if (!topView) {
                topView = [[YQIntrinsicContentSizeView alloc] init];
            }
            [topView addSubview:view];
            if (beforView) {
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.and.with.mas_equalTo(beforView);
                    make.top.mas_equalTo(beforView.mas_bottom).offset(5);
                }];
            }else{
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(@0);
                    make.width.and.centerX.mas_equalTo(topView);
                }];
            }
            beforView = view;
        }
    }
    if (beforView) {
        [beforView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(@0);
        }];
    }
    
    return topView;
}

#pragma mark - public
- (void)updateNextWithShap:(YQComponentShape)shape blockType:(YQBlockType)type{
    [self.nextBoard resetBlocksWithShape:shape blockType:type];
    [self.nextView reloadData];
}
- (void)updateScores:(NSInteger)scores{
    self.scoresLabel.text = [NSString yq_stringWithInteger:scores];
}

#pragma mark - action
- (void)play:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolView:didClickPlayButton:)]) {
        [self.delegate toolView:self didClickPlayButton:sender];
    }
}

#pragma mark - YQBoardViewDataSource
// 获取数据源
- (YQBlockType)boardView:(YQBoardView *)view blockTypeAtPoint:(YQIntPoint)point{
    return [self.nextBoard blockAtPoint:point].type;
}

@end
