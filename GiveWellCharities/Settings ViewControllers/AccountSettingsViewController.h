//
//  AccountSettingsViewController.h
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/15/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface AccountSettingsViewController : UIViewController
@property (nonatomic, strong) PFUser *user;
@end

NS_ASSUME_NONNULL_END
