//
//  BrowseViewController.h
//  MemoBox
//
//  Created by Sacha Best on 1/16/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowseCollectionViewCell.h"
#import "ParseManager.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ContactViewController.h"

@interface BrowseViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout, PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate, ABPeoplePickerNavigationControllerDelegate> {
    NSMutableDictionary *contacts;
    float cellDimension;
    PFObject *selectedContact;
    NSArray *contactData;
}

- (IBAction)checkAddressBookAccess:(id)sender;

@end
