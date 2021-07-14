//
//  DonateViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/13/21.
//

#import "DonateViewController.h"
#import "UIImageView+AFNetworking.h"
#import <Parse/Parse.h>

@interface DonateViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeControl;
@property (weak, nonatomic) IBOutlet UITextField *donationField;
@property (weak, nonatomic) IBOutlet UILabel *impactQuantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *impactMetricLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *cardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *cardExpirationField;
@property (weak, nonatomic) IBOutlet UITextField *cardCVVField;
@property (weak, nonatomic) IBOutlet UITextField *countryField;
@property (weak, nonatomic) IBOutlet UITextField *postalCodeField;
@property (weak, nonatomic) IBOutlet UILabel *donationMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *minimumLabel;
@property (assign, nonatomic) BOOL anonymous;
@property (weak, nonatomic) IBOutlet UIButton *anonymousButton;

@end

@implementation DonateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //initially set donation as public
    self.anonymous = NO;
    //set selected Image for when anonymous button is pressed
    UIImage *selectedImage = [UIImage systemImageNamed:@"circle.fill"];
    [self.anonymousButton setImage:selectedImage forState:UIControlStateSelected];
    
    self.nameLabel.text = self.organization[@"organizationName"];

    self.impactMetricLabel.text = self.organization[@"metric"];
    self.impactQuantityLabel.text = @"0"; //starts at 0
    self.minimumLabel.text = @""; //starts at no warning label (for minimum contribution of $5)
    self.donationMessageLabel.text = @"$0.00"; //starts at $0.00 donation
    
    //set organization logo image
    PFFileObject *logoPicture = self.organization[@"logo"];
    NSString *logoURLString = logoPicture.url;
    NSURL *logoURL = [NSURL URLWithString:logoURLString];
    self.logoView.image = nil;
    [self.logoView setImageWithURL:logoURL];
}

- (IBAction)onTap:(id)sender {
    //check if $5 minimum (for monthly or one-time) is met:
    double amount = [self.donationField.text doubleValue];
    double modeArray[] = {12, 1};
    double modeMultiplier = modeArray[self.modeControl.selectedSegmentIndex];
    double totalAmount = amount*modeMultiplier;
    if (totalAmount >= 5){
        NSLog(@"Exiting text field");
//        NSString *donationMessage = [@"$" stringByAppendingFormat:
//                                     @"%.2f", totalAmount];
//        self.donationMessageLabel.text = donationMessage;
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
    double amount = [self.donationField.text doubleValue];
    NSLog(@"Editing changed");
    double multiplier = [self.organization[@"multiplier"] doubleValue];
    double monetaryAmount = amount*modeMultiplier;
    double impact = amount*modeMultiplier*multiplier;
    if ((impact - 0.5) < 0){ //check if even one of metric (i.e. one malaria net can be donated
        self.impactQuantityLabel.text = @"0";
        if (monetaryAmount < 5){
            NSLog(@"Donation Minimum not met");
            self.minimumLabel.text = @"Value must be greater than or equal to 5.";
        } else {
            NSLog(@"Donation minimum met");
            self.minimumLabel.text = @""; //set as an empty non-warning string
        }
    } else { //one or more of metric quantity can be donated
        double rounded = round(impact - 0.5);
        NSLog(@"Amount calculated (unrounded): %.2f", impact);
        NSLog(@"Amount calculated (rounded): %.0f", impact);
        self.impactQuantityLabel.text = [NSString stringWithFormat:@"%.0f", rounded];
        
        //check for minimum of $5 contribution
        if (monetaryAmount < 5){
            NSLog(@"Donation Minimum not met");
            self.minimumLabel.text = @"Value must be greater than or equal to 5.";
        } else {
            NSLog(@"Donation minimum met");
            self.minimumLabel.text = @""; //set as an empty non-warning string
        }
        
    }
    //change donation message at bottom of view controller (regardless if donation minimum is met)
    NSString *donationMessage = [@"$" stringByAppendingFormat:
                                 @"%.2f", monetaryAmount];
    self.donationMessageLabel.text = donationMessage;
}

- (IBAction)changedMode:(id)sender {
    NSLog(@"Mode changed");
    double modeArray[] = {12, 1};
    double modeMultiplier = modeArray[self.modeControl.selectedSegmentIndex];
    [self calculator:modeMultiplier];
}

- (void)donateQuery{
    //code
    PFObject *transaction = [PFObject objectWithClassName:@"Payment"];
    transaction[@"author"] = [PFUser currentUser];
    transaction[@"firstName"] = self.firstNameField.text;
    transaction[@"lastName"] = self.lastNameField.text;
    transaction[@"email"] = self.emailField.text;
    transaction[@"cardNumber"] = self.cardNumberField.text;
    transaction[@"cardCVV"] = self.cardCVVField.text;
    transaction[@"zipcode"] = self.postalCodeField.text;
    transaction[@"country"] = self.countryField.text;
    transaction[@"expirationDate"] = self.cardExpirationField.text;
    
    //amount donated calculation and setting mode of transaction
    double amount = [self.donationField.text doubleValue];
    double modeArray[] = {12, 1};
    double modeMultiplier = modeArray[self.modeControl.selectedSegmentIndex];
    if (modeMultiplier == 12){
        transaction[@"mode"] = @"monthly";
    } else {
        transaction[@"mode"] = @"one-time";
    }
    double totalAmount = amount*modeMultiplier;
    NSNumber *totalNumber = [NSNumber numberWithDouble:totalAmount]; //change type from double to NSNumber
    transaction[@"donationAmount"] = totalNumber;
    
    //anonymous/public donation
    if (self.anonymous){
        transaction[@"anonymous"] = @YES;
    } else {
        transaction[@"anonymous"] = @NO;
    }
    
    [transaction saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
      if (succeeded) {
        // The object has been saved.
          NSLog(@"Payment saved successfully to database");
      } else {
        // There was a problem, check error.description
          NSLog(@"Error occurred: %@", error.localizedDescription);
      }
    }];
}

- (IBAction)didTapDonate:(id)sender {
    [self donateQuery];
}

- (IBAction)didTapAnonymous:(id)sender {
    NSLog(@"Tapped button");
    self.anonymous = !self.anonymous; //change anonymous boolean
    if (self.anonymous){
        NSLog(@"Anonymous Donation");
        [self.anonymousButton setSelected:YES];
    } else {
        NSLog(@"Public Donation");
        [self.anonymousButton setSelected:NO];
    }
    
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
