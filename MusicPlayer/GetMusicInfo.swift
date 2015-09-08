
//
//  GetMusicInfo.swift
//  MusicPlayer
//
//  Created by lanou3g on 15/8/31.
//  Copyright (c) 2015年 chehao. All rights reserved.
//

import UIKit
import AVFoundation

typealias BtnBlock = (data:NSData)->Void;
class GetMusicInfo: NSObject,NSURLSessionDataDelegate,NSURLSessionDelegate {
    
    class func getPlist(block:BtnBlock) {
        var urlString:String = "http:project.lanou3g.com/teacher/UIAPI/MusicInfoList.plist";
        var request:NSURLRequest = NSURLRequest(URL: NSURL(string: urlString)!);
        
        var sessionConfiguration:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        
        var session:NSURLSession = NSURLSession(configuration: sessionConfiguration);
        
        var sessionDownLoadTask:NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (NSData, NSURLResponse, NSError) -> Void in
            block(data: NSData);
        });
        sessionDownLoadTask.resume();
    }
    
    class func getUrlData(urlString:String,block:BtnBlock){
        var request:NSURLRequest = NSURLRequest(URL: NSURL(string: urlString)!);
        
        var sessionConfiguration:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration();
        
        var session:NSURLSession = NSURLSession(configuration: sessionConfiguration);
        
        var sessionDownLoadTask:NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (NSData, NSURLResponse, NSError) -> Void in
            block(data: NSData);
        });
        sessionDownLoadTask.resume();
    }
    
    
    
    
    
    
    //没有用到
    var session:NSURLSession!
    func getMusic(urlString:String) {
        
        
        var request:NSURLRequest = NSURLRequest(URL: NSURL(string: urlString)!);
        
        var sessionConfiguration:NSURLSessionConfiguration = NSURLSessionConfiguration.ephemeralSessionConfiguration();
        
        self.session = NSURLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil);
        var sessionDownloadTask:NSURLSessionDataTask = session.dataTaskWithRequest(request);
        sessionDownloadTask.resume();
    }
    
    var musicData:NSMutableData!
    var queue1:dispatch_queue_t = dispatch_get_global_queue(0, 0);
    var times:Int16 = 0;
    func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        if(times == 0){
            createFileForCachesDirectory();
            writingDataForCachesDirectoryFile(data);
            
            //添加任务
            dispatch_async(queue1, { () -> Void in
                //                self.initAVAudioPlayer();
            })
            
        }else{
            writingDataForCachesDirectoryFile(data);
        }
        times++;
    }
    
    
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        println("OK")
        if(error != nil){
            println("cuowu")
        }
    }
    
    //保存数据data
    var fileHandle:NSFileHandle!
    var filePath:String!
    func createFileForCachesDirectory(){
        let caches:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0] as! String;
        println(caches);
        
        //创建文件
        let manger:NSFileManager = NSFileManager.defaultManager();
        let filePath:String = caches .stringByAppendingString("/111.mp3");
        
        manger .createFileAtPath(filePath, contents: nil, attributes: nil);
        //获得文件句柄
        self.fileHandle = NSFileHandle(forWritingAtPath: filePath);
        self.filePath = filePath;
    }
    
    func writingDataForCachesDirectoryFile(data:NSData){
        self.fileHandle.seekToEndOfFile();
        self.fileHandle.writeData(data);
    }

    
   
    
}
