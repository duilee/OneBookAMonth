import SwiftUI
import UIKit
import AVFoundation

extension UIImage {
    func resized(toHeight targetHeight: CGFloat) -> UIImage? {
        // Calculate the scale factor based on the target height
        let scaleFactor = targetHeight / self.size.height

        // Calculate the new width to maintain the aspect ratio
        let targetWidth = self.size.width * scaleFactor

        // Create a new size with the calculated width and target height
        let newSize = CGSize(width: targetWidth, height: targetHeight)

        // Create a new image context
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))

        // Get the new image from the context
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    var compressionQuality: CGFloat
    var targetHeight: CGFloat

    // Method to check and request camera permission
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            completion(true)

        case .notDetermined:
            // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(granted)
            }

        case .denied, .restricted:
            // The user has previously denied access.
            completion(false)

        @unknown default:
            completion(false)
        }
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                // Resize the image to a specific height
                let resizedImage = uiImage.resized(toHeight: parent.targetHeight)

                // Convert to PNG
                if let resizedImage = resizedImage, let pngData = resizedImage.pngData() {
                    parent.image = UIImage(data: pngData)
                }
            }

            picker.dismiss(animated: true)
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            parent.isPresented = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera

        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
} 
