//
//  AppDelegate.swift
//  CapCut
//
//  Created by WangBin on 2025/5/9.
//

import UIKit
import CoreData // 1. 导入 CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        // 2. 将 "CapCutModel" 替换为您 .xcdatamodeld 文件的实际名称
        // 例如，如果您的模型文件名是 "MyAwesomeAppModel.xcdatamodeld"，
        // 那么这里的名字应该是 "MyAwesomeAppModel"
        let container = NSPersistentContainer(name: "CapCutModel") 
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // 替换此实现以处理错误。
                // fatalError() 会导致应用程序生成崩溃日志并终止。
                // 在实际应用中不应使用此函数。
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // 替换此实现以处理错误。
                // fatalError() 会导致应用程序生成崩溃日志并终止。
                // 在实际应用中不应使用此函数。
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // 3. （可选但推荐）在这里初始化您的 Window 和 RootViewController
        // 如果您还没有这样做的话。
        // 例如:
        // window = UIWindow(frame: UIScreen.main.bounds)
        // let projectViewModel = ProjectViewModel() // 您可能需要调整 ProjectViewModel 的初始化
        // let projectListVC = ProjectListViewController(viewmodel: projectViewModel)
        // let navigationController = UINavigationController(rootViewController: projectListVC)
        // window?.rootViewController = navigationController
        // window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

