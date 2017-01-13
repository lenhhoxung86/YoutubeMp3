//
//  FirstViewController.swift
//  MP3Lover
//
//  Created by tien dh on 12/14/16.
//  Copyright © 2016 tien dh. All rights reserved.
//

import UIKit
import XCDYouTubeKit
import AVFoundation
import CoreData
import GoogleMobileAds


let yt_channel_id = "PL5HXxoA6NX4l3KY4RRc8JqM95V77SSO9-"

let YOUTUBE_3GP_MEDIUM = "17"
let YOUTUBE_HD_QUALITY = "22"
let YOUTUBE_MEDIUM_360 = "18"
let YOUTUBE_3GP_SMALL_240 = "36"

class SearchVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UIScrollViewDelegate {
    //lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    var selectedIndex = -1
    var f_video_playing = false
    var videos = [YTVideo]()
    var player = AVPlayer()
    var selectedCell:MP3Cell?
    var loading:DPBasicLoading?
    var currentRemoteURL:URL?
    var f_downloading:Bool = false
    var refreshControl = UIRefreshControl()
    var f_keyboardShow = false
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Tìm Nhạc"
        //searchBar.placeholder = "Your placeholder"
        //let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        //self.navigationItem.leftBarButtonItem = leftNavBarButton
        
        self.searchBar.delegate = self
//        self.tableView.scroll
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        //set up loading indicator
        self.loading = DPBasicLoading(table: self.tableView)
        self.loading?.startLoading(text: "Loading...")
        
        // set up the refresh control
        self.refreshControl.attributedTitle = NSAttributedString(string: "Kéo xuống để refresh")
        self.refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControl)
        
        if !CommonHelper.isInternetAvailable() {
            let alert = UIAlertController(title: "Oops", message: "Kết nối mạng lỗi", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: {
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
                self.loading?.endLoading()
            })
        } else {
            let ytHelper = YoutubeHelper()
            ytHelper.getYoutubeVideosFromPlaylist(playlistID: yt_channel_id,callback: dataComes)
        }
        
        bannerView.adUnitID = "ca-app-pub-6555883110005763/2846327534"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        f_downloading = false
    }
    
    
    func refresh() -> () {
        NSLog("Refreshing...")
        if CommonHelper.isInternetAvailable() {
            let ytHelper = YoutubeHelper()
            ytHelper.getYoutubeVideosFromPlaylist(playlistID: yt_channel_id,callback: dataComes)
        } else {
            let alert = UIAlertController(title: "Oops", message: "Kết nối mạng lỗi", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: {
                if self.refreshControl.isRefreshing
                {
                    self.refreshControl.endRefreshing()
                }
            })
        }
    }
    
//    func videoEnd() -> Void {
//        NSLog("video ended!!!")
//        let tempBtn: UIButton = UIButton()
//        pressPlayButton(button: tempBtn)
//    }
    
    func playMovie(url:URL) -> Void {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem:playerItem)
        player.rate = 1.0;
        player.play()
    }
    
    func stopMovie(){
        player.pause()
    }
    
    
    func dataComes(videos:[YTVideo]) -> () {
        print("Data come... \(videos.count)")
        self.videos = videos
        self.tableView.reloadData()
        self.loading?.endLoading()
        
        // tell refresh control it can stop showing up now
        if self.refreshControl.isRefreshing
        {
            self.refreshControl.endRefreshing()
        }
    }
    
    
    func showActionIcon(_ playing: Bool) -> () {
        if playing {
            let playingButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            playingButton.setBackgroundImage( UIImage(named: "listen"), for: .normal)
            playingButton.addTarget(self, action: #selector(pressPlayButton(button:)), for: .touchUpInside)
            let rightPlayingItem = UIBarButtonItem(customView:playingButton)
            self.navigationItem.rightBarButtonItem = rightPlayingItem
            
            let downloadButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            downloadButton.setBackgroundImage(UIImage(named: "download"), for: .normal)
            downloadButton.addTarget(self, action: #selector(pressDownloadButton(button:)), for: .touchUpInside)
            let leftDownloadItem = UIBarButtonItem(customView:downloadButton)
            self.navigationItem.leftBarButtonItem = leftDownloadItem
        } else {
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    func pressDownloadButton(button: UIButton) -> () {
        if f_downloading {
            let alert = UIAlertController(title: "Oops", message: "Bạn vui lòng chờ đến khi tải xong", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        //delete the old video
        CommonHelper.removeTemporaryFiles()
        
        let ytHelper = YoutubeHelper()
        if selectedIndex < self.videos.count && selectedIndex >= 0 {
            let video = self.videos[selectedIndex]
            XCDYouTubeClient.default().getVideoWithIdentifier(video.videoID, completionHandler: { (ytVideo, error) in
                var remote_url_3gp_small:URL? = nil
                var remote_url_3gp_medium:URL? = nil
                var remote_url_medium_360:URL? = nil
                var remote_url_hd:URL? = nil
                for (key,val) in (ytVideo?.streamURLs)! {
                    let val_str = "\(key)"
                    if val_str == "36" {
                        remote_url_3gp_small = val
                    } else if val_str == "18" {
                        remote_url_medium_360 = val
                    } else if val_str == "22" {
                        remote_url_hd = val
                    } else if val_str == "17" {
                        remote_url_3gp_medium = val
                    }
                }
                if remote_url_3gp_small != nil {
                    self.currentRemoteURL = remote_url_3gp_small
                } else if remote_url_3gp_medium != nil {
                    self.currentRemoteURL = remote_url_3gp_medium
                } else if remote_url_medium_360 != nil {
                    self.currentRemoteURL = remote_url_medium_360
                } else {
                    self.currentRemoteURL = remote_url_hd
                }
                ytHelper.downloadYoutubeVideoFromURL(url: (self.currentRemoteURL?.absoluteString)!, progressCallback: self.progressUpdate, callback: self.dataDownloaded)
                self.f_downloading = true
            })
        }
    }
    
    func progressUpdate(_ rate:Float) -> () {
        NSLog("current rate: \(rate)")
        self.selectedCell?.progressView.isHidden = false
        self.selectedCell?.progressView.progress = rate
        if Int(rate) == 1 {
            self.selectedCell?.progressView.isHidden = true
        }
    }
    
    func dataDownloaded() -> () {
        let ytvideo = self.videos[selectedIndex]
        let audioFileName = CommonHelper.getDocumentFolderPath() +  "/temp.m4a"
        let targetAudioFileName = CommonHelper.getDocumentFolderPath() + "/" + CommonHelper.AUDIO_FOLDER + "/" + ytvideo.videoID + ".m4a"
        f_downloading = false
        Mp3Converter.getAudioFromVideo(CommonHelper.getDocumentFolderPath() + "/videoplayback.3gp", callback: {(audioPath,f_success)->Void in
            if f_success {
                NSLog("Converted successfully!!!")
                CommonHelper.copyFileFrom(fromPath: audioFileName, toPath: targetAudioFileName)
                
                //save now to core data
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                let managedContext = appDelegate.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "MP3CD",
                                                        in: managedContext)!
                let audio = MP3CD(entity: entity, insertInto: managedContext)
                audio.mp3Description = ytvideo.videoDescription
                audio.mp3DirectLink = "https://www.youtube.com/watch?v=" + ytvideo.videoID
                audio.mp3LocalLink = CommonHelper.AUDIO_FOLDER + "/" + ytvideo.videoID + ".m4a"
                audio.mp3Title = ytvideo.videoTitle
                
                do {
                    try managedContext.save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            } else {
                NSLog("Failed to convert!!!")
            }
            CommonHelper.removeTemporaryFiles()
        })
    }
    
    func pressPlayButton(button: UIButton) {
        let playingButton = self.navigationItem.rightBarButtonItem?.customView as! UIButton
        if !f_video_playing {
            f_video_playing = true
            playingButton.setBackgroundImage(UIImage(named: "pause"), for: .normal)
            if selectedIndex < self.videos.count && selectedIndex >= 0 {
                let video = self.videos[selectedIndex]
                self.selectedCell?.volumeIcon.isHidden = false
                XCDYouTubeClient.default().getVideoWithIdentifier(video.videoID, completionHandler: { (ytVideo, error) in
                    var remote_url_3gp_small:URL? = nil
                    var remote_url_3gp_medium:URL? = nil
                    var remote_url_medium_360:URL? = nil
                    var remote_url_hd:URL? = nil
                    for (key,val) in (ytVideo?.streamURLs)! {
                        let val_str = "\(key)"
                        if val_str == "36" {
                            remote_url_3gp_small = val
                        } else if val_str == "18" {
                            remote_url_medium_360 = val
                        } else if val_str == "22" {
                            remote_url_hd = val
                        } else if val_str == "17" {
                            remote_url_3gp_medium = val
                        }
                    }
                    if remote_url_3gp_small != nil {
                        self.currentRemoteURL = remote_url_3gp_small
                    } else if remote_url_3gp_medium != nil {
                        self.currentRemoteURL = remote_url_3gp_medium
                    } else if remote_url_medium_360 != nil {
                        self.currentRemoteURL = remote_url_medium_360
                    } else {
                        self.currentRemoteURL = remote_url_hd
                    }
                    
                    self.playMovie(url:self.currentRemoteURL!)
                })
            }
        } else {
            f_video_playing = false
            self.selectedCell?.volumeIcon.isHidden = true
            stopMovie()
            playingButton.setBackgroundImage(UIImage(named: "listen"), for: .normal)
            self.currentRemoteURL = nil
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK:UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedIndex == indexPath.row {
            self.showActionIcon(false)
            selectedIndex = -1
            tableView.deselectRow(at: indexPath, animated: true)
            self.selectedCell = nil
        } else  {
            self.showActionIcon(true)
            selectedIndex = indexPath.row
            if (self.selectedCell != nil) {
                self.selectedCell?.volumeIcon.isHidden = true
            }
            self.selectedCell = tableView.cellForRow(at: indexPath) as! MP3Cell?
        }
        if f_video_playing {
            stopMovie()
            f_video_playing = false
        }
    }

    // MARK:UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MP3Cell = tableView.dequeueReusableCell(withIdentifier: "MP3ItemCell") as! MP3Cell
        cell.volumeIcon.isHidden = true
        let video:YTVideo = self.videos[indexPath.row]
        cell.titleLb.text = video.videoTitle
        cell.progressView.isHidden = true
        
        return cell
    }
    
    // MARK:UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.loading?.startLoading(text: "Loading...")
        searchBar.resignFirstResponder()
        let ytHelper = YoutubeHelper()
        if (searchBar.text?.characters.count)! > 2 {
            //only search if the search term is more than 2 characters
            ytHelper.searchYoutubeVideos(keyword: searchBar.text!, callback: searchedDataCome)
        }
        if f_video_playing {
            stopMovie()
            f_video_playing = false
        }
    }
    
    func searchedDataCome(yt_videos:[YTVideo]) -> () {
        self.videos = yt_videos
        self.tableView.reloadData()
        self.loading?.endLoading()
    }
    
    // MARK:Keyboard handler
    func keyboardShow() -> () {
        f_keyboardShow = true
    }
    
    func keyboardHide() -> () {
        f_keyboardShow = false
    }
    
    // MARK:UIScrollViewDelegate
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if f_keyboardShow {
            self.searchBar.resignFirstResponder()
        }
    }
}

