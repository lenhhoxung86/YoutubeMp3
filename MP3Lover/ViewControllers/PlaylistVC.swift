//
//  PlaylistVC.swift
//  MP3Lover
//
//  Created by tien dh on 12/14/16.
//  Copyright © 2016 tien dh. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PlaylistVC: UIViewController {
    
    var player: AVPlayer = AVPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "My Playlist"
        
        let url = "https://r5---sn-cxab5jvh-cg0y.googlevideo.com/videoplayback?itag=18&upn=evcX4EQxqes&beids=%5B9452307%5D&mt=1482088343&sparams=clen%2Cdur%2Cei%2Cgir%2Cid%2Cinitcwndbps%2Cip%2Cipbits%2Citag%2Clmt%2Cmime%2Cmm%2Cmn%2Cms%2Cmv%2Cpcm2cms%2Cpl%2Cratebypass%2Crequiressl%2Csource%2Cupn%2Cexpire&mv=m&pl=41&ipbits=0&ms=au&ei=4OBWWMrEEtaA1gKXpZiQCg&source=youtube&expire=1482110272&mm=31&id=o-AFkmVc4nnihtOrWLcrXTcBHXM7LGi7dHqrn7aYWpwV4_&clen=14931375&pcm2cms=yes&mn=sn-cxab5jvh-cg0y&ratebypass=yes&lmt=1417190732196679&dur=286.162&initcwndbps=2132500&requiressl=yes&key=yt6&gir=yes&mime=video%2Fmp4&ip=2a02%3Aa03f%3Abd%3A600%3Ae422%3Aa147%3A63e2%3A39bb&signature=C3346E35C4394AE5CF48465A2DB1AF0A455F009A.B7B9B6B52135FA7E77C40EAF4891048A24910136"
        let playerItem = AVPlayerItem(url: URL(string: url)!)
        player = AVPlayer(playerItem:playerItem)
        player.rate = 1.0;
        player.play()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
