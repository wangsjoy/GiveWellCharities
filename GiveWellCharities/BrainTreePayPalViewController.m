//
//  BrainTreePayPalViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/29/21.
//

#import "BrainTreePayPalViewController.h"
@import BraintreeDropIn;
@import Braintree;

@interface BrainTreePayPalViewController ()

@end

@implementation BrainTreePayPalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onTap:(id)sender {
    
    [self showDropIn:@"sandbox_5rzkvvbq_yhmkqgz24bmzjpqv"];

}

- (void)showDropIn:(NSString *)clientTokenOrTokenizationKey {
BTDropInRequest *request = [[BTDropInRequest alloc] init];
BTDropInController *dropIn = [[BTDropInController alloc] initWithAuthorization:clientTokenOrTokenizationKey request:request handler:^(BTDropInController * _Nonnull controller, BTDropInResult * _Nullable result, NSError * _Nullable error) {

    if (error != nil) {
        NSLog(@"ERROR");
    } else if (result.canceled) {
        NSLog(@"CANCELLED");
    } else {
        // Use the BTDropInResult properties to update your UI
        // result.paymentOptionType
        // result.paymentMethod
        // result.paymentIcon
        // result.paymentDescription
    }
}];
[self presentViewController:dropIn animated:YES completion:nil];
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
