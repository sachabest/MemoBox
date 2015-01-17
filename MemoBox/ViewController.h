//
//  ViewController.h
//  MemoBox
//
//  Created by Sacha Best on 1/16/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import "ParseManager.h"

@interface ViewController : UIViewController <PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate> {
    NSMutableDictionary *contacts;
}


@end

