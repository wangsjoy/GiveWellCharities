//
//  DonationCell.h
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/14/21.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN
@import Parse;

@interface DonationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *metricImage;
@property (weak, nonatomic) IBOutlet UILabel *metricQuantityLabel;
@property (weak, nonatomic) IBOutlet UILabel *metricStringLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizationLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

NS_ASSUME_NONNULL_END
