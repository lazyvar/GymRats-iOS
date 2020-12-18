//
//  EZCache.swift
//  OutHere
//
//  Created by Biggy Smallz on 1/25/17.
//  Copyright © 2017 Mack Hasz. All rights reserved.
//

import Foundation
import UIKit

class EZCache: NSObject {
    var cacheInfoQueue: DispatchQueue
    var frozenCacheInfoQueue: DispatchQueue
    var diskQueue: DispatchQueue
    var cacheInfo: NSMutableDictionary
    var frozenCacheInfo: NSMutableDictionary
    var directory: String = ""
    var needsSave: Bool = false
    var defaultTimeoutInterval: Double = 3600 * 24 * 2

    var loadingDict: [String: Bool] = [:]

    func fired(_ url: String) -> Bool {
        if loadingDict[url] != nil {
            return true
        } else {
            return false
        }
    }

    func returned(_ url: String) -> Bool {
        if let val = loadingDict[url] {
            return val
        } else {
            return false
        }
    }

    static let shared = EZCache()
  
    func path(forKey key: String) -> String? {
      return cachePathForKey(self.directory, key)
    }

    override init() {
        /* set up directory */
        var cachesDirectory: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let oldCachesDirectory: String = URL(fileURLWithPath: URL(fileURLWithPath: cachesDirectory).appendingPathComponent(ProcessInfo.processInfo.processName).absoluteString).appendingPathComponent("EZCache").absoluteString
        if FileManager.default.fileExists(atPath: oldCachesDirectory) {
            try? FileManager.default.removeItem(atPath: oldCachesDirectory)
        }
        cachesDirectory = URL(fileURLWithPath: URL(fileURLWithPath: cachesDirectory).appendingPathComponent(Bundle.main.bundleIdentifier!).absoluteString).appendingPathComponent("EZCache").absoluteString

        self.directory = cachesDirectory

        /* set up queues */
        self.cacheInfoQueue = DispatchQueue(label: "com.haszie.ezcache.info")
        var priority = DispatchQueue.global(qos: .default)
        priority.setTarget(queue: self.cacheInfoQueue)
        self.frozenCacheInfoQueue = DispatchQueue(label: "com.haszie.ezcache.info.frozen")
        priority = DispatchQueue.global(qos: .default)
        priority.setTarget(queue: self.frozenCacheInfoQueue)
        self.diskQueue = DispatchQueue(label: "com.haszie.ezcache.disk")
        priority = DispatchQueue.global(qos: .default)
        priority.setTarget(queue: self.diskQueue)

        if let ayo = NSMutableDictionary(contentsOfFile: cachePathForKey(directory, "EZCache.plist")) {
            cacheInfo = ayo
        } else {
            self.cacheInfo = NSMutableDictionary()
        }

        do {
            try FileManager.default.createDirectory(atPath: URL(string: self.directory)!.path, withIntermediateDirectories: true, attributes: nil)
        } catch let e {
            print(e)
        }

        let now: TimeInterval = Date().timeIntervalSinceReferenceDate
        var removedKeys = [String]()
        for key: String in self.cacheInfo.allKeys as! [String] {
            if let dateInfo = self.cacheInfo[key] as? Date {
                if dateInfo.timeIntervalSinceReferenceDate <= now {
                    try? FileManager.default.removeItem(atPath: cachePathForKey(directory, key))
                    removedKeys.append(key)
                }
            }
        }

        self.cacheInfo.removeObjects(forKeys: removedKeys)
        self.frozenCacheInfo = self.cacheInfo
    }

    func clear() {
        self.cacheInfoQueue.sync(execute: {() -> Void in
            for key in self.cacheInfo.allKeys as! [String] {
                try? FileManager.default.removeItem(atPath: cachePathForKey(self.directory, key))
            }
            self.cacheInfo.removeAllObjects()
            self.frozenCacheInfoQueue.sync(execute: {() -> Void in
                self.frozenCacheInfo = self.cacheInfo
            })
            self.setNeedsSave()
        })
    }

    func remove(key: String) {
        if (key == "EZCache.plist") {
            return
        }

        self.diskQueue.async(execute: { [self] () -> Void  in
            try? FileManager.default.removeItem(atPath: cachePathForKey(self.directory, key))
        })
        self.setCacheTimeoutInterval(0, forKey: key)
    }

    func has(_ key: String) -> Bool {
        if let date = self.date(forKey: key) {
            if date.timeIntervalSinceReferenceDate < CFAbsoluteTimeGetCurrent() {
                return false
            }
            return FileManager.default.fileExists(atPath: cachePathForKey(self.directory, key))
        } else {
            return false
        }
    }

    func date(forKey key: String) -> Date? {
        var date: Date? = nil
        self.frozenCacheInfoQueue.sync(execute: {() -> Void in
            date = (self.frozenCacheInfo)[key] as! Date?
        })
        return date
    }

    func allKeys() -> [String] {
        var keys: [String]? = nil
        self.frozenCacheInfoQueue.sync(execute: {() -> Void in
            keys = self.frozenCacheInfo.allKeys as? [String]
        })
        return keys!
    }

    func setCacheTimeoutInterval(_ timeoutInterval: TimeInterval, forKey key: String) {
        let date = timeoutInterval > 0 ? Date(timeIntervalSinceNow: timeoutInterval) : nil
        // Temporarily store in the frozen state for quick reads
        self.frozenCacheInfoQueue.sync(execute: {() -> Void in
            let info: NSMutableDictionary = self.frozenCacheInfo.mutableCopy() as! NSMutableDictionary
            if (date != nil) {
                info[key] = date
            } else {
                info.removeObject(forKey: key)
            }
            self.frozenCacheInfo = info
        })
        // Save the final copy (this may be blocked by other operations)
        self.cacheInfoQueue.async(execute: {() -> Void in
            if (date != nil) {
                self.cacheInfo[key] = date
            } else {
                self.cacheInfo.removeObject(forKey: key)
            }
            self.frozenCacheInfoQueue.sync(execute: {() -> Void in
                self.frozenCacheInfo = self.cacheInfo
            })
            self.setNeedsSave()
        })
    }

    // MARK: -
    // MARK: Copy file methods

    func copyFilePath(_ filePath: String, asKey key: String) {
        self.copyFilePath(filePath, asKey: key, withTimeoutInterval: self.defaultTimeoutInterval)
    }

    func copyFilePath(_ filePath: String, asKey key: String, withTimeoutInterval timeoutInterval: TimeInterval) {
        self.diskQueue.async(execute: { [self] () -> Void in
            try? FileManager.default.copyItem(atPath: filePath, toPath: cachePathForKey(self.directory, key))
        })
        self.setCacheTimeoutInterval(timeoutInterval, forKey: key)
    }
    // MARK: -
    // MARK: Data methods

    func put(_ data: NSData, key: String) {
        self.put(data, key: key, withTimeoutInterval: self.defaultTimeoutInterval, callback: nil)
    }

    func put(_ data: NSData, key: String, callback finishBlock: (() -> Void)? ) {
        self.put(data, key: key, withTimeoutInterval: self.defaultTimeoutInterval, callback: finishBlock)
    }

    func put(_ data: NSData, key: String, withTimeoutInterval timeoutInterval: TimeInterval) {
        self.put(data, key: key, withTimeoutInterval: timeoutInterval, callback: nil)
    }

    func put(_ data: NSData, key: String, withTimeoutInterval timeoutInterval: TimeInterval, callback finishBlock: (() -> Void)?) {
        if (key == "EZCache.plist") {
            return
        }

        let cachePath: String = cachePathForKey(self.directory, key)
        self.diskQueue.async {
            do {
                try data.write(toFile: cachePath, options: .atomic)
            } catch let e {
                print(e)
            }
            finishBlock?()
        }
        self.setCacheTimeoutInterval(timeoutInterval, forKey: key)
    }

    func setNeedsSave() {
        self.cacheInfoQueue.async(execute: { () -> Void in
            if self.needsSave {
                return
            }
            self.needsSave = true
            self.cacheInfoQueue.async(execute: { [self] in
                if !self.needsSave {
                    return
                }
                self.cacheInfo.write(toFile: cachePathForKey(self.directory, "EZCache.plist"), atomically: true)
                self.needsSave = false
            })
        })
    }

    func get(_ key: String) -> NSData? {
        if self.has(key) {
            return try? NSData(contentsOf: URL(string: cachePathForKey(self.directory, key))!, options: [])
        } else {
            return nil
        }
    }

    // Object Methods

    func object(forKey key: String) -> NSCoding? {
        if self.has(key) {
            return NSKeyedUnarchiver.unarchiveObject(with: get(key)! as Data) as! NSCoding?
        } else {
            return nil
        }
    }

    func setObject(_ anObject: NSCoding, forKey key: String) {
        self.setObject(anObject, forKey: key, withTimeoutInterval: self.defaultTimeoutInterval)
    }

    func setObject(_ anObject: NSCoding, forKey key: String, withTimeoutInterval timeoutInterval: TimeInterval) {
        self.put(NSKeyedArchiver.archivedData(withRootObject: anObject) as NSData, key: key, withTimeoutInterval: timeoutInterval)
    }
}

func cachePathForKey(_ directory: String, _ key: String) -> String {
  let what = key.replacingOccurrences(of: "/", with: "_")
  let key: String
  
  if let ugh = what.split(separator: "?").first {
    key = String(ugh)
  } else {
    key = what
  }
  
  return URL(fileURLWithPath: directory).appendingPathComponent(key).path
}
