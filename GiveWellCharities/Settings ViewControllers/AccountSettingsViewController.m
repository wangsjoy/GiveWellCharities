//
//  AccountSettingsViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/15/21.
//

#import "AccountSettingsViewController.h"

@interface AccountSettingsViewController ()
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@end

@implementation AccountSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //requery for user information
    PFQuery *query = [PFUser query];
    PFUser *user = [PFUser currentUser];
    [query whereKey:@"objectId" equalTo:user.objectId]; // find the user
    NSArray *users = [query findObjects];
    PFUser *queriedUser = users[0];
    self.user = queriedUser;
    
    //fill in text fields if first/last name, email already available
    self.firstNameField.text = self.user[@"firstName"];
    self.lastNameField.text = self.user[@"lastName"];
    self.emailField.text = self.user[@"email"];
}

- (IBAction)onTap:(id)sender {
    //on tap exit text field kepboard
    [self.view endEditing:true];
}

- (IBAction)didTapSave:(id)sender {
    //post first/last name, email
    PFQuery *query = [PFUser query];
    PFUser *user = [PFUser currentUser];
    NSString *userID = user.objectId;
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:userID
                                 block:^(PFObject *user, NSError *error) {
        // Now let's update it with some new data.
        if (error){
            NSLog(@"%@", error.localizedDescription);
        } else {
            //successfully returned user, updated user information
            NSLog(@"Finished updating");
            user[@"firstName"] = self.firstNameField.text;
            user[@"lastName"] = self.lastNameField.text;
            user[@"email"] = self.emailField.text;
            [user saveInBackground];
        }
    }];
    //dismiss any keyboards still open
    [self.view endEditing:true];
    NSLog(@"Finished posting account information");
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
