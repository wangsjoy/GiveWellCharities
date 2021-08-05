//
//  SettingsViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/15/21.
//

#import "SettingsViewController.h"
#import "SettingsCell.h"
#import "AccountSettingsViewController.h"
#import "PaymentMethodsViewController.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //only 3 rows in tableView (account settings, payment methods, sign out) - perform appropriate segue for each
    if (indexPath.row == 0){ //account settings segue
        [self performSegueWithIdentifier:@"accountSegue" sender:nil];
    } else if (indexPath.row == 1){ //payment methods segue
        [self performSegueWithIdentifier:@"bankingSegue" sender:nil];
    } else { //signout segue
        //clear the current user
        [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"Error:%@", error.localizedDescription);
                
            } else {
                SceneDelegate *myDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"UserLoginViewController"];
                myDelegate.window.rootViewController = loginViewController;
                NSLog(@"Successfully logged out user!");//dismiss last view controller
            }
            
        }];
    }
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"accountSegue"]){
        NSLog(@"Entering Account Settings");
        AccountSettingsViewController *accountSettingsViewController = [segue destinationViewController];
        PFUser *user = [PFUser currentUser];
    } else if ([segue.identifier isEqualToString:@"bankingSegue"]){
        NSLog(@"Entering Payment Methods");
        PaymentMethodsViewController *paymentMethodsViewController = [segue destinationViewController];
        PFUser *user = [PFUser currentUser];
        paymentMethodsViewController.user = user; //pass user to paymentMethodsViewController
    }
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
    //Recall: only 3 rows in tableView (account settings, payment methods, sign out) - perform appropriate segue for each
    if (indexPath.row == 0){
        UIImage *image = [UIImage systemImageNamed:@"person.circle"];
        [cell.settingsIconView setImage:image];
        cell.settingsLabel.text = @"Account";
    } else if (indexPath.row == 1){
        UIImage *image = [UIImage systemImageNamed:@"creditcard"];
        [cell.settingsIconView setImage:image];
        cell.settingsLabel.text = @"Payment methods";
    } else {
        UIImage *image = [UIImage systemImageNamed:@"arrow.down.left.circle.fill"];
        [cell.settingsIconView setImage:image];
        cell.settingsLabel.text = @"Sign out";
    }
    return cell;

}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

@end
