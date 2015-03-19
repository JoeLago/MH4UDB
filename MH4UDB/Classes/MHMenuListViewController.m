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

#import "MHMenuListViewController.h"
#import "MHDatabase.h"
#import "MHMonstersListViewController.h"
#import "MHWeaponTypeListViewController.h"
#import "MHItemsListViewController.h"
#import "MHArmorListViewController.h"
#import "MHQuestListViewController.h"
#import "MHCombinationsListViewController.h"
#import "MHLocationsListViewController.h"
#import "MHDecorationsListViewController.h"
#import "MHSkillsListViewController.h"
#import "MHMonsterViewController.h"
#import "MHWeaponViewController.h"
#import "MHArmorViewController.h"
#import "MHQuestViewController.h"
#import "MHItemViewController.h"
#import "MHLocationViewController.h"

@interface MHMenuListViewController ()

@property (nonatomic, retain) NSArray *menuItems;
@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) UISearchDisplayController *searchController;
@property (nonatomic, retain) NSArray *monsters;
@property (nonatomic, retain) NSArray *weapons;
@property (nonatomic, retain) NSArray *armor;
@property (nonatomic, retain) NSArray *quests;
@property (nonatomic, retain) NSArray *items;
@property (nonatomic, retain) NSArray *locations;

@end

@implementation MHMenuListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"MH4U";
    self.menuItems =
    @[
      @{ @"name": @"Monsters", @"image": @"Book-White.png" },
      @{ @"name": @"Weapons", @"image": @"sword_and_shield1.png" },
      @{ @"name": @"Armor", @"image": @"body1.png" },
      @{ @"name": @"Quests", @"image": @"Quest-Icon-White.png" },
      @{ @"name": @"Items", @"image": @"Ore-White.png" },
      @{ @"name": @"Combinations", @"image": @"Liquid-White.png" },
      @{ @"name": @"Locations", @"image": @"Map-Icon-White.png" },
      @{ @"name": @"Decorations", @"image": @"Jewel-White.png" },
      @{ @"name": @"Skill Trees", @"image": @"Monster-Jewel-White.png" },
      //@{ @"name": @"Wishlists", @"image": @"Mantle-White.png" }
      ];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:
                              CGRectMake(0, 0, self.tableView.frame.size.width, 48)];
    searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    searchBar.delegate = self;
    self.tableView.tableHeaderView = searchBar;
    self.searchBar = searchBar;
    
    self.searchController = [[UISearchDisplayController alloc]
                             initWithSearchBar:searchBar
                             contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
}

- (void)populateResults {
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    
    self.monsters = [database dictionariesForQuery:
                     [NSString stringWithFormat:@"SELECT * FROM monsters"
                      " WHERE name LIKE '%%%@%%'", self.searchString]];
    
    self.weapons = [database dictionariesForQuery:
                    [NSString stringWithFormat:@"SELECT * FROM weapons"
                     " LEFT JOIN items on weapons._id = items._id"
                     " WHERE name LIKE '%%%@%%'", self.searchString]];
    
    self.armor = [database dictionariesForQuery:
                  [NSString stringWithFormat:@"SELECT * FROM armor"
                   " LEFT JOIN items on armor._id = items._id"
                   " WHERE name LIKE '%%%@%%'", self.searchString]];
    
    self.quests = [database dictionariesForQuery:
                   [NSString stringWithFormat:@"SELECT * FROM quests"
                    " WHERE name LIKE '%%%@%%'", self.searchString]];
    
    self.items = [database dictionariesForQuery:
                  [NSString stringWithFormat:@"SELECT * FROM items"
                   " WHERE sub_type == '' AND name LIKE '%%%@%%'", self.searchString]];
    
    self.locations = [database dictionariesForQuery:
                      [NSString stringWithFormat:@"SELECT * FROM locations"
                       " WHERE name LIKE '%%%@%%'", self.searchString]];
}

#pragma mark - UISearchBar Delegate Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchString = nil;
    [self.tableView reloadData];
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString {
    self.searchString = searchString;
    [self populateResults];
    return TRUE;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.searchString == nil) ? 1 : 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchString == nil) {
        return self.menuItems.count;
    } else {
        if (section == 0) {
            return [self.monsters count];
        } else if (section == 1) {
            return [self.weapons count];
        } else if (section == 2) {
            return [self.armor count];
        } else if (section == 3) {
            return [self.quests count];
        } else if (section == 4) {
            return [self.items count];
        } else if (section == 5) {
            return [self.locations count];
        } else {
            return 0;
        }
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.searchString == nil) {
        return nil;
    } else {
        if (section == 0) {
            return @"Monsters";
        } else if (section == 1) {
            return @"Weapons";
        } else if (section == 2) {
            return @"Armor";
        } else if (section == 3) {
            return @"Quests";
        } else if (section == 4) {
            return @"Items";
        } else if (section == 5) {
            return @"Locations";
        }
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"menucell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
    }
    
    if (self.searchString == nil) {
        cell.textLabel.text = self.menuItems[indexPath.row][@"name"];
        cell.imageView.image = [UIImage imageNamed:self.menuItems[indexPath.row][@"image"]];
    } else {
        if (indexPath.section == 0) {
            NSDictionary *monster = self.monsters[indexPath.row];
            cell.textLabel.text = monster[@"name"];
            cell.imageView.image = [UIImage imageNamed:monster[@"icon_name"]];
        } else if (indexPath.section == 1) {
            NSDictionary *weapon = self.weapons[indexPath.row];
            cell.textLabel.text = weapon[@"name"];
            cell.imageView.image = [UIImage imageNamed:weapon[@"icon_name"]];
        } else if (indexPath.section == 2) {
            NSDictionary *armor = self.armor[indexPath.row];
            cell.textLabel.text = armor[@"name"];
            cell.imageView.image = [UIImage imageNamed:armor[@"icon_name"]];
        } else if (indexPath.section == 3) {
            NSDictionary *quest = self.quests[indexPath.row];
            cell.textLabel.text = quest[@"name"];
            cell.imageView.image = nil;
        } else if (indexPath.section == 4) {
            NSDictionary *item = self.items[indexPath.row];
            cell.textLabel.text = item[@"name"];
            cell.imageView.image = [UIImage imageNamed:item[@"icon_name"]];
        } else if (indexPath.section == 5) {
            NSDictionary *location = self.locations[indexPath.row];
            cell.textLabel.text = location[@"name"];
            cell.imageView.image = [UIImage imageNamed:location[@"map"]];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchString == nil) {
        if (indexPath.row == 0) {
            MHMonstersListViewController *vc = [[MHMonstersListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.row == 1) {
            MHWeaponTypeListViewController *vc = [[MHWeaponTypeListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.row == 2) {
            MHArmorListViewController *vc = [[MHArmorListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.row == 3) {
            MHQuestListViewController *vc = [[MHQuestListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.row == 4) {
            MHItemsListViewController *vc = [[MHItemsListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.row == 5) {
            MHCombinationsListViewController *vc = [[MHCombinationsListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.row == 6) {
            MHLocationsListViewController *vc = [[MHLocationsListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.row == 7) {
            MHDecorationsListViewController *vc = [[MHDecorationsListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.row == 8) {
            MHSkillsListViewController *vc = [[MHSkillsListViewController alloc] init];
            [self.navigationController pushViewController:vc animated:TRUE];
        }
    } else {
        if (indexPath.section == 0) {
            NSDictionary *monster = self.monsters[indexPath.row];
            MHMonsterViewController *vc = [[MHMonsterViewController alloc] init];
            vc.monsterid = monster[@"_id"];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.section == 1) {
            NSDictionary *weapon = self.weapons[indexPath.row];
            MHWeaponViewController *vc = [[MHWeaponViewController alloc] init];
            vc.weaponId = weapon[@"_id"];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.section == 2) {
            NSDictionary *armor = self.armor[indexPath.row];
            MHArmorViewController *vc = [[MHArmorViewController alloc] init];
            vc.armorId = armor[@"_id"];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.section == 3) {
            NSDictionary *quest = self.quests[indexPath.row];
            MHQuestViewController *vc = [[MHQuestViewController alloc] init];
            vc.questId = quest[@"_id"];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.section == 4) {
            NSDictionary *item = self.items[indexPath.row];
            MHItemViewController *vc = [[MHItemViewController alloc] init];
            vc.itemId = item[@"_id"];
            [self.navigationController pushViewController:vc animated:TRUE];
        } else if (indexPath.section == 5) {
            NSDictionary *location = self.locations[indexPath.row];
            MHLocationViewController *vc = [[MHLocationViewController alloc] init];
            vc.locationId = location[@"_id"];
            [self.navigationController pushViewController:vc animated:TRUE];
        }
    }
}

@end
