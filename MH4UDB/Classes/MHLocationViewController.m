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

#import "MHLocationViewController.h"
#import "MHDatabase.h"
#import "MHItemViewController.h"
#import "MHMonsterViewController.h"
#import "MHDetailTableViewCell.h"

@interface MHLocationViewController ()

@property (nonatomic, retain) NSArray *monsters;
@property (nonatomic, retain) NSArray *lowRewards;
@property (nonatomic, retain) NSArray *highRewards;
@property (nonatomic, retain) NSArray *gRewards;

@end

@implementation MHLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.locationDictionary =  [database selectAllFrom:@"locations"
                                              where:@"_id == ?"
                                          arguments:@[self.locationId]
                                            orderBy:@"_id ASC"
                                              error:nil][0];
    
    self.title = self.locationDictionary[@"name"];
    
    self.monsters = [database dictionariesForQuery:@"SELECT *,"
                     " monsters.name AS monstername, monsters.icon_name AS monstericon"
                     " ,monsters._id AS monsterid"
                     " FROM monster_habitat"
                     " LEFT JOIN locations on monster_habitat.location_id = locations._id"
                     " LEFT JOIN monsters on monster_habitat.monster_id = monsters._id"
                     " WHERE locations._id == ?"
                              withArgumentsInArray:@[self.locationId]];
    
    self.lowRewards = [database dictionariesForQuery:@"SELECT *"
                       " ,items.name AS itemname ,items.icon_name AS itemicon"
                       " ,items._id AS itemid"
                       " FROM gathering"
                       " LEFT JOIN items on gathering.item_id = items._id"
                       " LEFT JOIN locations on gathering.location_id = locations._id"
                       " WHERE locations._id == ? AND rank == 'LR'"
                       " ORDER BY percentage DESC"
                                withArgumentsInArray:@[self.locationId]];
    
    self.highRewards = [database dictionariesForQuery:@"SELECT *"
                        " ,items.name AS itemname ,items.icon_name AS itemicon"
                        " ,items._id AS itemid"
                        " FROM gathering"
                        " LEFT JOIN items on gathering.item_id = items._id"
                        " LEFT JOIN locations on gathering.location_id = locations._id"
                        " WHERE locations._id == ? AND rank == 'HR'"
                        " ORDER BY percentage DESC"
                                 withArgumentsInArray:@[self.locationId]];
    
    self.gRewards = [database dictionariesForQuery:@"SELECT *"
                     " ,items.name AS itemname ,items.icon_name AS itemicon"
                     " ,items._id AS itemid"
                     " FROM gathering"
                     " LEFT JOIN items on gathering.item_id = items._id"
                     " LEFT JOIN locations on gathering.location_id = locations._id"
                     " WHERE locations._id == ? AND rank == 'G'"
                              withArgumentsInArray:@[self.locationId]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MHDetailTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"mhdetailcell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Map";
    } else if (section == 1) {
        return @"Monsters";
    } else if (section == 2) {
        return @"Low Rank";
    } else if (section == 3) {
        return @"High Rank";
    } else if (section == 4) {
        return @"G Rank";
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return [self.monsters count];
    } else if (section == 2) {
        return [self.lowRewards count];
    } else if (section == 3) {
        return [self.highRewards count];
    } else if (section == 4) {
        return [self.gRewards count];
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 350;
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
            UIImageView *map = [[UIImageView alloc] initWithImage:
                                [UIImage imageNamed:self.locationDictionary[@"map"]]];
            map.contentMode = UIViewContentModeScaleAspectFit;
            
            map.frame = cell.contentView.frame;
            map.autoresizingMask = UIViewAutoresizingFlexibleHeight
            | UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:map];
        }
        
        return cell;
    } else if (indexPath.section == 1) {
        NSString *reuseIdentifier = @"monstercell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                          reuseIdentifier:reuseIdentifier];
        }
        
        NSDictionary *monster = self.monsters[indexPath.row];
        cell.textLabel.text = monster[@"monstername"];
        cell.detailTextLabel.text = monster[@"move_area"];
        cell.imageView.image = [UIImage imageNamed:monster[@"monstericon"]];
        
        return cell;
    } else if (indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4) {
        MHDetailTableViewCell *cell = [self.tableView
                                       dequeueReusableCellWithIdentifier:@"mhdetailcell"];
        
        NSDictionary *item = (indexPath.section == 2)
        ? self.lowRewards[indexPath.row]
        : (indexPath.section == 3) ? self.highRewards[indexPath.row]
        : self.gRewards[indexPath.row];
        
        NSString *amount = [item[@"stack_size"] intValue] > 1
        ? [NSString stringWithFormat:@" x%@", [item[@"stack_size"] stringValue]] : @"";
        cell.titleLabel.text = [NSString stringWithFormat:@"%@%@", item[@"itemname"], amount];
        cell.subtitleLabel.text = [NSString stringWithFormat:@"%@ %@ %@",
                                   item[@"rank"],
                                   item[@"area"],
                                   item[@"site"]];
        cell.detailLabel.text = [NSString stringWithFormat:@"%@%%",
                                 [item[@"percentage"] stringValue]];
        cell.iconImageView.image = [UIImage imageNamed:item[@"itemicon"]];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        NSDictionary *monster = self.monsters[indexPath.row];
        MHMonsterViewController *vc = [[MHMonsterViewController alloc] init];
        vc.monsterid = monster[@"monsterid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    } else if (indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4) {
        NSDictionary *item = (indexPath.section == 2)
        ? self.lowRewards[indexPath.row]
        : (indexPath.section == 3) ? self.highRewards[indexPath.row]
        : self.gRewards[indexPath.row];
        MHItemViewController *vc = [[MHItemViewController alloc] init];
        vc.itemId = item[@"itemid"];
        [self.navigationController pushViewController:vc animated:TRUE];
    }
}

@end
