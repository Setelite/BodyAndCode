//
//  TimeSlotButton.swift
//  BodyCodeApp
//
//  Created by MAXIM GORNOSTAEV on 1/9/26.
//

import SwiftUI

struct TimeSlotButton: View {
    let time: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(time)
                .font(.subheadline)
                .frame(width: 70, height: 40)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
