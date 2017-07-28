//
//  YQScoresManager.m
//  diamond
//
//  Created by maygolf on 17/5/23.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import "YQScoresManager.h"

static const NSInteger kMaxClearCount = 4;

@interface YQScoresManager ()

@property (nonatomic, assign) NSInteger scoress;
@property (nonatomic, assign) NSInteger maxClearNumber; // 4清数

@end

@implementation YQScoresManager

#pragma mark - public
- (void)reset{
    self.scoress = 0;
    self.maxClearNumber = 0;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scoresManager:scoressDidChanger:)]) {
        [self.delegate scoresManager:self scoressDidChanger:self.scoress];
    }
}
- (void)updateScoressWithLineNumber:(NSInteger)lineNumber{
    NSInteger scoress = 0;
    switch (lineNumber) {
        case 1:
            scoress = 10;
            self.maxClearNumber = 0;
            break;
            
        case 2:
            scoress = 25;
            self.maxClearNumber = 0;
            break;
            
        case 3:
            scoress = 50;
            self.maxClearNumber = 0;
            break;
            
        case 4:
            self.maxClearNumber++;
            scoress = 40 + 40 * self.maxClearNumber;
            break;
            
        default:
            break;
    }
    
    self.scoress += scoress;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(scoresManager:scoressDidChanger:)]) {
        [self.delegate scoresManager:self scoressDidChanger:self.scoress];
    }
}

@end
