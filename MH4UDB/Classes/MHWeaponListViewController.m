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

#import "MHWeaponListViewController.h"
#import "MHDatabase.h"
#import "MHWeaponViewController.h"

@interface MHWeaponListViewController ()

@property (nonatomic, strong) NSMutableArray *weaponsTree;
@property (nonatomic, strong) NSMutableArray *weaponsList;
@property (nonatomic, strong) MHDatabase *lookupDatabase;
@property (nonatomic, assign) NSInteger largestDepth;

@end

@implementation MHWeaponListViewController

- (void)loadView {
    [super loadView];
    self.title = self.weaponType;
    
    self.weaponsTree = [NSMutableArray new];
    self.weaponsList = [NSMutableArray new];
    self.lookupDatabase = [MHDatabase sharedMHDatabase];
    [self populateWeapons];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.3; //seconds
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
}

- (void)populateWeapons {
    self.largestDepth = 0;
    
    NSError *error = nil;
    NSArray *weapons = [self.lookupDatabase selectAllFrom:@"weapons"
                        " LEFT JOIN items on weapons._id = items._id"
                                                    where:@"parent_id == 0 AND wType == ?"
                                                arguments:@[self.weaponType]
                                                  orderBy:nil
                                                    error:&error];
    
    for (NSDictionary *weapon in weapons) {
        NSMutableDictionary *newWeapon = [NSMutableDictionary dictionaryWithDictionary:weapon];
        [self.weaponsTree addObject:newWeapon];
        [self populateWeapon:newWeapon depth:0];
    }
}

- (void)populateWeapon:(NSMutableDictionary*)weapon depth:(NSInteger)depth {
    if (depth > self.largestDepth) {
        self.largestDepth = depth;
    }
    
    for (int i = 0; i < depth; i++) {
        weapon[@"name"] = [NSString stringWithFormat:@"-%@", weapon[@"name"]];
    }
    
    [self.weaponsList addObject:weapon];
    NSNumber *weaponId = weapon[@"_id"];
    NSArray *weapons = [self.lookupDatabase selectAllFrom:@"weapons"
                        " LEFT JOIN items on weapons._id = items._id"
                                                    where:@"parent_id == ?"
                                                arguments:@[weaponId]
                                                  orderBy:nil
                                                    error:nil];
    
    NSMutableArray *children = [[NSMutableArray alloc] init];
    weapon[@"Children"] = children;
    for (NSDictionary *weapon in weapons) {
        NSMutableDictionary *newWeapon = [NSMutableDictionary dictionaryWithDictionary:weapon];
        [self populateWeapon:newWeapon depth:depth + 1];
        [children addObject:newWeapon];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath == nil) {
        //NSLog(@"long press on table view but not on a row");
    } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        //NSLog(@"long press on table view at row %ld", (long)indexPath.row);
        [self colapseAtIndexPath:indexPath animated:TRUE];
    } else {
        //NSLog(@"gestureRecognizer.state = %ld", gestureRecognizer.state);
    }
}

- (void)colapseAtIndexPath:(NSIndexPath*)indexPath animated:(BOOL)animated {
    NSDictionary *weapon = self.weaponsList[indexPath.row];
    NSMutableArray *children = [self getChildrenForWeapon:weapon];
    
    if (children.count > 0) {
        if (animated) {
            if ([self.weaponsList indexOfObject:children[0]] == NSNotFound) {
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:
                                        NSMakeRange(indexPath.row + 1, children.count)];
                [self.weaponsList insertObjects:children atIndexes:indexSet];
                
                NSMutableArray *indexPaths = [NSMutableArray array];
                [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                    [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
                }];
                
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:TRUE];
            }
            else {
                NSMutableArray *indexPaths = [NSMutableArray array];
                [self.weaponsList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([children indexOfObject:obj] != NSNotFound) {
                        [indexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
                    }
                }];
                
                [self.weaponsList removeObjectsInArray:children];
                
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:TRUE];
            }
        } else {
            if (children.count > 0) {
                if ([self.weaponsList indexOfObject:children[0]] == NSNotFound) {
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:
                                            NSMakeRange(indexPath.row + 1, children.count)];
                    [self.weaponsList insertObjects:children atIndexes:indexSet];
                    [self.tableView reloadData];
                }
                else {
                    [self.weaponsList removeObjectsInArray:children];
                    [self.tableView reloadData];
                }
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.weaponsList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"weaponscell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
    }
    
    NSDictionary *weapon = self.weaponsList[indexPath.row];
    cell.textLabel.text = weapon[@"name"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.imageView.image = [UIImage imageNamed:weapon[@"icon_name"]];
    
    return cell;
}

- (NSMutableArray*)getChildrenForWeapon:(NSDictionary*)weapon {
    NSMutableArray *children = [NSMutableArray array];
    for (NSDictionary *child in weapon[@"Children"]) {
        [children addObject:child];
        [children addObjectsFromArray:[self getChildrenForWeapon:child]];
    }
    return children;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *weapon = self.weaponsList[indexPath.row];
    MHWeaponViewController *vc = [MHWeaponViewController new];
    vc.weaponId = weapon[@"_id"];
    [self.navigationController pushViewController:vc animated:TRUE];
}

@end
