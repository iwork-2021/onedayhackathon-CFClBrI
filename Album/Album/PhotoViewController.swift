//
//  PhotoViewController.swift
//  Album
//
//  Created by nju on 2021/12/21.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet weak var contentPhoto: UIImageView!
    var photo: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if photo != nil {
            contentPhoto.image = photo
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
