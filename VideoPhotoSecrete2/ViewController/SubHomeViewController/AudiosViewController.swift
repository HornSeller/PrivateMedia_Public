//
//  AudiosViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit
import GoogleMobileAds

class AudiosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {
    var bannerView: GADBannerView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataTable = userDefault.stringArray(forKey: "listAudiosAlbum")
        return dataTable!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var dataTable: [String] = userDefault.stringArray(forKey: "listAudiosAlbum")!
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! AudiosTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.titleLb.text = dataTable[indexPath.row]
        let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let audiosURL = documentURL!.appendingPathComponent("Audios")
        let albumURL = audiosURL.appendingPathComponent(dataTable[indexPath.row])
        do {
            let filesList = try fileManager.contentsOfDirectory(atPath: albumURL.path)
            cell.countLb.text = String(filesList.count)
        } catch {
            print(error.localizedDescription)
        }
        
        cell.menuBtn.showsMenuAsPrimaryAction = true
        cell.menuBtn.menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Delete", handler: { (_) in
                do {
                    try self.fileManager.removeItem(at: albumURL)
                    dataTable.remove(at: indexPath.row)
                    print(dataTable)
                    self.userDefault.setValue(dataTable, forKey: "listAudiosAlbum")
                    tableView.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
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
                    let newFolderUrl = audiosURL.appendingPathComponent(textField!.text!)
                    do {
                        try self.fileManager.moveItem(at: oldFolderUrl, to: newFolderUrl)
                    } catch {
                        print(error.localizedDescription)
                    }
                    var dataTable = self.userDefault.stringArray(forKey: "listAudiosAlbum")
                    dataTable![indexPath.row] = (textField?.text)!
                    self.userDefault.set(dataTable, forKey: "listAudiosAlbum")
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }),
            
            UIAction(title: "Share", handler: { (_) in
                let selectedAlbumUrl = audiosURL.appendingPathComponent(dataTable[indexPath.row])
                var filesToShare: [Any] = []
                do {
                    let audiosName = try self.fileManager.contentsOfDirectory(atPath: selectedAlbumUrl.path)
                    for audioName in audiosName {
                        filesToShare.append(selectedAlbumUrl.appendingPathComponent(audioName))
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
        let nameArray = userDefault.stringArray(forKey: "listAudiosAlbum")
        let name = nameArray![indexPath.row]
        self.navigationController?.pushViewController(SubAudiosViewController.makeSelf(name: name), animated: true)
    }
    
    var defaultValue = ["listAudiosAlbum": []]
    let userDefault = UserDefaults.standard
    let fileManager = FileManager.default
    
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

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        //userDefault.removeObject(forKey: "listAudiosAlbum")
        tableView.register(UINib(nibName: "AudiosTableViewCell", bundle: nil), forCellReuseIdentifier: "myCell")
        tableView.rowHeight = 93
        userDefault.register(defaults: defaultValue)
        
        guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let audiosURL = documentURL.appendingPathComponent("Audios")
        
        if !self.fileManager.fileExists(atPath: audiosURL.path) {
            do {
                try self.fileManager.createDirectory(atPath: audiosURL.path, withIntermediateDirectories: true, attributes: nil)
                let audiosPath = audiosURL.path
                print("Path to documents directory: \(audiosPath)")
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
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listAudiosAlbum") else {
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
            
            var dataUserdefault = self.userDefault.stringArray(forKey: "listAudiosAlbum")
            dataUserdefault?.append((textField?.text)!)
            self.userDefault.set(dataUserdefault, forKey: "listAudiosAlbum")
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listAudiosAlbum") else {
                return
            }
            
            guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let audiosURL = documentURL.appendingPathComponent("Audios")
            for fileName in fileNames {
                let fileURL = audiosURL.appendingPathComponent(fileName).path
                if !self.fileManager.fileExists(atPath: fileURL) {
                    do {
                        try self.fileManager.createDirectory(atPath: fileURL, withIntermediateDirectories: true, attributes: nil)
                        let documentPath = documentURL.path
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
    
}
