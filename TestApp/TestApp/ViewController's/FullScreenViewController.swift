//
//  FullScreenViewController.swift
//  TestApp
//
//  Created by Герман on 12.01.22.
//

import UIKit

class FullScreenViewController: UIViewController {
    
    var imageView = UIImageView()
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        imageView.contentMode = .scaleAspectFit
        if let image = image{
            imageView.image = image
        }
        
    }
}
