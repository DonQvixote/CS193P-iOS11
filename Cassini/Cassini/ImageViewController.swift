//
//  ImageViewController.swift
//  Cassini
//
//  Created by 夏语诚 on 2018/3/21.
//  Copyright © 2018年 Banana. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }

//    @IBOutlet weak var imageView: UIImageView!
    
    var imageView = UIImageView()
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView.contentSize = imageView.frame.size
        }
    }
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 1 / 25
            scrollView.maximumZoomScale = 1.0
            scrollView.delegate = self
            scrollView.addSubview(imageView)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if imageURL == nil {
            imageURL = DemoURLs.stanford
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if imageView.image == nil {
            fetchImage()
        }
    }
    
    private func fetchImage() {
        if let url = imageURL {
            let urlContents = try? Data(contentsOf: url)
            if let imageData = urlContents {
                image = UIImage(data: imageData)
            }
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
