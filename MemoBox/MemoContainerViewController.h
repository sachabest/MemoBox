//
//  MemoContainerViewController.h
//  memobox
//
//  Created by Sacha Best on 1/17/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MemoTableViewController.h"

@interface MemoContainerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property MemoTableViewController *memoTable;
@property PFObject *contact;
@end
