//
//  StatItemView.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/29/25.
//

import SwiftUI

struct StatItemView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    StatItemView(value: "100", label: "Read books")
}
