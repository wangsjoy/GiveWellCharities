//
//  OrganizationViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/12/21.
//

#import "OrganizationViewController.h"
#import "OrganizationCell.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "SceneDelegate.h"
#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface OrganizationViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfOrganizations;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

@implementation OrganizationViewController

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"detailSegue"]){
        NSLog(@"Entering Organization Details");
        DetailsViewController *detailsViewController = [segue destinationViewController];
        UITableViewCell *tappedCell = sender; //sender is just table view cell that was tapped on
        NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell]; //grabs index path
        PFObject *organization = self.arrayOfOrganizations[indexPath.row]; //right organization associated with right row
        detailsViewController.organization = organization; //pass organization to detailsViewController
    }


}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    OrganizationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrganizationCell"];
    PFObject *organization = self.arrayOfOrganizations[indexPath.row];
    NSString *organizationName = organization[@"organizationName"];
    NSString *mission = organization[@"missionStatement"];
    NSString *summary = organization[@"summary"];
    cell.nameLabel.text = organizationName;
    cell.synopsisLabel.text = mission;
    cell.summaryLabel.text = summary;
    
    //organization logo picture
    PFFileObject *logoPicture = organization[@"logo"];
    NSString *logoURLString = logoPicture.url;
    NSURL *logoURL = [NSURL URLWithString:logoURLString];
    cell.logoView.image = nil;
    [cell.logoView setImageWithURL:logoURL];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfOrganizations.count;
}

@end
