//
//  ContactsManager.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/04/18.
//

import UIKit
import Contacts


class ContactsManager: NSObject {
    
    func checkPermissionAccessForContacts(successBlock: PermissionVoidBlock?, failureBlock: PermissionVoidBlock?, deniedBlock: PermissionVoidBlock?) {
        let authState = CNContactStore.authorizationStatus(for: .contacts)
        if authState == .notDetermined {
            CNContactStore().requestAccess(for: .contacts, completionHandler: { granted, error in
                DispatchQueue.main.async {
                    if (granted) {
                        successBlock?()
                    }
                    else {
                        failureBlock?();
                    }
                }
            })
        }
        else if authState == .authorized {
            successBlock?();
        }
        else if authState == .denied {
            deniedBlock?()
        }
        else {
            failureBlock?()
        }
    }
    
    func getAllContacts(_ completion:@escaping(_ result:Array<Any>?, _ error:Error?) ->Void) {
        do {
            let contatStore = CNContactStore()
            let predicate = CNContainer.predicateForContainers(withIdentifiers: [contatStore.defaultContainerIdentifier()])
            try contatStore.containers(matching: predicate)

//            CNContactIdentifierKey,
//            CNContactFamilyNameKey,
//            CNContactGivenNameKey,
//            CNContactJobTitleKey,
//            CNContactDepartmentNameKey,
//            CNContactOrganizationNameKey,
//            CNContactPhoneNumbersKey,
//            CNContactEmailAddressesKey,
//            CNContactPostalAddressesKey,
//            CNContactImageDataKey

            let keysToFetch:[String] = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey
            ]

            let request = CNContactFetchRequest(keysToFetch: (keysToFetch as? [CNKeyDescriptor])!)
            request.sortOrder = CNContactSortOrder.givenName
            request.unifyResults = true
            
            var arrResult: [AnyHashable] = []
            
            try contatStore.enumerateContacts(with: request, usingBlock: { (contact, _) in
                let name = "\(contact.familyName)\(contact.givenName)"
                var phoneNumber = ""
                for cnValue in contact.phoneNumbers {
                    let cnPone = cnValue.value
                    phoneNumber = cnPone.stringValue
                    break
                }
                let param = ["name":name, "phone":phoneNumber]
                arrResult.append(param)
            })
            DispatchQueue.main.async {
                completion(arrResult, nil)
            }
        }
        catch let error {
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }
}

