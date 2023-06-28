//
//  MoreViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 30/05/2023.
//

import UIKit
import StoreKit
import MessageUI
import GoogleMobileAds

class MoreViewController: UIViewController, GADBannerViewDelegate, MFMailComposeViewControllerDelegate {

    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)

        switch result {
        case .cancelled:
            // Xử lý khi người dùng hủy gửi email
            break
        case .saved:
            // Xử lý khi email được lưu như phiên bản nháp
            break
        case .sent:
            // Xử lý khi email được gửi thành công
            break
        case .failed:
            // Xử lý khi gửi email thất bại
            break
        @unknown default:
            break
        }
    }
    
    @IBAction func feedbackBtnTapped(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = self
            composeVC.setToRecipients(["youraddress@example.com"])
            composeVC.setSubject("Feedback your app!")
            composeVC.setMessageBody("Dear AppChannel team, \n\n", isHTML: false)
            self.present(composeVC, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please try again later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    @IBAction func rateBtnTapped(_ sender: UIButton) {
        SKStoreReviewController.requestReview()
    }
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        if let name = URL(string: "https://apps.apple.com/vn/app/asphalt-9-legends/id1491129197?mt=12"), !name.absoluteString.isEmpty {
          let objectsToShare = [name]
          let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
          self.present(activityVC, animated: true, completion: nil)
        } else {
          // show alert for not available
            let alert = UIAlertController(title: "Error", message: "Please try again later", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
}
