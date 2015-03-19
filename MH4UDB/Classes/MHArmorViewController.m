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

#import "MHArmorViewController.h"
#import "MHDatabase.h"
#import "MHItemViewController.h"
#import "MHSkillViewController.h"

@interface MHArmorViewController ()

@property (nonatomic, retain) NSArray *skills;
@property (nonatomic, retain) NSArray *components;

@end

@implementation MHArmorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.armorDictionary =  [database selectAllFrom:@"items"
                             " LEFT JOIN armor on items._id = armor._id"
                                              where:@"items._id == ?"
                                          arguments:@[self.armorId]
                                            orderBy:@"items._id ASC"
                                              error:nil][0];
    
    self.title = self.armorDictionary[@"name"];
    
    self.skills = [database dictionariesForQuery:@"SELECT *"
                   " ,skill_trees.name AS skillname ,skill_trees._id AS skillid"
                   " FROM item_to_skill_tree"
                   " LEFT JOIN items ON item_to_skill_tree.item_id = items._id"
                   " LEFT JOIN skill_trees ON item_to_skill_tree.skill_tree_id = skill_trees._id"
                   " WHERE items._id == ?"
                            withArgumentsInArray:@[self.armorId]];
    
    self.components = [database dictionariesForQuery:@"SELECT *"
                       " ,component.name AS componentname ,component.icon_name AS componenticon"
                       " ,components.type AS componenttype ,component._id AS componentid"
                       " FROM components"
                       " LEFT JOIN items ON components.created_item_id = items._id"
                       " LEFT JOIN items AS component ON components.component_item_id = component._id"
                       " WHERE items._id == ?"
                                withArgumentsInArray:@[self.armorId]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Details";
    } else if (section == 1) {
        return @"Skills";
    } else if (section == 2) {
        return @"Components";
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    } else if (section == 1) {
        return [self.skills count];
    } else if (section == 2) {
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
            cell.textLabel.text = @"Slot";
            cell.detailTextLabel.text = self.armorDictionary[@"slot"];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Rarity";
            cell.detailTextLabel.text = [self stringForNumber:self.armorDictionary[@"rarity"]];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Defense";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",
                                         [self stringForNumber:self.armorDictionary[@"defense"]],
                                         [self stringForNumber:self.armorDictionary[@"max_defense"]]];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Buy";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@z",
                                         [self stringForNumber:self.armorDictionary[@"rarity"]]];
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"Slots";
            cell.detailTextLabel.text = [self stringForNumber:self.armorDictionary[@"slots"]];
        } else if (indexPath.row == 5) {
            cell.textLabel.text = @"Fire Resist";
            cell.detailTextLabel.text = [self stringForNumber:self.armorDictionary[@"fire_res"]];
        } else if (indexPath.row == 6) {
            cell.textLabel.text = @"Dragon Resist";
            cell.detailTextLabel.text = [self stringForNumber:self.armorDictionary[@"dragon_res"]];
        } else if (indexPath.row == 7) {
            cell.textLabel.text = @"Water Resist";
            cell.detailTextLabel.text = [self stringForNumber:self.armorDictionary[@"water_res"]];
        } else if (indexPath.row == 8) {
            cell.textLabel.text = @"Ice Resist";
            cell.detailTextLabel.text = [self stringForNumber:self.armorDictionary[@"ice_res"]];
        } else if (indexPath.row == 9) {
            cell.textLabel.text = @"Thunder Resist";
            cell.detailTextLabel.text = [self stringForNumber:self.armorDictionary[@"thunder_res"]];
        }
    } else if (indexPath.section == 1) {
        NSString *reuseIdentifier = @"skillcell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *skilltree = self.skills[indexPath.row];
        cell.textLabel.text = skilltree[@"skillname"];
        cell.detailTextLabel.text = [skilltree[@"point_value"] stringValue];
    } else if (indexPath.section == 2) {
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
        NSDictionary *skilltree = self.skills[indexPath.row];
        MHItemViewController *vc = [[MHItemViewController alloc] init];
        vc.itemId = skilltree[@"skillid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    } else if (indexPath.section == 2) {
        NSDictionary *item = self.components[indexPath.row];
        MHItemViewController *vc = [[MHItemViewController alloc] init];
        vc.itemId = item[@"componentid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    }
}

@end
