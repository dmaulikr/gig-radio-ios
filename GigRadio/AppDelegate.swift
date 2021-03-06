//
//  AppDelegate.swift
//  GigRadio
//
//  Created by Michael Forrest on 17/05/2015.
//  Copyright (c) 2015 Good To Hear. All rights reserved.
//

import UIKit
import RealmSwift
import Fabric
import Crashlytics
import Mixpanel

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        Mixpanel.sharedInstanceWithToken("09bb48cc8d1df1a1b63e48b512661cca")
        Typography.initBarButtonStyles()
        Appearance.apply()
        Defaults.register()
        setSchemaVersion(4, realmPath: Realm.defaultPath) { migration, oldSchemaVersion in
            if oldSchemaVersion < 4{
                migration.enumerate(SongKickEvent.className(), { (oldObject, newObject) -> Void in
                    newObject!["status"] = "ok"
                })
            }
            if oldSchemaVersion < 3{
                var seen = NSMutableSet()
                var toDelete = NSMutableArray()
                migration.enumerate(SongKickVenue.className(), { (oldObject, newObject) -> Void in
                    if seen.containsObject(newObject!["id"]!){
                        toDelete.addObject(newObject!)
                    }
                    seen.addObject(newObject!["id"]!)
                })
                for object in toDelete{
                    migration.delete(object as! MigrationObject)
                }
            }
        }
        
        if NSProcessInfo().environment["RESET_ALL"] == "YES"{
            Onboarding.resetAll()
            try! Realm().write {
                try! Realm().deleteAll()
            }
        }
        
        
        return true
    }
}
