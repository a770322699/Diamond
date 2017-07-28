//
//  YQComponentBoard.m
//  diamond
//
//  Created by Yiquan Ma on 2017/4/15.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQComponentBoard.h"

typedef NS_ENUM(NSInteger, YQCollideBlockManagerType) {
    YQCollideBlockManagerType_error,
    /*
             0
            0
     */
    YQCollideBlockManagerType_rightTop,
    /*
            0
            0
     */
    YQCollideBlockManagerType_topOne,
    /*
            0
     
            0
     */
    YQCollideBlockManagerType_topTwo,
};

@interface YQCollideBlockManager : NSObject

@property (nonatomic, assign) YQCollideBlockManagerType type;
@property (nonatomic, assign) YQIntPoint rotateCenter;  // 旋转中心
@property (nonatomic, strong) YQValue *currentPoint;  // 当前点
@property (nonatomic, strong) NSArray<YQValue *> *collideds;  // 旋转过程中会碰撞到的格子

@end

@implementation YQCollideBlockManager

- (instancetype)initWithType:(YQCollideBlockManagerType)type center:(YQIntPoint)center{
    if (self = [super init]) {
        self.type = type;
        self.rotateCenter = center;
        
        YQIntPoint current = {0, 0};
        NSMutableArray *collideds = [NSMutableArray array];
        switch (type) {
            case YQCollideBlockManagerType_rightTop:
                current = YQIntPointMake(center.x + 1, center.y - 1);
                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(current.x - 1, current.y)]];
                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(current.x - 2, current.y)]];
//                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(current.x, current.y - 1)]];
//                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(current.x - 1, current.y - 1)]];
//                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(current.x - 2, current.y - 1)]];
                break;
            
            case YQCollideBlockManagerType_topOne:
                current = YQIntPointMake(center.x, center.y - 1);
                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(center.x - 1, center.y - 1)]];
                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(center.x - 1, center.y)]];
                break;
                
            case YQCollideBlockManagerType_topTwo:
                current = YQIntPointMake(center.x, center.y - 2);
                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(current.x - 1, current.y)]];
                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(current.x - 2, current.y)]];
                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(current.x - 1, current.y - 1)]];
                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(current.x - 2, current.y - 1)]];
                [collideds addObject:[YQValue valueWithIntPoint:YQIntPointMake(center.x - 2, center.y)]];
                break;
                
            default:
                break;
        }
        [collideds addObject:[YQValue valueWithIntPoint:current]];
    }
    return self;
}

+ (instancetype)collideManagerWithType:(YQCollideBlockManagerType)type center:(YQIntPoint)center{
    return [[self alloc] initWithType:type center:center];
}

@end

/*YQCollideBlockManager end*/
/*********************************************************************************************/
/*YQComponentBoard begin*/

static const NSInteger kComponentBlockCount = 4;            // 有效方块数量

typedef NS_ENUM(NSInteger, YQComponentFirstLinePosition) {
    YQComponentFirstLinePosition_left,
    YQComponentFirstLinePosition_center,
    YQComponentFirstLinePosition_right,
};

typedef NS_OPTIONS(NSInteger, YQComponentMovePosition) {      // 移动方位
    YQComponentMovePosition_none        = 0,
    YQComponentMovePosition_up          = 1 << 1,
    YQComponentMovePosition_left        = 1 << 2,
    YQComponentMovePosition_down        = 1 << 3,
    YQComponentMovePosition_right       = 1 << 4,
};

typedef NS_ENUM(NSInteger, YQComponentDirection) {      // 组件的方向
    YQComponentDirection_up,
    YQComponentDirection_left,
    YQComponentDirection_down,
    YQComponentDirection_right,
};

typedef NS_ENUM(NSInteger, YQComponentRotateDirection) {                // 旋转方向
    YQComponentRotateDirection_anticlockwise,       // 逆时针
    YQComponentRotateDirection_clockwise,           // 顺时针
};

@interface YQComponentBoard ()

@property (nonatomic, assign) YQComponentShape shape;         // 形状
@property (nonatomic, assign) YQBlockType blockType;          // 方块类型
@property (nonatomic, assign) YQComponentDirection direction;   // 组件的方向
@property (nonatomic, strong) NSArray *validBlockPoints;     // 有效的方块所在的位置
@property (nonatomic, assign) YQIntPoint rotateCenter;  // 旋转中心

@end

@implementation YQComponentBoard

#pragma mark - private
// 移除有效方块
- (void)removeValidBlocks{
    for (YQValue *pointValue in self.validBlockPoints) {
        [self setBlock:[YQBlock block] atPoint:[pointValue intPoint]];
    }
    
    self.validBlockPoints = nil;
}

// 添加有效方块
- (void)addValidBlocks:(NSArray *)validPoints{
    for (YQValue *pointValue in validPoints) {
        [self setBlock:[YQBlock blockWithType:self.blockType] atPoint:[pointValue intPoint]];
    }
    
    self.validBlockPoints = validPoints;
}

// 创建有效方块
- (NSArray *)createValidBlocks{
    
    NSArray *validPoints = nil;
    switch (self.shape) {
        case YQComponentShape_line:
            validPoints = [self validBlocksWithFirstLintCount:0 firstLinePosition:YQComponentFirstLinePosition_center];
            break;
            
        case YQComponentShape_leftFolded:
            validPoints = [self validBlocksWithFirstLintCount:1 firstLinePosition:YQComponentFirstLinePosition_left];
            break;
            
        case YQComponentShape_rightFolded:
            validPoints = [self validBlocksWithFirstLintCount:1 firstLinePosition:YQComponentFirstLinePosition_right];
            break;
            
        case YQComponentShape_bulge:
            validPoints = [self validBlocksWithFirstLintCount:1 firstLinePosition:YQComponentFirstLinePosition_center];
            break;
            
        case YQComponentShape_leftSlipped:
            validPoints = [self validBlocksWithFirstLintCount:2 firstLinePosition:YQComponentFirstLinePosition_left];
            break;
            
        case YQComponentShape_rightSlipped:
            validPoints = [self validBlocksWithFirstLintCount:2 firstLinePosition:YQComponentFirstLinePosition_right];
            break;
            
        case YQComponentShape_grid:
            validPoints = [self validBlocksWithFirstLintCount:2 firstLinePosition:YQComponentFirstLinePosition_center];
            break;
            
        default:
            break;
    }
    
    return validPoints;
}

- (NSArray *)validBlocksWithFirstLintCount:(NSInteger)count firstLinePosition:(YQComponentFirstLinePosition)position{
    if (count < 0 || count > kComponentBlockCount) {
        return nil;
    }
    
    NSInteger firstCount = count;
    NSInteger secondCount = kComponentBlockCount - firstCount;
    
    NSMutableArray *points = [NSMutableArray array];
    if (firstCount) {
        [points addObjectsFromArray:[self aLineValidBlocksWithCount:firstCount y:self.size.height - 1 position:position]];
        [points addObjectsFromArray:[self aLineValidBlocksWithCount:secondCount y:self.size.height - 2 position:YQComponentFirstLinePosition_center]];
    }else{
        [points addObjectsFromArray:[self aLineValidBlocksWithCount:secondCount y:self.size.height - 1 position:YQComponentFirstLinePosition_center]];
    }
    
    return points;
}

- (NSArray *)aLineValidBlocksWithCount:(NSInteger)count y:(NSInteger)y position:(YQComponentFirstLinePosition)position{
    if (count <= 0 || count > self.size.width) {
        return nil;
    }
    
    if (y < 0 || y >= self.size.height) {
        return nil;
    }
    
    NSInteger center = self.size.width / 2;
    NSInteger startX = center - (count / 2);
    if (position == YQComponentFirstLinePosition_left) {
        startX--;
    }else if (position == YQComponentFirstLinePosition_right){
        startX++;
    }
    
    NSMutableArray *points = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        NSInteger x = startX + i;
        if (x < 0 || x >= self.size.width) {
            return nil;
        }
        
        [points addObject:[YQValue valueWithIntPoint:YQIntPointMake(x, y)]];
    }
    
    return points;
}

// 是否到达边界
- (BOOL)didArriveBorder:(YQComponentMovePosition)direction{
    for (YQValue *pointValue in self.validBlockPoints) {
        YQIntPoint point = [pointValue intPoint];
        switch (direction) {
            case YQComponentMovePosition_up:
                point.y++;
                break;
            
            case YQComponentMovePosition_down:
                point.y--;
                break;
                
            case YQComponentMovePosition_left:
                point.x--;
                break;
                
            case YQComponentMovePosition_right:
                point.x++;
                break;
                
            default:
                break;
        }
        
        if (point.x < 0 || point.x >= self.size.width) {    // 水平方向超出边界
            return YES;
        }
        
        if (point.y < 0 || point.y >= self.size.height) {   // 垂直方向超出边界
            return YES;
        }
        
        if ([self.mainBoard blockAtPoint:point].type != YQBlockType_none) {  // 边上已存在方块
            return YES;
        }
    }
    
    return NO;
}

// 向上、左、下、右移动
- (BOOL)moveBlocks:(YQComponentMovePosition)direction{
    // 已经达到边界，直接返回no
    if ([self didArriveBorder:direction]) {
        return NO;
    }
    
    YQIntPoint offset = {0, 0};
    YQIntPoint rotateCenter = self.rotateCenter;
    switch (direction) {
        case YQComponentMovePosition_left:
            rotateCenter.x--;
            
            offset.x = -1;
            offset.y = 0;
            break;
            
        case YQComponentMovePosition_down:
            rotateCenter.y--;
            
            offset.x = 0;
            offset.y = -1;
            break;
            
        case YQComponentMovePosition_up:
            rotateCenter.y++;
            
            offset.x = 0;
            offset.y = 1;
            break;
            
        case YQComponentMovePosition_right:
            rotateCenter.x++;
            
            offset.x = 1;
            offset.y = 0;
            break;
            
        default:
            break;
    }
    
    NSMutableArray *validPoints = [NSMutableArray array];
    for (YQValue *pointValue in self.validBlockPoints) {
        [validPoints addObject:[pointValue intPointValueWithOffsetIntPoint:offset]];
    }
    
    [self resetBlocks:validPoints];
    
    self.rotateCenter = rotateCenter;
    
    return YES;
        
}

- (BOOL)moveToBottom{
    // 如果不能下移，直接返回no
    if ([self didArriveBorder:YQComponentMovePosition_down]) {
        return NO;
    }
    
    // 一直向下移动，直到向下移动失败
    BOOL success = NO;
    do {
        success = [self moveBlocks:YQComponentMovePosition_down];
    } while (success);
    
    return YES;
}

// 旋转后得到一个新的点
// 逆时针旋转，angle只能为 π/2的整数倍
- (YQValue *)retatePoint:(YQValue *)ponint retateCenter:(YQIntPoint)center angle:(CGFloat)angle{
    YQIntPoint intPoint = [ponint intPoint];
    
    double sinAngle = sin(angle);
    double cosAngle = cos(angle);
    if (angle == M_PI_2) {
        sinAngle = 1;
        cosAngle = 0;
    }else if (angle == -M_PI_2){
        sinAngle = -1;
        cosAngle = 0;
    }
    
    // 先平移
    intPoint = YQIntPointMake(intPoint.x - self.rotateCenter.x, intPoint.y - self.rotateCenter.y);
    // 绕原点旋转
    intPoint = YQIntPointMake(intPoint.x * cosAngle - intPoint.y * sinAngle, intPoint.x * sinAngle + intPoint.y * cosAngle);
    // 再平移回去
    intPoint = YQIntPointMake(intPoint.x + self.rotateCenter.x, intPoint.y + self.rotateCenter.y);
    
    return [YQValue valueWithIntPoint:intPoint];
}

// 返回旋转过程中会碰到的格子
- (NSArray<YQValue *> *)collideBlocksWithRotatePoint:(YQIntPoint)point direction:(YQComponentRotateDirection)direction{
    // 如果是顺时针，先转动
    if (direction == YQComponentRotateDirection_clockwise) {
        point = [[self retatePoint:[YQValue valueWithIntPoint:point] retateCenter:self.rotateCenter angle: -M_PI_2] intPoint];
    }
    
    NSInteger dx = labs(point.x - self.rotateCenter.x);
    NSInteger dy = labs(point.y - self.rotateCenter.y);
    
    YQCollideBlockManagerType collideType = YQCollideBlockManagerType_error;
    if (dx == 1 && dy == 1) {
        collideType = YQCollideBlockManagerType_rightTop;
    }else if ((dx == 0 && dy == 1) || (dy == 0 && dx == 1)){
        collideType = YQCollideBlockManagerType_topOne;
    }else if ((dx == 0 && dy == 2) || (dy == 0 && dx == 2)){
        collideType = YQCollideBlockManagerType_topTwo;
    }
    YQCollideBlockManager *collideManager = [YQCollideBlockManager collideManagerWithType:collideType center:self.rotateCenter];
    
    CGFloat angle = 0;
    YQIntPoint managerPoint = [collideManager.currentPoint intPoint];
    if (!YQIntPointIsEqual(point, managerPoint)) {
        YQValue *pointValue = [YQValue valueWithIntPoint:point];
        if (YQIntPointIsEqual([[self retatePoint:pointValue retateCenter:self.rotateCenter angle:M_PI_2] intPoint], managerPoint)) {
            angle = -M_PI_2;
        }else if (YQIntPointIsEqual([[self retatePoint:pointValue retateCenter:self.rotateCenter angle:M_PI] intPoint], managerPoint)){
            angle = M_PI;
        }else if (YQIntPointIsEqual([[self retatePoint:pointValue retateCenter:self.rotateCenter angle:- M_PI_2] intPoint], managerPoint)){
            angle = M_PI_2;
        }else{
            return nil;
        }
    }
    
    NSMutableArray *collides = [NSMutableArray array];
    for (YQValue *managerCollide in collideManager.collideds) {
        YQValue *collide = [self retatePoint:managerCollide retateCenter:self.rotateCenter angle:angle];
        [collides addObject:collide];
    }
    
    return collides;
}

- (YQComponentBoard *)rotateWithDirection:(YQComponentRotateDirection)direction cannot:(YQComponentMovePosition)cannots{
    for (YQValue *validPoint in self.validBlockPoints) {
        YQIntPoint point = [validPoint intPoint];
        NSArray<YQValue *> *collides = [self collideBlocksWithRotatePoint:point direction:direction];
        for (YQValue *collide in collides) {
            YQIntPoint intCollide = [collide intPoint];
            if ([self.mainBoard blockAtPoint:intCollide].type != YQBlockType_none) {
                YQComponentMovePosition movePosition = YQComponentMovePosition_none;
                NSInteger dx = intCollide.x - point.x;
                NSInteger dy = intCollide.y - point.y;
                NSInteger absDx = labs(dx);
                NSInteger absDy = labs(dy);
                
                if (dx >= 0) {
                    if (dy >= 0) {
                        if (absDx >= absDy) {
                            movePosition = YQComponentMovePosition_left;
                        }else{
                            movePosition = YQComponentMovePosition_down;
                        }
                    }else{
                        if (absDx >= absDy) {
                            movePosition = YQComponentMovePosition_left;
                        }else{
                            movePosition = YQComponentMovePosition_up;
                        }
                    }
                }else{
                    if (dy >= 0) {
                        if (absDx >= absDy) {
                            movePosition = YQComponentMovePosition_right;
                        }else{
                            movePosition = YQComponentMovePosition_down;
                        }
                    }else{
                        if (absDx >= absDy) {
                            movePosition = YQComponentMovePosition_left;
                        }else{
                            movePosition = YQComponentMovePosition_down;
                        }
                    }
                }
                
                if (cannots & movePosition) {
                    return nil;
                }else{
                    YQComponentBoard *copyBoard = [self copy];
                    [copyBoard moveBlocks:movePosition];
                    return [copyBoard rotateWithDirection:direction cannot:cannots | movePosition];
                }
            }
        }
    }
    
    YQComponentBoard *copyBoard = [self copy];
    NSMutableArray *validPoints = [NSMutableArray array];
    CGFloat angle = M_PI_2;
    if (direction == YQComponentRotateDirection_clockwise) {
        angle = -angle;
    }
    for (YQValue *validPoint in self.validBlockPoints) {
        YQValue *changePoint = [self retatePoint:validPoint retateCenter:self.rotateCenter angle:angle];
        YQIntPoint intChangePoint = [changePoint intPoint];
        
        YQComponentMovePosition movePositionX = YQComponentMovePosition_none;
        YQComponentMovePosition movePositionY = YQComponentMovePosition_none;
        if (intChangePoint.x < 0) {
            movePositionX = YQComponentMovePosition_right;
        }else if (intChangePoint.x >= self.size.width){
            movePositionX = YQComponentMovePosition_left;
        }
        if (intChangePoint.y < 0) {
            movePositionY = YQComponentMovePosition_up;
        }else if (intChangePoint.y >= self.size.height){
            movePositionY = YQComponentMovePosition_down;
        }
        
        BOOL didMove = NO;
        if (movePositionX != YQComponentMovePosition_none) {
            if (cannots & movePositionX) {
                return nil;
            }
            [copyBoard moveBlocks:movePositionX];
            didMove = YES;
        }
        if (movePositionY != YQComponentMovePosition_none) {
            if (cannots & movePositionY) {
                return nil;
            }
            [copyBoard moveBlocks:movePositionY];
            didMove = YES;
        }
        
        if (didMove) {
            return [copyBoard rotateWithDirection:direction cannot:cannots | movePositionY | movePositionX];
        }
        
        [validPoints addObject:changePoint];
    }
    [copyBoard resetBlocks:validPoints];
    
    return copyBoard;
}

- (BOOL)rotate{
    // 如果是田字格，直接返回yes
    if (self.shape == YQComponentShape_grid) {
        return YES;
    }
    
    YQComponentRotateDirection direction = YQComponentRotateDirection_anticlockwise;
    if (self.shape == YQComponentShape_line || self.shape == YQComponentShape_rightSlipped || self.shape == YQComponentShape_leftSlipped) {
        if (self.direction == YQComponentDirection_left || self.direction == YQComponentDirection_right) {
            direction = YQComponentRotateDirection_clockwise;
        }
    }
    
    YQComponentBoard *rotatedBoard = [self rotateWithDirection:direction cannot:YQComponentMovePosition_none];
    if (rotatedBoard) {
        self.rotateCenter = rotatedBoard.rotateCenter;
        [self resetBlocks:rotatedBoard.validBlockPoints];
        
        return YES;
    }
    
    return NO;
}


// 重置有效格子
- (void)resetBlocks:(NSArray *)blockPoints{
    
    // 移除有效格子
    [self removeValidBlocks];
    
    // 添加格子
    [self addValidBlocks:blockPoints];
}

// 重置旋转中心
- (void)resetRotateCenter{
    NSInteger x = self.size.width / 2;
    NSInteger y = self.size.height - 2;
    
    if (self.shape == YQComponentShape_line) {
        y++;
    }
    
    self.rotateCenter = YQIntPointMake(x, y);
}

#pragma mark - public
// 重置方块
- (void)resetBlocksWithShape:(YQComponentShape)shape blockType:(YQBlockType)blockType{
    
    NSArray *oldBlocks = self.validBlockPoints;
    
    self.shape = shape;
    self.blockType = blockType;
    
    // 重置格子
    [self resetBlocks:[self createValidBlocks]];
    // 重置旋转中心
    [self resetRotateCenter];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(componentBoard:validBlocks:didChange:)]) {
        [self.delegate componentBoard:self validBlocks:oldBlocks didChange:self.validBlockPoints];
    }
}

// 改变方块
- (BOOL)changeBlocksWithPattern:(YQComponentBlockChangePattern)pattern{
    NSArray *oldBlocks = [self.validBlockPoints copy];
    BOOL result = NO;
    
    if (pattern == YQComponentBlockChangePattern_reset) {   // 重置
        [self resetBlocksWithShape:self.shape blockType:self.blockType];
        return YES;
    }
    
    if (!self.mainBoard) {  // 如果主面板不存在，直接返回no
        return NO;
    }
    if (!YQIntSizeIsEqual(self.mainBoard.size, self.size)) { // 如果组件和主板的大小不等，直接返回no，不能操作
        return NO;
    }
    
    switch (pattern) {
        case YQComponentBlockChangePattern_moveToDown:
            result = [self moveBlocks:YQComponentMovePosition_down];
            break;
        
        case YQComponentBlockChangePattern_moveToLeft:
            result =  [self moveBlocks:YQComponentMovePosition_left];
            break;
            
        case YQComponentBlockChangePattern_moveToRight:
            result =  [self moveBlocks:YQComponentMovePosition_right];
            break;
            
        case YQComponentBlockChangePattern_moveToBottom:
            result =  [self moveToBottom];
            break;
        
        case YQComponentBlockChangePattern_rotate:
            result =  [self rotate];
            break;
            
        default:
            break;
    }
    
    // 通知代理回调
    if (result && self.delegate && [self.delegate respondsToSelector:@selector(componentBoard:validBlocks:didChange:)]) {
        [self.delegate componentBoard:self validBlocks:oldBlocks didChange:self.validBlockPoints];
    }

    return result;
}

// 判断是否已经到达底部
- (BOOL)didArriveBottom{
    return [self didArriveBorder:YQComponentMovePosition_down];
}

// 判断是否已经重叠
- (BOOL)isGameOver{
    return [self didArriveBorder:YQComponentMovePosition_none];
}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone{
    YQComponentBoard *board = nil;
    if ([super respondsToSelector:@selector(copyWithZone:)]) {
        board = [super copyWithZone:zone];
    }else{
        board = [(YQComponentBoard *)[[self class] alloc] initWithSize:self.size];
    }
    
    board.shape = self.shape;
    board.blockType = self.blockType;
    board.delegate = self.delegate;
    board.mainBoard = self.mainBoard;
    board.direction = self.direction;
    board.validBlockPoints = [self.validBlockPoints copy];
    board.rotateCenter = self.rotateCenter;
    
    return board;
}

@end
