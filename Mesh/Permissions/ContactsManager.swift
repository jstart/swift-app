//
//  ContactsManager.swift
//  Mesh
//
//  Created by Christopher Truman on 8/18/16.
//  Copyright © 2016 Tinder. All rights reserved.
//

import Foundation
import Contacts
import UIKit

extension CNContact {
    var searchText: String { return [givenName, familyName].joined(separator: " ") }
    var phoneNumberStrings: [String]? { return phoneNumbers.flatMap({ return $0.value.value(forKey: "digits") as? String }) }
    var emailStrings: [String]? { return emailAddresses.flatMap({ return $0.value as String }) }
}

class ContactsManager : NSObject {
    
    let store = CNContactStore()
    let keysToFetch = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactEmailAddressesKey,
        CNContactPhoneNumbersKey,
        CNContactImageDataAvailableKey,
        CNContactThumbnailImageDataKey] as [Any]
    var viewController : UIViewController?
    
    static var authStatus : CNAuthorizationStatus { return CNContactStore.authorizationStatus(for: .contacts) }
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized: completionHandler(true)
        case .denied, .notDetermined:
            store.requestAccess(for: .contacts, completionHandler: { (access, accessError) -> Void in
                completionHandler(access)
                if authorizationStatus == .denied || authorizationStatus == .restricted {
                    DispatchQueue.main.async {
                        let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                        let alertController = UIAlertController(
                            title: "Contacts Access Disabled",
                            message: message,
                            preferredStyle: .alert)
                        
                        let openAction = UIAlertAction("Open Settings") { (action) in
                            guard let url = URL(string:UIApplicationOpenSettingsURLString) else { return }
                            UIApplication.shared.openURL(url as URL)
                        }
                        alertController.addActions(UIAlertAction.cancel(), openAction)
                        guard let vc = self.viewController else {
                            UIApplication.shared.keyWindow!.rootViewController!.present(alertController)
                            return
                        }
                        vc.present(alertController)
                    }
                }
            })
        default: completionHandler(false)
        }
    }
    
    func contacts() -> [CNContact] {
        var allContainers: [CNContainer] = []
        do { allContainers = try store.containers(matching: nil) } catch { print("Error fetching containers") }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            do {
                var containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                containerResults = containerResults.filter({
                    if !$0.phoneNumbers.isEmpty {
                        // Remove contact with our own phone
                        return ($0.phoneNumberStrings?.first)?.range(of: UserResponse.current?.phone_number ?? "") == nil
                    }
                    //TODO: Filter by email
//                    if !$0.emailAddresses.isEmpty {
                          // Same for email
//                        return ($0.emailStrings?.first)?.range(of: UserResponse.current?.ema ?? "") == nil
//                    }
                    // Only contacts that have at least one email or phone number
                    return !$0.emailAddresses.isEmpty || !$0.phoneNumbers.isEmpty
                })
                results.append(contentsOf: containerResults)
            } catch { print("Error fetching results for container") }
        }
        
        return results
    }
    
    func allContacts(results: @escaping ([CNContact]) -> Void) {
        DispatchQueue.global().async {
            let contacts = self.contacts()
            DispatchQueue.main.async { results(contacts) }
        }
    }

}
