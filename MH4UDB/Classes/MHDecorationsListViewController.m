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

#import "MHDecorationsListViewController.h"
#import "MHDatabase.h"
#import "MHDecorationViewController.h"

@interface MHDecorationsListViewController ()

@property (nonatomic, retain) NSArray *decorations;

@end

@implementation MHDecorationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Decorations";
    MHDatabase *database = [MHDatabase sharedMHDatabase];
    self.decorations = [database selectAllFrom:@"decorations"
                      " LEFT JOIN items on decorations._id = items._id"
                                       where:nil
                                   arguments:nil
                                     orderBy:@"_id ASC"
                                       error:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.decorations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"itemcell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
    }
    
    NSDictionary *decoration = self.decorations[indexPath.row];
    cell.textLabel.text = decoration[@"name"];
    cell.imageView.image = [UIImage imageNamed:decoration[@"icon_name"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *decoration = self.decorations[indexPath.row];
    MHDecorationViewController *vc = [[MHDecorationViewController alloc] init];
    vc.decorationId = decoration[@"_id"];
    [self.navigationController pushViewController:vc animated:TRUE];
}

@end

