//
//  MCOrganizationViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 8/5/21.
//

#import "MCOrganizationViewController.h"
#import "MCSwipeCell.h"
#import <Parse/Parse.h>
#import "SceneDelegate.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@import MCSwipeTableViewCell;

@interface MCOrganizationViewController () <UITableViewDelegate, UITableViewDataSource, MCSwipeTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfOrganizations;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation MCOrganizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self fetchOrganizations];
    
    //refresh controls
    self.refreshControl = [[UIRefreshControl alloc] init]; //instantiate refreshControl
    [self.refreshControl addTarget:self action:@selector(fetchOrganizations) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0]; //so that the refresh icon doesn't hover over any cells
}

- (void)fetchOrganizations {
    //fetch organizations from parse databases
    PFQuery *query = [PFQuery queryWithClassName:@"Organization"];
//    [query orderByDescending:@"createdAt"];
    [query orderByAscending:@"createdAt"];


    [query findObjectsInBackgroundWithBlock:^(NSArray *organizations, NSError *error) {
      if (!error) {
        // The find succeeded.
          NSLog(@"Successfully retrieved organizations.");
          self.arrayOfOrganizations = organizations;
          for (PFObject *organization in organizations){
              NSLog(@"%@", organization);
          }
          [self.tableView reloadData];
          [self.refreshControl endRefreshing]; //end refreshing

      } else {
        // Log details of the failure
        NSLog(@"Error: %@ %@", error, [error userInfo]);
      }
        [self.refreshControl endRefreshing]; //end refreshing

    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    
//
//
//
//    OrganizationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrganizationCell"];
//    PFObject *organization = self.arrayOfOrganizations[indexPath.row];
//    NSString *organizationName = organization[@"organizationName"];
//    NSString *mission = organization[@"missionStatement"];
//    NSString *summary = organization[@"summary"];
//    cell.nameLabel.text = organizationName;
//    cell.synopsisLabel.text = mission;
//    cell.summaryLabel.text = summary;
//
//    //organization logo picture
//    PFFileObject *logoPicture = organization[@"logo"];
//    NSString *logoURLString = logoPicture.url;
//    NSURL *logoURL = [NSURL URLWithString:logoURLString];
//    cell.logoView.image = nil;
//    [cell.logoView setImageWithURL:logoURL];
//
//    return cell;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *CellIdentifier = @"Cell";
    
    
    MCSwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSwipeCell"];

//    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
//        cell = [[MCSwipeTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell = [[MCSwipeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MCSwipeCell"];

        // Remove inset of iOS 7 separators.
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsZero;
        }

        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];

        // Setting the background color of the cell.
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }

    // Configuring the views and colors.
    UIView *checkView = [self viewWithImageName:@"check"];
    UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];

    UIView *crossView = [self viewWithImageName:@"cross"];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];

    UIView *clockView = [self viewWithImageName:@"clock"];
    UIColor *yellowColor = [UIColor colorWithRed:254.0 / 255.0 green:217.0 / 255.0 blue:56.0 / 255.0 alpha:1.0];

    UIView *listView = [self viewWithImageName:@"list"];
    UIColor *brownColor = [UIColor colorWithRed:206.0 / 255.0 green:149.0 / 255.0 blue:98.0 / 255.0 alpha:1.0];

    // Setting the default inactive state color to the tableView background color.
    [cell setDefaultColor:self.tableView.backgroundView.backgroundColor];
    
    PFObject *organization = self.arrayOfOrganizations[indexPath.row];
    NSString *organizationName = organization[@"organizationName"];
    NSString *mission = organization[@"missionStatement"];
    NSString *summary = organization[@"summary"];
    cell.nameLabel.text = organizationName;
    cell.synopsisLabel.text = mission;
    cell.summaryLabel.text = summary;
    
    NSLog(@"Organization Found: %@", organization);
    
    //organization logo picture
    PFFileObject *logoPicture = organization[@"logo"];
    NSString *logoURLString = logoPicture.url;
    NSURL *logoURL = [NSURL URLWithString:logoURLString];
    cell.logoView.image = nil;
    [cell.logoView setImageWithURL:logoURL];
    

//    [cell.textLabel setText:@"Switch Mode Cell"];
//    [cell.detailTextLabel setText:@"Swipe to switch"];

    // Adding gestures per state basis.
    [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Checkmark\" cell");
    }];

    [cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState2 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Cross\" cell");
    }];

    [cell setSwipeGestureWithView:clockView color:yellowColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Clock\" cell");
    }];

    [cell setSwipeGestureWithView:listView color:brownColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState4 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"List\" cell");
    }];

    return cell;
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}




- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfOrganizations.count;
}

@end
