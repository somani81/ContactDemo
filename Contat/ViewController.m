//
//  ViewController.m
//  Contat
//
//  Created by indianic on 22/07/16.
//  Copyright © 2016 indianic. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property(strong,nonatomic)NSMutableArray *objects;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CNContactStore *store = [[CNContactStore alloc]init];
    if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusNotDetermined)
    {
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if (granted)
            {
                [self retrieveContactsWithStore:store];
            }
        }];
    }
    else if ([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusAuthorized)
    {
       [self retrieveContactsWithStore:store];
    }
    
//    CNContactStore *store = [[CNContactStore alloc]init];
//    CNMutableContact *contact = [[CNMutableContact alloc]init];
//    contact.familyName = _txtLastName.text;
//    contact.givenName = _txtFirstName.text;
//    CNLabeledValue *homePage = [CNLabeledValue labeledValueWithLabel:CNLabelHome value:[CNPhoneNumber phoneNumberWithStringValue:_txtMobileNumber.text]];
//    contact.phoneNumbers = @[homePage];
//    
//    CNSaveRequest *saveRequest = [[CNSaveRequest alloc]init];
//    [saveRequest addContact:contact toContainerWithIdentifier:nil];
//    [store executeSaveRequest:saveRequest error:nil];
    
    
    //    CNContactViewController *controller = [CNContactViewController viewControllerForUnknownContact:contact];
    //    controller.contactStore = store;
    //    controller.delegate = self;
    //    [self.navigationController pushViewController:controller animated:YES];
}

-(void)retrieveContactsWithStore:(CNContactStore*)store{
    
//    NSArray *groups = [store groupsMatchingPredicate:nil error:nil];
//    CNGroup *group = groups[0];
//    NSPredicate *predicate = [CNContact predicateForContactsInGroupWithIdentifier:group.identifier];
//    NSArray *keysToFetch = [NSArray arrayWithObject:[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]];
//    NSArray *contacts = [store unifiedContactsMatchingPredicate:predicate keysToFetch:keysToFetch error:nil];
//    self.objects = contacts;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        //self.tableView.reloadData()
//    });
    
    NSArray *keysToFetch = [NSArray arrayWithObjects:[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactEmailAddressesKey,CNContactPhoneNumbersKey,CNContactImageDataAvailableKey,CNContactThumbnailImageDataKey,nil];
    NSArray *allContainers = [store containersMatchingPredicate:nil error:nil];
    
    self.objects = [[NSMutableArray alloc]init];
    for (CNContainer *container in allContainers) {
        
        NSPredicate *fetchPredicate = [CNContact predicateForContactsInContainerWithIdentifier:container.identifier];
        NSArray *containerResults =[store unifiedContactsMatchingPredicate:fetchPredicate keysToFetch:keysToFetch error:nil];
        [self.objects addObjectsFromArray:containerResults];
    }
    
    NSLog(@"%@",self.objects);
    for (CNContact *contact in self.objects)
    {
        NSLog(@"%@",contact.givenName);
        for (CNLabeledValue *phoneNumber in contact.phoneNumbers) {
            
            CNPhoneNumber *phone = phoneNumber.value;
            NSLog(@"%@",phone.stringValue);
        }
        NSLog(@"%@",contact.emailAddresses);
       
    }
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
