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

#import "MHSkillViewController.h"
#import "MHDatabase.h"
#import "MHQuestViewController.h"
#import "MHArmorViewController.h"

@interface MHSkillViewController ()

@property (nonatomic, retain) NSArray *skills;
@property (nonatomic, retain) NSArray *usages;

@end

@implementation MHSkillViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.skillTreeDictionary =  [database selectAllFrom:@"skill_trees"
                                             where:@"_id == ?"
                                         arguments:@[self.skillTypeId]
                                           orderBy:nil
                                             error:nil][0];
    
    self.title = self.skillTreeDictionary[@"name"];
    
    self.skills = [database dictionariesForQuery:@"SELECT *"
                   " FROM skills"
                   " WHERE skill_tree_id == ?"
                            withArgumentsInArray:@[self.skillTypeId]];
    
    self.usages = [database dictionariesForQuery:@"SELECT *"
                   " ,items.name AS itemname ,items.icon_name AS itemicon"
                   " ,items._id AS itemid"
                   " FROM item_to_skill_tree"
                   " LEFT JOIN items ON item_to_skill_tree.item_id = items._id"
                   " LEFT JOIN skill_trees ON item_to_skill_tree.skill_tree_id = skill_trees._id"
                   " WHERE skill_trees._id == ?"
                   " ORDER BY item_to_skill_tree.point_value DESC"
                            withArgumentsInArray:@[self.skillTypeId]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Skills";
    } else if (section == 1) {
        return @"Usage";
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.skills count];
    } else if (section == 1) {
        return [self.usages count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 38;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {
        NSString *reuseIdentifier = @"skillcell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *skill = self.skills[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                               skill[@"name"],
                               [skill[@"required_skill_tree_points"] stringValue]];
        cell.detailTextLabel.text = skill[@"description"];
    } else if (indexPath.section == 1) {
        NSString *reuseIdentifier = @"createdcell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *usage = self.usages[indexPath.row];
        cell.textLabel.text = usage[@"itemname"];
        cell.detailTextLabel.text = [usage[@"point_value"] stringValue];
        cell.imageView.image = [UIImage imageNamed:usage[@"itemicon"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSDictionary *skilltree = self.skills[indexPath.row];
        MHArmorViewController *vc = [[MHArmorViewController alloc] init];
        vc.armorId = skilltree[@"itemid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    }
}

@end
