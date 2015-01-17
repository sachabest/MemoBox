//
//  ParseManager.m
//  MemoBox
//
//  Created by Sacha Best on 1/17/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import "ParseManager.h"

@implementation ParseManager

static NSArray *contactData;

+ (BOOL)isLoggedIn {
    return [PFUser currentUser] != nil;
}

+ (int)numContacts {
    PFUser *user = [PFUser currentUser];
    return (int) [[PFUser currentUser][@"contacts"] count];
}
+ (NSArray *)contacts {
    [[PFUser currentUser] fetchIfNeeded];
    return [PFUser currentUser][@"contacts"];
}
+ (NSArray *)memosForContact:(PFObject *)contact {
    PFQuery *q = [PFQuery queryWithClassName:@"Memo"];
    [q whereKey:@"user" equalTo:[PFUser currentUser]];
    [q whereKey:@"contact" equalTo:contact];
    return [q findObjects];
    // note this is a synchronous operation
    // can be done asynchronously later
}
+ (PFObject *)addContact:(NSString *)name withNum:(NSString *)number {
    PFObject *new = [PFObject objectWithClassName:@"Contact"];
    new[@"name"] = name;
    new[@"phone"] = number;
    [new saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[PFUser currentUser] addObject:new forKey:@"contacts"];
            [[PFUser currentUser] saveInBackground];
        }
    }];
    // does not handle duplicates
    return new;
}
+ (PFObject *)addMemo:(PFObject *)contact withText:(NSString *)text image:(UIImage *)image {
    PFObject *new = [PFObject objectWithClassName:@"Memo"];
    new[@"text"] = text;
    if (image) {
        PFFile *img = [PFFile fileWithName:@"memo.png" data:UIImagePNGRepresentation(image)];
        [img saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            new[@"photo"] = img;
            [new saveInBackground];
        }];
        return new;
    }
    return nil;
}
// Note this method will cause a crash if the objectId is invalid
+ (PFObject *)getContact:(NSString *)objectId {
    PFQuery *query = [PFQuery queryWithClassName:@"Contact"];
    [query whereKey:@"objectId" equalTo:objectId];
    return [query findObjects][0];
}

+ (void)loadAllContacts {
    [[PFUser currentUser] fetchIfNeeded];
    contactData = [PFUser currentUser][@"contacts"];
    // this is a heavy operation
    for (PFObject *contact in contactData) {
        [contact fetchIfNeeded];
    }
    /** not necessary
    if ([ParseManager numContacts] == 0) {
        return;
    }
    if (!contactData) {
        PFQuery *all = [PFQuery queryWithClassName:@"Contact"];
        [all whereKey:@"objectId" containedIn:[ParseManager contacts]];
        contactData = [all findObjects];
    }
    else {
        for (PFObject *contact in contactData) {
            [contact fetchIfNeeded];
        }
    } **/
}
+ (NSArray *)contactData {
    return contactData;
}

+ (void)createInstallation {
    // create PFInstallation here and push to server with column for pointer to user
}
@end
