//
//  BrowseViewController.m
//  MemoBox
//
//  Created by Sacha Best on 1/16/15.
//  Copyright (c) 2015 MemoBox. All rights reserved.
//

#import "BrowseViewController.h"

#define kOrange [UIColor colorWithRed:0.973 green:0.58 blue:0.024 alpha:1]
@interface BrowseViewController ()

@end

@implementation BrowseViewController

static NSString * const reuseIdentifier = @"Contact";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[BrowseCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    cellDimension = ([[UIScreen mainScreen] bounds].size.width - 0 /* padding */ ) / 2.0;
    [ParseManager loadAllContacts];
    contactData = [ParseManager contactData];
    [self.collectionView reloadData];
    self.collectionView.allowsSelection = YES;
    PFInstallation *install = [PFInstallation currentInstallation];
    if ([PFUser currentUser] && install && !install[@"user"]) {
        install[@"user"] = [PFUser currentUser];
        [install saveInBackground];
    }
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![ParseManager isLoggedIn]) {
        [self showLoginUI:self];
    } else {
        [ParseManager loadAllContacts];
        contactData = [ParseManager contactData];
        [self.collectionView reloadData];
    }
}

- (void)showLoginUI:(UIViewController *)sender {
    PFLogInViewController *login = [[PFLogInViewController alloc] init];
    PFSignUpViewController *signup = [[PFSignUpViewController alloc] init];
    signup.fields = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsAdditional | PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton;
    login.delegate = self;
    signup.delegate = self;
    login.logInView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon"]];
    login.logInView.backgroundColor = kOrange;
    signup.signUpView.logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon"]];
    signup.signUpView.backgroundColor = kOrange;
    signup.signUpView.usernameField.keyboardType = UIKeyboardTypePhonePad;
    login.logInView.usernameField.keyboardType = UIKeyboardTypePhonePad;
    signup.signUpView.usernameField.placeholder = @"Phone";
    signup.signUpView.additionalField.placeholder = @"Name";
    login.logInView.usernameField.placeholder = @"Phone";
    [login setSignUpController:signup];
    [sender presentViewController:login animated:YES completion:nil];
    // show Parse login UI here
}

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [ParseManager loadAllContacts];
    [self.collectionView reloadData];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
}
// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:^{
        // nothing here
    }]; // Dismiss the PFLoginViewController
}
// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                    message:@"Make sure you fill out all of the information!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:^{
        [ParseManager createInstallation];
    }]; // Dismiss the PFSignUpViewController
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    [[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                message:@"Could not sign you up at this time. Please try again later."
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    [self dismissViewControllerAnimated:YES completion:^{
        [ParseManager createInstallation];
    }]; // Dismiss the PFSignUpViewController
}

#pragma mark Address Book Access

static ABAddressBookRef addressBook;

- (void)addContact {
    [self requestAddressBookAccess];
}
- (void)accessGrantedForAddressBook {
    [self showContactChooser];
    //NSArray *results = [self searchForNumber:inQuestion];
    // call some selector here as completion handler
}
// Check the authorization status of our application for Address Book
- (IBAction)checkAddressBookAccess:(id)sender
{
    switch (ABAddressBookGetAuthorizationStatus())
    {
            // Update our UI if the user has granted access to their Contacts
        case  kABAuthorizationStatusAuthorized:
            [self accessGrantedForAddressBook];
            break;
            // Prompt the user for access to Contacts if there is no definitive answer
        case  kABAuthorizationStatusNotDetermined:
            [self requestAddressBookAccess];
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
- (void)requestAddressBookAccess
{
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self accessGrantedForAddressBook];
            });
        }
    });
}
- (void)showContactChooser {
    ABPeoplePickerNavigationController *new = [[ABPeoplePickerNavigationController alloc] init];
    new.peoplePickerDelegate = self;
    new.predicateForEnablingPerson = [NSPredicate predicateWithFormat:@"phoneNumber.@count > 0"];
    [new setDisplayedProperties:[NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]]];
    [self presentViewController:new animated:YES completion:^{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"How to add someone"
                                                    message:@"Click on the person you'd like to add. Then, on the next page, click on their phone number for their mobile phone."
                                                    delegate:nil
                                           cancelButtonTitle:@"Got it!"
                                           otherButtonTitles:nil];
    [alert show];
    }];
    
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {

}
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)
person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    NSString *name = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
    name = [name stringByAppendingString:@" "];
    NSString *last = (__bridge_transfer NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
    if (last)
        name = [name stringByAppendingString:last];
    ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, property);
    NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, identifier);
    phone = [ParseManager filterPhone:phone];
    selectedContact = [ParseManager addContact:name withNum:phone];
    [self dismissViewControllerAnimated:YES completion:^{
        [self requestPicture:phone];
        [self performSegueWithIdentifier:@"show" sender:self];
    }];
    // call twillo api here...
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

#pragma mark <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(cellDimension, cellDimension);
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [ParseManager numContacts] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item >= [ParseManager numContacts]) {
        // i.e. plus button
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"Add" forIndexPath:indexPath];
    }
    BrowseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[BrowseCollectionViewCell alloc] init];
    }
    PFObject *contact = contactData[indexPath.item];
    if (contact[@"photo"] != nil) {
        cell.picture.file = contact[@"photo"];
        [cell.picture loadInBackground:^(UIImage *image, NSError *error) {
            cell.picture.contentMode = UIViewContentModeScaleAspectFill;
        }];
    } else {
        cell.picture.image = [UIImage imageNamed:@"avatar"];
    }
    cell.name.text = contact[@"name"];

    // Configure the cell
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [ParseManager numContacts]) {
        return YES;
    }
    return NO;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
        selectedContact = [ParseManager contactData][indexPath.row];
        [self performSegueWithIdentifier:@"show" sender:self];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show"]) {
        UINavigationController *nav = segue.destinationViewController;
        [((ContactViewController *)nav.topViewController) setContact:selectedContact];
    }
}

- (void)requestPicture:(NSString *)phoneNumber {
    [PFCloud callFunctionInBackground:@"requestPicture"
                       withParameters:@{ @"receiverNumber" : phoneNumber,
                                         @"userNumber" : [PFUser currentUser][@"username"],
                                         @"username" : [PFUser currentUser][@"additional"]}];
}

@end
