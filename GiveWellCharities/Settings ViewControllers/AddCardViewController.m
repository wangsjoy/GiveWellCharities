//
//  AddCardViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/15/21.
//

#import "AddCardViewController.h"

@interface AddCardViewController ()
@property (weak, nonatomic) IBOutlet UITextField *cardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *expirationField;
@property (weak, nonatomic) IBOutlet UITextField *cardCVVField;
@property (weak, nonatomic) IBOutlet UITextField *zipcodeField;
@property (weak, nonatomic) IBOutlet UITextField *countryField;

@end

@implementation AddCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (BOOL)checkEmptyFields {
    //returns yes if there are any empty fields, no otherwise
    if ([self.cardNumberField.text isEqualToString:@""] || [self.expirationField.text isEqualToString:@""] || [self.cardCVVField.text isEqualToString:@""] || [self.zipcodeField.text isEqualToString:@""] || [self.countryField.text isEqualToString:@""]){
        return YES;
    } else {
        return NO;
    }
}

- (IBAction)onTap:(id)sender {
    //on tap, dismiss any keyboards
    [self.view endEditing:YES];
}

- (IBAction)addCard:(id)sender {
    if ([self checkEmptyFields]){
        NSLog(@"Not all fields filled");
    } else {
        NSLog(@"Fields filled");
        PFObject *card = [PFObject objectWithClassName:@"BankAccount"];
        card[@"author"] = [PFUser currentUser];
        card[@"cardNumber"] = self.cardNumberField.text;
        card[@"expirationDate"] = self.expirationField.text;
        card[@"cardCVV"] = self.cardCVVField.text;
        card[@"zipcode"] = self.zipcodeField.text;
        card[@"country"] = self.countryField.text;
        
        [card saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
          if (succeeded) {
            // The object has been saved.
              NSLog(@"Card saved successfully to database");
          } else {
            // There was a problem, check error.description
              NSLog(@"Error occurred: %@", error.localizedDescription);
          }
        }];
        [self dismissViewControllerAnimated:YES completion:nil]; //dismiss view controller
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
