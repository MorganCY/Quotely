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

    func createImage(
        image: UIImage,
        completion: @escaping StatusCompletion
    ) {

        let scaledImage = image.scale(newWidth: 320.0)

        let imageStorageRef = imagePath.child("\(Date().millisecondsSince1970).jpg")

        guard let imageData = scaledImage.jpegData(compressionQuality: 0.3) else {

            return
        }

        let metadata = StorageMetadata()

        metadata.contentType = "image/jpg"

        let uploadTask = imageStorageRef.putData(imageData, metadata: metadata)

        uploadTask.observe(.success) { (snapshot) in

            snapshot.reference.downloadURL(completion: { (url, error) in

                guard let urlString = url?.absoluteString else {

                    return
                }

                if let error = error {

                    completion(.failure(error))

                } else {

                    completion(.success(urlString))
                }
            })
        }

        uploadTask.observe(.failure) { (snapshot) in

            if let error = snapshot.error {

                print(error)
            }
        }
    }

    func deleteImage(
        imageUrl: String,
        completion: @escaping StatusCompletion
    ) {

        if imageUrl == "" {

            completion(.success("There was no image so no need to delete"))

        } else {

            let reference = imagePath.storage.reference(forURL: imageUrl)

            reference.delete { error in

                if let error = error {

                    completion(.failure(error))

                } else {

                    completion(.success("Image was deleted from storage"))
                }
            }
        }
    }
}
