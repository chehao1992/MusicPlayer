//
//  Music.swift
//  MusicPlayer
//
//  Created by lanou3g on 15/9/4.
//  Copyright (c) 2015年 chehao. All rights reserved.
//

import UIKit
import AVFoundation

class Music: NSObject {
    var ququePlayer:AVQueuePlayer!
    var musicInfo_muisc:NSMutableArray!
    var ququePlayerItemArray:NSMutableArray!
    static var music:Music!
    static var onceToken:dispatch_once_t = dispatch_once_t();
    class func sharedUserInfo(array:NSArray!)->Music{
        dispatch_once(&onceToken, { () -> Void in
            self.music = Music(array: array);
        });
        return self.music;
    }
    
    init(array:NSArray!) {
        super.init();
        if (array != nil){
            self.ququePlayerItemArray = NSMutableArray();
            self.musicInfo_muisc = NSMutableArray(array: array);
            for item in self.musicInfo_muisc{
                let music:MusicInfoModel = item as! MusicInfoModel;
                let url:NSURL = NSURL(string: music.mp3Url)!;
                let playerItem:AVPlayerItem = AVPlayerItem(URL: url);
                ququePlayerItemArray.addObject(playerItem);
            }
            if(ququePlayerItemArray.count > 0){
                initWithQuquePlayer(ququePlayerItemArray);
            }else{
                println("初始化播放器失败！")
            }
        }
    }
    //初始化ququeplayer
    func initWithQuquePlayer(itemArray:NSArray){
        self.ququePlayer = AVQueuePlayer.queuePlayerWithItems(itemArray as [AnyObject]) as! AVQueuePlayer;
        
//        self.ququePlayer.currentItem.addObserver(self, forKeyPath:"status", options: NSKeyValueObservingOptions.New, context: nil);
//        self.ququePlayer.currentItem.addObserver(self, forKeyPath:"loadedTimeRanges", options: NSKeyValueObservingOptions.New, context: nil);
        
//        println(self.ququePlayer.rate)
        
    }
    
       
//    override func  observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
//        println(keyPath)
//    }
    
    //下一曲
    func advanceToNextItem(){
        self.ququePlayer.advanceToNextItem();
    }
    //播放暂停
    func playOrPause(str:String){
        if(str == "play"){
            self.ququePlayer.play();
        }else{
            self.ququePlayer.pause();
        }
    }
    //播放某一首歌
    func playOneMusic(id:Int){
        
        self.ququePlayer.removeAllItems();
        var i:Int = 0;
        for( i = id;i < self.ququePlayerItemArray.count;i++){
            let obj:AVPlayerItem = self.ququePlayerItemArray[i] as! AVPlayerItem;
            if(self.ququePlayer.canInsertItem(obj, afterItem: nil)){
                obj.seekToTime(kCMTimeZero);
                self.ququePlayer.insertItem(obj, afterItem: nil);
            }
        }
        self.ququePlayer.play();
        
    }
    
    func change(){
        change()
    }
    
}
