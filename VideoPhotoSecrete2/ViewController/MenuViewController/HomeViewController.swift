//
//  HomeViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit
import GoogleMobileAds

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, GADBannerViewDelegate, GADFullScreenContentDelegate {
    
    let titleCell = ["Photos", "Videos", "Audios", "Documents"]
    let imageCell = ["elipse-5", "elipse-6", "elipse-7", "elipse-8"]
    var identifierSegue = ""
    var bannerView: GADBannerView!
    private var interstitial: GADInterstitialAd?
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        titleCell.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! HomeCollectionViewCell
        cell.label.text = titleCell[indexPath.row]
        cell.imageView.image = UIImage(named: imageCell[indexPath.row])
        cell.layer.cornerRadius = 20 // Bo tròn viền cell
        cell.layer.borderWidth = 0.5 // Độ rộng của viền cell
//        cell.layer.borderColor = UIColor.lightGray.cgColor // Màu của viền cell
//        cell.layer.shadowColor = UIColor.darkGray.cgColor // Màu của đổ bóng cell
//        cell.layer.shadowOffset = CGSize(width: 2, height: 2) // Kích thước của đổ bóng cell
//        cell.layer.shadowOpacity = 0.3 // Độ đậm của đổ bóng cell
//        cell.layer.shadowRadius = 2.5 // Độ cong của đổ bóng cell
        cell.alpha = 0.9
        return cell
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: view.safeAreaLayoutGuide,
                              attribute: .bottom,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
       }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        addBannerViewToView(bannerView)
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAd()
        
        collectionView.register(UINib(nibName: "HomeCollectionViewCell", bundle: .main), forCellWithReuseIdentifier: "myCell")
        
        let adSize = GADAdSizeFromCGSize(CGSize(width: view.frame.width, height: 55))
        bannerView = GADBannerView(adSize: adSize)
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.backgroundColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
        bannerView.layer.borderWidth = 2.0
        bannerView.layer.borderColor = CGColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
                
        let margin: CGFloat = 13
        var marginTop: CGFloat = 13
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = margin
        layout.minimumInteritemSpacing = margin
        var sizeCell = (view.frame.size.width - 3 * margin) / 2 - 2
        if UIDevice.current.userInterfaceIdiom == .pad {
            sizeCell = (view.frame.size.width - 5 * margin) / 4 - 2
            marginTop = 150
            layout.sectionInset = UIEdgeInsets.init(top: marginTop, left: margin, bottom: margin, right: margin)
        }
                            
        layout.itemSize = CGSize(width: sizeCell, height: sizeCell)
        layout.sectionInset = UIEdgeInsets.init(top: marginTop, left: margin, bottom: margin, right: margin)
        collectionView.collectionViewLayout = layout
    }
  
    func loadAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: "ca-app-pub-3940256099942544/4411468910",
                                    request: request,
                          completionHandler: { [self] ad, error in
                            if let error = error {
                              print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                              return
                            }
                            interstitial = ad
                            interstitial?.fullScreenContentDelegate = self
                          })
    }
    /// Tells the delegate that the ad failed to present full screen content.
      func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
      }

      /// Tells the delegate that the ad will present full screen content.
      func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
      }

      /// Tells the delegate that the ad dismissed full screen content.
      func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
          loadAd()
          self.performSegue(withIdentifier: identifierSegue, sender: self)
      }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            identifierSegue = "photosSegue"
            showAd()
            break
        case 1:
            identifierSegue = "videosSegue"
            showAd()
            break
        case 2:
            identifierSegue = "audiosSegue"
            showAd()
            break
        case 3:
            identifierSegue = "documentsSegue"
            showAd()
            break
        default:
            break
        }
    }
    
    func showAd() {
        if self.interstitial != nil {
            let root = UIApplication.shared.keyWindow!.rootViewController
            // you can also use: UIApplication.shared.keyWindow.rootViewController
            self.interstitial!.present(fromRootViewController: root!)
        } else {
            self.performSegue(withIdentifier: identifierSegue, sender: self)
        }
    }

}
