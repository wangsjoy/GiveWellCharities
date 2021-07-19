//
//  DonateViewController.h
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/13/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DonateViewController : UIViewController <CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
}
@property (nonatomic, strong) PFObject *organization;

@end

NS_ASSUME_NONNULL_END
