//
//  OCRScannerView.swift
//  Deets
//
//  Created by IVY (VisionKit & OCR Engineer)
//
//  Example SwiftUI view demonstrating OCRService usage
//  Shows how to integrate DataScannerViewController with SwiftUI
//

import SwiftUI
import VisionKit

/// Main scanning view with camera overlay and recognized text display
struct OCRScannerView: View {
    @StateObject private var ocrService = OCRService()
    @State private var showingPermissionAlert = false
    @State private var showingErrorAlert = false
    @State private var capturedResult: ScanResult?

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera scanner view
                if ocrService.authorizationStatus == .authorized {
                    scannerView
                } else {
                    permissionView
                }

                // Overlay with recognized text
                if ocrService.isScanning {
                    recognizedTextOverlay
                }
            }
            .navigationTitle("Scan Business Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    captureButton
                }
            }
            .alert("Camera Access Required", isPresented: $showingPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Deets needs camera access to scan business cards. Please enable it in Settings.")
            }
            .alert("Scanning Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                if let error = ocrService.error {
                    Text(error.localizedDescription)
                }
            }
            .task {
                await checkAndStartScanning()
            }
            .onChange(of: ocrService.error) { _, newError in
                showingErrorAlert = newError != nil
            }
        }
    }

    // MARK: - Subviews

    private var scannerView: some View {
        Group {
            if let scanner = try? ocrService.createScanner() {
                DataScannerView(scanner: scanner)
                    .ignoresSafeArea()
                    .onAppear {
                        try? ocrService.startScanning()
                    }
                    .onDisappear {
                        ocrService.stopScanning()
                    }
            } else {
                errorView
            }
        }
    }

    private var permissionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.fill")
                .iconMediumLarge()
                .foregroundStyle(.secondary)

            Text("Camera Access Required")
                .font(.title2)
                .fontWeight(.semibold)

            Text("To scan business cards, Deets needs access to your camera.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Grant Access") {
                Task {
                    let granted = await ocrService.requestCameraAccess()
                    if !granted {
                        showingPermissionAlert = true
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var errorView: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .iconMediumLarge()
                .foregroundStyle(.orange)

            Text("Scanner Unavailable")
                .font(.title2)
                .fontWeight(.semibold)

            if let error = ocrService.error {
                Text(error.localizedDescription)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let recovery = error.recoverySuggestion {
                    Text(recovery)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.horizontal)
                }
            }
        }
        .padding()
    }

    private var recognizedTextOverlay: some View {
        VStack {
            Spacer()

            // Show recognized items at bottom
            if !ocrService.recognizedItems.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(ocrService.recognizedItems.sortedByPosition()) { item in
                            RecognizedTextRow(item: item)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: 300)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
            }
        }
    }

    private var captureButton: some View {
        Button {
            captureCurrentFrame()
        } label: {
            Image(systemName: "camera.circle.fill")
                .font(.title)
        }
        .disabled(!ocrService.isScanning)
    }

    // MARK: - Actions

    private func checkAndStartScanning() async {
        guard OCRService.isSupported else {
            ocrService.error = .deviceNotSupported
            return
        }

        ocrService.checkCameraAuthorization()

        if ocrService.authorizationStatus == .notDetermined {
            _ = await ocrService.requestCameraAccess()
        }
    }

    private func captureCurrentFrame() {
        // Create scan result from current recognized items
        let result = ScanResult(items: ocrService.recognizedItems)
        capturedResult = result

        // Provide haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Could navigate to detail view or save here
        AppLogger.ocr.info("Captured \(result.items.count, privacy: .public) recognized items")
    }
}

// MARK: - Supporting Views

struct RecognizedTextRow: View {
    let item: ScannedText

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Category icon
            categoryIcon
                .frame(width: 32, height: 32)
                .background(categoryColor.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(item.text)
                    .font(.body)
                    .fontWeight(.medium)

                HStack(spacing: 8) {
                    if let category = item.category {
                        Text(category.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    // Confidence indicator
                    ConfidenceBadge(confidence: item.confidence)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
    }

    private var categoryIcon: some View {
        Group {
            switch item.category {
            case .email:
                Image(systemName: "envelope.fill")
            case .phone:
                Image(systemName: "phone.fill")
            case .website:
                Image(systemName: "globe")
            case .name:
                Image(systemName: "person.fill")
            case .title:
                Image(systemName: "briefcase.fill")
            case .company:
                Image(systemName: "building.2.fill")
            case .address:
                Image(systemName: "map.fill")
            case .other, .none:
                Image(systemName: "text.alignleft")
            }
        }
        .font(.caption)
        .foregroundStyle(categoryColor)
    }

    private var categoryColor: Color {
        switch item.category {
        case .email: return .blue
        case .phone: return .green
        case .website: return .purple
        case .name: return .orange
        case .title: return .pink
        case .company: return .indigo
        case .address: return .teal
        case .other, .none: return .gray
        }
    }
}

struct ConfidenceBadge: View {
    let confidence: Float

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: confidenceIcon)
                .font(.caption2)

            Text("\(Int(confidence * 100))%")
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundStyle(confidenceColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(confidenceColor.opacity(0.1))
        .clipShape(Capsule())
    }

    private var confidenceIcon: String {
        if confidence >= 0.8 {
            return "checkmark.circle.fill"
        } else if confidence >= 0.6 {
            return "checkmark.circle"
        } else {
            return "questionmark.circle"
        }
    }

    private var confidenceColor: Color {
        if confidence >= 0.8 {
            return .green
        } else if confidence >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OCRScannerView_Previews: PreviewProvider {
    static var previews: some View {
        OCRScannerView()

        // Preview recognized text row
        RecognizedTextRow(
            item: ScannedText(
                text: "john.smith@email.com",
                confidence: 0.92,
                boundingBox: BoundingBox(x: 0, y: 0, width: 0, height: 0),
                category: .email
            )
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
