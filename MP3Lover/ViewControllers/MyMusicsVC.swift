//
//  SecondViewController.swift
//  MP3Lover
//
//  Created by tien dh on 12/14/16.
//  Copyright © 2016 tien dh. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import GoogleMobileAds

class MyMusicsVC: UIViewController,UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var audioFiles: [MP3CD] = []
    var selectedIndex = 0
    var managedContext:NSManagedObjectContext? = nil

    @IBOutlet weak var bannerView: GADBannerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "Thư Viện"
        let rightBarItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(pressEdit(_:)))
        self.navigationItem.rightBarButtonItem = rightBarItem
        tableView.allowsMultipleSelectionDuringEditing = true
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        self.managedContext = appDelegate.persistentContainer.viewContext
        
        bannerView.adUnitID = "ca-app-pub-6555883110005763/2846327534"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextVC:PlayerVC = segue.destination as! PlayerVC
        nextVC.audioObjects = self.audioFiles
        nextVC.currentPlayIndex = selectedIndex
    }
    
    func refreshData() -> () {
        do {
            audioFiles = try self.managedContext!.fetch(MP3CD.fetchRequest())
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func pressEdit(_ sender: Any) {
        if tableView.isEditing {
            tableView.isEditing = false
            let rightBarItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(pressEdit(_:)))
            self.navigationItem.rightBarButtonItem = rightBarItem
        } else {
            tableView.isEditing = true
            let rightBarItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(pressEdit(_:)))
            self.navigationItem.rightBarButtonItem = rightBarItem
        }
    }

    @IBAction func actionTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Lựa chọn", message: "", preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.addAction(UIAlertAction(title: "Chia sẻ qua email", style: UIAlertActionStyle.default, handler: {action in
            if self.tableView.isEditing {
                let selectedRows = self.tableView.indexPathsForSelectedRows
                var selectedAudios:[MP3CD] = []
                for indexPath in selectedRows! {
                    selectedAudios.append(self.audioFiles[indexPath.row])
                }
                if selectedAudios.count > 0 {
                    self.sendEmail(audios: selectedAudios)
                }
            }
        }))
        
//        alert.addAction(UIAlertAction(title: "Save to Library", style: UIAlertActionStyle.default, handler: {action in
//            let selectedRows = self.tableView.indexPathsForSelectedRows
//            for indexPath in selectedRows! {
//                let audioPath = CommonHelper.getDocumentFolderPath() + "/" + self.audioFiles[indexPath.row].mp3LocalLink!
//                UISaveVideoAtPathToSavedPhotosAlbum(audioPath, nil, nil, nil)
//            }
//            let completeAlert = UIAlertController(title: "Success", message: "Audio saved successfully!", preferredStyle: UIAlertControllerStyle.alert)
//            completeAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
//            self.present(completeAlert, animated: true, completion: nil)
//        }))
        alert.addAction(UIAlertAction(title: "Xoá", style: UIAlertActionStyle.destructive, handler: {action in
            let selectedRows = self.tableView.indexPathsForSelectedRows
            if self.tableView.isEditing {
                for indexPath in selectedRows! {
                    let audioPath = CommonHelper.getDocumentFolderPath() + "/" + self.audioFiles[indexPath.row].mp3LocalLink!
                    CommonHelper.removeFile(path: audioPath)
                    self.managedContext?.delete(self.audioFiles[indexPath.row])
                    do {
                        try self.managedContext?.save()
                    } catch {
                        NSLog("Error when deleting object from persistent store")
                    }
                    self.refreshData()
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {action in
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func sendEmail(audios:[MP3CD])
    {
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            //Set to recipients
//            mailComposer.setToRecipients(["your email address heres"])
            
            //Set the subject
            mailComposer.setSubject("Bài hát yêu thích")
            
            //set mail body
            mailComposer.setMessageBody("Chào bạn, đây là những bài hát ưa thích của mình, hy vọng bạn cũng thích nó :)", isHTML: true)
            let fileManager = FileManager.default
            for audio in audios {
                let audioPath = CommonHelper.getDocumentFolderPath() + "/" + audio.mp3LocalLink!
                let filecontent = fileManager.contents(atPath: audioPath)
                if (filecontent != nil) {
                    mailComposer.addAttachmentData(filecontent! , mimeType: " audio/mpeg4", fileName: audio.mp3Title! + ".m4a")
                }
            }
            //this will compose and present mail to user
            self.present(mailComposer, animated: true, completion: nil)
        } else {
            print("email is not supported")
        }
    }
    
    // MARK:UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            return
        }
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath.row
        self.performSegue(withIdentifier: "showMusicDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
            CommonHelper.removeFile(path: CommonHelper.getDocumentFolderPath() + "/" + self.audioFiles[indexPath.row].mp3LocalLink!)
            self.managedContext!.delete(self.audioFiles[indexPath.row])
            do {
                try self.managedContext?.save()
            } catch {
                NSLog("Error when deleting object from persistent store")
            }
            self.refreshData()
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK:UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MP3SavedItemCell")
        let titleLb = cell?.viewWithTag(10) as! UILabel
        let mp3cd = audioFiles[indexPath.row]
        titleLb.text = mp3cd.mp3Title
        
        return cell!
    }
    
    // MARK:MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

