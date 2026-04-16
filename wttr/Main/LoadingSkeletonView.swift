import SwiftUI

struct LoadingSkeletonView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Current condition skeleton
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Surface"))
                .frame(height: 120)

            // Decision cards skeleton
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("Surface"))
                        .frame(height: 100)
                }
            }

            // Hourly chart skeleton
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("Surface"))
                .frame(height: 160)

            // Weekly skeleton
            VStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color("Surface"))
                        .frame(height: 44)
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
