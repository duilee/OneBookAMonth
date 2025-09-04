//
//  FullScreenImageView.swift
//  OneBookAMonth
//
//  Created by delightroom on 8/2/25.
//

import SwiftUI

struct FullScreenImageView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()
                .onAppear {
                    print("FullScreenImageView appeared")
                    print("Image size: \(image.size)")
                }
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.7))
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding()
                }
                Spacer()
            }
            .zIndex(1)
            
            // Zoomable Image
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaleEffect(scale)
                .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
                .onTapGesture(count: 2) {
                    withAnimation(.spring()) {
                        if scale > 1 {
                            scale = 1
                            lastScale = 1
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2
                            lastScale = 2
                        }
                    }
                }
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { value in
                                lastScale = scale
                                
                                // Limit zoom
                                if scale < 1 {
                                    withAnimation(.spring()) {
                                        scale = 1
                                        lastScale = 1
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                } else if scale > 5 {
                                    scale = 5
                                    lastScale = 5
                                }
                            },
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                let newOffset = CGSize(
                                    width: offset.width + value.translation.width,
                                    height: offset.height + value.translation.height
                                )
                                
                                // Calculate image bounds to constrain movement
                                let imageSize = image.size
                                let screenSize = UIScreen.main.bounds.size
                                
                                // Calculate actual displayed image size
                                let imageAspectRatio = imageSize.width / imageSize.height
                                let screenAspectRatio = screenSize.width / screenSize.height
                                
                                let displayedImageSize: CGSize
                                if imageAspectRatio > screenAspectRatio {
                                    // Image is wider - constrained by screen width
                                    displayedImageSize = CGSize(
                                        width: screenSize.width,
                                        height: screenSize.width / imageAspectRatio
                                    )
                                } else {
                                    // Image is taller - constrained by screen height
                                    displayedImageSize = CGSize(
                                        width: screenSize.height * imageAspectRatio,
                                        height: screenSize.height
                                    )
                                }
                                
                                // Calculate scaled image size
                                let scaledImageSize = CGSize(
                                    width: displayedImageSize.width * scale,
                                    height: displayedImageSize.height * scale
                                )
                                
                                // Calculate maximum allowed offset
                                let maxOffsetX = max(0, (scaledImageSize.width - screenSize.width) / 2)
                                let maxOffsetY = max(0, (scaledImageSize.height - screenSize.height) / 2)
                                
                                // Constrain offset to image bounds
                                let constrainedOffset = CGSize(
                                    width: max(-maxOffsetX, min(maxOffsetX, newOffset.width)),
                                    height: max(-maxOffsetY, min(maxOffsetY, newOffset.height))
                                )
                                
                                offset = constrainedOffset
                                lastOffset = constrainedOffset
                            }
                    )
                )
        }
        //.statusBarHidden(true)
    }
}

// MARK: - Preview

#Preview {
    FullScreenImageView(
        image: UIImage(systemName: "photo.fill")!,
        isPresented: .constant(true)
    )
}
