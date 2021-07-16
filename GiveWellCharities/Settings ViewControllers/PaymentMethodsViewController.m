//
//  PaymentMethodsViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/15/21.
//

#import "PaymentMethodsViewController.h"
#import "BankingCell.h"
#import <Parse/Parse.h>
#import "AddCardViewController.h"

@interface PaymentMethodsViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfAccounts;
@end

@implementation PaymentMethodsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self fetchAccounts];
}

- (void)fetchAccounts{
    //fetch all donation transactions
    
    PFQuery *query = [PFQuery queryWithClassName:@"BankAccount"];
    [query whereKey:@"author" equalTo:self.user];
    [query orderByDescending:@"createdAt"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *accounts, NSError *error) {
        if (accounts != nil) {
            // do something with the array of object returned by the call
            NSLog(@"All Accounts retrieved, shown below:");
            for (PFObject *account in accounts){
                NSLog(@"%@", account);
            }
            self.arrayOfAccounts = accounts;
            [self.tableView reloadData];

        } else {
            NSLog(@"Either no accounts stored for the user or error");
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"addCardSegue"]){
        //segue info
        NSLog(@"Entering Payment Methods");
        AddCardViewController *addCardViewController = [segue destinationViewController];
        PFUser *user = [PFUser currentUser];
        addCardViewController.user = user; //pass user to paymentMethodsViewController
    }
}

-(void)didTapAddButton:(UIButton*)sender
{
    NSLog(@"Entered tapped state");
     if (sender.tag == (self.arrayOfAccounts.count))
     {
         NSLog(@"Will Transition");
         [self performSegueWithIdentifier:@"addCardSegue" sender:nil];
     }
}



- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    BankingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BankingCell"];
    cell.accountImageButton.tag = indexPath.row;
    [cell.accountImageButton addTarget:self action:@selector(didTapAddButton:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.row == (self.arrayOfAccounts.count)){
        //if reached the cell row where there are no more accounts to show
        // (note: this will be the first row if user has no account information uploaded yet)
        UIImage *image = [UIImage systemImageNamed:@"plus.rectangle"];
        [cell.accountImageButton setBackgroundImage:image forState:UIControlStateNormal];
        cell.cardTitleLabel.text = @"Add a bank or card";
        cell.cardNumber.text = @""; //empty string
        [cell.arrowView setImage:nil]; //nil arrow image
    } else {
        PFObject *account = self.arrayOfAccounts[indexPath.row];
        UIImage *image = [UIImage systemImageNamed:@"creditcard"];
        [cell.accountImageButton setBackgroundImage:image forState:UIControlStateNormal];
        cell.cardTitleLabel.text = @"Credit Card";
        cell.cardNumber.text = account[@"cardNumber"]; //card number
        
        UIImage *arrowImage = [UIImage systemImageNamed:@"chevron.right"];
        [cell.arrowView setImage:arrowImage];
    }
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfAccounts.count + 1; // add one for a cell with add account option
}

@end
