//
//  WriteViewController.h
//  memobox
//
//  Created by Sacha Best on 1/17/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WriteConfirmViewController.h"
#import "ParseManager.h"

@interface WriteViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *input;
@property PFObject *contact;
@end
