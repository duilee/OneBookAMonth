import SwiftUI
import AVFoundation

struct ImagePickerView: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    var compressionQuality: CGFloat
    var targetHeight: CGFloat
    
    @State private var showImagePicker = true
    @State private var permissionDenied = false
    
    // Declare ImagePicker variable for reuse
    private var imagePicker: ImagePicker {
        ImagePicker(
            image: $image,
            isPresented: $showImagePicker,
            compressionQuality: compressionQuality,
            targetHeight: targetHeight
        )
    }
    
    var body: some View {
        ZStack {
            // Always show the image picker
            imagePicker
            
            // Show overlay only if permission was previously denied
            if permissionDenied {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("Camera Access Required")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Please enable camera access in Settings to capture photos.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 40)
                    
                    Button("Open Settings") {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.secondary)
                }
                .padding(40)
                .background(Color.white)
                .cornerRadius(16)
            }
        }
        .background(Color.white)
        .task {
            await checkAndRequestCameraPermission()
        }
        .onChange(of: showImagePicker) { _, newValue in
            if !newValue {
                isPresented = false
            }
        }
    }
    
    func checkAndRequestCameraPermission() async {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .notDetermined:
            // Request permission - this will show the system dialog
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run {
                if !granted {
                    permissionDenied = true
                }
            }
        case .denied, .restricted:
            await MainActor.run {
                permissionDenied = true
            }
        case .authorized:
            // Permission already granted, proceed
            break
        @unknown default:
            break
        }
    }
} 
