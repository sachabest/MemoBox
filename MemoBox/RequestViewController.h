//
//  RequestViewController.h
//  memobox
//
//  Created by Sacha Best on 1/17/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *confirm;

@property NSString *name;
@end
