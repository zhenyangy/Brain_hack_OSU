/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import AVKit
import AVFoundation

class VacationViewController: UIViewController {
  
  @IBOutlet weak var imageVRView: GVRPanoramaView!
  @IBOutlet weak var videoVRView: GVRVideoView!
  @IBOutlet weak var imageLabel: UILabel!
  @IBOutlet weak var videoLabel: UILabel!
  
  enum Media {
    static var photoArray = ["sindhu_beach.jpg", "grand_canyon.jpg", "underwater.jpg"]
    static let videoURL = ["https://s3.amazonaws.com/zhenyang.yu/ENTER+THE+BLACKHOLE+IN+360+-+Space+Engine+%5B360+video%5D.mp4", "https://s3.amazonaws.com/zhenyang.yu/360+VR+VIDEO.mp4"]
  }
  
  var currentView: UIView?
  var currentDisplayMode = GVRWidgetDisplayMode.embedded
  var isPaused = true
  var index = 0
  var start = DispatchTime.now()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imageLabel.isHidden = true
    imageVRView.isHidden = true
    videoLabel.isHidden = true
    videoVRView.isHidden = true

    imageVRView.load(UIImage(named: Media.photoArray.first!),
                            of: GVRPanoramaImageType.mono)
    imageVRView.enableCardboardButton = true
    imageVRView.enableFullscreenButton = true
    imageVRView.delegate = self
    
    videoVRView.load(from: URL(string: Media.videoURL[0]))
    videoVRView.enableCardboardButton = true
    videoVRView.enableFullscreenButton = true
    videoVRView.delegate = self
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    tap.numberOfTapsRequired = 2
    view.addGestureRecognizer(tap)
    
    
    do {
        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        print("AVAudioSession Category Playback OK")
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            print("AVAudioSession is Active")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    } catch let error as NSError {
        print(error.localizedDescription)
    }
    
    
//    do {
//        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: .mixWithOthers)
//        print("Playback OK")
//        try AVAudioSession.sharedInstance().setActive(true)
//        print("Session is Active")
//    } catch {
//        print(error)
//    }
  }

    
    
    func doubleTapped() {
    print("TAPPED")
}
  
  func refreshVideoPlayStatus() {
    if currentView == videoVRView && currentDisplayMode != GVRWidgetDisplayMode.embedded {
      videoVRView?.resume()
      isPaused = false
    } else {
      videoVRView?.pause()
      isPaused = true
    }
  }
  
  func setCurrentViewFromTouch(touchPoint point:CGPoint) {
    if imageVRView!.frame.contains(point) {
      currentView = imageVRView
    } else  if videoVRView!.frame.contains(point) {
      currentView = videoVRView
    }
  }

    
//    override func viewDidAppear(_ animated: Bool) {
//        let videoURL = URL(string: "https://ia802508.us.archive.org/5/items/testmp3testfile/mpthreetest.mp3")
//        guard let player = AVPlayer(URL: videoURL!) else { return }
//        let playerLayer = AVPlayerLayer(player: player)
//        playerLayer.frame = self.view.bounds
//        self.view.layer.addSublayer(playerLayer)
//        player.play()
//    }
}

extension VacationViewController: GVRWidgetViewDelegate {
  func widgetView(_ widgetView: GVRWidgetView!, didLoadContent content: Any!) {
    if content is UIImage {
      imageVRView.isHidden = false
      imageLabel.isHidden = false
        
        let urlString = "https://s3.amazonaws.com/zhenyang.yu/360+VR+VIDEO.mp3"
        guard let url = URL(string: urlString)
            else {
                return
        }
        let playerItem = AVPlayerItem.init(url: url)
        let player = AVPlayer.init(playerItem: playerItem)
        player.play()
        print("audio")
        let urltest = URL(string: urlString)
        _ = URLSession.shared.dataTask(with: urltest!){
            data, response, error in
            if(error != nil){
                print("Error info: -> \(error!)")
            }
            else{
                print("It is going to be play without problem")
            }
        }
        
//        var player = AVPlayer()
        
//        var player = AVPlayer()
//        let playerItem = AVPlayerItem(url: URL(string: "https://ia802508.us.archive.org/5/items/testmp3testfile/mpthreetest.mp3")! as URL)
//        player = AVPlayer(playerItem: playerItem)
//        player.rate = 1.0;
//        player.play()
    } else if content is NSURL {
      videoVRView.isHidden = false
      videoLabel.isHidden = false
      refreshVideoPlayStatus()
    }
  }

  func widgetView(_ widgetView: GVRWidgetView!, didFailToLoadContent content: Any!, withErrorMessage errorMessage: String!)  {
    print(errorMessage)
  }
  
    func widgetView(_ widgetView: GVRWidgetView!, didChange displayMode: GVRWidgetDisplayMode) {
    currentView = widgetView
    currentDisplayMode = displayMode
    refreshVideoPlayStatus()
    print("2016")
    print(displayMode.hashValue)
    if currentView == imageVRView && currentDisplayMode != GVRWidgetDisplayMode.embedded {
      view.isHidden = true
    } else {
      view.isHidden = false
    }
  }

  func widgetViewDidTap(_ widgetView: GVRWidgetView!) {
    let end = DispatchTime.now()
    let time = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
    print(time)
    guard currentDisplayMode != GVRWidgetDisplayMode.embedded else {return}
    if currentView == imageVRView {
      Media.photoArray.append(Media.photoArray.removeFirst())
      imageVRView?.load(UIImage(named: Media.photoArray.first!), of: GVRPanoramaImageType.mono)
    } else {
        if time>0.5{
      if isPaused {
        videoVRView?.resume()
      } else {
        videoVRView?.pause()
      }
      isPaused = !isPaused
        }else{
        index = (index+1)%2
        print(index)
        videoVRView.load(from: URL(string: Media.videoURL[index]))
        videoVRView.enableCardboardButton = true
        videoVRView.enableFullscreenButton = true
        videoVRView.delegate = self
        refreshVideoPlayStatus()
        currentView = videoVRView
//        start = DispatchTime.now()
        }
        start = DispatchTime.now()
    }
  }
}

extension VacationViewController: GVRVideoViewDelegate {
  func videoView(_ videoView: GVRVideoView!, didUpdatePosition position: TimeInterval) {
    OperationQueue.main.addOperation() {
      if position >= videoView.duration() {
        videoView.seek(to: 0)
        videoView.resume()
      }
    }
  }
}

class TouchView: UIView {
  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    if let vacationViewController = viewController() as? VacationViewController , event?.type == UIEventType.touches {
      vacationViewController.setCurrentViewFromTouch(touchPoint: point)
    }
    return true
  }
  
  func viewController() -> UIViewController? {
    if self.next!.isKind(of: VacationViewController.self) {
      return self.next as? UIViewController
    } else {
      return nil
    }
  }
}
