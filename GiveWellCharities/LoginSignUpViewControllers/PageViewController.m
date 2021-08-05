//
//  PageViewController.m
//  GiveWellCharities
//
//  Created by Sophia Joy Wang on 8/5/21.
//

#import "PageViewController.h"
#import "LoginSignupViewController.h"

@interface PageViewController ()

@property (nonatomic, strong) NSArray *arrayOfOrganizations;

@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arrayOfOrganizations = @[@"Sightsavers", @"MalariaConsortium", @"AgainstMalaria", @"GiveDirectly", @"Keller"];
    self.dataSource = self;
    
    LoginSignupViewController *initialViewController = (LoginSignupViewController *)[self viewControlleratIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
}

//helper method
- (UIViewController *) viewControlleratIndex: (NSUInteger)index{
    LoginSignupViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginSignupViewController"];
    viewController.strImage = self.arrayOfOrganizations[index];
    viewController.pageIndex = index;
    
    return viewController;
}

- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerBeforeViewController:(nonnull UIViewController *)viewController {
    
    NSUInteger index = ((LoginSignupViewController *) viewController).pageIndex;
    
    if (index == 0 || index == NSNotFound){
        return nil;
    }
    index--;
    
    return [self viewControlleratIndex:index];
    
}

- (nullable UIViewController *)pageViewController:(nonnull UIPageViewController *)pageViewController viewControllerAfterViewController:(nonnull UIViewController *)viewController {
    
    NSUInteger index = ((LoginSignupViewController *) viewController).pageIndex;
    
    if (index == NSNotFound){
        return nil;
    }
    index++;
    
    if (index == self.arrayOfOrganizations.count){
        return nil;
    }

    return [self viewControlleratIndex:index];
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
