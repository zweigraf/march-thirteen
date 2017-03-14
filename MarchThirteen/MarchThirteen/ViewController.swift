//
//  ViewController.swift
//  MarchThirteen
//
//  Created by Luis Reisewitz on 13.03.17.
//  Copyright © 2017 ZweiGraf. All rights reserved.
//

import UIKit
import PureLayout
import Sensitive

class ViewController: UIViewController {

    let serviceManager = ServiceManager()
    let counterlabel = UILabel()
    
    override func loadView() {
        let newView = UIView()
        newView.backgroundColor = .green
        
        newView.addSubview(counterlabel)
        counterlabel.autoCenterInSuperview()
        counterlabel.isUserInteractionEnabled = true
        counterlabel.text = String(0)
        view = newView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        counterlabel.onTap { [weak self] _ in
            let text = self!.counterlabel.text!
            let number = Int(text)! + 1
            self?.counterlabel.text = "\(number)"
            self?.serviceManager.send(counter: number)
        }
        serviceManager.delegate = self
    }


}

// MARK: - ServiceManagerDelegate
extension ViewController: ServiceManagerDelegate {
    func receivedCounter(_ counter: Int) {
        DispatchQueue.main.async {
            self.counterlabel.text = "\(counter)"
        }
    }
}

