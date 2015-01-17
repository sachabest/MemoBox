//
//  ParseManager.m
//  MemoBox
//
//  Created by Sacha Best on 1/17/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import "ParseManager.h"

@implementation ParseManager

+ (BOOL)isLoggedIn {
    return [PFUser currentUser] != nil;
}

+ (int)numContacts {
    return (int) [[PFUser currentUser][@"contacts"] count];
}
+ (NSArray *)contacts {
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
    new[@"number"] = number;
    [new saveInBackground];
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

+ (void)createInstallation {
    // create PFInstallation here and push to server with column for pointer to user
}
@end
