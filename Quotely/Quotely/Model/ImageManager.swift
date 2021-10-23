//
//  ImageManager.swift
//  Quotely
//
//  Created by Zheng-Yuan Yu on 2021/10/19.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ImageManager {

    static let shared = ImageManager()

    private init() {}

    let imagePath = Storage.storage().reference()

    func uploadImage(image: UIImage, postHandler: @escaping (Result<String, Error>) -> Void) {

        let scaledImage = image.scale(newWidth: 320.0)

        let imageStorageRef = imagePath.child("\(Date().millisecondsSince1970).jpg")

        guard let imageData = scaledImage.jpegData(compressionQuality: 0.5) else {

            return
        }

        let metadata = StorageMetadata()

        metadata.contentType = "image/jpg"

        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)

        uploadTask.observe(.success) { (snapshot) in

            // Enable this after implementing firestore Auth
            /*
             guard let uid = Auth.auth().currentUser?.uid else {
             return
             }
             */

            snapshot.reference.downloadURL(completion: { (url, error) in

                guard let urlString = url?.absoluteString else {

                    return
                }

                if let error = error {

                    postHandler(.failure(error))

                } else {

                    postHandler(.success(urlString))
                }
            })
        }

        uploadTask.observe(.failure) { (snapshot) in

            if let error = snapshot.error {

                print(error.localizedDescription)
            }
        }
    }

    func deleteImage(imageUrl: String, removeUrlHandler: @escaping () -> Void) {

        let reference = imagePath.storage.reference(forURL: imageUrl)

        reference.delete { error in

            if let error = error {

                print(error.localizedDescription)

            } else {

                print("Delete image successfully")

                removeUrlHandler()
            }
        }
    }
}
