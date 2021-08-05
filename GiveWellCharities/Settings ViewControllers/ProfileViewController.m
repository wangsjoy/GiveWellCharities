//
//  ProfileViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/12/21.
//

#import "ProfileViewController.h"
#import <Parse/Parse.h>
#import "DonationCell.h"
#import "UIImageView+AFNetworking.h"
#import "DateTools.h"

@import Parse;

@interface ProfileViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrayOfPayments;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) PFUser *user;
@property (weak, nonatomic) IBOutlet PFImageView *profileView;
@property (nonatomic, strong) NSMutableArray *arrayOfPaymentDictionaries;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.user = [PFUser currentUser];
    self.usernameLabel.text = self.user.username;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //load profile picture
    [self fetchProfilePicture];
//    imageView.contentMode = UIViewContentMode.ScaleAspectFill;

    self.profileView.contentMode = UIViewContentModeScaleAspectFill;
    self.profileView.layer.masksToBounds = YES;
    self.profileView.layer.cornerRadius = self.profileView.bounds.size.width/2;
    
//    circularImage.layer.masksToBounds = true
//        circularImage.layer.cornerRadius = circularImage.bounds.width / 2
    
    //add gesture recognition to the imageView element
    UITapGestureRecognizer *fingerTap =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(onProfilePhotoTap:)];
    [self.profileView setUserInteractionEnabled:YES];
    [self.profileView addGestureRecognizer:fingerTap];
    
    //fetch user transactions
    [self fetchTransactions];
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
            [self.tableView reloadData];

        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}


- (IBAction)didTapSettings:(id)sender {
    [self performSegueWithIdentifier:@"settingsSegue" sender:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

     - (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
        DonationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DonationCell"];
        PFObject *payment = self.arrayOfPayments[indexPath.row];
         //populate cell labels
         cell.organizationLabel.text = payment[@"organizationName"];
         cell.metricStringLabel.text = payment[@"metricString"];
         cell.metricQuantityLabel.text = payment[@"metricQuantity"];
         cell.metricImage.file = payment[@"metricImage"];
         [cell.metricImage loadInBackground];
         
         //timestamp label
         NSDate *createdAt = payment.createdAt;
         NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
         dateFormatter.dateFormat = @"dd/MM/yyyy";
         NSString *dateString = [dateFormatter stringFromDate:createdAt];
         cell.timeLabel.text = createdAt.timeAgoSinceNow;
         
        return cell;
    }
     
     - (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return self.arrayOfPayments.count;
    }
     
     @end
