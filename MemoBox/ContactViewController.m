//
//  ContactViewController.m
//  MemoBox
//
//  Created by Sacha Best on 1/17/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import "ContactViewController.h"

@interface ContactViewController ()

@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _phone.text = _contact[@"phone"];
    _name.text = _contact[@"name"];
    _photo.file = _contact[@"photo"];
    [_photo loadInBackground];
    _photo.layer.cornerRadius = 75;
    _photo.clipsToBounds = YES;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)requestMemo:(id)sender {
    [PFCloud callFunctionInBackground:@"requestMemo"
                       withParameters:@{ @"receiverNumber" : _phone.text,
                                         @"userNumber" : [PFUser currentUser][@"username"],
                                         @"username" : [PFUser currentUser][@"additional"]}
                                block:^(id object, NSError *error) {
                                    [self performSegueWithIdentifier:@"request" sender:self];
                                }];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)writeMemo:(id)sender {
    [self performSegueWithIdentifier:@"write" sender:self];
}
- (IBAction)viewMemos:(id)sender {
    [self performSegueWithIdentifier:@"view" sender:self];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"view"]) {
        [(MemoContainerViewController *)segue.destinationViewController setContact:_contact];
    } else if ([segue.identifier isEqualToString:@"request"]) {
        [(RequestViewController *)segue.destinationViewController setName:_contact[@"name"]];
    } else if ([segue.identifier isEqualToString:@"write"]) {
        [(WriteViewController *)segue.destinationViewController setContact:_contact];
    }
}


@end
