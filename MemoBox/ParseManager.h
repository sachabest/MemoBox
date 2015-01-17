//
//  ParseManager.h
//  MemoBox
//
//  Created by Sacha Best on 1/17/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ParseUI/ParseUI.h>

@interface ParseManager : NSObject <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

+ (BOOL)isLoggedIn;
+ (void)showLoginUI:(UIViewController *)sender;
+ (int)numContacts;
+ (NSArray *)contacts;
+ (NSArray *)memosForContact:(PFObject *)contact;
+ (PFObject *)addContact:(NSString *)name withNum:(NSString *)number;
+ (PFObject *)addMemo:(PFObject *)contact withText:(NSString *)text image:(UIImage *)image;

@end
