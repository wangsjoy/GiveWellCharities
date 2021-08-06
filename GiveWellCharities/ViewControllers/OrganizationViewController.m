//
//  OrganizationViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/12/21.
//

#import "OrganizationViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "MCSwipeCell.h"
#import <QuartzCore/QuartzCore.h>

@import MCSwipeTableViewCell;

@interface OrganizationViewController () <UITableViewDelegate, UITableViewDataSource, MCSwipeTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfOrganizations;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property NSInteger swipeIndex;

@end

@implementation OrganizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //ui for table view
    self.tableView.layer.borderColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0].CGColor;
    self.tableView.layer.borderWidth = 1;
    self.tableView.layer.cornerRadius = 20;
//    self.tableView.layer.borderColor = [UIColor colorWithWhite:0.6 alpha:1].CGColor;
//     self.tableView.layer.borderWidth = 1;
//     self.tableView.layer.cornerRadius = 4;
    
    
    [self fetchOrganizations];
    
    //refresh controls
    self.refreshControl = [[UIRefreshControl alloc] init]; //instantiate refreshControl
    [self.refreshControl addTarget:self action:@selector(fetchOrganizations) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0]; //so that the refresh icon doesn't hover over any cells

}

- (void)fetchOrganizations {
    //fetch organizations from parse databases
    PFQuery *query = [PFQuery queryWithClassName:@"Organization"];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"swipeSegue"]){
        NSLog(@"Entering Organization Details through Swipe");
        DetailsViewController *detailsViewController = [segue destinationViewController];
        PFObject *organization = self.arrayOfOrganizations[self.swipeIndex]; //right organization associated with right row
        detailsViewController.organization = organization; //pass organization to detailsViewController
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MCSwipeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSwipeCell"];

    if (!cell) {
        
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
    UIView *checkView = [self viewWithImageName:@"rsz_info_icon"];
    UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];

    // Setting the default inactive state color to the tableView background color.
    [cell setDefaultColor:self.tableView.backgroundView.backgroundColor];
    
    PFObject *organization = self.arrayOfOrganizations[indexPath.row];
    NSString *organizationName = organization[@"organizationName"];
    NSString *mission = organization[@"missionStatement"];
    NSString *summary = organization[@"summary"];
    cell.nameLabel.text = organizationName;
    cell.synopsisLabel.text = mission;
    cell.summaryLabel.text = summary;
    
    cell.tag = indexPath.row;
    
    NSLog(@"Organization Found: %@", organization);
    
    //organization logo picture
    PFFileObject *logoPicture = organization[@"logo"];
    NSString *logoURLString = logoPicture.url;
    NSURL *logoURL = [NSURL URLWithString:logoURLString];
    cell.logoView.image = nil;
    [cell.logoView setImageWithURL:logoURL];
    
    // Adding gestures per state basis.
    [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        NSLog(@"Did swipe \"Details\" cell");
        self.swipeIndex = cell.tag;
        [self performSegueWithIdentifier:@"swipeSegue" sender:nil];
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
