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

#import "MHCombinationViewController.h"
#import "MHDatabase.h"
#import "MHItemViewController.h"

@interface MHCombinationViewController ()

@property (nonatomic, retain) NSDictionary *combination;
@property (nonatomic, retain) NSDictionary *created;
@property (nonatomic, retain) NSDictionary *item1;
@property (nonatomic, retain) NSDictionary *item2;

@end

@implementation MHCombinationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.combination =  [database dictionariesForQuery:@"SELECT *"
                         " FROM combining"
                         " WHERE combining._id == ?"
                                  withArgumentsInArray:@[self.combinationId]][0];
    
    self.title = @"Combination";
    
    self.created = [database selectAllFrom:@"items"
                                     where:@"_id == ?"
                                 arguments:@[self.combination[@"created_item_id"]]
                                   orderBy:nil
                                     error:nil][0];
    
    self.item1 = [database selectAllFrom:@"items"
                                   where:@"_id == ?"
                               arguments:@[self.combination[@"item_1_id"]]
                                 orderBy:nil
                                   error:nil][0];
    
    self.item2 = [database selectAllFrom:@"items"
                                   where:@"_id == ?"
                               arguments:@[self.combination[@"item_2_id"]]
                                 orderBy:nil
                                   error:nil][0];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Created";
    } else if (section == 1) {
        return @"Combined";
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return 2;
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
    NSString *reuseIdentifier = @"skillcell";
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:reuseIdentifier];
    }
    
    if (indexPath.section == 0) {
        NSString *amountMade = ([self.combination[@"amount_made_min"] intValue] > 1
                                || [self.combination[@"amount_made_max"] intValue] > 1)
        ? [NSString stringWithFormat:@" (%@ - %@)",
           [self.combination[@"amount_made_min"] stringValue],
           [self.combination[@"amount_made_max"] stringValue]]
        : @"";
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@",
                               self.created[@"name"],
                               amountMade];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%%",
                                     [self.combination[@"percentage"] stringValue]];
        cell.imageView.image = [UIImage imageNamed:self.created[@"icon_name"]];
    } else if (indexPath.section == 1) {
        NSDictionary *item = (indexPath.row == 0) ? self.item1 : self.item2;
        cell.textLabel.text = item[@"name"];
        cell.imageView.image = [UIImage imageNamed:item[@"icon_name"]];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = (indexPath.section == 0) ? self.created
    : (indexPath.row == 1) ? self.item1 : self.item2;
    MHItemViewController *vc = [[MHItemViewController alloc] init];
    vc.itemId = item[@"_id"];
    [self.navigationController pushViewController:vc animated:TRUE];
}

@end
