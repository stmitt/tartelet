import SwiftUI

struct GitHubPrivateKeyPicker: View {
    @Binding private var filename: String
    private let isEnabled: Bool
    private let onSelectFile: (URL) -> Void

    init(filename: Binding<String>, isEnabled: Bool, onSelectFile: @escaping (URL) -> Void) {
        self._filename = filename
        self.isEnabled = isEnabled
        self.onSelectFile = onSelectFile
    }

    var body: some View {
        LabeledContent {
            VStack {
                HStack {
                    TextField(
                        L10n.Settings.Github.privateKey,
                        text: $filename,
                        prompt: Text(L10n.Settings.Github.PrivateKey.placeholder)
                    )
                    .labelsHidden()
                    .disabled(true)
                    Button {
                        if let fileURL = presentOpenPanel() {
                            onSelectFile(fileURL)
                        }
                    } label: {
                        Text(L10n.Settings.Github.PrivateKey.selectFile)
                    }.disabled(!isEnabled)
                }
                Text(L10n.Settings.Github.PrivateKey.scopes)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.secondary)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.separator, lineWidth: 1)
                    }
            }
        } label: {
            Text(L10n.Settings.Github.privateKey)
        }
    }
}

private extension GitHubPrivateKeyPicker {
    func presentOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.x509Certificate]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
}
