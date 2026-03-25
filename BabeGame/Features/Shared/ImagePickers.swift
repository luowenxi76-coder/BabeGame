import PhotosUI
import SwiftUI
import UIKit

enum PhotoPickerService {
    static func loadImageData(from item: PhotosPickerItem) async throws -> Data {
        guard let loadedData = try await item.loadTransferable(type: Data.self) else {
            throw PhotoPickerError.loadFailed
        }

        return normalizedJPEGData(from: loadedData)
    }

    static func normalizedJPEGData(from data: Data) -> Data {
        guard let image = UIImage(data: data),
              let jpegData = image.jpegData(compressionQuality: 0.86) else {
            return data
        }
        return jpegData
    }
}

enum PhotoPickerError: Error {
    case loadFailed
}

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var imageData: Data?
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        private let parent: CameraPickerView

        init(parent: CameraPickerView) {
            self.parent = parent
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
            if let image, let data = image.jpegData(compressionQuality: 0.86) {
                parent.imageData = data
            }
            parent.dismiss()
        }
    }
}
