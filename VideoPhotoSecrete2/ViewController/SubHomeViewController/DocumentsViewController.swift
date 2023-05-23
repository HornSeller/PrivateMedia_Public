//
//  DocumentsViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit

class DocumentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albumNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    var defaultValue = ["listDocumentsAlbum": []]
    let userDefault = UserDefaults.standard
    let fileManager = FileManager.default
    var albumNameArray: [String] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let alert = UIAlertController(title: "Create album", message: "", preferredStyle: .alert)
        alert.addTextField(){ (textfield) in
            textfield.placeholder = "Enter album name here"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .cancel, handler: { [weak alert] (_) in
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
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
