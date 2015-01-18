//
//  ContactViewController.h
//  MemoBox
//
//  Created by Sacha Best on 1/17/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemoTableViewController.h"

@interface ContactViewController : UIViewController {
    NSArray *memos;
}

@property (weak, nonatomic) IBOutlet PFImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *phone;

@property PFObject *contact;

@end
