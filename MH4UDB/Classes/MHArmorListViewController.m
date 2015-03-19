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

#import "MHArmorListViewController.h"
#import "MHDatabase.h"
#import "MHArmorViewController.h"

@interface MHArmorListViewController ()

@property (nonatomic, retain) UIBarButtonItem *typeButton;
@property (nonatomic, retain) UIBarButtonItem *slotButton;
@property (nonatomic, retain) UIAlertView *typeAlert;
@property (nonatomic, retain) UIAlertView *slotAlert;
@property (nonatomic, retain) NSString *typeFilter;
@property (nonatomic, retain) NSString *slotFilter;
@property (nonatomic, retain) NSArray *armor;

@end

@implementation MHArmorListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Armor";
    
    self.typeButton = [[UIBarButtonItem alloc]
                       initWithTitle:@"All Types"
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(typeButtonPressed)];
    
    self.slotButton = [[UIBarButtonItem alloc]
                       initWithTitle:@"All Slots"
                       style:UIBarButtonItemStylePlain
                       target:self
                       action:@selector(slotButtonPressed)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil
                                      action:nil];
    
    [self.navigationController setToolbarHidden:NO];
    self.toolbarItems = @[flexibleSpace, self.typeButton, self.slotButton, flexibleSpace];
    
    self.typeAlert = [[UIAlertView alloc] initWithTitle:nil
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:
                      @"All",
                      @"Blade",
                      @"Gunner",
                      @"Both",
                      nil];
    
    self.slotAlert = [[UIAlertView alloc] initWithTitle:nil
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      otherButtonTitles:
                      @"All",
                      @"Head",
                      @"Body",
                      @"Arms",
                      @"Waist",
                      @"Legs",
                      nil];
    
    [self refreshArmors];
}

- (void)refreshArmors {
    NSString *whereStatement = nil;
    NSArray *arguments = nil;
    
    if (self.typeFilter != nil && self.slotFilter != nil) {
        whereStatement = @"hunter_type == ? AND slot == ?";
        arguments = @[self.typeFilter, self.slotFilter];
    } else if (self.typeFilter != nil) {
        whereStatement = @"hunter_type == ?";
        arguments = @[self.typeFilter];
    } else if (self.slotFilter != nil) {
        whereStatement = @"slot == ?";
        arguments = @[self.slotFilter];
    }
    
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.armor = [database selectAllFrom:@"armor"
                  " LEFT JOIN items on armor._id = items._id"
                                   where:whereStatement
                               arguments:arguments
                                 orderBy:@"_id ASC"
                                   error:nil];
    [self.tableView reloadData];
}

- (void)typeButtonPressed {
    [self.typeAlert show];
}

- (void)slotButtonPressed {
    [self.slotAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.typeAlert) {
        if (buttonIndex == 1) {
            self.typeFilter = nil;
            self.typeButton.title = @"All Types";
        } else if (buttonIndex == 2) {
            self.typeButton.title = self.typeFilter = @"Blade";
        } else if (buttonIndex == 3) {
            self.typeButton.title = self.typeFilter = @"Gunner";
        } else if (buttonIndex == 4) {
            self.typeButton.title = self.typeFilter = @"Both";
        }
    } else if (alertView == self.slotAlert) {
        if (buttonIndex == 1) {
            self.slotFilter = nil;
            self.slotButton.title = @"All Slots";
        } else if (buttonIndex == 2) {
            self.slotButton.title = self.slotFilter = @"Head";
        } else if (buttonIndex == 3) {
            self.slotButton.title = self.slotFilter = @"Body";
        } else if (buttonIndex == 4) {
            self.slotButton.title = self.slotFilter = @"Arms";
        } else if (buttonIndex == 5) {
            self.slotButton.title = self.slotFilter = @"Waist";
        } else if (buttonIndex == 6) {
            self.slotButton.title = self.slotFilter = @"Legs";
        }
    }
    
    if (buttonIndex != 0) {
        [self refreshArmors];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.armor count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"itemcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
    }
    
    cell.textLabel.text = self.armor[indexPath.row][@"name"];
    cell.imageView.image = [UIImage imageNamed:self.armor[indexPath.row][@"icon_name"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *armor = self.armor[indexPath.row];
    MHArmorViewController *vc = [[MHArmorViewController alloc] init];
    vc.armorId = armor[@"_id"];
    [self.navigationController pushViewController:vc animated:TRUE];
}

@end
