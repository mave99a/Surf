//
//  Twitter.m
//  Surf
//
//  Created by Sapan Bhuta on 6/15/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define kAPI @"https://api.twitter.com/1.1/statuses/home_timeline.json"

#import "Twitter.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "SDWebImage/UIImageView+WebCache.h"

@interface Twitter ()
@property id dataSource;
@property NSMutableArray *tweets;
@end

@implementation Twitter

- (void)getData
{
    NSLog(@"Twitter");

    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];

             if ([arrayOfAccounts count] > 0)
             {
                 ACAccount *twitterAccount = arrayOfAccounts.lastObject;
                 NSURL *requestURL = [NSURL URLWithString: kAPI];
                 NSDictionary *parameters = @{@"count" : @"200"};
                 SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                             requestMethod:SLRequestMethodGET
                                                                       URL:requestURL
                                                                parameters:parameters];
                 postRequest.account = twitterAccount;
                 [postRequest performRequestWithHandler: ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if (!error)
                      {
                          self.dataSource = [NSJSONSerialization JSONObjectWithData:responseData
                                                                            options:NSJSONReadingMutableLeaves
                                                                              error:&error];
                          if (!error)
                          {
                              if ([self.dataSource isKindOfClass:[NSDictionary class]])
                              {
                                  NSLog(@"%@",self.dataSource);
//                                  UIAlertView *alert = [[UIAlertView alloc] init];
//                                  alert.title = @"Pulling from Twitter too often";
//                                  alert.message = @"Please retry after 2 minutes";
//                                  [alert addButtonWithTitle:@"Dismiss"];
//                                  [alert show];
                              }
                              else
                              {
                                  [self filterTweetsForLinkedPosts];

                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"Twitter" object:self.tweets];
                                  });

                              }
                          }
                          else
                          {
                              UIAlertView *alert = [[UIAlertView alloc] init];
                              alert.title = @"Error Understanding Twitter Data";
                              alert.message = @"Please retry later and check for an app update";
                              [alert addButtonWithTitle:@"Dismiss"];
                              [alert show];
                          }
                      }
                      else
                      {
                          UIAlertView *alert = [[UIAlertView alloc] init];
                          alert.title = @"Error Connecting to Twitter";
                          alert.message = @"Please check your internet connection";
                          [alert addButtonWithTitle:@"Dismiss"];
                          [alert show];
                      }
                  }];
             }
             else
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"stopSpinner" object:nil];
             }
         }
         else
         {
             UIAlertView *alert = [[UIAlertView alloc] init];
             alert.title = @"Error Authenticating to Twitter";
             alert.message = @"Please login to Twitter in the settings app";
             [alert addButtonWithTitle:@"Dismiss"];
             [alert show];
        }
     }
     ];
}

- (void)filterTweetsForLinkedPosts
{
    self.tweets = [NSMutableArray new];

    for (NSDictionary *tweet in self.dataSource)
    {
        NSArray *urls = tweet[@"entities"][@"urls"];

        if (urls.count)
        {
            [self.tweets addObject:tweet];
        }
    }
}

+ (NSDictionary *)layoutFrom:(NSDictionary *)tweet
{
    NSDictionary *originalTweet = tweet;
    NSDictionary *retweet = tweet[@"retweeted_status"];

    NSString *textLabel;
    NSString *detailTextLabel;
    NSString *imgUrlString;

    if (retweet)
    {
        tweet = retweet;
        detailTextLabel = [NSString stringWithFormat:@"%@\nRetweeted by: %@",tweet[@"user"][@"name"], originalTweet[@"user"][@"name"]];
    }
    else
    {
        detailTextLabel = tweet[@"user"][@"name"];
    }

    textLabel = [self modifyTweetText:tweet];
    imgUrlString = tweet[@"user"][@"profile_image_url"];

//    data now convert to view

//collection view
//    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self width:tweet], [self height:tweet])];
//    contentView.backgroundColor = [UIColor whiteColor];
//
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10+48+10, 0, 320-68-5, contentView.frame.size.height)];
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,48,48)];
//    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.origin.x+20,
//                                                                  contentView.frame.size.height-.5,
//                                                                  contentView.frame.size.width-20,
//                                                                  .5)];
//
//    textView.text = [NSString stringWithFormat:@"%@\n\n%@",textLabel,detailTextLabel];
//    textView.font = [UIFont systemFontOfSize:13];
//    textView.editable = NO;
//    textView.selectable = NO;
//    textView.userInteractionEnabled = NO;
//
//    [imageView setImageWithURL:[NSURL URLWithString:imgUrlString] placeholderImage:[UIImage imageNamed:@"bluewave"]];
//    imageView.center = CGPointMake(10+24, CGRectGetMidY(contentView.frame));
//    imageView.layer.masksToBounds = YES;
//    imageView.layer.cornerRadius = 48/2;
//
//    borderView.backgroundColor = [UIColor lightGrayColor];
//
//    [contentView addSubview:textView];
//    [contentView addSubview:imageView];
//    [contentView addSubview:borderView];

    return @{@"simple":@YES,
             @"text":textLabel,
             @"subtext":detailTextLabel,
             @"image":imgUrlString,
//             @"contentView":contentView,
             @"Cell1Exist":@YES,
             @"Cell1Image":@"pocket-cell",
             @"Cell1Color":[UIColor colorWithRed:0.941 green:0.243 blue:0.337 alpha:1],
             @"Cell1Mode":@2,
             @"Cell2Exist":@NO,
             @"Cell2Image":@"twitter-cell",
             @"Cell2Color":[UIColor colorWithRed:0 green:0.69 blue:0.929 alpha:1],
             @"Cell2Mode":@2,
             };
}

+ (NSString *)modifyTweetText:(NSDictionary *)tweet
{
    NSString *tweetText = tweet[@"text"];
    NSURL *url = [NSURL URLWithString:tweet[@"entities"][@"urls"][0][@"expanded_url"]];
    NSArray *indices = tweet[@"entities"][@"urls"][0][@"indices"];
    int index0 = [indices[0] intValue];
    int index1 = [indices[1] intValue];
    NSString *host = url.host;
    if ([host hasPrefix:@"www."])
    {
        host = [host substringFromIndex:[@"www." length]];
    }
    NSString *newTweetText = [tweetText stringByReplacingCharactersInRange:NSMakeRange(index0, index1-index0) withString:host];

    return [self cleanup:newTweetText];
}

+ (NSString *)cleanup:(NSString *)tweetText
{
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    tweetText = [tweetText stringByReplacingOccurrencesOfString:@"&apos;" withString:@"\'"];
    return tweetText;
}

+ (NSString *)selected:(NSDictionary *)tweet
{
    return tweet[@"entities"][@"urls"][0][@"expanded_url"];
}

+ (CGFloat)width:(NSDictionary *)tweet
{
    return 320;
}

+ (CGFloat)height:(NSDictionary *)tweet
{
    return 120;
}

+ (void)retweet:(NSDictionary *)tweet
{

    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        NSString *text;
        NSURL *url;
        if (tweet[@"retweeted_status"])
        {
            text = [NSString stringWithFormat:@"%@",tweet[@"text"]];
            url = [NSURL URLWithString:tweet[@"entities"][@"urls"][0][@"expanded_url"]];
        }
        else
        {
            text = [NSString stringWithFormat:@"RT @%@ %@",tweet[@"user"][@"screen_name"],tweet[@"text"]];
            url = [NSURL URLWithString:tweet[@"entities"][@"urls"][0][@"expanded_url"]];
        }
        NSLog(@"%@",url);
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:text];
        [tweetSheet addURL:url];
//        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Sorry"
                                  message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup"
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

+ (void)retweetAdvanced:(NSDictionary *)tweet
{
    NSString *id_str = tweet[@"retweeted_status"] ? tweet[@"retweeted_status"][@"id_str"] : tweet[@"id_str"];
    NSString *api = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json",id_str];

    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [account requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];

             if ([arrayOfAccounts count] > 0)
             {
                 ACAccount *twitterAccount = arrayOfAccounts.lastObject;
                 NSURL *requestURL = [NSURL URLWithString:api];
                 NSDictionary *parameters = @{@"id" : id_str};
                 SLRequest *postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                             requestMethod:SLRequestMethodPOST
                                                                       URL:requestURL
                                                                parameters:parameters];
                 postRequest.account = twitterAccount;
                 [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      //tell that you retweeted
                  }];
             }
         }
     }];
}

@end
