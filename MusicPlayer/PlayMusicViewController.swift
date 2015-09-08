//
//  PlayMusicViewController.swift
//  MusicPlayer
//
//  Created by lanou3g on 15/9/4.
//  Copyright (c) 2015年 chehao. All rights reserved.
//

import UIKit
import AVFoundation

class PlayMusicViewController: UIViewController, UITableViewDelegate , UITableViewDataSource{
    
 
    @IBOutlet var musicImageView: UIImageView!//歌曲的图片
    @IBOutlet var downLoadProgress: UIProgressView!//缓存进度条
    @IBOutlet var playSlider: UISlider!//播放进度条
    
    @IBOutlet var playOrStop: UIButton!//播放暂停
    @IBOutlet var stopMusic: UIButton!//下一曲
    @IBOutlet var lastMusic: UIButton!//上一曲
    
    @IBOutlet var currentTiems: UILabel!//当前播放时间
    @IBOutlet var allTimes: UILabel!//总播放时间
    @IBOutlet var tableView: UITableView!//显示歌词
    
    var totalTime:String!;
    var dateFormatter:NSDateFormatter = NSDateFormatter();
    var playbackTimeObserver:AnyObject!;
    var timeTextArray:NSArray!//歌词时间
    var otherTextArray:NSArray!//歌词
    
    var musicInfo:MusicInfoModel!//模型
    var musicInfoArray:NSMutableArray!
    var music:Music!
    var id:Int = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        self.music = Music.sharedUserInfo(nil);
        initOther();//初始化控件
        self.title = self.musicInfo.name;
        
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(//(title: "列表", style: UIBarButtonItemStyle.Plain, target: self, action:"leftBarButtonClick")
//        getMusic(self.musicInfo.mp3Url);
        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func sliderTouchUpInside(sender: AnyObject) {
        
        self.music.playOrPause("");
        println("123456");
                let cmTime:CMTime = CMTimeMakeWithSeconds(Float64((sender as! UISlider).value), 1);
        
                self.music.ququePlayer.currentItem.seekToTime(cmTime);
                self.music.playOrPause("play");
        
    }
    
    @IBAction func sliderDragInside(sender: AnyObject) {
        self.music.playOrPause("");
    }
    
    
    @IBAction func leftBarButtonClick(){
        removeMusicOBserver();
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func initOther(){
        if(self.musicInfo != nil){
            self.music.playOneMusic(self.id);
            
            imageBeginRotate();
            self.playSlider.continuous = false;
            let url:NSURL = NSURL(string: self.musicInfo.mp3Url)!;

            
            var bezier1 = UIBezierPath()
            bezier1.addArcWithCenter(CGPointMake(85, 85), radius: 85, startAngle: 0, endAngle: 6.283, clockwise: true);
            let shape:CAShapeLayer = CAShapeLayer(layer: CALayer());
            shape.path = bezier1.CGPath;
            self.musicImageView.layer.mask = shape;
            
            //这只tableview 歌词
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = 30
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            initOthers();

        }
    }
    
    
    func removeMusicOBserver(){
        self.music.ququePlayer.currentItem.removeObserver(self, forKeyPath: "status");
        self.music.ququePlayer.currentItem.removeObserver(self, forKeyPath: "loadedTimeRanges");
        self.music.ququePlayer.removeTimeObserver(self.playbackTimeObserver);
        self.playbackTimeObserver = nil;
    }
    
    func initOthers(){
        
        self.musicInfo = self.musicInfoArray[self.id] as! MusicInfoModel;
        
        self.title = self.musicInfo.name;
        
        self.musicImageView.image = self.musicInfo.image;
        
        let dic:NSDictionary = LRCAnalysis.GetLRCTimeArray(self.musicInfo.lyric);//解析歌词
        self.timeTextArray = dic["time"] as! NSArray;
        self.otherTextArray = dic["other"] as! NSArray;
        
        //添加属性监听
        self.music.ququePlayer.currentItem.addObserver(self, forKeyPath:"status", options: NSKeyValueObservingOptions.New, context: nil);
        self.music.ququePlayer.currentItem.addObserver(self, forKeyPath:"loadedTimeRanges", options: NSKeyValueObservingOptions.New, context: nil);
        (NSNotificationCenter.defaultCenter()).addObserver(self, selector:"playerItemDidReachEnd", name: "AVPlayerItemDidPlayToEndTimeNotification", object: self.music.ququePlayer.currentItem);
        if(self.music.ququePlayer.currentItem.status == AVPlayerItemStatus.ReadyToPlay){
            
            let duration:CMTime = self.music.ququePlayer.currentItem.duration;//获取视频总长度
            let totalSecond:CGFloat = CGFloat(self.music.ququePlayer.currentItem.duration.value) / CGFloat(self.music.ququePlayer.currentItem.duration.timescale);//穿换成秒
            self.totalTime = convertTime(totalSecond);//转换成播放时
            self.allTimes.text = self.totalTime;
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.customMusicSlider(duration);//自定义slider 外观
                self.monitoringPlayback(self.music.ququePlayer.currentItem);
            })
        }
        self.downLoadProgress.setProgress(Float(1), animated: false);
    }
    
    func playerItemDidReachEnd(){
        
        nextSong("");
      
    }
    //监听方法KVO
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        AVPlayerStatus.ReadyToPlay
        var playerItem:AVPlayerItem = object as! AVPlayerItem;
        if(keyPath == "status"){
 
            if(self.music.ququePlayer.currentItem.status == AVPlayerItemStatus.ReadyToPlay){
                
                let duration:CMTime = self.music.ququePlayer.currentItem.duration;//获取视频总长度
                let totalSecond:CGFloat = CGFloat(self.music.ququePlayer.currentItem.duration.value) / CGFloat(self.music.ququePlayer.currentItem.duration.timescale);//穿换成秒
                self.totalTime = convertTime(totalSecond);//转换成播放时
                self.allTimes.text = self.totalTime;
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.customMusicSlider(duration);//自定义slider 外观
                    self.monitoringPlayback(self.music.ququePlayer.currentItem);
                })
            }else

            if(playerItem.status == AVPlayerItemStatus.Failed){
                println("AVPlayerStatusFailed");
            }
            
        }else if(keyPath == "loadedTimeRanges"){
            let timeInterval:NSTimeInterval = availableDuration();

            let duration:CMTime = self.music.ququePlayer.currentItem.duration;
            let totalDuration = CMTimeGetSeconds(duration);
            self.downLoadProgress.setProgress(Float(timeInterval / totalDuration), animated: false);
        }
    }
    
    func availableDuration()-> NSTimeInterval{
        let loadedTimeRanges:NSArray = self.music.ququePlayer.currentItem.loadedTimeRanges as NSArray;
        let timeRange:CMTimeRange = loadedTimeRanges.firstObject!.CMTimeRangeValue;//获取缓冲区域
        let startSeconds:Float = Float(CMTimeGetSeconds(timeRange.start));
        let durationSeconds:Float = Float(CMTimeGetSeconds(timeRange.duration));
        let result:NSTimeInterval = NSTimeInterval(startSeconds + durationSeconds);//计算缓冲总进度
        return result;
    }
    
    func monitoringPlayback(playerItem:AVPlayerItem){
        if(self.playbackTimeObserver == nil){
            self.playbackTimeObserver = self.music.ququePlayer.addPeriodicTimeObserverForInterval(CMTimeMake(1, 1), queue: nil, usingBlock: { (time:CMTime) -> Void in
                
                var currentSecond:CGFloat = CGFloat(playerItem.currentTime().value) / CGFloat(playerItem.currentTime().timescale);
                self.playSlider.setValue(Float(currentSecond), animated: true);
                var timeString:String = self.convertTime(currentSecond);
                self.currentTiems.text = timeString;
                self.lrcAccording(Float(currentSecond));
                println(self.playSlider.value)
            });
        }
    }
    
    func customMusicSlider(duration:CMTime){
        self.playSlider.maximumValue = Float(CMTimeGetSeconds(duration));
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), false, 0.0);
        var transparentImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.playSlider.setMinimumTrackImage(transparentImage, forState: UIControlState.Normal);
        self.playSlider.setMaximumTrackImage(transparentImage, forState: UIControlState.Normal);
    
    }
    
    
    func convertTime(second:CGFloat) -> String{
        var d:NSDate = NSDate(timeIntervalSince1970:Double(second)) ;
        if(second/3600 >= 1){
            self.dateFormatter.dateFormat = "HH:mm:ss";
        }else{
            self.dateFormatter.dateFormat = "mm:ss";
        }
        var showtimeNew:String = self.dateFormatter.stringFromDate(d);
        return showtimeNew;
    }
    
    //图片旋转
    func imageBeginRotate(){
        let rotationAnimation:CABasicAnimation!
        rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(double: M_PI * 2.0)
        rotationAnimation.duration = 20.0;
        rotationAnimation.cumulative = true;
        rotationAnimation.repeatCount = Float(600);
        rotationAnimation.timingFunction = CAMediaTimingFunction(name:kCAMediaTimingFunctionLinear)
        self.musicImageView.layer.addAnimation(rotationAnimation, forKey: "1")
    }
//    图片停止旋转
    func imageStopRotate(){
        self.musicImageView.layer.removeAnimationForKey("1");
    }
    
    
    @IBAction func changePlayOrStopButton(sender: UIButton) {
        //tag 1 为播放 2 为暂停状态
        if(sender.tag == 1){
            sender.tag = 2;
            sender.setImage(UIImage(named: "play")!, forState: UIControlState.Normal);
            self.music.playOrPause("");
            imageStopRotate()
        }else{
            sender.tag = 1;
            sender.setImage(UIImage(named: "pause")!, forState: UIControlState.Normal);
            self.music.playOrPause("play");
            imageBeginRotate()
        }
    }

    @IBAction func nextSong(sender: AnyObject) {
        self.id++;
        if(self.id <= 199){
            removeMusicOBserver();
            music.advanceToNextItem();
            
            self.initOthers();
            self.tableView.reloadData();//刷新歌词
        }else{
            println("没有下一曲了")
        }
    }
    
    @IBAction func lastSong(sender: AnyObject) {
        self.id--;
        if(self.id >= 0){
            removeMusicOBserver();
            
            music.playOneMusic(self.id);
            initOthers();
        }else{
            println("没有上一曲了傻逼")
        }
    }
        
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.timeTextArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("lrc", forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.textColor = UIColor.grayColor()
        cell.textLabel?.text = self.otherTextArray[indexPath.row] as? String
        cell.textLabel?.font = UIFont(name: "Marion", size: 14)
        cell.textLabel?.textAlignment = NSTextAlignment.Center
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //歌词滚动
    func lrcAccording(cunrrentValue:Float){
        for time in self.timeTextArray {
            if (time as! NSString).integerValue == Int(cunrrentValue) {
                let index = (self.timeTextArray as NSArray).indexOfObject(time)
                
                self.tableView.setContentOffset(CGPointMake(0, CGFloat(index * 30 - 2 * 30)), animated: true)
                let indexPath:NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
                if !(self.tableView.indexPathsForVisibleRows()! as NSArray).containsObject(indexPath){
                    self.tableView.setContentOffset(CGPointMake(0, CGFloat(index * 30 - 2 * 30)), animated: false)
                    
                }
                let cell:UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
                cell.textLabel?.textColor = UIColor.blueColor() 
                let indexPathFront:NSIndexPath = NSIndexPath(forRow: index-1, inSection: 0)
                if index > 0 {
                    let cellFront:UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPathFront)!
                    cellFront.textLabel?.textColor = UIColor.grayColor()
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
