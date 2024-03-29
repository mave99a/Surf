//
//  TwitterViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 6/6/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#define CellIdentifier @"Cell"
#define PickTableView 0
#define PickCollectionView 1

#define kWall @"back"

#import "ReadingViewController.h"
#import "SettingsViewController.h"
#import "MCSwipeTableViewCell.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "Twitter.h"
#import "Global.h"
#import "Feedly.h"
#import "Pocket.h"
#import "Instapaper.h"
#import "Readability.h"
#import "Facebook.h"
#import "Dribbble.h"
#import "Designernews.h"
#import "Bookmarks.h"
#import "History.h"
#import "Hackernews.h"
#import "Reddit.h"
#import "Producthunt.h"
#import "Gmail.h"
#import "RSS.h"
#import "Techcrunch.h"
#import "Theverge.h"
@import Twitter;
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "PocketAPI.h"
#import "UIImage+ImageEffects.h"

@interface ReadingViewController () <
                                    UITableViewDataSource,
                                    UITableViewDelegate,
                                    UICollectionViewDataSource,
                                    UICollectionViewDelegateFlowLayout,
                                    UIPickerViewDelegate,
                                    UIPickerViewDataSource,
                                    UIGestureRecognizerDelegate
                                    >
@property UITableView *tableView;
@property UICollectionView *collectionView;
@property UICollectionView *buttons;
@property UIPickerView *pickerView;
@property UIActivityIndicatorView *activity;
@property NSArray *buttonItems;
@property NSArray *data;
@property UISwipeGestureRecognizer *swipeLeft;
@property UISwipeGestureRecognizer *swipeRight;
@property Class selectedClass;
@property Twitter *twitter;
@property Global *global;
@property Feedly *feedly;
@property Pocket *pocket;
@property Instapaper *instapaper;
@property Readability *readability;
@property Facebook *facebook;
@property Dribbble *dribbble;
@property Designernews *designernews;
@property Bookmarks *bookmarks;
@property History *history;
@property Hackernews *hackernews;
@property Reddit *reddit;
@property Producthunt *producthunt;
@property Gmail *gmail;
@property RSS *rss;
@property Techcrunch *techcrunch;
@property Theverge *theverge;
@end

@implementation ReadingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    [self loadButtonItems];
    [self loadServiceObservers];
    [self createButtons];
    [self createTableView];
    [self createCollectionView];
    [self createPicker];
    [self createGestures];
    [self createActivityIndicator];

    [self.activity startAnimating];
    [[NSNotificationCenter defaultCenter] postNotificationName:self.buttonItems[0] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSpinner) name:@"stopSpinner" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    [self loadButtonItems];
    [self.pickerView reloadAllComponents];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]))
    {
        [self adjustViews];
    }
    else
    {
        [self adjustViews];
    }
}

- (void)loadButtonItems
{
    self.buttonItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonsSome"];
    if (!self.buttonItems)
    {
        self.buttonItems = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonsFull"];
        [[NSUserDefaults standardUserDefaults] setObject:self.buttonItems forKey:@"buttonsSome"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)loadServiceObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTwitter) name:@"twitter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGlobal) name:@"global" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFeedly) name:@"feedly" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPocket) name:@"pocket" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadInstapaper) name:@"instapaper" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadReadability) name:@"readability" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFacebook) name:@"facebook" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDribbble) name:@"dribbble" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDesignernews) name:@"designernews" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadBookmarks) name:@"bookmarks" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHistory) name:@"history" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHackernews) name:@"hackernews" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadReddit) name:@"reddit" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProducthunt) name:@"producthunt" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadGmail) name:@"gmail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRss) name:@"rss" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTechcrunch) name:@"techcrunch" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadTheverge) name:@"theverge" object:nil];
}

- (void)createButtons
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                 target:self
                                                                                 action:@selector(unwind)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cancelButton, nil];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                target:self
                                                                                action:@selector(settings)];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:addButton, nil];
}

- (void)createTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                   self.view.frame.origin.y,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height)
                                                  style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];

//    UIView *background = [[UIView alloc] initWithFrame:self.tableView.bounds];
//    UIImageView *wallPaper = [[UIImageView alloc] initWithImage:[UIImage imageNamed:kWall]];
//    [background addSubview:wallPaper];
//    UIView *black = [[UIView alloc] initWithFrame:self.tableView.bounds];
//    black.backgroundColor = [UIColor blackColor];
//    black.alpha = .75;
//    [background addSubview:black];
//
//    self.tableView.backgroundView = background;

//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:kWall] applyDarkEffect]];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.view addSubview:self.tableView];
    self.tableView.hidden = YES;
}

- (void)createCollectionView
{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                             self.view.frame.origin.y,
                                                                             self.view.frame.size.width,
                                                                             self.view.frame.size.height)
                                             collectionViewLayout:flow];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CellPost"];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.collectionView];
    self.collectionView.hidden = YES;
}

- (void)createPicker
{
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    self.pickerView.backgroundColor = [UIColor clearColor];
    self.pickerView.transform = CGAffineTransformMakeRotation(-M_PI_2);
    self.navigationItem.titleView = self.pickerView;
    self.pickerView.frame = CGRectMake(52, -52, 216, 162);  //to remove height error
    NSArray *subviews = self.pickerView.subviews;
    [subviews[1] setBackgroundColor:[UIColor clearColor]];
    [subviews[2] setBackgroundColor:[UIColor clearColor]];

}

- (void)createGestures
{
    self.swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    self.swipeLeft.delegate = self;
    self.swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self.view addGestureRecognizer:self.swipeLeft];

    self.swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    self.swipeRight.delegate = self;
    self.swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:self.swipeRight];
}

- (void)swipeLeft:(UISwipeGestureRecognizer *)sender
{
    int current = (int)[self.pickerView selectedRowInComponent:0];
    if (current<self.buttonItems.count-1)
    {
        [self.pickerView selectRow:current+1 inComponent:0 animated:YES];
        [self selectedRow:current+1 inComponent:0];
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)sender
{
    int current = (int)[self.pickerView selectedRowInComponent:0];
    if (current>0)
    {
        [self.pickerView selectRow:current-1 inComponent:0 animated:YES];
        [self selectedRow:current-1 inComponent:0];
    }
}

- (void)createActivityIndicator
{
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activity.center = self.view.center;
    self.activity.hidesWhenStopped = YES;
//    [self.view addSubview:self.activity];
}

- (void)stopSpinner
{
    [self.activity stopAnimating];
}

#pragma mark - UIPickerView Delegate Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.buttonItems.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIImage *image = [UIImage imageNamed:self.buttonItems[row]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setImage:image forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, 32, 32);
    button.center = view.center;
    button.transform = CGAffineTransformMakeRotation(M_PI_2);

    return button;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self selectedRow:row inComponent:component];
}

- (void)selectedRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.tableView.hidden = YES;
    self.collectionView.hidden = YES;

    for (NSString *item in self.buttonItems)
    {
        if (![item isEqualToString:self.buttonItems[row]])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:[item capitalizedString] object:nil];
        }
    }

    [self.activity startAnimating];
    self.data = nil;
    [self.collectionView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:self.buttonItems[row] object:nil];
}

#pragma mark - UITableView DataSource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.selectedClass height:self.data[indexPath.item]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TableCell"];
    if (!cell)
    {
        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"TableCell"];
    }
    cell.defaultColor = [UIColor colorWithRed:227.0 / 255.0 green:227.0 / 255.0 blue:227.0 / 255.0 alpha:1.0];
//    cell.backgroundColor = [UIColor clearColor];

    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.imageView.image = nil;

    NSDictionary *layoutViews = [self.selectedClass layoutFrom:self.data[indexPath.row]];

    if ([layoutViews[@"simple"] boolValue])
    {
        cell.textLabel.text = layoutViews[@"text"];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:13];
//        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.text = layoutViews[@"subtext"];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.numberOfLines = 0;

        if (self.selectedClass == [Twitter class] || self.selectedClass == [Global class])
        {
            [cell.imageView setImageWithURL:[NSURL URLWithString:layoutViews[@"image"]] placeholderImage:[UIImage imageNamed:@"bluewave"]];
            cell.imageView.layer.masksToBounds = YES;
            cell.imageView.layer.cornerRadius = 48/2;
        }
        else if (self.selectedClass == [Reddit class] || self.selectedClass == [Facebook class])
        {
            [cell.imageView setImageWithURL:[NSURL URLWithString:layoutViews[@"image"]] placeholderImage:[UIImage imageNamed:@"bluewave"]];
        }
    }
    else
    {
        [cell.contentView addSubview:layoutViews[@"contentView"]];
    }

    if ([layoutViews[@"Cell1Exist"] boolValue])
    {
        [cell setSwipeGestureWithView:[self viewWithImageName:layoutViews[@"Cell1Image"]]
                                color:layoutViews[@"Cell1Color"]
                                 mode:[layoutViews[@"Cell1Mode"] intValue]
                                state:MCSwipeTableViewCellState1
                      completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
         {
             if (mode == MCSwipeTableViewCellModeExit)
             {
                 [self deleteCell:cell];
             }
             if (self.selectedClass == [Pocket class])
             {
                 NSLog(@"%@",self.data);
                 NSLog(@"%@",self.data[indexPath.row][@"item_id"]);
                 [Pocket archivePocket:self.data[indexPath.row][@"item_id"]];
             }
             else if (self.selectedClass == [History class])
             {
                 NSMutableArray *temp = [self.data mutableCopy];
                 [temp removeObject:self.data[indexPath.row]];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:temp] forKey:@"history"];
             }
             else if (self.selectedClass == [Bookmarks class])
             {
                 NSMutableArray *temp = [self.data mutableCopy];
                 [temp removeObject:self.data[indexPath.row]];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:temp] forKey:@"bookmarks"];
             }
             else if (self.selectedClass == [Twitter class] ||
                      self.selectedClass == [Facebook class] ||
                      self.selectedClass == [Hackernews class] ||
                      self.selectedClass == [Producthunt class] ||
                      self.selectedClass == [Dribbble class] ||
                      self.selectedClass == [Reddit class] ||
                      self.selectedClass == [Designernews class])
             {
                 NSString *urlString = [self.selectedClass selected:self.data[indexPath.row]];
                 [self pocket:urlString];
             }
         }];
    }
    if ([layoutViews[@"Cell2Exist"] boolValue])
    {
        [cell setSwipeGestureWithView:[self viewWithImageName:layoutViews[@"Cell2Image"]]
                                color:layoutViews[@"Cell2Color"]
                                 mode:[layoutViews[@"Cell2Mode"] intValue]
                                state:MCSwipeTableViewCellState2
                      completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
         {
             if (mode == MCSwipeTableViewCellModeExit)
             {
                 [self deleteCell:cell];
             }
             if (self.selectedClass == [Pocket class])
             {
                 [Pocket deletePocket:self.data[indexPath.row][@"item_id"]];
             }
             else if (self.selectedClass == [Twitter class])
             {
                 [Twitter retweetAdvanced:self.data[indexPath.row]];
             }
         }];
    }
    if ([layoutViews[@"Cell3Exist"] boolValue])
    {
        [cell setSwipeGestureWithView:[self viewWithImageName:layoutViews[@"Cell3Image"]]
                                color:layoutViews[@"Cell3Color"]
                                 mode:[layoutViews[@"Cell3Mode"] intValue]
                                state:MCSwipeTableViewCellState3
                      completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
         {
             if (mode == MCSwipeTableViewCellModeExit)
             {
                 [self deleteCell:cell];
             }
         }];
    }
    if ([layoutViews[@"Cell4Exist"] boolValue])
    {
        [cell setSwipeGestureWithView:[self viewWithImageName:layoutViews[@"Cell4Image"]]
                                color:layoutViews[@"Cell4Color"]
                                 mode:[layoutViews[@"Cell4Mode"] intValue]
                                state:MCSwipeTableViewCellState4
                      completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
         {
             if (mode == MCSwipeTableViewCellModeExit)
             {
                 [self deleteCell:cell];
             }
         }];
    }

    return cell;
}

- (UIView *)viewWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}

- (void)deleteCell:(MCSwipeTableViewCell *)cell
{
    if (cell)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSMutableArray *temp = [self.data mutableCopy];
        [temp removeObjectAtIndex:indexPath.row];
        self.data = [NSArray arrayWithArray:temp];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = [self.selectedClass selected:self.data[indexPath.row]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackFromReadVC" object:urlString];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionView DataSource Methods

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake([self.selectedClass width:self.data[indexPath.item]],
                      [self.selectedClass height:self.data[indexPath.item]]);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellPost" forIndexPath:indexPath];

    for (UIView *view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    NSDictionary *layoutViews = [self.selectedClass layoutFrom:self.data[indexPath.item]];
    [cell.contentView addSubview:layoutViews[@"contentView"]];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = [self.selectedClass selected:self.data[indexPath.item]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackFromReadVC" object:urlString];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Services

- (void)loadServiceUsing:(int)num
{
    if (num == PickTableView)
    {
        [self.tableView reloadData];
        self.tableView.hidden = NO;
    }
    else
    {
        [self.collectionView reloadData];
        self.collectionView.hidden = NO;
    }
    [self.activity stopAnimating];
}

- (void)loadTwitter
{
    if (!self.twitter)
    {
        self.twitter = [Twitter new];
    }
    [self.twitter getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactTwitter:) name:@"Twitter" object:nil];
}

- (void)reactTwitter:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Twitter" object:nil];
    self.data = notification.object;
    self.selectedClass = [Twitter class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadGlobal
{
    if (!self.global)
    {
        self.global = [Global new];
    }
    [self.global getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactGlobal:) name:@"Global" object:nil];
}

- (void)reactGlobal:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Global" object:nil];
    self.data = notification.object;
    self.selectedClass = [Global class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadFeedly
{
    if (!self.feedly)
    {
        self.feedly = [Feedly new];
    }
    [self.feedly getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactFeedly:) name:@"Feedly" object:nil];
}

- (void)reactFeedly:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Feedly" object:nil];
    self.data = notification.object;
    self.selectedClass = [Feedly class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadPocket
{
    if (!self.pocket)
    {
        self.pocket = [Pocket new];
    }
    [self.pocket getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactPocket:) name:@"Pocket" object:nil];
}

- (void)reactPocket:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pocket" object:nil];
    self.data = notification.object;
    self.selectedClass = [Pocket class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadInstapaper
{
    if (!self.instapaper)
    {
        self.instapaper = [Instapaper new];
    }
    [self.instapaper getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactInstapaper:) name:@"Instapaper" object:nil];
}

- (void)reactInstapaper:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Instapaper" object:nil];
    self.data = notification.object;
    self.selectedClass = [Instapaper class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadReadability
{
    if (!self.readability)
    {
        self.readability = [Readability new];
    }
    [self.readability getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactReadability:) name:@"Readability" object:nil];
}

- (void)reactReadability:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Readability" object:nil];
    self.data = notification.object;
    self.selectedClass = [Readability class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadFacebook
{
    if (!self.facebook)
    {
        self.facebook = [Facebook new];
    }
    [self.facebook getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactFacebook:) name:@"Facebook" object:nil];
}

- (void)reactFacebook:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Facebook" object:nil];
    self.data = notification.object;
    self.selectedClass = [Facebook class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadDribbble
{
    if (!self.dribbble)
    {
        self.dribbble = [Dribbble new];
    }
    [self.dribbble getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactDribbble:) name:@"Dribbble" object:nil];
}

- (void)reactDribbble:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Dribbble" object:nil];
    self.data = notification.object;
    self.selectedClass = [Dribbble class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadDesignernews
{
    if (!self.designernews)
    {
        self.designernews = [Designernews new];
    }
    [self.designernews getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactDesignernews:) name:@"Designernews" object:nil];
}

- (void)reactDesignernews:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Designernews" object:nil];
    self.data = notification.object;
    self.selectedClass = [Designernews class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadHackernews
{
    if (!self.hackernews)
    {
        self.hackernews = [Hackernews new];
    }
    [self.hackernews getData];
    self.selectedClass = [Hackernews class];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactHackernews:) name:@"Hackernews" object:nil];
}

- (void)reactHackernews:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Hackernews" object:nil];
    self.data = notification.object;
    self.selectedClass = [Hackernews class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadReddit
{
    if (!self.reddit)
    {
        self.reddit = [Reddit new];
    }
    [self.reddit getData];
    self.selectedClass = [Reddit class];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactReddit:) name:@"Reddit" object:nil];
}

- (void)reactReddit:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Reddit" object:nil];
    self.data = notification.object;
    self.selectedClass = [Reddit class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadProducthunt
{
    if (!self.producthunt)
    {
        self.producthunt = [Producthunt new];
    }
    [self.producthunt getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactProducthunt:) name:@"Producthunt" object:nil];
}

- (void)reactProducthunt:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Producthunt" object:nil];
    self.data = notification.object;
    self.selectedClass = [Producthunt class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadGmail
{
    if (!self.gmail)
    {
        self.gmail = [Gmail new];
    }
    [self.gmail getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactGmail:) name:@"Gmail" object:nil];
}

- (void)reactGmail:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Gmail" object:nil];
    self.data = notification.object;
    self.selectedClass = [Gmail class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadRss
{
    if (!self.rss)
    {
        self.rss = [RSS new];
    }
    [self.rss getData:@"http://techcrunch.com/feed/"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactRss:) name:@"Rss" object:nil];
}

- (void)reactRss:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Rss" object:nil];
    self.data = notification.object;
    self.selectedClass = [RSS class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadTechcrunch
{
    if (!self.techcrunch)
    {
        self.techcrunch = [Techcrunch new];
    }
    [self.techcrunch getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactTechcrunch:) name:@"Techcrunch" object:nil];
}

- (void)reactTechcrunch:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Techcrunch" object:nil];
    self.data = notification.object;
    self.selectedClass = [Techcrunch class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadTheverge
{
    if (!self.theverge)
    {
        self.theverge = [Theverge new];
    }
    [self.theverge getData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reactTheverge:) name:@"Theverge" object:nil];
}

- (void)reactTheverge:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Theverge" object:nil];
    self.data = notification.object;
    self.selectedClass = [Theverge class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadBookmarks
{
    if (!self.bookmarks)
    {
        self.bookmarks = [Bookmarks new];
    }
    self.data = [[NSUserDefaults standardUserDefaults] objectForKey:@"bookmarks"];
    self.selectedClass = [Bookmarks class];
    [self loadServiceUsing:PickTableView];
}

- (void)loadHistory
{
    if (!self.history)
    {
        self.history = [History new];
    }
    self.data = [[NSUserDefaults standardUserDefaults] objectForKey:@"history"];
    self.selectedClass = [History class];
    [self loadServiceUsing:PickTableView];
}

#pragma mark - Add to Pocket

- (void)pocket:(NSString *)urlString
{
    NSLog(@"%@",urlString);

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"pocketLoggedIn"])
    {
        [[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *api, NSError *error)
         {
             if (!error)
             {
                 [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"pocketLoggedIn"];
                 [self pocket2:[NSURL URLWithString:urlString]];
             }
         }];
    }
    else
    {
        [self pocket2:[NSURL URLWithString:urlString]];
    }
}

- (void)pocket2:(NSURL *)url
{
    [[PocketAPI sharedAPI] saveURL:url
                           handler:^(PocketAPI *API, NSURL *URL, NSError *error)
     {
         if(!error)
         {
             NSLog(@"saved to pocket");
         }
         else
         {
             NSLog(@"failed");
         }
     }];
}

#pragma mark - Buttons

- (void)settings
{
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    [self presentViewController:navigationController animated:NO completion:nil];
}

- (void)unwind
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BackFromReadVC" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Landscape Layout Adjust

- (void)adjustViews
{
    self.activity.center = self.view.center;
    self.tableView.frame = CGRectMake(self.view.frame.origin.x,
                                      self.view.frame.origin.y,
                                      self.view.frame.size.width,
                                      self.view.frame.size.height);
}

@end