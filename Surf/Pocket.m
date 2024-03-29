//
//  Pocket.m
//  Surf
//
//  Created by Sapan Bhuta on 6/18/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"https://getpocket.com/v3/get"

#import "Pocket.h"
#import "PocketAPI.h"

@interface Pocket ()
@property NSMutableArray *data;
@end

@implementation Pocket

- (void)getData
{
    NSLog(@"Pocket, user: %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"pocketLoggedIn"]);


    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"pocketLoggedIn"])
    {
        [[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error)
        {
            if (!error)
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"pocketLoggedIn"];
                [self getPockets];
            }
        }];
    }
    else
    {
        [self getPockets];
    }
}

- (void)getPockets
{
    self.data = [NSMutableArray new];

    [[PocketAPI sharedAPI] callAPIMethod:@"get"
                          withHTTPMethod:PocketAPIHTTPMethodPOST
                               arguments:@{@"sort":@"newest"}
                                 handler:^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error)
    {
        if (!error && response)
        {
//            NSLog(@"response %@", [response description]);

            for (NSDictionary *article in response[@"list"])
            {
                NSDictionary *site = @{@"url":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"resolved_url"],
                                       @"title":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"resolved_title"],
                                       @"excerpt":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"excerpt"],
                                       @"item_id":response[@"list"][[NSString stringWithFormat:@"%@",article]][@"item_id"]};

                [self.data addObject:site];
            }

//            NSLog(@"data %@",self.data);

            [[NSNotificationCenter defaultCenter] postNotificationName:@"Pocket" object:self.data];
        }
        else
        {
            NSLog(@"error %@", [error localizedDescription]);

            UIAlertView *alert = [[UIAlertView alloc] init];
            alert.title = @"Error Retrieving Data";
            alert.message = @"Please check your internet connection & for an app update (API might be broken)";
            [alert addButtonWithTitle:@"Dismiss"];
            [alert show];
        }
    }];
}

+ (NSDictionary *)layoutFrom:(NSDictionary *)site
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self width:site], [self height:site])];
    contentView.backgroundColor = [UIColor whiteColor];

    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 0, 300, contentView.frame.size.height)];
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.origin.x+20,
                                                                  contentView.frame.size.height-.5,
                                                                  contentView.frame.size.width-20,
                                                                  .5)];

    NSURL *url = [NSURL URLWithString:site[@"url"]];
    NSString *host = url.host;
    if ([host hasPrefix:@"www."])
    {
        host = [host substringFromIndex:[@"www." length]];
    }

    textView.text = [NSString stringWithFormat:@"%@\n%@",site[@"title"],host];
    textView.font = [UIFont systemFontOfSize:13];
    textView.editable = NO;
    textView.selectable = NO;
    textView.userInteractionEnabled = NO;

    borderView.backgroundColor = [UIColor lightGrayColor];

    [contentView addSubview:textView];
    [contentView addSubview:borderView];

    return @{@"simple":@YES,
             @"text":site[@"title"],
             @"subtext":host,
             @"contentView":contentView,
             @"Cell1Exist":@YES,
             @"Cell1Image":@"check",
             @"Cell1Color":[UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0],
             @"Cell1Mode":@1,
             @"Cell2Exist":@YES,
             @"Cell2Image":@"cross",
             @"Cell2Color":[UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0],
             @"Cell2Mode":@1,
             };
}

+ (NSString *)selected:(NSDictionary *)site
{
    return site[@"url"];
}

+ (CGFloat)width:(NSDictionary *)site
{
    return 320;
}

+ (CGFloat)height:(NSDictionary *)site
{
    return 68;
}

+ (void)archivePocket:(NSString *)item_id
{
    [[PocketAPI sharedAPI] callAPIMethod:@"send"
                          withHTTPMethod:PocketAPIHTTPMethodPOST
                               arguments:@{@"actions":@[@{ @"action": @"archive", @"item_id":item_id}]}
                                 handler:^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error)
     {
         NSLog(@"response %@", [response description]);
         NSLog(@"error %@", [error localizedDescription]);
     }];
}

+ (void)deletePocket:(NSString *)item_id
{
    [[PocketAPI sharedAPI] callAPIMethod:@"send"
                          withHTTPMethod:PocketAPIHTTPMethodPOST
                               arguments:@{@"actions":@[@{ @"action": @"delete", @"item_id":item_id}]}
                                 handler:^(PocketAPI *api, NSString *apiMethod, NSDictionary *response, NSError *error)
     {
         NSLog(@"response %@", [response description]);
         NSLog(@"error %@", [error localizedDescription]);
     }];
}

@end
