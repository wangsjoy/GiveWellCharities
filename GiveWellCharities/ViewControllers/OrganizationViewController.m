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

@interface OrganizationViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OrganizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)didTapLogout:(id)sender {
    //clear the current user
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Errror:%@", error.localizedDescription);
            
        } else {
            SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            myDelegate.window.rootViewController = loginViewController;
            NSLog(@"Successfully logged out user!");//dismiss last view controller
        }
        
    }];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    OrganizationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OrganizationCell"];
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

@end
