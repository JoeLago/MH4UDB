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

#import "MHQuestViewController.h"
#import "MHDatabase.h"
#import "MHMonsterViewController.h"
#import "MHItemViewController.h"

@interface MHQuestViewController ()

@property (nonatomic, retain) NSArray *monsters;
@property (nonatomic, retain) NSArray *rewards;

@end

@implementation MHQuestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.questDictionary =  [database selectAllFrom:@"quests"
                                              where:@"_id == ?"
                                          arguments:@[self.questId]
                                            orderBy:@"_id ASC"
                                              error:nil][0];
    
    self.title = self.questDictionary[@"name"];
    
    self.monsters = [database dictionariesForQuery:@"SELECT *,"
                     " monsters.name AS monstername, monsters.icon_name AS monstericon"
                     " FROM monster_to_quest"
                     " LEFT JOIN quests on monster_to_quest.quest_id = quests._id"
                     " LEFT JOIN monsters on monster_to_quest.monster_id = monsters._id"
                     " WHERE quests._id == ?"
                              withArgumentsInArray:@[self.questId]];
    
    self.rewards = [database dictionariesForQuery:@"SELECT *,"
                    " items.name AS itemname, items._id AS itemid"
                    " FROM quest_rewards"
                    " LEFT JOIN items on quest_rewards.item_id = items._id"
                    " LEFT JOIN quests on quest_rewards.quest_id = quests._id"
                    " WHERE quests._id == ?"
                             withArgumentsInArray:@[self.questId]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Details";
    } else if (section == 1) {
        return @"Monsters";
    } else if (section == 2) {
        return @"Rewards";
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return [self.monsters count];
    } else if (section == 2) {
        return [self.rewards count];
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
            cell.detailTextLabel.text = self.questDictionary[@"name"];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Type";
            cell.detailTextLabel.text = self.questDictionary[@"type"];
        }
    } else if (indexPath.section == 1) {
        NSString *reuseIdentifier = @"monstercell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *monster = self.monsters[indexPath.row];
        cell.textLabel.text = monster[@"monstername"];
        cell.detailTextLabel.text = [monster[@"unstable"] boolValue] ? @"Unstable" : @"";
        cell.imageView.image = [UIImage imageNamed:monster[@"monstericon"]];
    } else if (indexPath.section == 2) {
        NSString *reuseIdentifier = @"itemcell";
        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *reward = self.rewards[indexPath.row];
        cell.textLabel.text = reward[@"itemname"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%%",
                                     [reward[@"percentage"] stringValue]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSDictionary *monster = self.monsters[indexPath.row];
        MHMonsterViewController *vc = [[MHMonsterViewController alloc] init];
        vc.monsterid = monster[@"monsterid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    } else if (indexPath.section == 2) {
        NSDictionary *reward = self.rewards[indexPath.row];
        MHItemViewController *vc = [[MHItemViewController alloc] init];
        vc.itemId = reward[@"itemid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    }
}

@end
