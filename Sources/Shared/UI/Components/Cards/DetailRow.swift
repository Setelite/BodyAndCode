//
//  DetailRow.swift
//  BodyCodeApp
//
//  Created by MAXIM GORNOSTAEV on 1/9/26.
//

import SwiftUI

struct DetailRow: View {
    let title: String
    let value: String
    var icon: Image? = nil

    var body: some View {
        HStack(spacing: 12) {

            if let icon {
                icon
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
            }

            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
