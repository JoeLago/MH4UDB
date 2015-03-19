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

#import "MHWeaponTypeListViewController.h"
#import "MHWeaponListViewController.h"
#import "MHDatabase.h"

@interface MHWeaponTypeListViewController ()

@property (nonatomic, retain) NSArray *weaponTypes;

@end

@implementation MHWeaponTypeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Weapons";
    self.weaponTypes =
    @[
      @{ @"name": @"Great Sword", @"image": @"great_sword1.png" },
      @{ @"name": @"Long Sword", @"image": @"long_sword1.png" },
      @{ @"name": @"Sword and Shield", @"image": @"sword_and_shield1.png" },
      @{ @"name": @"Dual Blades", @"image": @"dual_blades1.png" },
      @{ @"name": @"Hammer", @"image": @"hammer1.png" },
      @{ @"name": @"Hunting Horn", @"image": @"hunting_horn1.png" },
      @{ @"name": @"Lance", @"image": @"lance1.png" },
      @{ @"name": @"Gunlance", @"image": @"gunlance1.png" },
      @{ @"name": @"Switch Axe", @"image": @"switch_axe1.png" },
      @{ @"name": @"Charge Blade", @"image": @"charge_blade1.png" },
      @{ @"name": @"Insect Glaive", @"image": @"insect_glaive1.png" },
      @{ @"name": @"Light Bowgun", @"image": @"light_bowgun1.png" },
      @{ @"name": @"Heavy Bowgun", @"image": @"heavy_bowgun1.png" },
      @{ @"name": @"Bow", @"image": @"bow1.png" }
      ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.weaponTypes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseIdentifier = @"weapontypecell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:reuseIdentifier];
    }
    
    cell.textLabel.text = self.weaponTypes[indexPath.row][@"name"];
    cell.imageView.image = [UIImage imageNamed:self.weaponTypes[indexPath.row][@"image"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MHWeaponListViewController *vc = [[MHWeaponListViewController alloc] init];
    vc.weaponType = self.weaponTypes[indexPath.row][@"name"];
    [self.navigationController pushViewController:vc animated:TRUE];
}

@end
