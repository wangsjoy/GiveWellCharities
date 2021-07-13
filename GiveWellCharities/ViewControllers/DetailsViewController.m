//
//  DetailsViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 7/12/21.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *summaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *missionLabel;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.nameLabel.text = self.organization[@"organizationName"];
    self.summaryLabel.text = self.organization[@"summary"];
    self.missionLabel.text = self.organization[@"missionStatement"];
    
    //set organization logo image
    PFFileObject *logoPicture = self.organization[@"logo"];
    NSString *logoURLString = logoPicture.url;
    NSURL *logoURL = [NSURL URLWithString:logoURLString];
    self.logoView.image = nil;
    [self.logoView setImageWithURL:logoURL];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
