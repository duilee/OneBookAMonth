//
//  ProgressTagView.swift
//  OneBookAMonth
//
//  Created by delightroom on 2/8/25.
//

import SwiftUI

struct ProgressTagView: View {
    let progress: Float
    
    var body: some View {
        if progress >= 1.0 {
            Text("DONE!")
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
        } else if progress > 0.8 {
            Text("ALMOST THERE!")
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.2))
                .cornerRadius(12)
        } else if progress > 0.5 {
            Text("HALFWAY DONE!")
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(12)
        } else if progress > 0.3 {
            Text("KEEP GOING!")
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
        } else if progress > 0.0 {
            Text("ON A ROLL!")
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.2))
                .cornerRadius(12)
        } else if progress == 0.0 {
            Text("GET STARTED NOW!")
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.2))
                .cornerRadius(12)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressTagView(progress: 0.0)
        ProgressTagView(progress: 0.1)
        ProgressTagView(progress: 0.4)
        ProgressTagView(progress: 0.6)
        ProgressTagView(progress: 0.9)
        ProgressTagView(progress: 1.0)
    }
}
