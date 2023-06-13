//
//  VideosViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit
import AVFoundation
import GoogleMobileAds

class VideosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {
    
    var bannerView: GADBannerView!
    var defaultValue = ["listVideosAlbum": []]
    
    let userDefault = UserDefaults.standard
    
    let fileManager = FileManager.default
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataTable = userDefault.stringArray(forKey: "listVideosAlbum")
        return dataTable!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! VideosTableViewCell
        cell.backgroundColor = UIColor.clear
        var dataTable: [String] = userDefault.stringArray(forKey: "listVideosAlbum")!
        cell.titleLb.text = dataTable[indexPath.row]
        
        let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let videosURL = documentURL!.appendingPathComponent("Videos")
        let albumURL = videosURL.appendingPathComponent(dataTable[indexPath.row])
        do {
            var filesList = try fileManager.contentsOfDirectory(atPath: albumURL.path)
            if filesList.count == 0 {
                cell.imgView.image = UIImage(named: "2")
                cell.videoCountLb.text = "0 video"
            }
            else if filesList.count == 1 {
                let videoURL = albumURL.appendingPathComponent(filesList[0])
                cell.imgView.image = generateThumbnail(path: videoURL)
                cell.imgView.layer.borderWidth = 0.1
                cell.imgView.layer.cornerRadius = 15
                cell.videoCountLb.text = "1 video"
            }
            else {
                filesList.sort { (lhs: String, rhs: String) -> Bool in
                    return lhs < rhs
                }
                let lastVideoURL = albumURL.appendingPathComponent(filesList[filesList.count - 1])
                cell.imgView.image = generateThumbnail(path: lastVideoURL)
                cell.imgView.layer.borderWidth = 0.1
                cell.imgView.layer.cornerRadius = 15
                cell.videoCountLb.text = String(filesList.count) + " videos"
            }
        } catch {
            print(error.localizedDescription)
        }
        
        cell.menuBtn.showsMenuAsPrimaryAction = true
        cell.menuBtn.menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Delete", handler: { (_) in
                let alert = UIAlertController(title: "Do you really want to delete this Album?", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                    do {
                        try self.fileManager.removeItem(at: albumURL)
                        dataTable.remove(at: indexPath.row)
                        print(dataTable)
                        self.userDefault.setValue(dataTable, forKey: "listVideosAlbum")
                        tableView.reloadData()
                    } catch {
                        print(error.localizedDescription)
                    }
                }))
                alert.addAction(UIAlertAction(title: "No", style: .cancel))
                
                self.present(alert, animated: true)
            }),
            
            UIAction(title: "Rename", handler: { (_) in
                let oldFolderUrl = albumURL
                let alert = UIAlertController(title: "Enter the new name", message: nil, preferredStyle: .alert)
                alert.addTextField()
                alert.addAction(UIAlertAction(title: "Rename", style: .default, handler: { [weak alert] (_) in
                    let textField = alert?.textFields![0]
                    if textField?.text == "" {
                        let alert = UIAlertController(title: "Error", message: "Please enter album name", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self.present(alert, animated: true)
                        return
                    }
                    for name in dataTable {
                        if textField?.text == name {
                            let alert = UIAlertController(title: "Error", message: "This name has existed", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                            self.present(alert, animated: true)
                            return
                        }
                    }
                    let newFolderUrl = videosURL.appendingPathComponent(textField!.text!)
                    do {
                        try self.fileManager.moveItem(at: oldFolderUrl, to: newFolderUrl)
                    } catch {
                        print(error.localizedDescription)
                    }
                    var dataTable = self.userDefault.stringArray(forKey: "listVideosAlbum")
                    dataTable![indexPath.row] = (textField?.text)!
                    self.userDefault.set(dataTable, forKey: "listVideosAlbum")
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }),
            
            UIAction(title: "Share", handler: { (_) in
                let selectedAlbumUrl = videosURL.appendingPathComponent(dataTable[indexPath.row])
                var filesToShare: [Any] = []
                do {
                    let videosName = try self.fileManager.contentsOfDirectory(atPath: selectedAlbumUrl.path)
                    for videoName in videosName {
                        filesToShare.append(selectedAlbumUrl.appendingPathComponent(videoName))
                    }
                } catch {
                    print(error.localizedDescription)
                }
                let activityViewController = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
            })
            
        ])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nameArray = userDefault.stringArray(forKey: "listVideosAlbum")
        let name = nameArray![indexPath.row]
        self.navigationController?.pushViewController(SubVideosViewController.makeSelf(name: name), animated: true)
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .bottom,
                              multiplier: 1,
                              constant: -20),
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
        
        userDefault.register(defaults: defaultValue)
        //userDefault.removeObject(forKey: "listVideosAlbum")
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
                ]
        
        tableView.register(UINib(nibName: "VideosTableViewCell", bundle: nil), forCellReuseIdentifier: "myCell")
        
        tableView.rowHeight = 93
        
        // kiểm tra xem đã tồn tại folder "Videos" chưa
        guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let videosURL = documentURL.appendingPathComponent("Videos")
        
        if !self.fileManager.fileExists(atPath: videosURL.path) {
            do {
                try self.fileManager.createDirectory(atPath: videosURL.path, withIntermediateDirectories: true, attributes: nil)
                let documentPath = videosURL.path
                print("Path to pictures directory: \(documentPath)")
            } catch {
                print("Error creating directory: \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func createAlbumBtnTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Create album", message: nil, preferredStyle: .alert)
        alert.addTextField(){ (textfield) in
            textfield.placeholder = "Enter album name here"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listVideosAlbum") else {
                return
            }
            
            for fileName in fileNames {
                if textField?.text == fileName {
                   let alert = UIAlertController(title: "Error", message: "Album has existed", preferredStyle: .alert)
                   alert.addAction(UIAlertAction(title: "OK", style: .cancel))
                   self.present(alert, animated: true)
                   return
                   }
            }
            
            var dataUserdefault = self.userDefault.stringArray(forKey: "listVideosAlbum")
            dataUserdefault?.append((textField?.text)!)
            self.userDefault.set(dataUserdefault, forKey: "listVideosAlbum")
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listVideosAlbum") else {
                return
            }
            
            guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let videosURL = documentURL.appendingPathComponent("Videos")
            
            for fileName in fileNames {
                let fileURL = videosURL.appendingPathComponent(fileName).path
                if !self.fileManager.fileExists(atPath: fileURL) {
                    do {
                        try self.fileManager.createDirectory(atPath: fileURL, withIntermediateDirectories: true, attributes: nil)
                        let documentPath = videosURL.path
                        print("Path to pictures directory: \(documentPath)")
                    } catch {
                        print("Error creating directory: \(error)")
                    }
                }
            }
            
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.present(alert, animated: true)
    }
    
    func generateThumbnail(path: URL) -> UIImage? {
        let asset = AVAsset(url: path)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        do {
            let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: 1, preferredTimescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
