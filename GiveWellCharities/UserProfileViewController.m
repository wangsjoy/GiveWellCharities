//
//  UserProfileViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 8/5/21.
//

#import "UserProfileViewController.h"
#import <Parse/Parse.h>
#import "UIImageView+AFNetworking.h"
#import "DateTools.h"
#import "UserDonationCell.h"
#import <EBCardCollectionViewLayout/EBCardCollectionViewLayout.h>

@import Parse;
@import EBCardCollectionViewLayout;

//<UICollectionViewDelegate, UICollectionViewDataSource>

@interface UserProfileViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) NSMutableArray *arrayOfPayments;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet PFImageView *profileView;
@property (nonatomic, strong) NSMutableArray *arrayOfPaymentDictionaries;
@property (weak, nonatomic) IBOutlet UICollectionView *donationsCollectionView;

@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.user = [PFUser currentUser];
    
    self.nameLabel.text = self.user.username;
    
    //find user first and last name, if unavailable, use username
    NSString *firstName = self.user[@"firstName"];
    NSString *lastName = self.user[@"lastName"];
    if ([firstName isEqualToString:@""] && [lastName isEqualToString:@""]){
        NSLog(@"No saved name found - using username");
        self.nameLabel.text = self.user.username;
    } else {
        NSString *firstNameSpace = [firstName stringByAppendingString:@" "];
        NSString *nameString = [firstNameSpace stringByAppendingString:lastName];
        NSLog(@"Welcome to the profile page, %@", nameString);
        self.nameLabel.text = nameString;
    }
    
    //load profile picture
    [self fetchProfilePicture];

    self.profileView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileView.layer.masksToBounds = YES;
    self.profileView.layer.cornerRadius = self.profileView.bounds.size.width/2;
    
    //add gesture recognition to the imageView element
    UITapGestureRecognizer *fingerTap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(onProfilePhotoTap:)];
    [self.profileView setUserInteractionEnabled:YES];
    [self.profileView addGestureRecognizer:fingerTap];
    
    //fetch user transactions
    [self fetchTransactions];
    
    //configure Collection View
//    self.donationsCollectionView.dataSource = self;
//    self.donationsCollectionView.delegate = self;
    
    //  The bigger the offset, the more you see on previous / next cards.
    self.donationsCollectionView.dataSource = self;
    self.layoutType = EBCardCollectionLayoutHorizontal;
    self.title = @"Horizontal Scrolling";
    
    UIOffset horizontalOffset = UIOffsetMake(40, 10);
    
    EBCardCollectionViewLayout *layout = [[EBCardCollectionViewLayout alloc] init];
    [layout setOffset:horizontalOffset];
    [layout setLayoutType:EBCardCollectionLayoutHorizontal];
    self.donationsCollectionView.collectionViewLayout = layout;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.donationsCollectionView.contentOffset = CGPointMake(0, 0);
}

- (void)fetchProfilePicture{
    //get profile picture
    PFUser *user = [PFUser currentUser];
    self.profileView.file = user[@"profilePicture"];
    [self.profileView loadInBackground];
}

- (void)onProfilePhotoTap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"Photo Tapped");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Choose Photo"
                                                                               message:@"Choose photo from camera roll or take photo"
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    // create a take photo action
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle cancel response here. Doing nothing will dismiss the view.
        //take photo if camera available, otherwise use photo library
        UIImagePickerController *imagePickerVC = [UIImagePickerController new];
        imagePickerVC.delegate = self;
        imagePickerVC.allowsEditing = YES;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else {
            NSLog(@"Camera 🚫 available so we will use photo library instead");
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:imagePickerVC animated:YES completion:nil];
        
    }];
    // add the cancel action to the alertController
    [alert addAction:takePhotoAction];

    // create a choose photo from photo library action
    UIAlertAction *photoLibraryAction = [UIAlertAction actionWithTitle:@"Photo Library"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
        //choose photo from photo library
        UIImagePickerController *imagePickerVC = [UIImagePickerController new];
        imagePickerVC.delegate = self;
        imagePickerVC.allowsEditing = YES;
        
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:imagePickerVC animated:YES completion:nil];
                                                     }];
    // add the OK action to the alert controller
    [alert addAction:photoLibraryAction];
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    // Get the image captured by the UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];

    // Do something with the images (based on your use case)
    [self.profileView setImage:editedImage];
    
    //resize photo
    CGSize size = CGSizeMake(300, 215);
    UIImage *edited = [self resizeImage:editedImage withSize:(size)];
    self.image = edited;
    
    //post profile picture
    PFQuery *query = [PFUser query];
    PFUser *user = [PFUser currentUser];
    NSString *userID = user.objectId;
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:userID
                                 block:^(PFObject *user, NSError *error) {
        // Now let's update it with some new data.
        if (error){
            NSLog(@"%@", error.localizedDescription);
        } else {
            //successfully returned user
            NSData *imageData = UIImagePNGRepresentation(self.image);
            PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"image.png" data:imageData];
            user[@"profilePicture"] = imageFile; //update profile picture
            NSLog(@"Finished updating");
            [user saveInBackground];
        }
    }];
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Finished Taking Photo");
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)fetchTransactions{
    //fetch all donation transactions
    
    PFQuery *query = [PFQuery queryWithClassName:@"Payment"];
    [query whereKey:@"author" equalTo:self.user];
    [query orderByDescending:@"createdAt"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *payments, NSError *error) {
        if (payments != nil) {
            // do something with the array of object returned by the call
            NSLog(@"All Payments retrieved");
            for (PFObject *payment in payments){
                NSLog(@"%@", payment);
            }
            self.arrayOfPayments = payments;
            [self.donationsCollectionView reloadData];

        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (BOOL)shouldAutorotate {
    [self.donationsCollectionView.collectionViewLayout invalidateLayout];
    
    BOOL retVal = YES;
    return retVal;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UserDonationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserDonationCell" forIndexPath:indexPath];
    PFObject *payment = self.arrayOfPayments[indexPath.row];

    NSLog(@"Payment: %@", payment);
    
//    DonationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DonationCell"];
//    PFObject *payment = self.arrayOfPayments[indexPath.row];
     //populate cell labels
     cell.organizationLabel.text = payment[@"organizationName"];
    
    //create string for metric (e.g. "392 children vaccinated")
    NSString *metricQuantity = payment[@"metricQuantity"];
    NSString *metricStringLabel = payment[@"metricString"];
    NSString *metricSpace = [metricQuantity stringByAppendingString:@" "];
    NSString *metricString = [metricSpace stringByAppendingString:metricStringLabel];
    cell.metricQuantityLabel.text = metricString;
//     cell.metricStringLabel.text = payment[@"metricString"];
//     cell.metricQuantityLabel.text = payment[@"metricQuantity"];
     cell.metricImage.file = payment[@"metricImage"];
     [cell.metricImage loadInBackground];
     
     //timestamp label
     NSDate *createdAt = payment.createdAt;
     NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
     dateFormatter.dateFormat = @"dd/MM/yyyy";
     NSString *dateString = [dateFormatter stringFromDate:createdAt];
     cell.timeLabel.text = createdAt.timeAgoSinceNow;
     
    return cell;
    
    
    
//    DemoCollectionViewCell *retVal = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewCell"
//                                                                              forIndexPath:indexPath];
//    retVal.person = _people[indexPath.row];
//    return retVal;
    
    
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfPayments.count;
}

@end
