//
//  AppDelegate.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 06/09/2024.
//

import bLinkup
import FirebaseCore
import FirebaseMessaging
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate,
                   UNUserNotificationCenterDelegate, MessagingDelegate
{
    var messagingToken: String?
    { didSet { onMessagingToken?(messagingToken) }}
    var onMessagingToken: ((String?) -> Void)?
    { didSet { onMessagingToken?(messagingToken) }}
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let token = deviceToken.map({ String(format: "%02.2hhx", $0) }).joined()
        bLinkup.setPushID(token, completion: { _ in })
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler(.banner)
    }
    
    // MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messagingToken = fcmToken
    }
}
