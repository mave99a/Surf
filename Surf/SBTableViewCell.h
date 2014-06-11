//
//  SBTableViewCell.h
//  Surf
//
//  Created by Sapan Bhuta on 6/9/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBTableViewCell : UITableViewCell

+ (CGFloat)heightForCellWithTweet:(NSDictionary *)tweet;
- (void)layoutWithTweetFrom:(NSMutableArray *)tweets AtIndexPath:(NSIndexPath *)indexPath;

@end