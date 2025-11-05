//
//  ScanView.swift
//  Deets
//
//  Business card scanning view with VisionKit integration
//

import SwiftUI
import VisionKit

struct ScanView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ScanViewModel()
    @State private var showScanner = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.teal.opacity(0.1), Color.teal.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // Icon
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.teal)
                        .accessibilityHidden(true)

                    // Title and description
                    VStack(spacing: 12) {
                        Text("Scan Business Card")
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.primary)

                        Text("Point your camera at a business card to extract contact information automatically")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Spacer()

                    // Scan button
                    VStack(spacing: 16) {
                        if viewModel.isScannerAvailable {
                            PrimaryButton(
                                "Start Scanning",
                                systemImage: "camera.fill",
                                isDisabled: !viewModel.isScannerAvailable
                            ) {
                                showScanner = true
                            }
                            .padding(.horizontal, 24)
                        } else {
                            // Scanner not available message
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title)
                                    .foregroundStyle(.orange)

                                Text("Camera scanning is not available on this device")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 32)
                        }

                        // Help text
                        Text("Requires iOS 16+ and camera access")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Scan")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(isPresented: $showScanner) {
                DataScannerView(viewModel: viewModel)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $viewModel.showContactPreview) {
                if let scannedText = viewModel.scannedText {
                    ContactPreviewView(
                        scannedText: scannedText,
                        onDismiss: {
                            viewModel.resetAfterSave()
                        }
                    )
                }
            }
            .alert("Scan Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("Retry") {
                    viewModel.retryScan()
                }
                Button("Cancel", role: .cancel) {
                    viewModel.cancelScanning()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Data Scanner View

struct DataScannerView: UIViewControllerRepresentable {
    @Bindable var viewModel: ScanViewModel
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )

        scanner.delegate = context.coordinator

        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // Start scanning when view appears
        if !uiViewController.isScanning {
            try? uiViewController.startScanning()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, dismiss: dismiss)
    }

    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }

    // MARK: - Coordinator

    @MainActor
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let viewModel: ScanViewModel
        let dismiss: DismissAction

        init(viewModel: ScanViewModel, dismiss: DismissAction) {
            self.viewModel = viewModel
            self.dismiss = dismiss
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .text(let text):
                let scannedText = text.transcript
                viewModel.handleScannedText(scannedText)
                dismiss()
            default:
                break
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // Optional: Auto-capture after stable text detection
            guard let firstText = addedItems.first(where: { item in
                if case .text = item { return true }
                return false
            }) else { return }

            if case .text(let text) = firstText {
                let scannedText = text.transcript
                // Only auto-capture if text is substantial
                if scannedText.count > 20 {
                    viewModel.handleScannedText(scannedText)
                    dismiss()
                }
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // Handle removed items if needed
        }

        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            viewModel.handleScanError(error)
            dismiss()
        }
    }
}

// MARK: - Scanner Overlay View

struct ScannerOverlayView: View {
    let onCancel: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()

                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding()
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                        )
                }
                .padding()
                .accessibilityLabel("Cancel scanning")
                .accessibilityHint("Double tap to close scanner")
            }

            Spacer()

            // Guidance text
            VStack(spacing: 12) {
                Text("Tap on text to capture")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Position the business card in the viewfinder")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Preview

#Preview("Scan View") {
    ScanView()
        .modelContainer(for: BusinessCard.self, inMemory: true)
}
