//
//  NotificationService.swift
//  iClimate
//
//  Created by Sagar Modi on 15/01/2024.
//

import Foundation
import UserNotifications
import SwiftUI

final class NotificationService {
    
    static let instance = NotificationService()
    private let vm = ForecastViewModel()
    var showAlert: Bool?
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert,.sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { [self] (result, error) in
            if let error = error {
                print(error)
            }else{
                if(result){
                    showAlert = false
                    vm.scheduleForecastNotification()
                }else{
                    showAlert = true
                }
            }
        }
    }
}
