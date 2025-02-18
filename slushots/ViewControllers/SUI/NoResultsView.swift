//
//  NoResultsView.swift
//  slushots
//
//  Created by Anatoliy Petrov on 7.12.24..
//

import SwiftUI

struct NoResultsView: View {
    
    var errorMessage: String
    var onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Oops, nothing here🫠")
                .font(.largeTitle)
                .bold()
            Text(errorMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            Button(action: onRetry) {
                Text("Back to start")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(hex: "98B4AA"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    NoResultsView(
        errorMessage: "No results found for this username. Try another or check spelling.",
        onRetry: {
            print("Retry tapped!")
        }
    )
}
