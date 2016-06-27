//
//  UIImageView+DownloadImage.swift..swift
//  GoodsFinder
//
//  Created by MyMacbook on 3/24/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit
extension UIImageView {
    
    func loadImageWithURL(url: NSURL) -> NSURLSessionDownloadTask {
    
    let session = NSURLSession.sharedSession()
    
    let downloadTask = session.downloadTaskWithURL(//This is similar to a data task but it saves the downloaded file to a temporary location on disk instead of keeping it in memory.
    url, completionHandler: { [weak self] url, response, error in
    
    if error == nil, let url = url,
    
    data = NSData(contentsOfURL: url), image = UIImage(data: data) {
    
    dispatch_async(dispatch_get_main_queue()) {
        if let strongSelf = self {//you check here whether “self” (UIImageView) still exists;
    strongSelf.image = image//Because this is UI code you need to do this on the main thread.
            }
        }
    }
    })
    
    downloadTask.resume()
    return downloadTask
    }
}

