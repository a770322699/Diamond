//
//  YQBoardViewController.m
//  diamond
//
//  Created by maygolf on 17/4/21.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQBoardViewController.h"

#import "YQBoardView.h"
#import "YQToolView.h"
#import "YQOperationView.h"

#import "YQMainBoard.h"
#import "YQComponentBoard.h"

#import "YQScoresManager.h"

static const CGFloat kBoardWidth        = 250.0;

@interface YQBoardViewController ()<YQBoardViewDataSource, YQBoardViewDelegate, YQMainBoardDelegate, YQComponentBoardDelegate, YQToolViewDelegate, YQScoresManagerDelegate, YQOperationViewDelegate>

@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) YQBoardView *mainBoardView;
@property (nonatomic, strong) YQBoardView *componentBoardView;

@property (nonatomic, strong) YQMainBoard *mainBoard;
@property (nonatomic, strong) YQComponentBoard *componentBoard;

@property (nonatomic, strong) YQToolView *toolView;
@property (nonatomic, strong) YQOperationView *operationView;
@property (nonatomic, strong) YQScoresManager *scoressManager;

@property (nonatomic, assign) YQIntSize size;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval timeSpace;

@property (nonatomic, assign) YQBlockType nextType;
@property (nonatomic, assign) YQComponentShape nextShape;

@end

@implementation YQBoardViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _size = YQIntSizeMake(10, 20);
        _timeSpace = 1;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self building];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - building
- (void)building{
    
    [self.view addSubview:self.bgView];
    
    [self.view addSubview:self.operationView];
    [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(@ -20);
        make.height.mas_equalTo(@60);
    }];
    
    [self.view addSubview:self.mainBoardView];
    [self.mainBoardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(YQScaleSizeBaseIphone6(kBoardWidth));
        make.height.mas_equalTo(self.mainBoardView.mas_width).multipliedBy(self.size.height / self.size.width);
        make.leading.mas_equalTo(@30);
        make.bottom.mas_equalTo(self.operationView.mas_top).offset(-10);
        make.centerX.mas_equalTo(self.operationView);
    }];
    
    [self.view addSubview:self.componentBoardView];
    [self.componentBoardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.mainBoardView);
        make.center.mas_equalTo(self.mainBoardView);
    }];
    
    [self.view addSubview:self.toolView];
    [self.toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainBoardView);
        make.leading.mas_equalTo(self.mainBoardView.mas_trailing);
        make.trailing.mas_equalTo(@0);
    }];
}

#pragma mark - getter
- (YQBoardView *)mainBoardView{
    if (!_mainBoardView) {
        _mainBoardView = [[YQBoardView alloc] initWithSize:self.size];
        _mainBoardView.translatesAutoresizingMaskIntoConstraints = NO;
        _mainBoardView.needGrid = YES;
        _mainBoardView.delegate = self;
        _mainBoardView.dataSource = self;
        
        // 旋转
        UITapGestureRecognizer *rotateGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(rotate)];
        [_mainBoardView addGestureRecognizer:rotateGes];
        
        // 下滑
        UISwipeGestureRecognizer *swipeGes = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(moveToBottom)];
        swipeGes.direction = UISwipeGestureRecognizerDirectionDown;
        [_mainBoardView addGestureRecognizer:swipeGes];
        
        // 左右移动
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [_mainBoardView addGestureRecognizer:panGes];
        
        // 只有在下滑失败时才能左右移动
        [panGes requireGestureRecognizerToFail:swipeGes];
    }
    return _mainBoardView;
}

- (YQBoardView *)componentBoardView{
    if (!_componentBoardView) {
        _componentBoardView = [[YQBoardView alloc] initWithSize:self.size];
        _componentBoardView.translatesAutoresizingMaskIntoConstraints = NO;
        _componentBoardView.delegate = self;
        _componentBoardView.dataSource = self;
        _componentBoardView.userInteractionEnabled = NO;
    }
    return _componentBoardView;
}

- (UIImageView *)bgView{
    if (!_bgView) {
        _bgView = [[UIImageView alloc] initWithImage:YQImage(@"background")];
        _bgView.frame = self.view.bounds;
        _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _bgView;
}

- (YQMainBoard *)mainBoard{
    if (!_mainBoard) {
        _mainBoard = [[YQMainBoard alloc] initWithSize:self.size];
        _mainBoard.delegate = self;
    }
    return _mainBoard;
}

- (YQComponentBoard *)componentBoard{
    if (!_componentBoard) {
        _componentBoard = [[YQComponentBoard alloc] initWithSize:self.size];
        _componentBoard.mainBoard = self.mainBoard;
        _componentBoard.delegate = self;
    }
    return _componentBoard;
}

- (YQToolView *)toolView{
    if (!_toolView) {
        _toolView = [[YQToolView alloc] initWithTypes:YQToolViewItemType_next | YQToolViewItemType_scores | YQToolViewItemType_play];
        _toolView.delegate = self;
        _toolView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _toolView;
}

- (YQScoresManager *)scoressManager{
    if (!_scoressManager) {
        _scoressManager = [[YQScoresManager alloc] init];
        _scoressManager.delegate = self;
    }
    return _scoressManager;
}

- (YQOperationView *)operationView{
    if (!_operationView) {
        _operationView = [[YQOperationView alloc] init];
        _operationView.translatesAutoresizingMaskIntoConstraints = NO;
        _operationView.backgroundColor = kYQColorClear;
        _operationView.delegate = self;
    }
    return _operationView;
}

#pragma mark - private
- (YQBoard *)boardFromView:(YQBoardView *)view{
    if (view == self.mainBoardView) {
        return self.mainBoard;
    }else if (view == self.componentBoardView){
        return self.componentBoard;
    }
    
    return nil;
}

// 重置组件
- (void)resetComponent{
    // 关闭定时器
    [self.timer invalidate];
    
    // 产生随机数
    YQBlockType type = YQBlockType_none;
    YQComponentShape shape = YQComponentShape_none;
    if (self.nextType != YQBlockType_none) {
        type = self.nextType;
    }else{
        type = rand() % (YQBlockType_max - YQBlockType_min + 1) + YQBlockType_min;
    }
    if (self.nextShape != YQComponentShape_none) {
        shape = self.nextShape;
    }else{
        shape = rand() % (YQComponentShape_max - YQComponentShape_min + 1) + YQComponentShape_min;
    }
    self.nextType = rand() % (YQBlockType_max - YQBlockType_min + 1) + YQBlockType_min;
    self.nextShape = rand() % (YQComponentShape_max - YQComponentShape_min + 1) + YQComponentShape_min;
    [self.toolView updateNextWithShap:self.nextShape blockType:self.nextType];
    
    // 重置组件
    [self.componentBoard resetBlocksWithShape:shape blockType:type];
    
    // 如果游戏结束，做相应处理,然后返回
    if ([self.componentBoard isGameOver]) {
        [self gameOver];
        return;
    }
    
    // 定时下移
    self.timer =
    [NSTimer scheduledTimerWithTimeInterval:self.timeSpace target:self selector:@selector(moveToDown) userInfo:nil repeats:YES];
}

- (void)gameOver{
    [UIAlertController yq_showAskAlertViewWithTitle:nil message:@"游戏结束" actionTitle:@"重新开始" action:^(UIAlertAction *action) {
        [self restartGame];
    }];
}

- (void)restartGame{
    [self.scoressManager reset];
    
    [self.mainBoard reset];
    [self.mainBoardView reloadData];
    
    [self.componentBoard reset];
    [self.componentBoardView reloadData];
    
    [self resetComponent];
}

#pragma mark - action
// 下移
- (void)moveToDown{
    BOOL success = [self.componentBoard changeBlocksWithPattern:YQComponentBlockChangePattern_moveToDown];
    
    // 若果下移不成功，那么证明已经到底了
    if (!success) {
        // 在主板上添加方块
        [self.mainBoard addBlocks:self.componentBoard.validBlockPoints withType:self.componentBoard.blockType];
        // 重置组件
        [self resetComponent];
    }
}

// 移到底部
- (void)moveToBottom{
    [self.componentBoard changeBlocksWithPattern:YQComponentBlockChangePattern_moveToBottom];
    
    // 在主板上添加方块
    [self.mainBoard addBlocks:self.componentBoard.validBlockPoints withType:self.componentBoard.blockType];
    // 重置组件
    [self resetComponent];
}

// 左右移动
- (void)panAction:(UIPanGestureRecognizer *)sender{
    
    CGFloat blockWidth = self.mainBoardView.gridSize.width;
    static CGFloat start = 0;
    if (sender.state == UIGestureRecognizerStateBegan) {
        start = [sender translationInView:self.mainBoardView].x;
        
    }else if (sender.state == UIGestureRecognizerStateChanged){
        YQComponentBlockChangePattern pattern = YQComponentBlockChangePattern_none;
        CGFloat current = [sender translationInView:self.mainBoardView].x;
        if (current - start >= blockWidth) {
            pattern = YQComponentBlockChangePattern_moveToRight;
        }else if (start - current >= blockWidth){
            pattern = YQComponentBlockChangePattern_moveToLeft;
        }
        
        if (pattern != YQComponentBlockChangePattern_none) {
            [self.componentBoard changeBlocksWithPattern:pattern];
            start = current;
        }
    }
}

// 旋转
- (void)rotate{
    [self.componentBoard changeBlocksWithPattern:YQComponentBlockChangePattern_rotate];
}

#pragma mark - YQBoardViewDataSource
// 获取数据源
- (YQBlockType)boardView:(YQBoardView *)view blockTypeAtPoint:(YQIntPoint)point{
    YQBoard *board = [self boardFromView:view];
    return [board blockAtPoint:point].type;
}

#pragma mark - YQBoardViewDelegate

#pragma mark - YQMainBoardDelegate
// 消除完成
- (void)mainBoard:(YQMainBoard *)board didRemoveLines:(NSIndexSet *)indexs{
    [self.scoressManager updateScoressWithLineNumber:indexs.count];
    [self.mainBoardView reloadData];
}

// 添加格子完成
- (void)mainBoard:(YQMainBoard *)board didAddBlocks:(NSArray<YQValue *> *)blocks{
    [self.mainBoardView reloadDataAtPoints:blocks];
}

#pragma mark - YQComponentBoardDelegate
// 有效方块发生变化
- (void)componentBoard:(YQComponentBoard *)componentBoard validBlocks:(NSArray *)oldBlocks didChange:(NSArray *)newBlocks{
    
    // 游戏结束
    if ([componentBoard isGameOver]) {
        return;
    }
    
    // 更新界面
    [self.componentBoardView reloadDataAtPoints:[oldBlocks arrayByAddingObjectsFromArray:newBlocks]];
}

#pragma mark - YQToolViewDelegate
- (void)toolView:(YQToolView *)view didClickPlayButton:(UIButton *)playButton{
    
    if (playButton.isSelected) {
        self.timer.fireDate = [NSDate distantFuture];
    }else{
        if (self.timer == nil && ![self.timer isValid]) {
            [self restartGame];
        }else{
            self.timer.fireDate = [NSDate date];
        }
    }
    
    playButton.selected = !playButton.isSelected;
}

#pragma mark - YQScoresManagerDelegate
- (void)scoresManager:(YQScoresManager *)manager scoressDidChanger:(NSInteger)scoress{
    [self.toolView updateScores:scoress];
}

#pragma mark - YQOperationViewDelegate
- (void)operationView:(YQOperationView *)view didClickType:(YQOperationType)type{
    switch (type) {
        case YQOperationType_rotate:
            [self rotate];
            break;
            
        case YQOperationType_bottom:
            [self moveToBottom];
            break;
            
        case YQOperationType_left:
             [self.componentBoard changeBlocksWithPattern:YQComponentBlockChangePattern_moveToLeft];
            break;
            
        case YQOperationType_right:
             [self.componentBoard changeBlocksWithPattern:YQComponentBlockChangePattern_moveToRight];
            break;
            
        default:
            break;
    }
}

@end
