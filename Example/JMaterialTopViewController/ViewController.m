//
//  ViewController.m
//  JMaterialTopViewController
//
//  Created by jun on 2019/7/27.
//  Copyright © 2019 jun. All rights reserved.
//

#import "ViewController.h"
#import "TopViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)click:(UIButton *)sender {
    TopViewController *topVC = [[TopViewController alloc] init];
    topVC.view.backgroundColor = UIColor.whiteColor;
    
    UIViewController *aVC = UIViewController.new;
    aVC.view.backgroundColor = UIColor.cyanColor;
    
    UIViewController *bVC = UIViewController.new;
    bVC.view.backgroundColor = UIColor.lightGrayColor;
    
    UIViewController *cVC = UIViewController.new;
    cVC.view.backgroundColor = UIColor.redColor;
    
    topVC.viewControllers = @[aVC, bVC, cVC];
    topVC.titles = @[@"java", @"php", @"ObjC"];
    
    switch (sender.tag) {
        case 1000:
        {
            
        }
            break;
        case 1001:
        {
            topVC.titleLabelWidth = UIScreen.mainScreen.bounds.size.width / 3;
        }
            break;
        case 1002:
        {
            topVC.ifAsNavBarTitle = YES;
        }
            break;
        default:
            break;
    }
    
    [self.navigationController pushViewController:topVC animated:YES];
}

@end
