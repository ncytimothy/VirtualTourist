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
        loader.color = UIColor.white
        return loader
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.backgroundColor = UIColor.white
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let colorOverlay: UIView = {
        let colorOverlay = UIView()
         colorOverlay.backgroundColor = UIColor.rgb(red: 55, green: 54, blue: 56, alpha: 0.85)
        return colorOverlay
    }()
    
    let checkmark: UIImageView = {
        let checkmark = UIImageView()
        checkmark.image = UIImage(named: "check")
        return checkmark
    }()
    
    func setupViews() {
        
        addSubview(imageView)
        addSubview(colorOverlay)
        addSubview(loader)
        addSubview(checkmark)
        
        checkmark.isHidden = true
        loader.startAnimating()
        
        addConstraintsWith(format: "H:|[v0]|", views: loader)
        addConstraintsWith(format: "H:|[v0]|", views: imageView)
        addConstraintsWith(format: "H:|[v0]|", views: colorOverlay)
        addConstraintsWith(format: "H:[v0]-8-|", views: checkmark)
        
        addConstraintsWith(format: "V:|[v0]|", views: loader)
        addConstraintsWith(format: "V:|[v0]|", views: imageView)
        addConstraintsWith(format: "V:|[v0]|", views: colorOverlay)
        addConstraintsWith(format: "V:[v0]-8-|", views: checkmark)
    }
}

extension UIColor {
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
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
