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

#import "GiveWellCharities-Swift.h"

@import Parse;
@import EBCardCollectionViewLayout;


@interface UserProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) NSMutableArray *arrayOfPayments;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet PFImageView *profileView;
@property (nonatomic, strong) NSMutableArray *arrayOfPaymentDictionaries;
@property (nonatomic, strong) NSMutableArray *arrayOfMetricStrings;
@property (nonatomic, strong) NSMutableArray *arrayOfOrganizationStrings;
@property (weak, nonatomic) IBOutlet UICollectionView *donationsCollectionView;
@property (weak, nonatomic) IBOutlet UILabel *metricLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizationLabel;
@property (weak, nonatomic) IBOutlet UIButton *confettiButton;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *donationCountView;
@property (weak, nonatomic) IBOutlet UILabel *transactionCountLabel;
@property(nonatomic, weak) CAEmitterLayer *confettiEmitter;
@end

@implementation UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.user = [PFUser currentUser];
    self.donationsCollectionView.dataSource = self;
    self.donationsCollectionView.delegate = self;
    
    NSString *atSymbol = @"@";
    NSString *handle = [atSymbol stringByAppendingString:self.user.username];
    self.usernameLabel.text = handle;
    
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
    
    //  The bigger the offset, the more you see on previous / next cards.
    self.donationsCollectionView.dataSource = self;
    self.layoutType = EBCardCollectionLayoutHorizontal;
    
    UIOffset horizontalOffset = UIOffsetMake(100, 10);
    
    EBCardCollectionViewLayout *layout = [[EBCardCollectionViewLayout alloc] init];
    [layout setOffset:horizontalOffset];
    [layout setLayoutType:EBCardCollectionLayoutHorizontal];
    self.donationsCollectionView.collectionViewLayout = layout;
    
    //round the edges of the donation count view
    [self.donationCountView.layer setCornerRadius:8];
    [self.donationCountView.layer setMasksToBounds:YES];
    [self.donationCountView.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.donationCountView.layer setBorderWidth:1.0];
}

- (IBAction)didTapSettings:(id)sender {
    [self performSegueWithIdentifier:@"userSettingsSegue" sender:nil];
}


- (IBAction)didTapConfetti:(id)sender {
    [self startConfetti];
}

- (void)startConfetti{
    NSLog(@"Start Confetti Emitter");
    //confetti emitter
    CAEmitterLayer *confettiEmitter = [[CAEmitterLayer alloc] init];
    confettiEmitter.emitterPosition = CGPointMake(0, 0);
    CAEmitterCell *emitterCell = [[CAEmitterCell alloc] init];
    emitterCell.birthRate = 100;
    emitterCell.lifetime = 5;
    emitterCell.velocity = 100;
    emitterCell.scale = 0.01;
    emitterCell.emissionRange = 3.14 * 2.0;
    emitterCell.contents = (id) [[UIImage imageNamed:@"green_confetti"] CGImage];
    confettiEmitter.emitterCells = [NSArray arrayWithObject:emitterCell];
    [self.view.layer addSublayer:confettiEmitter];
}


- (UserDonationCell *)configureUserDonationCell:(UserDonationCell *)cell index:(NSIndexPath *)indexPath{
        
    PFObject *payment = self.arrayOfPayments[indexPath.row];

    NSLog(@"Payment: %@", payment);

//     cell.metricImage.file = payment[@"metricImage"];
    cell.metricImage.file = payment[@"metricWhiteImage"];
    [cell.metricImage loadInBackground];
    
    [cell.timeLabel.layer setCornerRadius:8];
    [cell.timeLabel setClipsToBounds:TRUE];
    [cell.timeLabel setTextColor:[UIColor whiteColor]];
    [cell.timeLabel.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [cell.timeLabel.layer setBorderWidth:1.0];
    
    //timestamp label
    NSDate *createdAt = payment.createdAt;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    NSString *dateString = [dateFormatter stringFromDate:createdAt];
    cell.timeLabel.text = createdAt.timeAgoSinceNow;
    
    self.metricLabel.text = self.arrayOfMetricStrings[indexPath.row];
    self.organizationLabel.text = self.arrayOfOrganizationStrings[indexPath.row];
    
    //cell gradient
    [cell setBackgroundColor:[UIColor clearColor]];

    CAGradientLayer *grad = [CAGradientLayer layer];
    grad.frame = cell.bounds;
    grad.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:51.0/255.0 green:204.0/255.0 blue:51.0/255.0 alpha:1.0] CGColor], (id)[[UIColor colorWithRed:235.0/255.0 green:250.0/255.0 blue:235.0/255.0 alpha:1.0] CGColor], nil];
    
    //rounded corners
    [grad setCornerRadius:30];
    [grad setMasksToBounds:YES];

    [cell setBackgroundView:[[UIView alloc] init]];
    [cell.backgroundView.layer insertSublayer:grad atIndex:0];

    CAGradientLayer *selectedGrad = [CAGradientLayer layer];
    selectedGrad.frame = cell.bounds;
    selectedGrad.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor], (id)[[UIColor whiteColor] CGColor], nil];

    [cell setSelectedBackgroundView:[[UIView alloc] init]];
    [cell.selectedBackgroundView.layer insertSublayer:selectedGrad atIndex:0];
    
    //rounded corners
    cell.contentView.layer.cornerRadius = 30;
    cell.contentView.layer.masksToBounds = YES;
    
    return cell;
    
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
//    [scanner setScanLocation:1]; // bypass '#' character
    [scanner setScanLocation:0]; // bypass '#' character

    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.donationsCollectionView.contentOffset = CGPointMake(0, 0);
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
            self.arrayOfPayments = payments;
            
            //create array of metric strings (e.g. "392 children vaccinated")
            NSMutableArray *metricStringArray = [[NSMutableArray alloc] init];
            //create array of organization names (e.g. "Helen Keller International")
            NSMutableArray *organizationStringArray = [[NSMutableArray alloc] init];

            for (PFObject *payment in payments){
                NSLog(@"%@", payment);
                NSString *metricQuantity = payment[@"metricQuantity"];
                NSString *metricStringLabel = payment[@"metricString"];
                NSString *metricSpace = [metricQuantity stringByAppendingString:@" "];
                NSString *metricString = [metricSpace stringByAppendingString:metricStringLabel];
                [metricStringArray addObject:metricString];
                [organizationStringArray addObject:payment[@"organizationName"]];
            }
            
            self.arrayOfMetricStrings = metricStringArray;
            self.arrayOfOrganizationStrings = organizationStringArray;
            
            NSInteger transactionCount = self.arrayOfPayments.count;
            
            NSString *countString = [NSString stringWithFormat:@"%ld", (long)transactionCount];
            self.transactionCountLabel.text = countString;
            
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
    UserDonationCell *formattedCell = [self configureUserDonationCell:cell index:indexPath];
    return formattedCell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayOfPayments.count;
}

- (void)fetchProfilePicture{
    //get profile picture
    PFUser *user = [PFUser currentUser];
    self.profileView.file = user[@"profilePicture"];
    [self.profileView loadInBackground];
    
    self.profileView.contentMode = UIViewContentModeScaleAspectFill;
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

@end
