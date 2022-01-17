//
//  ViewController.swift
//  TestApp
//
//  Created by Герман on 3.01.22.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, VCDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, LibraryViewModelDelegate{
    
    var imageView = UIImageView()
    var labelTitle = UILabel()// подумать
    var imageTitle = UIImage(named: "imageTitle")
    var tableView : UITableView = {
        let table = UITableView()
        table.register(TableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var library: LibraryViewModel?
    
    var location: String?
    var images: [UIImage]?
    var addImage : UIImage?
    var indicator : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 89).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.image = UIImage(named: "imageTitle")
        
        view.addSubview(labelTitle)
        labelTitle.translatesAutoresizingMaskIntoConstraints = false
        labelTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 86).isActive = true
        labelTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelTitle.heightAnchor.constraint(equalToConstant: 45).isActive = true
        labelTitle.backgroundColor = .clear
        labelTitle.textAlignment = .center
        labelTitle.font = UIFont(name: "Oswald-ExtraLight", size: 25)
        labelTitle.text = "ЛОКАЦИИ"
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.labelTitle.bottomAnchor, constant: 45).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        library = LibraryViewModel(delegate: self)
        library?.getLibrary()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return library?.getCountOfLibrary() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.backgroundColor = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1)
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        if let libraryOption = library{
            cell.textField.text = libraryOption.getLocation(index: indexPath.row)
            cell.library = libraryOption
            cell.indicator = indexPath.row
            cell.images = libraryOption.getImages(index: indexPath.row)
            cell.delegate = self
            if let addImage = addImage, indicator == indexPath.row{
                cell.addImage = addImage
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height / 1.9
    }
    
    func translateToIphoneWidth(size: CGFloat) -> CGFloat{
        return (view.frame.size.width * size) / 750
    }
    
    func openUserPhotoLibrary(location: String, images: [UIImage], indicator: Int) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
        self.location = location
        self.images = images
        self.indicator = indicator
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        guard let imageData = image.jpegData(compressionQuality: 0.99) else {return}
        library?.saveImage(location: location, imageData: imageData)
        addImage = UIImage(data: imageData)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func openFullScreenViewController(image: UIImage) {
        let fullScreenViewController = FullScreenViewController()
        let navVC = UINavigationController(rootViewController: fullScreenViewController)
        fullScreenViewController.image = image
        present(navVC, animated: true, completion: nil)
    }
    
    func saveNewFolder(location: String, images: [UIImage]) {
        for i in images.indices{
            if let data = images[i].jpegData(compressionQuality: 0.99){
                library?.saveNewFolder(location: location, imageData: data)
            }
        }
    }
    
    func deleteOldFolder(location: String) {
        library?.deleteOldFolder(location: location + "/")
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func showError(string: String) {
        present(Errors.shared.getError(stringOfError: string), animated: true, completion: nil)
    }
}


@objc protocol VCDelegate{
    func openUserPhotoLibrary(location: String, images: [UIImage], indicator: Int)
    @objc optional func openFullScreenViewController(image: UIImage)
    @objc optional func addImage(images: [UIImage])
    @objc optional func saveNewFolder(location: String, images: [UIImage])
    @objc optional func deleteOldFolder(location: String)
}

