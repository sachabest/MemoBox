//
//  ParseManager.h
//  MemoBox
//
//  Created by Sacha Best on 1/17/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserPhone @"username'
#define kUserName @"additional"

@interface ParseManager : NSObject

+ (BOOL)isLoggedIn;
+ (int)numContacts;
+ (NSArray *)contacts;
+ (NSArray *)memosForContact:(PFObject *)contact;
+ (PFObject *)addContact:(NSString *)name withNum:(NSString *)number;
+ (PFObject *)addMemo:(PFObject *)contact withText:(NSString *)text image:(UIImage *)image;
+ (void)createInstallation;
+ (PFObject *)getContact:(NSString *)objectId;
+ (void)loadAllContacts;
+ (NSArray *)contactData;
+ (NSString *)filterPhone:(NSString *)input;
+ (void)writeMemo:(NSString *)text withContact:(PFObject *)contact;

@end
