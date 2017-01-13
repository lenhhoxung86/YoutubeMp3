//
//  CommonHelper.swift
//  MP3Lover
//
//  Created by tien dh on 12/30/16.
//  Copyright © 2016 tien dh. All rights reserved.
//

import Foundation
import SystemConfiguration


extension FileManager.SearchPathDirectory {
    func createSubFolder(named: String, withIntermediateDirectories: Bool = false) -> Bool {
        guard let url = FileManager.default.urls(for: self, in: .userDomainMask).first else { return false }
        do {
            try FileManager.default.createDirectory(at: url.appendingPathComponent(named), withIntermediateDirectories: withIntermediateDirectories, attributes: nil)
            return true
        } catch let error as NSError {
            print(error.description)
            return false
        }
    }
}

class CommonHelper {
    static let AUDIO_FOLDER = "audio"
    class func getDocumentFolderPath() -> String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    }
    
    class func getAudioFolderPath() -> String {
        return CommonHelper.getDocumentFolderPath() + "/" + AUDIO_FOLDER
    }
    
    class func fileExist(path:String) -> Bool {
        let fm = FileManager.default
        return fm.fileExists(atPath: path)
    }
    
    class func removeTemporaryFiles() {
        let fm = FileManager.default
        do {
            let directoryContents: NSArray = try fm.contentsOfDirectory(atPath: CommonHelper.getDocumentFolderPath()) as NSArray
            if directoryContents.count > 0 {
                for item in directoryContents {
                    let fullFilePath = CommonHelper.getDocumentFolderPath() + "/" + (item as! String)
                    var isDir : ObjCBool = false
                    if fm.fileExists(atPath: fullFilePath, isDirectory: &isDir) {
                        if !isDir.boolValue {
                            try fm.removeItem(atPath: fullFilePath)
                        }
                    }
                }
            }
        }
        catch {
            print("removeTemporaryVideo::error")
        }
    }
    
    class func copyFileFrom(fromPath:String, toPath:String) {
        let fm = FileManager.default
        do {
            try fm.copyItem(atPath: fromPath, toPath: toPath)
        } catch {
            print("copyFileFrom::error")
        }
    }
    
    class func removeFile(path:String) {
        let fm = FileManager.default
        do {
            try fm.removeItem(atPath: path)
        } catch {
            print("removeFile::error")
        }
    }
    
    class func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
