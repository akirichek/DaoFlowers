//
//  DownloadFile.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

class DownloadFile: NSObject , NSURLSessionDownloadDelegate {
    
    
    var downloadTask: NSURLSessionDownloadTask!
    var backgroundSession: NSURLSession!
    
    override init() {
        super.init()
        let backgroundSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundSession")
        backgroundSession = NSURLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        startDownload()
        
    }
    
    func startDownload() {
        let url = NSURL(string: "https://daoflowers.com:7443/documents/unzip?doc=clients%5C57%5C2_invoices%5C2016_1117_invoice_adg_2_5fb.zip")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("Basic dGVzdF8xMTc6NHBONzU5OTQ=", forHTTPHeaderField: "Authorization")
        downloadTask = backgroundSession.downloadTaskWithRequest(request)
        //downloadTask = backgroundSession.downloadTaskWithURL(url)
        downloadTask.resume()
    }
    
    
    
    // 1
    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    didFinishDownloadingToURL location: NSURL){
        
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = NSFileManager()
        let destinationURLForFile = NSURL(fileURLWithPath: documentDirectoryPath.stringByAppendingString("/file.html"))
        
            do {
                try fileManager.moveItemAtURL(location, toURL: destinationURLForFile)
                // show file
                print(location)
                //showFileWithPath(destinationURLForFile.path!)
            }catch{
                print("An error occurred while moving file to destination url")
            }
    }
    
    
    func URLSession(session: NSURLSession,
                    task: NSURLSessionTask,
                    didCompleteWithError error: NSError?){
        downloadTask = nil
        if (error != nil) {
            print(error?.description)
        }else{
            print("The task finished transferring data successfully")
        }
    }
    
    
}