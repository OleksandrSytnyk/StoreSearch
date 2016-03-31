//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by MyMacbook on 3/31/16.
//  Copyright © 2016 Oleksandr. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    deinit {
    print("deinit \(self)")// to check if the controller is actually disposed
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
