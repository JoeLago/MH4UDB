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

#import "MHMonstersListViewController.h"
#import "MHDatabase.h"
#import "MHMonsterViewController.h"

@interface MHMonstersListViewController ()

@property (nonatomic, retain) UISegmentedControl *typeSegment;
@property (nonatomic, retain) NSArray *monsters;

@end

@implementation MHMonstersListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Monsters";
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc]
                                   initWithItems:@[@"Large", @"Small", @"All"]];
    segmentedControl.frame = CGRectMake(0, 0, 300, 30);
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self
                         action:@selector(refreshMonsters)
               forControlEvents:UIControlEventValueChanged];
    self.typeSegment = segmentedControl;
    UIBarButtonItem *segmentedControlButtonItem = [[UIBarButtonItem alloc]
                                                   initWithCustomView:(UIView *)segmentedControl];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                      target:nil
                                      action:nil];
    
    [self.navigationController setToolbarHidden:NO];
    [self setToolbarItems:@[flexibleSpace, segmentedControlButtonItem, flexibleSpace]];

    [self refreshMonsters];
}

- (void)refreshMonsters {
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    if (self.typeSegment.selectedSegmentIndex == 0) {
        self.monsters =  [database selectAllFrom:@"monsters"
                                           where:@"class == ?"
                                       arguments:@[@"Boss"]
                                         orderBy:@"sort_name ASC"
                                           error:nil];
    } else if (self.typeSegment.selectedSegmentIndex == 1) {
        self.monsters =  [database selectAllFrom:@"monsters"
                                           where:@"class == ?"
                                       arguments:@[@"Minion"]
                                         orderBy:@"sort_name ASC"
                                           error:nil];
    } else if (self.typeSegment.selectedSegmentIndex == 2) {
        self.monsters =  [database selectAllFrom:@"monsters"
                                           where:nil
                                       arguments:nil
                                         orderBy:@"sort_name ASC"
                                           error:nil];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.monsters count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"weapontypecell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
    }
    
    cell.textLabel.text = self.monsters[indexPath.row][@"name"];
    cell.imageView.image = [UIImage imageNamed:self.monsters[indexPath.row][@"icon_name"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MHMonsterViewController *vc = [[MHMonsterViewController alloc] init];
    vc.monsterid = self.monsters[indexPath.row][@"_id"];
    [self.navigationController pushViewController:vc animated:TRUE];
}

@end
