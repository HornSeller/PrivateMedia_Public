//
//  DocumentsViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit
import GoogleMobileAds

class DocumentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, GADBannerViewDelegate {
    var bannerView: GADBannerView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albumNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataTable: [String] = userDefault.stringArray(forKey: "listDocumentsAlbum")!
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as! DocumentsTableViewCell
        cell.titleLb.text = albumNameArray[indexPath.row]
        cell.backgroundColor = UIColor.clear
        
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let documentsURL = documentURL?.appendingPathComponent("Documents")
        let folderURL = documentsURL?.appendingPathComponent(albumNameArray[indexPath.row])
        do {
            let attrs = try fileManager.attributesOfItem(atPath: folderURL!.path) as NSDictionary
            
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, yyyy"
            let formattedDate = formatter.string(from: attrs.fileCreationDate()!)
            cell.dateLb.text = formattedDate
            cell.sizeLb.text = fileSize(fromPath: folderURL!.path)
        } catch {
            print(error.localizedDescription)
        }
        
        cell.menuBtn.showsMenuAsPrimaryAction = true
        cell.menuBtn.menu = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "Delete", handler: { (_) in
                do {
                    try self.fileManager.removeItem(at: folderURL!)
                    self.albumNameArray.remove(at: indexPath.row)
                    print(self.albumNameArray)
                    self.userDefault.setValue(self.albumNameArray, forKey: "listDocumentsAlbum")
                    tableView.reloadData()
                } catch {
                    print(error.localizedDescription)
                }
            }),
            
            UIAction(title: "Rename", handler: { (_) in
                let oldFolderUrl = folderURL
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
                    let newFolderUrl = documentsURL!.appendingPathComponent(textField!.text!)
                    do {
                        try self.fileManager.moveItem(at: oldFolderUrl!, to: newFolderUrl)
                    } catch {
                        print(error.localizedDescription)
                    }
                    var dataTable = self.userDefault.stringArray(forKey: "listDocumentsAlbum")
                    dataTable![indexPath.row] = (textField?.text)!
                    self.userDefault.set(dataTable, forKey: "listDocumentsAlbum")
                    self.albumNameArray = self.userDefault.stringArray(forKey: "listDocumentsAlbum")!
                    self.tableView.reloadData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alert, animated: true)
            }),
            
            UIAction(title: "Share", handler: { (_) in
                let selectedAlbumUrl = documentsURL!.appendingPathComponent(dataTable[indexPath.row])
                var filesToShare: [Any] = []
                do {
                    let documentsName = try self.fileManager.contentsOfDirectory(atPath: selectedAlbumUrl.path)
                    for documentName in documentsName {
                        filesToShare.append(selectedAlbumUrl.appendingPathComponent(documentName))
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
        let name = albumNameArray[indexPath.row]
        self.navigationController?.pushViewController(SubDocumentsViewController.makeSelf(name: name), animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var filteredArray: [String] = []
        filteredArray.removeAll()
        let arr = userDefault.stringArray(forKey: "listDocumentsAlbum")!
        filteredArray = arr.filter { $0.lowercased().contains(searchText.lowercased()) }
        albumNameArray = filteredArray
        tableView.reloadData()
        if searchText == "" {
            albumNameArray = userDefault.stringArray(forKey: "listDocumentsAlbum")!
            tableView.reloadData()
        }
        
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        searchBar.text = ""
        albumNameArray = userDefault.stringArray(forKey: "listDocumentsAlbum")!
        tableView.reloadData()
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

    var defaultValue = ["listDocumentsAlbum": []]
    let userDefault = UserDefaults.standard
    let fileManager = FileManager.default
    var albumNameArray: [String] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
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
        //userDefault.removeObject(forKey: "listDocumentsAlbum")
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font = UIFont.systemFont(ofSize: 14)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
                    NSAttributedString.Key.foregroundColor: UIColor.white,
                    NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)
                ]
        
        tableView.register(UINib(nibName: "DocumentsTableViewCell", bundle: nil), forCellReuseIdentifier: "myCell")
        tableView.rowHeight = 73
        
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            let placeholderAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.white, // Màu sắc mong muốn
                .font: UIFont.systemFont(ofSize: 14) // Font chữ mong muốn
            ]
            textFieldInsideSearchBar.attributedPlaceholder = NSAttributedString(string: "Search", attributes: placeholderAttributes)
        }
        
        guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        print(documentURL)
        let documentsURL = documentURL.appendingPathComponent("Documents")
        
        if !self.fileManager.fileExists(atPath: documentsURL.path) {
            do {
                try self.fileManager.createDirectory(atPath: documentsURL.path, withIntermediateDirectories: true, attributes: nil)
                let documentPath = documentsURL.path
                print("Path to documents directory: \(documentPath)")
            } catch {
                print("Error creating directory: \(error)")
            }
        }
        albumNameArray = userDefault.stringArray(forKey: "listDocumentsAlbum")!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        albumNameArray = userDefault.stringArray(forKey: "listDocumentsAlbum")!
        tableView.reloadData()
    }
    
    @IBAction func createAlbumBtnTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Create album", message: nil, preferredStyle: .alert)
        alert.addTextField(){ (textfield) in
            textfield.placeholder = "Enter album name here"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listDocumentsAlbum") else {
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
            
            var dataUserdefault = self.userDefault.stringArray(forKey: "listDocumentsAlbum")
            dataUserdefault?.append((textField?.text)!)
            self.userDefault.set(dataUserdefault, forKey: "listDocumentsAlbum")
            self.albumNameArray = self.userDefault.stringArray(forKey: "listDocumentsAlbum")!
            
            guard let fileNames = self.userDefault.stringArray(forKey: "listDocumentsAlbum") else {
                return
            }
            
            guard let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            
            let documentsURL = documentURL.appendingPathComponent("Documents")
            for fileName in fileNames {
                let fileURL = documentsURL.appendingPathComponent(fileName).path
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
    
    @IBAction func backBtnTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    func fileSize(fromPath path: String) -> String? {
        guard let size = try? FileManager.default.attributesOfItem(atPath: path)[FileAttributeKey.size],
            let fileSize = size as? UInt64 else {
            return nil
        }

        // bytes
        if fileSize < 1023 {
            return String(format: "%lu bytes", CUnsignedLong(fileSize))
        }
        // KB
        var floatSize = Float(fileSize / 1024)
        if floatSize < 1023 {
            return String(format: "%.1f KB", floatSize)
        }
        // MB
        floatSize = floatSize / 1024
        if floatSize < 1023 {
            return String(format: "%.1f MB", floatSize)
        }
        // GB
        floatSize = floatSize / 1024
        return String(format: "%.1f GB", floatSize)
    }
    
}
