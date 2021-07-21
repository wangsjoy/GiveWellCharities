//
//  MapViewController.h
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/19/21.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@end

NS_ASSUME_NONNULL_END
