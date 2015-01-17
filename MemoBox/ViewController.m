//
//  ViewController.m
//  MemoBox
//
//  Created by Sacha Best on 1/16/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![ParseManager isLoggedIn]) {
        [ParseManager showLoginUI:self];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark Address Book Access

static ABAddressBookRef addressBook;

- (void)addContact:(NSString *)inQuestion {
    [self requestAddressBookAccess:inQuestion];
}
- (void)accessGrantedForAddressBook:(NSString *)inQuestion {
    if (!contacts) {
        [self migrateContacts];
    }
    NSArray *results = [self searchForNumber:inQuestion];
    // call some selector here as completion handler
}
// Check the authorization status of our application for Address Book
-(void)checkAddressBookAccess:(NSString *)inQuestion
{
    switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            [self accessGrantedForAddressBook:inQuestion];
            break;
            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined:
            [self requestAddressBookAccess:inQuestion];
            break;
            // Display a message if the user has denied or restricted access to Contacts
        case  kABAuthorizationStatusDenied:
        case  kABAuthorizationStatusRestricted:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Privacy Warning" message:@"Permission was not granted for Contacts." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
}

// Prompt the user for access to their Address Book data
- (void)requestAddressBookAccess:(NSString *)inQuestion
{
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self accessGrantedForAddressBook:inQuestion];
            });
        }
    });
}

- (void)migrateContacts
{
    contacts = [[NSMutableDictionary alloc] init];
    CFArrayRef all = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex n = ABAddressBookGetPersonCount(addressBook);
    NSDate *date = [NSDate date];
    for ( int i = 0; i < n; i++ ) {
        ABRecordRef ref = CFArrayGetValueAtIndex(all, i);
        ABMultiValueRef phones = (ABMultiValueRef)ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for (CFIndex j = 0; j < ABMultiValueGetCount(phones); j++) {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(phones, j);
            NSString *phoneNumber = (__bridge NSString *)phoneNumberRef;
            [contacts setObject:(__bridge id)(ref) forKey:phoneNumber];
        }
    }
    NSLog(@" Time taken %f for %ld contacts",[[NSDate date] timeIntervalSinceDate:date],[contacts count]);
}
- (NSArray *)searchForNumber:(NSString *)number {
    ABRecordRef res = (__bridge ABRecordRef)([contacts objectForKey:number]);
    return [NSArray arrayWithObjects:(__bridge id)(res), nil];
}

@end
