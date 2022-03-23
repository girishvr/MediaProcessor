//
//  ViewController.swift
//  MediaProcessor
//
//  Created by Girish Rathod on 23/03/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func recordVideo(_ sender: UIButton){
        
    }

}


extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }

}

/**
 DispatchQueue.background(delay: 3.0, background: {
     // do something in background
 }, completion: {
     // when background job finishes, wait 3 seconds and do something in main thread
 })

 DispatchQueue.background(background: {
     // do something in background
 }, completion:{
     // when background job finished, do something in main thread
 })

 DispatchQueue.background(delay: 3.0, completion:{
     // do something in main thread after 3 seconds
 })
 */
