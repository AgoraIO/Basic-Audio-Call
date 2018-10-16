//
//  MainViewController.swift
//  OpenVoiceCall
//
//  Created by GongYuhua on 16/8/17.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var roomNameTextField: UITextField!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier , segueId == "mainToRoom",
            let roomName = sender as? String else {
            return
        }
        
        let roomVC = segue.destination as! RoomViewController
        roomVC.roomName = roomName
        roomVC.delegate = self
    }
    
    @IBAction func doRoomNameTextFieldEditing(_ sender: UITextField) {
        if let text = sender.text , !text.isEmpty {
            let legalString = MediaCharacter.updateToLegalMediaString(from: text)
            sender.text = legalString
        }
    }
    
    @IBAction func doJoinPressed(_ sender: UIButton) {
        enter(roomName: roomNameTextField.text)
    }
}

private extension MainViewController {
    func enter(roomName: String?) {
        guard let roomName = roomName , !roomName.isEmpty else {
            return
        }
        performSegue(withIdentifier: "mainToRoom", sender: roomName)
    }
}

extension MainViewController: RoomVCDelegate {
    func roomVCNeedClose(_ roomVC: RoomViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        enter(roomName: textField.text)
        return true
    }
}
