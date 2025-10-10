//
//  CloudKitUser.swift
//  Push Notification
//
//  Created by Keitiely Silva Viana on 09/10/25.
//

import SwiftUI
import CloudKit

class CloudKitUserViewModel: ObservableObject {
    
    @Published var isSignedInToiCloud: Bool = false
    @Published var error: String = ""
    
    init(){
        getiCloudStatus()
        
    }
    
    private func getiCloudStatus(){
        CKContainer.default().accountStatus {[weak self] returnedStatus, returnedError in
            DispatchQueue.main.async {
                switch returnedStatus {
                case .available:
                    break
                case .noAccount:
                    self?.error = CloudKitError.iCloudAccountNotFound.rawValue
                case .couldNotDetermine:
                    self?.error =
                    CloudKitError.iCloudAccountNotDetermined.rawValue
                case .restricted:
                    self?.error = CloudKitError.iCloudAccountRestricted.rawValue
                default:
                    self?.error = CloudKitError.iCloudAccountUnknown.rawValue
                }
            }
        }
    }
    
    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
    }
    
}
    func discoveriCloudUser(id: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { returnedIdentity, returnedError in
            
        }
    }


struct CloudKitUser: View {
    @StateObject var vm = CloudKitUserViewModel()
    
    var body: some View {
        VStack {
            Text("IS SIGNED IN: \(vm.isSignedInToiCloud.description.uppercased())")
            Text(vm.error)
        }
    }
}

//#Preview {
//    CloudKitUser()
//}
