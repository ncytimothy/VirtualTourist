//
//  ImageCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Timothy Ng on 4/15/18.
//  Copyright © 2018 Timothy Ng. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.color = UIColor.red
        return loader
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
      //TODO: Constraints for ImageView
   
    func setupViews() {
        
        addSubview(imageView)
        addSubview(loader)
       
        loader.startAnimating()
        
        addConstraintsWith(format: "H:|[v0]|", views: loader)
        addConstraintsWith(format: "H:|[v0]|", views: imageView)
        
        addConstraintsWith(format: "V:|[v0]|", views: loader)
        addConstraintsWith(format: "V:|[v0]|", views: imageView)
        
        
        
    }
}

extension UIView {
    
    func addConstraintsWith(format: String, views: UIView...) {
        var viewsDictionary = [String:UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: [], metrics: nil, views: viewsDictionary))
    }
}
