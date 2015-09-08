//
//  MusicListTableViewController.swift
//  MusicPlayer
//
//  Created by lanou3g on 15/8/31.
//  Copyright (c) 2015年 chehao. All rights reserved.
//

import UIKit
import AVFoundation

class MusicListTableViewController: UITableViewController {

    var listArray:NSMutableArray!
    var selectedIndexPath:NSIndexPath!
    var theQueuePlayer:AVQueuePlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.listArray = NSMutableArray();
        self.selectedIndexPath = NSIndexPath();
        
//        GetMusicInfo.getPlist { (data) -> Void in
//            //创建路径
//            let documentPathArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as NSArray;
//            let documentPath = documentPathArray.firstObject as! String;
//            let plistPath = documentPath + "/sourceData.plist";
//            //写入路径
//            data.writeToFile(plistPath, atomically: true);
//            let rootArray:NSArray = NSArray(contentsOfFile: plistPath)!;
//            println(rootArray.count);
//            
//            for(var i = 0;i < rootArray.count;i++){
//                let dicssss:NSDictionary = rootArray[i] as! NSDictionary;
//                var musicInfo = MusicInfoModel();
//                musicInfo.setValuesForKeysWithDictionary(dicssss as [NSObject : AnyObject]);
//                self.listArray.addObject(musicInfo);
//                self.tableView.reloadData();
//            }
//        };
    
        let documentPathArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as NSArray;
        let documentPath = documentPathArray.firstObject as! String;
        let plistPath = documentPath + "/sourceData.plist";
        let rootArray:NSArray = NSArray(contentsOfFile: plistPath)!;
        println(rootArray.count);
        var itemArray:NSMutableArray = NSMutableArray();
        for(var i = 0;i < rootArray.count;i++){
            let dicssss:NSDictionary = rootArray[i] as! NSDictionary;
            var musicInfo = MusicInfoModel();
            musicInfo.setValuesForKeysWithDictionary(dicssss as [NSObject : AnyObject]);
            self.listArray.addObject(musicInfo);
            self.tableView.reloadData();
            var url:NSURL = NSURL(string: musicInfo.mp3Url)!;
            let item:AVPlayerItem = AVPlayerItem(URL: url);
            itemArray.addObject(item);
        }
        Music.sharedUserInfo(self.listArray);
//        self.theQueuePlayer = AVQueuePlayer.queuePlayerWithItems(itemArray as [AnyObject]) as! AVQueuePlayer;
//        self.theQueuePlayer.play();
        
//        [[NSNotificationCenter defaultCenter] addObserver:self
//            selector:@selector(playerItemDidReachEnd:)
//        name:AVPlayerItemDidPlayToEndTimeNotification
//        object:[theItems lastObject]];
//        [theQueuePlayer play];
        

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return self.listArray.count;
    }
    
    private var mycontext:NSIndexPath = NSIndexPath();
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identfier:String = "musicList";
        let cell = tableView.dequeueReusableCellWithIdentifier(identfier, forIndexPath: indexPath) as! UITableViewCell;
        
        cell.contentView.backgroundColor = UIColor.grayColor();
        

        cell.textLabel?.text = (self.listArray[indexPath.row] as! MusicInfoModel).name;
        cell.detailTextLabel?.text = (self.listArray[indexPath.row] as! MusicInfoModel).singer;
//        cell.imageView?.image = (self.listArray[indexPath.row] as! MusicInfoModel).image;
        cell.imageView?.image = UIImage(contentsOfFile: (self.listArray[indexPath.row] as! MusicInfoModel).imageSandBoxPath((self.listArray[indexPath.row] as! MusicInfoModel).picUrl));
        
                //空心圆
        var bezier1 = UIBezierPath()
        bezier1.addArcWithCenter(CGPointMake(40, 40), radius: 35, startAngle: 0, endAngle: 6.28, clockwise: true);
        let shape:CAShapeLayer = CAShapeLayer(layer: CALayer());
        shape.path = bezier1.CGPath;
        cell.imageView?.layer.mask = shape;
        
        
        cell.layer.shouldRasterize = true;
        cell.layer.rasterizationScale = UIScreen.mainScreen().scale;
//        cell.layer.shouldRasterize = YES;
//        cell.layer.rasterizationScale = [UIScreen mainScreen].scale;
        
        
        
//        var count = 100
//        var voidPtr = withUnsafePointer(&count, { (a: UnsafeMutablePointer<Int>) -> UnsafeMutablePointer<Void> in
//            return unsafeBitCast(a, UnsafePointer<Void>.self)
//        })
//        // voidPtr 是 UnsafePointer<Void>。相当于 C 中的 void *
//        // 转换回 UnsafePointer<Int>
//        var intPtr = unsafeBitCast(voidPtr, UnsafePointer<Int>.self)
        
        self.mycontext = indexPath;
        if((self.listArray[indexPath.row] as! MusicInfoModel).image == nil){
            (self.listArray[indexPath.row] as! MusicInfoModel).imageDownload();
            self.listArray[indexPath.row].addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.New, context:  &self.mycontext);
//           self.listArray[indexPath.row].addObserver(<#observer: NSObject#>, forKeyPath: <#String#>, options: <#NSKeyValueObservingOptions#>, context: UnsafeMutablePointer<Void>)
        }
        // Configure the cell...

        return cell
    }
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        println("观察者");
        var newImage:UIImage = (change as NSDictionary).objectForKey("new") as! UIImage;
        let visibleIndexPathArray:NSArray = self.tableView.indexPathsForVisibleRows()! as NSArray;
        
        let indexPath:NSIndexPath = (context) as! NSIndexPath;
//        let newcontext = unsafeBitCast(context, UnsafePointer<Int>.self)
//        let indexPath:NSIndexPath = NSIndexPath(indexes: newcontext, length: 2)

        //unsafeBitCast(context, UnsafePointer<Void>.self);
        if(visibleIndexPathArray.containsObject(indexPath)){
            var tableViewCell:UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell;
            tableViewCell.imageView?.image = newImage;
            self.tableView.reloadRowsAtIndexPaths(NSArray(object: indexPath) as [AnyObject], withRowAnimation: UITableViewRowAnimation.Automatic);
        }
        object.removeObserver(self, forKeyPath: "image");
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //不为空代表点击的为单元格    为空代表点击的是右边button
        if(sender is UITableViewCell){
            var playMusic:PlayMusicViewController = segue.destinationViewController as! PlayMusicViewController;
            playMusic.musicInfo = self.listArray[self.tableView.indexPathForSelectedRow()!.row] as! MusicInfoModel;
            playMusic.musicInfoArray = self.listArray;
            playMusic.id = Int(self.tableView.indexPathForSelectedRow()!.row);
//            GetMusicInfo().getMusic((self.listArray[self.tableView.indexPathForSelectedRow()!.row] as! MusicInfoModel).mp3Url);
        }else{
            println("fuck")
        }
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    

}
