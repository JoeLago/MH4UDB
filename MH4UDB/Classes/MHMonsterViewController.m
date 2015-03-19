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


#import "MHMonsterViewController.h"
#import "MHDatabase.h"
#import "MHItemViewController.h"
#import "MHQuestViewController.h"
#import "MHLocationViewController.h"
#import "MHDetailTableViewCell.h"

@interface MHMonsterViewController ()

@property (nonatomic, retain) NSArray *stati;
@property (nonatomic, retain) NSArray *habitats;
@property (nonatomic, retain) NSArray *quests;
@property (nonatomic, retain) NSArray *lowRewards;
@property (nonatomic, retain) NSArray *highRewards;
@property (nonatomic, retain) NSArray *gRewards;

@end

@implementation MHMonsterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.monsterDictionary =  [database selectAllFrom:@"monsters"
                                                where:@"_id == ?"
                                            arguments:@[self.monsterid]
                                              orderBy:@"_id ASC"
                                                error:nil][0];
    
    self.title = self.monsterDictionary[@"name"];
    
    self.habitats = [database dictionariesForQuery:@"SELECT *,"
                     " locations.name AS locationname ,locations._id AS locationid"
                     " FROM monster_habitat"
                     " LEFT JOIN locations on monster_habitat.location_id = locations._id"
                     " LEFT JOIN monsters on monster_habitat.monster_id = monsters._id"
                     " WHERE monsters._id == ?"
                              withArgumentsInArray:@[self.monsterid]];
    
    self.quests = [database dictionariesForQuery:@"SELECT *,"
                   " quests.name AS questname ,quests._id AS questid"
                   " FROM monster_to_quest"
                   " LEFT JOIN quests on monster_to_quest.quest_id = quests._id"
                   " LEFT JOIN monsters on monster_to_quest.monster_id = monsters._id"
                   " WHERE monsters._id == ?"
                            withArgumentsInArray:@[self.monsterid]];
    
    self.lowRewards = [database dictionariesForQuery:@"SELECT *"
                       " ,items.name AS itemname ,items.icon_name AS itemicon"
                       " ,items._id AS itemid"
                       " FROM hunting_rewards"
                       " LEFT JOIN items on hunting_rewards.item_id = items._id"
                       " LEFT JOIN monsters on hunting_rewards.monster_id = monsters._id"
                       " WHERE monsters._id == ? AND rank == 'LR'"
                                withArgumentsInArray:@[self.monsterid]];
    
    self.highRewards = [database dictionariesForQuery:@"SELECT *"
                        " ,items.name AS itemname ,items.icon_name AS itemicon"
                        " ,items._id AS itemid"
                        " FROM hunting_rewards"
                        " LEFT JOIN items on hunting_rewards.item_id = items._id"
                        " LEFT JOIN monsters on hunting_rewards.monster_id = monsters._id"
                        " WHERE monsters._id == ? AND rank == 'HR'"
                                 withArgumentsInArray:@[self.monsterid]];
    
    self.gRewards = [database dictionariesForQuery:@"SELECT *"
                     " ,items.name AS itemname ,items.icon_name AS itemicon"
                     " ,items._id AS itemid"
                     " FROM hunting_rewards"
                     " LEFT JOIN items on hunting_rewards.item_id = items._id"
                     " LEFT JOIN monsters on hunting_rewards.monster_id = monsters._id"
                     " WHERE monsters._id == ? AND rank == 'G'"
                              withArgumentsInArray:@[self.monsterid]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MHDetailTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"mhdetailcell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Details";
    } else if (section == 1) {
        return @"Status";
    } else if (section == 2) {
        return @"Habitat";
    } else if (section == 3) {
        return @"Low Rank Rewards";
    } else if (section == 4) {
        return @"High Rank Rewards";
    } else if (section == 5) {
        return @"G Rank Rewards";
    } else if (section == 6) {
        return @"Quests";
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 0;
    } else if (section == 2) {
        return [self.habitats count];
    } else if (section == 3) {
        return [self.lowRewards count];
    } else if (section == 4) {
        return [self.highRewards count];
    } else if (section == 5) {
        return [self.gRewards count];
    } else if (section == 6) {
        return [self.quests count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 28;
    } else if (indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5) {
        return 44;
    } else {
        return 38;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        NSString *reuseIdentifier = @"detailcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                          reuseIdentifier:reuseIdentifier];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.monsterDictionary[@"name"];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Class";
            cell.detailTextLabel.text = self.monsterDictionary[@"class"];
        }
        return cell;
    } else if (indexPath.section == 1) {
        NSString *reuseIdentifier = @"statuscell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                          reuseIdentifier:reuseIdentifier];
        }
        
        return cell;
    } else if (indexPath.section == 2) {
        NSString *reuseIdentifier = @"habitatcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *location = self.habitats[indexPath.row];
        cell.textLabel.text = location[@"locationname"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@ - %@",
                                     location[@"start_area"],
                                     location[@"move_area"],
                                     location[@"rest_area"]];
        return cell;
    } else if (indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5) {
        MHDetailTableViewCell *cell = [self.tableView
                                       dequeueReusableCellWithIdentifier:@"mhdetailcell"];
        
        NSDictionary *item = (indexPath.section == 3)
        ? self.lowRewards[indexPath.row]
        : (indexPath.section == 4) ? self.highRewards[indexPath.row]
        : self.gRewards[indexPath.row];
        
        NSString *amount = [item[@"stack_size"] intValue] > 1
        ? [NSString stringWithFormat:@" x%@", [item[@"stack_size"] stringValue]] : @"";
        cell.titleLabel.text = [NSString stringWithFormat:@"%@%@", item[@"itemname"], amount];
        cell.subtitleLabel.text = item[@"condition"];
        cell.detailLabel.text = [NSString stringWithFormat:@"%@%%",
                                     [item[@"percentage"] stringValue]];
        cell.iconImageView.image = [UIImage imageNamed:item[@"itemicon"]];
        return cell;
    } else if (indexPath.section == 6) {
        NSString *reuseIdentifier = @"questcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *quest = self.quests[indexPath.row];
        cell.textLabel.text = quest[@"questname"];
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        NSDictionary *location = self.habitats[indexPath.row];
        MHLocationViewController *vc = [[MHLocationViewController alloc] init];
        vc.locationId = location[@"locationid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    } else if (indexPath.section == 3 || indexPath.section == 4 || indexPath.section == 5) {
        NSDictionary *item = (indexPath.section == 3)
        ? self.lowRewards[indexPath.row]
        : (indexPath.section == 4) ? self.highRewards[indexPath.row]
        : self.gRewards[indexPath.row];
        MHItemViewController *vc = [[MHItemViewController alloc] init];
        vc.itemId = item[@"itemid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    } else if (indexPath.section == 6) {
        NSDictionary *quest = self.quests[indexPath.row];
        MHQuestViewController *vc = [[MHQuestViewController alloc] init];
        vc.questId = quest[@"questid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    }
}

@end
