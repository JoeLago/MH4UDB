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

#import "MHWeaponViewController.h"
#import "MHDatabase.h"
#import "MHItemViewController.h"

@interface MHWeaponViewController ()

@property (nonatomic, retain) NSArray *path;
@property (nonatomic, retain) NSArray *upgrades;
@property (nonatomic, retain) NSArray *components;

@end

@implementation MHWeaponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.weaponDictionary =  [database dictionariesForQuery:@"SELECT *"
                              " FROM weapons"
                              " LEFT JOIN items ON weapons._id = items._id"
                              " WHERE weapons._id == ?"
                                       withArgumentsInArray:@[self.weaponId]][0];
    
    self.title = self.weaponDictionary[@"name"];
    
    self.upgrades = [database dictionariesForQuery:@"SELECT *"
                     " FROM weapons"
                     " LEFT JOIN items ON weapons._id = items._id"
                     " WHERE parent_id == ?"
                              withArgumentsInArray:@[self.weaponId]];
    
    NSMutableArray *weaponTree = [[NSMutableArray alloc] init];
    NSDictionary *parentWeapon = self.weaponDictionary;
    while (parentWeapon != nil && parentWeapon[@"parent_id"] != nil) {
        NSArray *results = [database dictionariesForQuery:@"SELECT *"
                            " FROM weapons"
                            " LEFT JOIN items ON weapons._id = items._id"
                            " WHERE weapons._id == ?"
                                     withArgumentsInArray:@[parentWeapon[@"parent_id"]]];
        if ([results count] > 0) {
            parentWeapon = results[0];
            [weaponTree addObject:parentWeapon];
        }
        else {
            break;
        }
    }
    self.path = [[NSArray alloc] initWithArray:weaponTree];
    
    self.components = [database dictionariesForQuery:@"SELECT *"
                       " ,component.name AS componentname ,component.icon_name AS componenticon"
                       " ,components.type AS componenttype ,component._id AS componentid"
                       " FROM components"
                       " LEFT JOIN items ON components.created_item_id = items._id"
                       " LEFT JOIN items AS component ON components.component_item_id = component._id"
                       " WHERE items._id == ?"
                                withArgumentsInArray:@[self.weaponId]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Details";
    } else if (section == 1) {
        return @"Upgrades To";
    } else if (section == 2) {
        return @"Path";
    } else if (section == 3) {
        return @"Components";
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else if (section == 1) {
        return [self.upgrades count];
    } else if (section == 2) {
        return [self.path count];
    } else if (section == 3) {
        return [self.components count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 28;
    } else {
        return 38;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        NSString *reuseIdentifier = @"detailcell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                          reuseIdentifier:reuseIdentifier];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.weaponDictionary[@"name"];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = self.weaponDictionary[@"wtype"];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Rarity";
            cell.detailTextLabel.text = [self.weaponDictionary[@"rarity"] stringValue];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Attack";
            cell.detailTextLabel.text = [self.weaponDictionary[@"attack"] stringValue];
        }
    } else if (indexPath.section == 1) {
        NSString *reuseIdentifier = @"skillcell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *weapon = self.upgrades[indexPath.row];
        cell.textLabel.text = weapon[@"name"];
        cell.imageView.image = [UIImage imageNamed:weapon[@"icon_name"]];
    } else if (indexPath.section == 2) {
        NSString *reuseIdentifier = @"skillcell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *weapon = self.path[indexPath.row];
        cell.textLabel.text = weapon[@"name"];
        cell.imageView.image = [UIImage imageNamed:weapon[@"icon_name"]];
    } else if (indexPath.section == 3) {
        NSString *reuseIdentifier = @"itemcell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *item = self.components[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ x%@",
                               item[@"componentname"], [item[@"quantity"] stringValue]];
        cell.detailTextLabel.text = item[@"componenttype"];
        cell.imageView.image = [UIImage imageNamed:item[@"componenticon"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSDictionary *weapon = self.upgrades[indexPath.row];
        MHWeaponViewController *vc = [[MHWeaponViewController alloc] init];
        vc.weaponId = weapon[@"_id"];
        [self.navigationController pushViewController:vc animated:TRUE];
    } else if (indexPath.section == 2) {
        NSDictionary *weapon = self.path[indexPath.row];
        MHWeaponViewController *vc = [[MHWeaponViewController alloc] init];
        vc.weaponId = weapon[@"_id"];
        [self.navigationController pushViewController:vc animated:TRUE];
    } else if (indexPath.section == 3) {
        NSDictionary *item = self.components[indexPath.row];
        MHItemViewController *vc = [[MHItemViewController alloc] init];
        vc.itemId = item[@"componentid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    }
}

@end
