//
//  CPlayerView.swift
//  TodayIsYou
//
//  Created by 김학철 on 2022/03/06.
//

import UIKit
import AVKit

class CPlayerView: UIView {
    private var xib: UIView!
    var player: AVPlayer!
    private var playerLayer: AVPlayerLayer!
    
    var playUrl : String! {
        didSet {
            guard let uurl = URL(string: playUrl) else { return }
            let item = AVPlayerItem.init(url: uurl)
            self.player = AVPlayer(playerItem: item)
            playerLayer = AVPlayerLayer(player: player)
            xib.layer.addSublayer(playerLayer)
            playerLayer.frame = xib.bounds
            self.player.externalPlaybackVideoGravity = .resizeAspectFill
        }
    }

    var urls: [String]! {
        didSet {
            var items = [AVPlayerItem]()
            for urlStr in urls {
                if let url = URL(string: urlStr) {
                    let asset = AVAsset(url: url)
                    let item = AVPlayerItem.init(asset: asset)
                    items.append(item)
                }
            }

            self.player = AVQueuePlayer.init(items: items)
            playerLayer = AVPlayerLayer(player: player)
            xib.layer.addSublayer(playerLayer)
            self.player.externalPlaybackVideoGravity = .resizeAspectFill
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commitXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commitXib()
    }
    
    private func commitXib() {
        guard let xib = Bundle.main.loadNibNamed("CPlayerView", owner: self, options: nil)?.first as? UIView else { return }
        self.xib = xib
        self.addSubview(xib)
        xib.addConstraintsSuperView()
        self.awakeFromNib()
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
