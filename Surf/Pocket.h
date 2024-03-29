//
//  Pocket.h
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pocket : NSObject
- (void)getData;
+ (NSDictionary *)layoutFrom:(NSDictionary *)site;
+ (NSString *)selected:(NSDictionary *)site;
+ (CGFloat)width:(NSDictionary *)site;
+ (CGFloat)height:(NSDictionary *)site;
+ (void)deletePocket:(NSString *)item_id;
+ (void)archivePocket:(NSString *)item_id;
@end
