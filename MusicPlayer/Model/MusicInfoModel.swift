//
//  MusicInfoModel.swift
//  MusicPlayer
//
//  Created by lanou3g on 15/8/31.
//  Copyright (c) 2015年 chehao. All rights reserved.
//

import UIKit

class MusicInfoModel: NSObject {
    var mp3Url:String = "";
    var id:NSNumber!;
    var name:String = "";
    var picUrl:String = "";
    var blurPicUrl:String = "";
    var album:String = "";
    var singer:String = "";
    var artists_name:String = "";
    var lyric:String = "";
    var duration:NSNumber!;
    dynamic var image:UIImage!;
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {
//        super.setValue(value, forUndefinedKey: key);

    }
    
    override func setValue(value: AnyObject?, forKey key: String) {
        super.setValue(value, forKey: key);
        if(key == "picUrl"){
            var imageSandboxPath:String = imageSandBoxPath(self.picUrl);
//            self.image = UIImage(contentsOfFile: imageSandboxPath);//(named: imageSandboxPath);
        }
    }
    
    func imageDownload(){
        GetMusicInfo .getUrlData(self.picUrl, block: { (data) -> Void in
            
            self.image = UIImage(data: data);
            let imageSanBoxpath:String = self.imageSandBoxPath(self.picUrl);
            if self.image != nil{
                let imageData:NSData = data;
                imageData.writeToFile(imageSanBoxpath, atomically: true);
//                UIImagePNGRepresentation(UIImage(data: data)!).writeToFile(imageSanBoxpath, atomically: true);
            }
            
        });
    }
    
    func imageSandBoxPath(imageUrl:String) -> String{
        var cachePath:String = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory,  NSSearchPathDomainMask.UserDomainMask, true)[0] as! String;
        var imageDirPath = cachePath.stringByAppendingPathComponent("DownImage");
        var fileManger:NSFileManager = NSFileManager.defaultManager();
        if(!fileManger.fileExistsAtPath(imageDirPath)){
            fileManger.createDirectoryAtPath(imageDirPath, withIntermediateDirectories: true, attributes: nil, error: nil);
        }
        var url = imageUrl.stringByReplacingOccurrencesOfString("/", withString: "_", options: nil, range: nil);
        var imageSandBoxPath = imageDirPath.stringByAppendingPathComponent(url);
        return imageSandBoxPath;
    }
    
    
//    override func setValuesForKeysWithDictionary(keyedValues: [NSObject : AnyObject]) {
////        super.setValuesForKeysWithDictionary(keyedValues);
//    }
}
