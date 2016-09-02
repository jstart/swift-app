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
    var viewController : UIViewController?
    
    static var authStatus : CNAuthorizationStatus {
        get { return CNContactStore.authorizationStatus(for: .contacts) }
    }
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
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
                        
                        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        
                        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                            guard let url = URL(string:UIApplicationOpenSettingsURLString) else { return }
                            UIApplication.shared.openURL(url as URL)
                        }
                        alertController.addAction(openAction)
                        guard let vc = self.viewController else {
                            UIApplication.shared.keyWindow!.rootViewController!.present(alertController, animated: true, completion: nil)
                            return
                        }
                        vc.present(alertController, animated: true, completion: nil)
                    }
                }
            })
        default:
            completionHandler(false)
        }
    }
    
    func contacts() -> [CNContact] {
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
    
    func allContacts(results: @escaping ([CNContact]) -> Void) {
        DispatchQueue.global().async {
            let contacts = self.contacts()
            DispatchQueue.main.async {
                results(contacts)
            }
        }
    }

    func contacts(_ forName: String) -> [CNContact] {
        let predicate = CNContact.predicateForContacts(matchingName: forName)
        var contacts = [CNContact]()

        do {
            contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
            if contacts.count == 0 {
                print("No contacts were found matching the given name.")
            }
            return contacts
            
        }
        catch {
            print("Unable to fetch contacts.")
            return contacts
        }
    }

    func contacts(_ forName: String, results: @escaping ([CNContact]) -> Void) {
        DispatchQueue.global().async {
            let contacts = self.contacts(forName)
            DispatchQueue.main.async {
                results(contacts)
            }
        }
    }

}
