//
//  DetailsViewController.h
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/12/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController
@property (nonatomic, strong) PFObject *organization;

@end

NS_ASSUME_NONNULL_END
