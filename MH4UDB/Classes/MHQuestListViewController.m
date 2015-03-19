//
// The MIT License (MIT)
// 
// Copyright (c) 2015 Joe Lagomarsino
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// 

#import "MHQuestListViewController.h"
#import "MHDatabase.h"
#import "MHQuestViewController.h"

@interface MHQuestListViewController ()

@property (nonatomic, retain) UIBarButtonItem *hubButton;
@property (nonatomic, retain) UIBarButtonItem *rankButton;
@property (nonatomic, retain) UIAlertView *hubAlert;
@property (nonatomic, retain) UIAlertView *rankAlert;
@property (nonatomic, retain) NSString *hubFilter;
@property (nonatomic, retain) NSNumber *rankFilter;
@property (nonatomic, retain) NSArray *quests;

@end

@implementation MHQuestListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Quests";
    
    self.hubButton = [[UIBarButtonItem alloc]
                       initWithTitle:@"All Hubs"
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(pressedHubButton)];
    
    self.rankButton = [[UIBarButtonItem alloc]
                       initWithTitle:@"All Ranks"
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(pressedRankButton)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil
                                      action:nil];
    
    [self.navigationController setToolbarHidden:NO];
    self.toolbarItems = @[flexibleSpace, self.hubButton, self.rankButton, flexibleSpace];
    
    self.hubAlert = [[UIAlertView alloc] initWithTitle:nil
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:
                      @"All",
                      @"Caravan",
                      @"Guild",
                      nil];
    
    self.rankAlert = [[UIAlertView alloc] initWithTitle:nil
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:
                      @"All",
                      @"1",
                      @"2",
                      @"3",
                      @"4",
                      @"5",
                      @"6",
                      @"7",
                      @"8",
                      @"9",
                      @"10",
                      nil];
    
    [self refreshQuests];
}

- (void)pressedHubButton {
    [self.hubAlert show];
}

- (void)pressedRankButton {
    [self.rankAlert show];
}

- (void)refreshQuests {
    NSString *whereStatement = nil;
    NSArray *arguments = nil;
    
    if (self.hubFilter != nil && self.rankFilter != nil) {
        whereStatement = @"hub == ? AND stars == ?";
        arguments = @[self.hubFilter, self.rankFilter];
    } else if (self.hubFilter != nil) {
        whereStatement = @"hub == ?";
        arguments = @[self.hubFilter];
    } else if (self.rankFilter != nil) {
        whereStatement = @"stars == ?";
        arguments = @[self.rankFilter];
    }
    
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.quests = [database selectAllFrom:@"quests"
                                   where:whereStatement
                               arguments:arguments
                                 orderBy:@"_id ASC"
                                   error:nil];
    [self.tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.hubAlert) {
        if (buttonIndex == 1) {
            self.hubFilter = nil;
            self.hubButton.title = @"All Hubs";
        } else if (buttonIndex == 2) {
            self.hubButton.title = self.hubFilter = @"Caravan";
        } else if (buttonIndex == 3) {
            self.hubButton.title = self.hubFilter = @"Guild";
        }
    } else if (alertView == self.rankAlert) {
        if (buttonIndex == 1) {
            self.rankFilter = nil;
            self.rankButton.title = @"All Ranks";
        } else {
            self.rankFilter = @(buttonIndex - 1);
            self.rankButton.title = [NSString stringWithFormat:@"%@ Stars",
                                     [self.rankFilter stringValue]];
        }
    }
    
    if (buttonIndex != 0) {
        [self refreshQuests];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.quests count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"itemcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:reuseIdentifier];
    }
    
    NSDictionary *quest = self.quests[indexPath.row];
    cell.textLabel.text = quest[@"name"];
    cell.detailTextLabel.text = quest[@"type"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *quest = self.quests[indexPath.row];
    MHQuestViewController *vc = [[MHQuestViewController alloc] init];
    vc.questId = quest[@"_id"];
    [self.navigationController pushViewController:vc animated:TRUE];
}

@end
