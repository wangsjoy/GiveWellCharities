//
//  UserProfileViewController.h
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 8/5/21.
//

#import <UIKit/UIKit.h>
@import EBCardCollectionViewLayout;

NS_ASSUME_NONNULL_BEGIN

@interface UserProfileViewController : UIViewController <UICollectionViewDataSource>
@property (assign) EBCardCollectionLayoutType layoutType;
@end

NS_ASSUME_NONNULL_END
