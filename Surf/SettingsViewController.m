//
//  ReadSettingsViewController.m
//  Surf
//
//  Created by Sapan Bhuta on 6/15/14.
//  Copyright (c) 2014 SapanBhuta. All rights reserved.
//

#import "SettingsViewController.h"
#import "SBSwitch.h"
#import "UIImage+ImageEffects.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@property UITableView *tableView;
@property NSArray *fullButtons;
@property NSMutableArray *someButtons;
@property UIBarButtonItem *editButton;
@property UIBarButtonItem *doneButton;
@property UIBarButtonItem *cancelButton;
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;


    self.fullButtons = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttonsFull"];
    self.someButtons = [[[NSUserDefaults standardUserDefaults] objectForKey:@"buttonsSome"] mutableCopy];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                   self.view.frame.origin.y,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height)
                                                  style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.scrollEnabled = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];

//    UIView *background = [[UIView alloc] initWithFrame:self.tableView.bounds];
//    UIImageView *wallPaper = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3"]];
//    [background addSubview:wallPaper];
//    UIView *black = [[UIView alloc] initWithFrame:self.tableView.bounds];
//    black.backgroundColor = [UIColor blackColor];
//    black.alpha = .75;
//    [background addSubview:black];
//    self.tableView.backgroundView = background;

    [self.view addSubview:self.tableView];

    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(edit)];

    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                    target:self
                                                                    action:@selector(edit)];

    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                  target:self
                                                                                  action:@selector(unwind)];
    self.navigationItem.leftBarButtonItem = self.editButton;
    self.navigationItem.rightBarButtonItem = self.cancelButton;
}


- (void)unwind
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithArray:self.someButtons] forKey:@"buttonsSome"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - Table Editing


- (void)edit
{
    if ([self.tableView isEditing])
    {
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.leftBarButtonItem = self.editButton;
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        self.navigationItem.leftBarButtonItem = self.doneButton;
    }
}

#pragma mark - UITableView DataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fullButtons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.separatorInset =  UIEdgeInsetsMake(0, 0, 0, 0);
    cell.imageView.image = [UIImage imageNamed:self.fullButtons[indexPath.row]];
    SBSwitch *currentSwitch = nil;
    for (UIView *view in cell.contentView.subviews)
    {
        if ([view isKindOfClass:[SBSwitch class]])
        {
            currentSwitch = (SBSwitch *)view;
        }
    }
    if (!currentSwitch)
    {
        currentSwitch = [[SBSwitch alloc] init];
        currentSwitch.center = CGPointMake(80 + currentSwitch.frame.size.width/2,
                                           cell.contentView.center.y);

        [currentSwitch addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:currentSwitch];
    }
    currentSwitch.on = [self.someButtons containsObject:self.fullButtons[indexPath.row]];
    currentSwitch.path = indexPath;

    return cell;
}

- (void)toggle:(SBSwitch *)sender
{
    sender.on ? NSLog(@"on") : NSLog(@"off");

    if (sender.on)
    {
        [self.someButtons insertObject:self.fullButtons[sender.path.row] atIndex:0];
        [self sort];
    }
    else
    {
        [self.someButtons removeObject:self.fullButtons[sender.path.row]];
    }
}

- (void)sort
{
    NSMutableArray *temp = [NSMutableArray new];
    for (NSString *service in self.fullButtons)
    {
        if ([self.someButtons containsObject:service])
        {
            [temp addObject:service];
        }
    }
    self.someButtons = temp;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *fullM = [self.fullButtons mutableCopy];

    NSString *service = [self.fullButtons objectAtIndex:fromIndexPath.row];
    [fullM removeObjectAtIndex:fromIndexPath.row];
    [fullM insertObject:service atIndex:toIndexPath.row];
    self.fullButtons = [NSArray arrayWithArray:fullM];
    [[NSUserDefaults standardUserDefaults] setObject:self.fullButtons forKey:@"buttonsFull"];
    [self sort];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

@end