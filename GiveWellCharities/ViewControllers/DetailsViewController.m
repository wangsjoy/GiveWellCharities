//
//  DetailsViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/12/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "DonateViewController.h"
#import "OrganizationMapViewController.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *missionLabel;
@property (weak, nonatomic) IBOutlet UITextField *calculatorField;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *metricLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeControl;
@property (weak, nonatomic) IBOutlet UILabel *minimumLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = self.organization[@"organizationName"];
    self.summaryLabel.text = self.organization[@"summary"];
    self.missionLabel.text = self.organization[@"missionStatement"];
    self.metricLabel.text = self.organization[@"metric"];
    self.quantityLabel.text = @"0"; //starts at 0
    self.minimumLabel.text = @""; //starts at an empty non-warning string
    
    //set organization logo image
    PFFileObject *logoPicture = self.organization[@"logo"];
    NSString *logoURLString = logoPicture.url;
    NSURL *logoURL = [NSURL URLWithString:logoURLString];
    self.logoView.image = nil;
    [self.logoView setImageWithURL:logoURL];
}

- (IBAction)onTap:(id)sender {
    //exit keypad
    
    //check if $5 minimum (for monthly or one-time) is met:
    double amount = [self.calculatorField.text doubleValue];
    double modeArray[] = {12, 1};
    double modeMultiplier = modeArray[self.modeControl.selectedSegmentIndex];
    double totalAmount = amount*modeMultiplier;
    if (totalAmount >= 5){
        NSLog(@"Exiting calculator");
        [self.view endEditing:true];
    } else {
        NSLog(@"Donation Minimum not met");
        self.minimumLabel.text = @"Value must be greater than or equal to 5.";
        [self.view endEditing:true];
        
    }

}

- (IBAction)calculatingImpact:(id)sender {
    double modeArray[] = {12, 1};
    double modeMultiplier = modeArray[self.modeControl.selectedSegmentIndex];
    [self calculator:modeMultiplier];
}

- (void)calculator:(double)modeMultiplier{
    double amount = [self.calculatorField.text doubleValue];
    NSLog(@"Editing changed");
    double multiplier = [self.organization[@"multiplier"] doubleValue];
    double monetaryAmount = amount*modeMultiplier;
    double impact = amount*modeMultiplier*multiplier;
    if ((impact - 0.5) < 0){
        self.quantityLabel.text = @"0";
        if (monetaryAmount < 5){
            NSLog(@"Donation Minimum not met");
            self.minimumLabel.text = @"Value must be greater than or equal to 5.";
        } else {
            NSLog(@"Donation minimum met");
            self.minimumLabel.text = @""; //set as an empty non-warning string
        }
    } else {
        double rounded = round(impact - 0.5);
        NSLog(@"Amount calculated (unrounded): %.2f", impact);
        NSLog(@"Amount calculated (rounded): %.0f", impact);
        self.quantityLabel.text = [NSString stringWithFormat:@"%.0f", rounded];
        
        //check for minimum of $5 contribution
        if (monetaryAmount < 5){
            NSLog(@"Donation Minimum not met");
            self.minimumLabel.text = @"Value must be greater than or equal to 5.";
        } else {
            NSLog(@"Donation minimum met");
            self.minimumLabel.text = @""; //set as an empty non-warning string
        }
        
    }
}

- (IBAction)changedMode:(id)sender {
    NSLog(@"Mode changed");
    double modeArray[] = {12, 1};
    double modeMultiplier = modeArray[self.modeControl.selectedSegmentIndex];
    [self calculator:modeMultiplier];
}

- (IBAction)didTapDonate:(id)sender {
    // manually segue to logged in view
    [self performSegueWithIdentifier:@"donateSegue" sender:nil];
}


- (IBAction)didTapMap:(id)sender {
    [self performSegueWithIdentifier:@"organizationMapSegue" sender:nil];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"donateSegue"]){
        NSLog(@"Entering Donation View Controller");
        DonateViewController *donateViewController = [segue destinationViewController];
        donateViewController.organization = self.organization; //pass organization to detailsViewController
    } else if ([segue.identifier isEqualToString:@"organizationMapSegue"]){
        NSLog(@"Entering Organization Map View Controller");
        OrganizationMapViewController *organizationMapViewController = [segue destinationViewController];
        organizationMapViewController.organization = self.organization; //pass organization to detailsViewController
    }
    
}


@end
