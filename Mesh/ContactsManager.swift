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

class ContactsManager : NSObject {
    
    let store = CNContactStore()
    let keysToFetch = [
        CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
        CNContactEmailAddressesKey,
        CNContactPhoneNumbersKey,
        CNContactImageDataAvailableKey,
        CNContactThumbnailImageDataKey] as [Any]
    
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            store.requestAccess(for: .contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else if authorizationStatus == CNAuthorizationStatus.denied {
                    DispatchQueue.main.async {
                        let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                        let alertController = UIAlertController(
                            title: "Contacts Access Disabled",
                            message: message,
                            preferredStyle: .alert)
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        
                        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                            if let url = URL(string:UIApplicationOpenSettingsURLString) {
                                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
                            }
                        }
                        alertController.addAction(openAction)
                        
                        UIApplication.shared.keyWindow!.rootViewController!.present(alertController, animated: true, completion: nil)
                    }
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    func contacts() -> [CNContact] {
        // Get all the containers
        var allContainers: [CNContainer] = []
        do {
            allContainers = try store.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }
    
    func allContacts(results: ([CNContact]) -> Void) {
        results(contacts())
    }
    
    func contacts(forName: String, results: ([CNContact]) -> Void) {
        let predicate = CNContact.predicateForContacts(matchingName: forName)
        var contacts = [CNContact]()
        
        do {
            contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
            results(contacts)
            if contacts.count == 0 {
                print("No contacts were found matching the given name.")
            }
        }
        catch {
            print("Unable to fetch contacts.")
            results([])
        }
    }

}
