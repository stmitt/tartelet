import Foundation
import LogHelpers
import OSLog
import SettingsStore
import Tart
import TartVirtualMachine
import VirtualMachine
import VirtualMachineFactory
import VirtualMachineResourcesService

enum LongLivedVirtualMachineFactoryError: LocalizedError {
    case sourceVirtualMachineNameUnavailable

    var errorDescription: String? {
        switch self {
        case .sourceVirtualMachineNameUnavailable:
            return "The source virtual machine name is unavailable. Please select a virtual machine in settings."
        }
    }
}

struct LongLivedVirtualMachineFactory: VirtualMachineFactory {
    let tart: Tart
    let settingsStore: SettingsStore
    let resourcesService: VirtualMachineResourcesService
    var preferredVirtualMachineName: String {
        get throws {
            guard case let .virtualMachine(vmName) = settingsStore.virtualMachine else {
                throw EphemeralVirtualMachineFactoryError.sourceVirtualMachineNameUnavailable
            }
            return vmName
        }
    }

    let logger = Logger(category: "LongLivedVirtualMachineFactory")

    func makeVirtualMachine(named name: String) async throws -> VirtualMachine {
        guard case let .virtualMachine(vmName) = settingsStore.virtualMachine else {
            logger.error("Failed making long-lived virtual machine as name is not available")
            throw EphemeralVirtualMachineFactoryError.sourceVirtualMachineNameUnavailable
        }
        do {
            try await resourcesService.createResourcesIfNeeded()
        } catch {
            // swiftlint:disable:next line_length
            logger.error("Failed making long-lived virtual machine as resources could not be created: \(error.localizedDescription, privacy: .public)")
            throw error
        }
        return TartVirtualMachine(
            tart: tart,
            vmName: vmName,
            resourcesDirectoryURL: resourcesService.directoryURL
        )
    }
}
