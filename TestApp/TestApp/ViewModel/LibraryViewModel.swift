//
//  LibraryViewModel.swift
//  TestApp
//
//  Created by Герман on 16.01.22.
//

import Foundation
import UIKit
import Firebase
import FirebaseStorage

protocol LibraryViewModelDelegate: AnyObject{
    func reloadData()
    func showError(string: String)
}

class LibraryViewModel{
    
    weak var delegate: LibraryViewModelDelegate?
    
    private let storageRef = Storage.storage().reference()
    private var library = [Library]()
    private var locations = [String]()
    private var imageOfLocations = [UIImage]()
    
    init(delegate: LibraryViewModelDelegate){
        self.delegate = delegate
    }
    
    func getLibrary(){
        storageRef.listAll {
            locations, error in
            if let error = error{
                print("\(error)")
                self.delegate?.showError(string: "\(error)")
            } else {
                for i in locations.prefixes.indices{
                    self.getImagesOfLibriraries(locations: locations.prefixes[i].name) {
                        images, error in
                        if let error = error{
                            self.delegate?.showError(string: "\(error)")
                        } else {
                            self.library.append(Library(location: locations.prefixes[i].name, imageOfLocations: images))
                            self.delegate?.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func getImagesOfLibriraries(locations: String, completion: @escaping([UIImage], Error?) -> Void){
        var imageCache = [UIImage]()
        storageRef.child(locations).listAll {
            itemsOfImages, error in
            if let error = error{
                print("\(error)")
                self.delegate?.showError(string: "\(error)")
                completion([], error)
            } else {
                for i in itemsOfImages.items.indices{
                    itemsOfImages.items[i].getData(maxSize: 1 * 1024 * 1024) {
                        data, error in
                        if let error = error{
                            print("\(error)")
                        } else if let data = data {
                            imageCache.append(UIImage(data: data)!)
                            if imageCache.count == itemsOfImages.items.count{
                                self.imageOfLocations = imageCache
                                imageCache = []
                                completion(self.imageOfLocations, nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func saveImage(location: String?, imageData: Data){
        if let location = location{
            self.storageRef.child(location).child(location + "\(Int.random(in: 10...100))" + "\(randomString(length: 8))" + "\(Int.random(in: 10...100))" + "\(randomString(length: 8)).png").putData(imageData, metadata: nil, completion: {
            metaData, error in
                if let error = error{
                    print("\(error)")
                } else {
                    self.delegate?.reloadData()
                }
            })
        }
    }
    
    func saveNewFolder(location: String?, imageData: Data){
        if let location = location{
            self.storageRef.child(location).child(location + "\(Int.random(in: 10...100))" + "\(randomString(length: 8))" + "\(Int.random(in: 10...100))" + "\(randomString(length: 8)).png").putData(imageData, metadata: nil, completion: {
            metaData, error in
                if let error = error{
                    print("\(error)")
                } else {
                    print("OK!")
                }
            })
        }
    }
    
    func deleteOldFolder(location: String?){
        if let location = location{
            storageRef.child(location).listAll {
                result, error in
                if let error = error{
                    print("\(error)")
                } else {
                    for i in result.items.indices{
                        self.storageRef.child(location).child(result.items[i].name).delete {
                            error in
                            if let error = error{
                                print("\(error)")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getLocation(index: Int) -> String{
        return library[index].location
    }
    
    func getCountOfLibrary() -> Int{
        return library.count
    }
    
    func getImages(index: Int) -> [UIImage]{
        return library[index].imageOfLocations
    }
    
    func getCountOfImages(index: Int) -> Int{
        return library[index].imageOfLocations.count
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
