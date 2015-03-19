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

#import "MHDecorationViewController.h"
#import "MHDatabase.h"
#import "MHSkillViewController.h"
#import "MHItemViewController.h"

@interface MHDecorationViewController ()

@property (nonatomic, retain) NSArray *skills;
@property (nonatomic, retain) NSArray *components;

@end

@implementation MHDecorationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.decorationDictionary =  [database selectAllFrom:@"items"
                                                   where:@"_id == ?"
                                               arguments:@[self.decorationId]
                                                 orderBy:@"_id ASC"
                                                   error:nil][0];
    
    self.title = self.decorationDictionary[@"name"];
    
    self.skills = [database dictionariesForQuery:@"SELECT *"
                   " ,skill_trees.name AS skillname ,skill_trees._id AS skillid"
                   " FROM item_to_skill_tree"
                   " LEFT JOIN items ON item_to_skill_tree.item_id = items._id"
                   " LEFT JOIN skill_trees ON item_to_skill_tree.skill_tree_id = skill_trees._id"
                   " WHERE items._id == ?"
                            withArgumentsInArray:@[self.decorationId]];
    
    self.components = [database dictionariesForQuery:@"SELECT *"
                       " ,component.name AS componentname ,component.icon_name AS componenticon"
                       " ,components.type AS componenttype ,component._id AS componentid"
                       " FROM components"
                       " LEFT JOIN items ON components.created_item_id = items._id"
                       " LEFT JOIN items AS component ON components.component_item_id = component._id"
                       " WHERE items._id == ?"
                                withArgumentsInArray:@[self.decorationId]];
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
        return 5;
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
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.decorationDictionary[@"name"];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Rarity";
            cell.detailTextLabel.text = [self.decorationDictionary[@"rarity"] stringValue];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Buy";
            cell.detailTextLabel.text = [self stringForNumber:self.decorationDictionary[@"buy"]];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Sell";
            cell.detailTextLabel.text = [self stringForNumber:self.decorationDictionary[@"sell"]];
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"Carry Capacity";
            cell.detailTextLabel.text = [self stringForNumber:self.decorationDictionary[@"carry_capacity"]];
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
