//
//  YQScoresManager.h
//  diamond
//
//  Created by maygolf on 17/5/23.
//  Copyright © 2017年 YiquanMa. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YQScoresManager;
@protocol YQScoresManagerDelegate <NSObject>

- (void)scoresManager:(YQScoresManager *)manager scoressDidChanger:(NSInteger)scoress;

@end

@interface YQScoresManager : NSObject

@property (nonatomic, readonly) NSInteger scoress;

@property (nonatomic, weak) id<YQScoresManagerDelegate> delegate; 

- (void)reset;
- (void)updateScoressWithLineNumber:(NSInteger)lineNumber;

@end
