//
//  BankingCell.h
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/15/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BankingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *cardTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardNumber;
@property (weak, nonatomic) IBOutlet UIImageView *arrowView;
@property (weak, nonatomic) IBOutlet UIButton *accountImageButton;

@end

NS_ASSUME_NONNULL_END
