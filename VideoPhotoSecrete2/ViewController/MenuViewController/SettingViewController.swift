//
//  SettingViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 30/05/2023.
//

import UIKit
import PasscodeKit
import GoogleMobileAds

class SettingViewController: UIViewController, GADFullScreenContentDelegate, GADBannerViewDelegate {
    
    private var interstitial: GADInterstitialAd?
    var bannerView: GADBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadAd()
        
        let adSize = GADAdSizeFromCGSize(CGSize(width: view.frame.width, height: 55))
        bannerView = GADBannerView(adSize: adSize)
        bannerView.delegate = self
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.backgroundColor = UIColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
        bannerView.layer.borderWidth = 5.0
        bannerView.layer.borderColor = CGColor(red: 41/255, green: 41/255, blue: 41/255, alpha: 1)
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
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
      }
    
    @IBAction func creatPCBtn(_ sender: UIButton) {
        if PasscodeKit.enabled() {
            let alert = UIAlertController(title: "PassCode has existed", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                if self.interstitial != nil {
                    self.interstitial!.present(fromRootViewController: self)
                  } else {
                    print("Ad wasn't ready")
                  }
            }))
            present(alert, animated: true)
        }
        else {
            PasscodeKit.createPasscode(self)
        }
    }
    
    @IBAction func changePCBtn(_ sender: UIButton) {
        if !PasscodeKit.enabled() {
            let alert = UIAlertController(title: "PassCode does not exist", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                if self.interstitial != nil {
                    self.interstitial!.present(fromRootViewController: self)
                  } else {
                    print("Ad wasn't ready")
                  }
            }))
            present(alert, animated: true)
        }
        else {
            PasscodeKit.changePasscode(self)
        }
    }
    
    @IBAction func removePcBtn(_ sender: UIButton) {
        if !PasscodeKit.enabled() {
            let alert = UIAlertController(title: "PassCode does not exist", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                if self.interstitial != nil {
                    self.interstitial!.present(fromRootViewController: self)
                  } else {
                    print("Ad wasn't ready")
                  }
            }))
            present(alert, animated: true)
        }
        else {
            PasscodeKit.removePasscode(self)
        }
    }
    
}
