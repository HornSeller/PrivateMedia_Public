//
//  AudiosViewController.swift
//  VideoPhotoSecrete2
//
//  Created by Macmini on 10/05/2023.
//

import UIKit

class AudiosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataTable = userDefault.stringArray(forKey: "listAudiosAlbum")
        return dataTable!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataTable = userDefault.stringArray(forKey: "listAudiosAlbum")
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! AudiosTableViewCell
        cell.backgroundColor = UIColor.clear
        cell.titleLb.text = dataTable![indexPath.row]
        let documentURL = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let audiosURL = documentURL!.appendingPathComponent("Audios")
        let albumURL = audiosURL.appendingPathComponent(dataTable![indexPath.row])
        do {
            let filesList = try fileManager.contentsOfDirectory(atPath: albumURL.path)
            cell.countLb.text = String(filesList.count)
        } catch {
            print(error.localizedDescription)
        }
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

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let alert = UIAlertController(title: "Create album", message: "", preferredStyle: .alert)
        alert.addTextField(){ (textfield) in
            textfield.placeholder = "Enter album name here"
        }
        alert.addAction(UIAlertAction(title: "Create", style: .cancel, handler: { [weak alert] (_) in
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
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        self.present(alert, animated: true)
    }
    
}
