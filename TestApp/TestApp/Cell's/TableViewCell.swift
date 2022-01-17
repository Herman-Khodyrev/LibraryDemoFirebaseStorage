//
//  TableViewCell.swift
//  TestApp
//
//  Created by Герман on 3.01.22.
//

import UIKit

class TableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var view = UIView()
    var viewBackground = UIView()
    var viewShadow = UIView()
    var textField = UITextField()
    var buttonAdd = UIButton()
    var collectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 110, height: 110)
        collection.register(CollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collection
    }()
    
    var library: LibraryViewModel?
    
    var indicator: Int?
    var images: [UIImage]?
    var addImage: UIImage?

    weak var delegate : VCDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.addSubview(viewBackground)
        viewBackground.translatesAutoresizingMaskIntoConstraints = false
        viewBackground.backgroundColor = .white
        viewBackground.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        viewBackground.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        viewBackground.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        viewBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        viewBackground.layer.masksToBounds = true
        viewBackground.layer.cornerRadius = 20

        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
        view.topAnchor.constraint(equalTo: viewBackground.topAnchor, constant: 14).isActive = true
        view.leadingAnchor.constraint(equalTo: viewBackground.leadingAnchor, constant: 12).isActive = true
        view.trailingAnchor.constraint(equalTo: viewBackground.trailingAnchor, constant: -12).isActive = true
        view.bottomAnchor.constraint(equalTo: viewBackground.bottomAnchor, constant: -14).isActive = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 20
        
        view.addSubview(buttonAdd)
        buttonAdd.translatesAutoresizingMaskIntoConstraints = false
        buttonAdd.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        buttonAdd.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        buttonAdd.heightAnchor.constraint(equalToConstant: 30).isActive = true
        buttonAdd.widthAnchor.constraint(equalToConstant: 30).isActive = true
        buttonAdd.backgroundColor = UIColor(patternImage: UIImage(named: "buttonAdd")!)
        buttonAdd.addTarget(self, action: #selector(openPhotoLibraryButton), for: .touchUpInside)
        
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerYAnchor.constraint(equalTo: buttonAdd.centerYAnchor, constant: 0).isActive = true
        textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        textField.trailingAnchor.constraint(equalTo: buttonAdd.leadingAnchor, constant: -10).isActive = true
        textField.textColor = UIColor(red: 0.525, green: 0.58, blue: 0.584, alpha: 1)
        textField.addTarget(self, action: #selector(startEditingTest), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(endEditingTest), for: .editingDidEndOnExit)
        textField.backgroundColor = .none
        textField.font = UIFont(name: "Ubuntu-Regular", size: 17)
        textField.placeholder = "Haзвание локации"

        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: textField.topAnchor, constant: 40).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        collectionView.backgroundColor = .clear
        
        if let addImage = addImage{                 // костыль, но надеюсь простите дерзость наглого юнца
            images?.append(addImage)                // все сохраняется в firebase
            collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        if let image = images?[indexPath.row]{
            cell.imageView.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedImage = images?[indexPath.row]{
            delegate?.openFullScreenViewController?(image: selectedImage)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width / 3) - 5, height: (collectionView.bounds.width / 3) - 5)
    }
    
    @objc func openPhotoLibraryButton(sender: AnyObject) {
        if let location = library?.getLocation(index: indicator ?? 0), let images = library?.getImages(index: indicator ?? 0), let indicator = indicator{
            delegate?.openUserPhotoLibrary(location: location, images: images, indicator: indicator)
        }
    }
    
    @objc func startEditingTest(){
        var location: String?
        location = textField.text
        print(location)
        delegate?.deleteOldFolder?(location: location ?? "")
    }
    
    @objc func endEditingTest(){
        var string: String?
        string = textField.text
        print(string)
        delegate?.saveNewFolder?(location: string ?? "trash", images: images ?? [])
    }
}
