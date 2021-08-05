//
//  MCSwipeCell.h
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 8/5/21.
//

#import <MCSwipeTableViewCell/MCSwipeTableViewCell.h>

NS_ASSUME_NONNULL_BEGIN

@interface MCSwipeCell : MCSwipeTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;

@end

NS_ASSUME_NONNULL_END
