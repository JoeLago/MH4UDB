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

#import "MHCombinationsListViewController.h"
#import "MHDatabase.h"
#import "MHCombinationViewController.h"

@interface MHCombinationsListViewController ()

@property (nonatomic, retain) NSArray *combinations;

@end

@implementation MHCombinationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Combinations";
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    
    FMResultSet *combinationResult = [database executeQuery:@"SELECT *"
                                      " ,combining._id AS combineid"
                                      " ,createitem.name AS createname ,item1.name AS item1name ,item2.name AS item2name"
                                      " ,createitem.icon_name AS createicon ,item1.icon_name AS item1icon ,item2.icon_name AS item2icon"
                                      " FROM combining"
                                      " LEFT JOIN items AS createitem ON combining.created_item_id = createitem._id"
                                      " LEFT JOIN items AS item1 ON combining.item_1_id = item1._id"
                                      " LEFT JOIN items AS item2 ON combining.item_2_id = item2._id"];
    
    NSMutableArray *combinations = [[NSMutableArray alloc] init];
    while ([combinationResult next]) {
        NSDictionary *resultDictionary = [combinationResult resultDictionary];
        [combinations addObject:resultDictionary];
    }
    self.combinations = [[NSArray alloc] initWithArray:combinations];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.combinations count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 32;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"itemcell";
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
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *combination = self.combinations[indexPath.row];
    MHCombinationViewController *vc = [[MHCombinationViewController alloc] init];
    vc.combinationId = combination[@"combineid"];
    [self.navigationController pushViewController:vc animated:TRUE];
}

@end
