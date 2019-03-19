//  ImagePickerController.swift
//  ImageRow ( https://github.com/EurekaCommunity/ImageRow )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Eureka
import Foundation
import AssetsLibrary

/// Selector Controller used to pick an image
open class ImagePickerController: UIImagePickerController, TypedRowControllerType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<UIImage>!
    
    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> ())?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    public var validatePhotoWasTakenToday: Bool = false
    
    open func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if validatePhotoWasTakenToday {
            if info[.mediaMetadata] != nil { // user took pic
                (row as? ImageRow)?.imageURL = info[.referenceURL] as? URL
                row.value = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
                onDismissCallback?(self)
            } else {
                if let url = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
                    let assetsLibrary = ALAssetsLibrary()
                    assetsLibrary.asset(for: url, resultBlock: { (asset: ALAsset!) -> Void in
                        if let date = asset.value(forProperty: ALAssetPropertyDate) as? Date {
                            if date.challengeDate().isToday {
                                (self.row as? ImageRow)?.imageURL = info[.referenceURL] as? URL
                                self.row.value = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
                                self.onDismissCallback?(self)
                            } else {
                                self.presentAlert(title: "Photo Not Taken Today", message: "A photo can only be posted for a workout if it was taken today.")
                            }
                        }
                    }) { (error: Error?) -> Void in
                        self.presentAlert(title: "Permission Required", message: "Permission was be given for photos blah blah blah.")
                    }
                }
            }
        } else {
            (row as? ImageRow)?.imageURL = info[.referenceURL] as? URL
            row.value = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage
            onDismissCallback?(self)
        }
    }

    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        onDismissCallback?(self)
    }
    
}
