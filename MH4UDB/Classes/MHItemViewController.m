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

#import "MHItemViewController.h"
#import "MHDatabase.h"
#import "MHItemViewController.h"
#import "MHQuestViewController.h"
#import "MHMonsterViewController.h"
#import "MHLocationViewController.h"
#import "MHCombinationViewController.h"
#import "MHArmorViewController.h"
#import "MHWeaponViewController.h"
#import "MHDetailTableViewCell.h"

@interface MHItemViewController ()

@property (nonatomic, retain) NSArray *combinations;
@property (nonatomic, retain) NSArray *quests;
@property (nonatomic, retain) NSArray *monsters;
@property (nonatomic, retain) NSArray *locations;
@property (nonatomic, retain) NSArray *usages;

@end

@implementation MHItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.itemDictionary =  [database selectAllFrom:@"items"
                                             where:@"_id == ?"
                                         arguments:@[self.itemId]
                                           orderBy:@"_id ASC"
                                             error:nil][0];
    
    self.title = self.itemDictionary[@"name"];
    
    self.combinations = [database dictionariesForQuery:@"SELECT "
                         " createitem.name AS createname, item1.name AS item1name, item2.name AS item2name,"
                         " createitem.icon_name AS createicon, item1.icon_name AS item1icon, item2.icon_name AS item2icon"
                         " ,combining._id AS combiningid"
                         " FROM combining"
                         " LEFT JOIN items AS createitem ON combining.created_item_id = createitem._id"
                         " LEFT JOIN items AS item1 ON combining.item_1_id = item1._id"
                         " LEFT JOIN items AS item2 ON combining.item_2_id = item2._id"
                         " WHERE created_item_id == ?"
                         " OR item_1_id == ?"
                         " OR item_2_id == ?"
                                  withArgumentsInArray:@[self.itemId, self.itemId, self.itemId]];
    
    self.quests = [database dictionariesForQuery:@"SELECT *"
                   " ,quests.name AS questname ,quests._id AS questid"
                   " FROM quest_rewards"
                   " LEFT JOIN items on quest_rewards.item_id = items._id"
                   " LEFT JOIN quests on quest_rewards.quest_id = quests._id"
                   " WHERE items._id == ?"
                            withArgumentsInArray:@[self.itemId]];
    
    self.monsters = [database dictionariesForQuery:@"SELECT *"
                     " ,monsters.name AS monstername ,monsters.icon_name AS monstericon"
                     " ,monsters._id AS monsterid"
                     " FROM hunting_rewards"
                     " LEFT JOIN items on hunting_rewards.item_id = items._id"
                     " LEFT JOIN monsters on hunting_rewards.monster_id = monsters._id"
                     " WHERE items._id == ?"
                              withArgumentsInArray:@[self.itemId]];
    
    self.locations = [database dictionariesForQuery:@"SELECT *,"
                      " locations.name AS locationname"
                      " FROM gathering"
                      " LEFT JOIN items on gathering.item_id = items._id"
                      " LEFT JOIN locations on gathering.location_id = locations._id"
                      " WHERE items._id == ?"
                               withArgumentsInArray:@[self.itemId]];
    
    self.usages = [database dictionariesForQuery:@"SELECT *,"
                   " created.name AS createdname"
                   " FROM components"
                   " LEFT JOIN items AS created on components.created_item_id = created._id"
                   " LEFT JOIN items on components.component_item_id = items._id"
                   " WHERE items._id == ?"
                            withArgumentsInArray:@[self.itemId]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MHDetailTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"mhdetailcell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Details";
    } else if (section == 1) {
        return @"Combinations";
    } else if (section == 2) {
        return @"Location";
    } else if (section == 3) {
        return @"Monster";
    } else if (section == 4) {
        return @"Quest";
    } else if (section == 5) {
        return @"Usage";
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 6;
    } else if (section == 1) {
        return [self.combinations count];
    } else if (section == 2) {
        return [self.locations count];
    } else if (section == 3) {
        return [self.monsters count];
    } else if (section == 4) {
        return [self.quests count];
    } else if (section == 5) {
        return [self.usages count];
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
    if (indexPath.section == 0) {
        NSString *reuseIdentifier = @"detailcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                          reuseIdentifier:reuseIdentifier];
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = self.itemDictionary[@"name"];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = self.itemDictionary[@"type"];
        } else if (indexPath.row == 2) {
            cell.textLabel.text = @"Rarity";
            cell.detailTextLabel.text = [self.itemDictionary[@"rarity"] stringValue];
        } else if (indexPath.row == 3) {
            cell.textLabel.text = @"Buy";
            cell.detailTextLabel.text = [self stringForNumber:self.itemDictionary[@"buy"]];
        } else if (indexPath.row == 4) {
            cell.textLabel.text = @"Sell";
            cell.detailTextLabel.text = [self stringForNumber:self.itemDictionary[@"sell"]];
        } else if (indexPath.row == 5) {
            cell.textLabel.text = @"Carry Capacity";
            cell.detailTextLabel.text = [self stringForNumber:self.itemDictionary[@"carry_capacity"]];
        }
        
        return cell;
    } else if (indexPath.section == 1) {
        NSString *reuseIdentifier = @"combinationcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *combination = self.combinations[indexPath.row];
        cell.textLabel.text = combination[@"createname"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ + %@",
                                     combination[@"item1name"],
                                     combination[@"item2name"]];
        
        return cell;
    } else if (indexPath.section == 2) {
        NSString *reuseIdentifier = @"locationcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *location = self.locations[indexPath.row];
        NSString *quantity = ([location[@"quantity"] intValue] > 1)
        ? [NSString stringWithFormat:@"(x%@) ", location[@"quantity"]]
        : @"";
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",
                               location[@"locationname"],
                               location[@"rank"],
                               location[@"area"],
                               location[@"site"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%%",
                                     quantity,
                                     location[@"percentage"]];
        
        return cell;
    } else if (indexPath.section == 3) {
        MHDetailTableViewCell *cell = [self.tableView
                                       dequeueReusableCellWithIdentifier:@"mhdetailcell"];
        
        NSDictionary *monster = self.monsters[indexPath.row];
        cell.titleLabel.text = monster[@"monstername"];
        cell.subtitleLabel.text = [NSString stringWithFormat:@"%@ %@",
                                   monster[@"rank"],
                                   monster[@"condition"]];
        cell.detailLabel.text = [NSString stringWithFormat:@"%@%%",
                                 [monster[@"percentage"] stringValue]];
        cell.iconImageView.image = [UIImage imageNamed:monster[@"monstericon"]];
        
        return cell;
    } else if (indexPath.section == 4) {
        NSString *reuseIdentifier = @"questcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *quest = self.quests[indexPath.row];
        cell.textLabel.text = quest[@"questname"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%%",
                                     [quest[@"percentage"] stringValue]];
        
        return cell;
    } else if (indexPath.section == 5) {
        NSString *reuseIdentifier = @"createdcell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *usage = self.usages[indexPath.row];
        cell.textLabel.text = usage[@"createdname"];
        cell.detailTextLabel.text = [usage[@"quantity"] stringValue];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSDictionary *combination = self.combinations[indexPath.row];
        MHCombinationViewController *vc = [[MHCombinationViewController alloc] init];
        vc.combinationId = combination[@"combiningid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    } else if (indexPath.section == 2) {
        NSDictionary *location = self.locations[indexPath.row];
        MHLocationViewController *vc = [[MHLocationViewController alloc] init];
        vc.locationId = location[@"locationid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    } else if (indexPath.section == 3) {
        NSDictionary *monster = self.monsters[indexPath.row];
        MHMonsterViewController *vc = [[MHMonsterViewController alloc] init];
        vc.monsterid = monster[@"monsterid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    } else if (indexPath.section == 4) {
        NSDictionary *quest = self.quests[indexPath.row];
        MHQuestViewController *vc = [[MHQuestViewController alloc] init];
        vc.questId = quest[@"questid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    } else if (indexPath.section == 5) {
        // TODO: what if weapon? Maybe separate sections for weapons, armors, decorations, combos?
        NSDictionary *usage = self.usages[indexPath.row];
        MHArmorViewController *vc = [[MHArmorViewController alloc] init];
        vc.armorId = usage[@"itemid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    }
}

@end
