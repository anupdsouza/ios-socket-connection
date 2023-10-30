//
//  SocketService.swift
//  SocketConnection
//
//  Created by Anup D'Souza on 16/10/23.
//

import Foundation
import SwiftUI
import Combine
import SocketIO

final class SocketService: ObservableObject {
    private var cancellable: AnyCancellable?
    private var socketManager: SocketManager?
    private var socket: SocketIOClient?
    private let socketURL = URL(string: "http://localhost:3000")!
    private var namespace: String?
    private let loggingEnabled: Bool = false
    private var timer = Timer()
    private var seconds: Int = 0
    @Published private var socketState = SocketState.disconnected
    
    init() {
        self.socketManager = SocketManager(socketURL: socketURL, config: [.log(loggingEnabled), .compress])
        self.socket = socketManager?.defaultSocket
        self.cancellable = $socketState.receive(on: DispatchQueue.main)
            .sink { socketState in
            print("socket event: \(socketState)")
        }
    }

    deinit {
        cancellable?.cancel()
        cancellable = nil
        socketManager = nil
        socket = nil
    }
}

// MARK: Socket event listeners
extension SocketService {
    
    private func addEventListeners() {
        
        socket?.on(SocketEvents.userConnected) { [weak self] data, _ in
            print("client => received event: \(SocketEvents.userConnected)")
            guard let data = data.first as? String else { return }
            if data == self?.socket?.sid {
                print("client => received event: \(SocketEvents.userConnected), id(self): \(data)")
                self?.socketState = .userConnected
            } else  {
                print("client => received event: \(SocketEvents.userConnected), id(other user): \(data)")
            }
        }
        
        socket?.on(SocketEvents.userDisconnected) { [weak self] data, _ in
            print("client => received event: \(SocketEvents.userDisconnected)")
            guard let data = data.first as? String else { return }
            if data == self?.socket?.sid {
                print("client => received event: \(SocketEvents.userDisconnected), id(self): \(data)")
                self?.socketState = .userDisconnected
            } else  {
                print("client => received event: \(SocketEvents.userDisconnected), id(other user): \(data)")
            }
        }
        
        socket?.on("disconnect", callback: { data, _ in
            print("reason: \(data)")
        })
    }
}

// MARK: Socket user actions
extension SocketService {
    
    func connectToServer() {
        closeConnection()
        startTimer()
        establishConnection()
    }
    
    func disconnectFromServer() {
        stopTimer()
        closeConnection()
    }
    
    func connectedToServer() -> Bool {
        self.socketState == .userConnected
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateStatus), userInfo: nil, repeats: true)
    }
    
    private func stopTimer() {
        seconds = 0
        timer.invalidate()
    }
    
    @objc private func updateStatus() {
        seconds += 1
        print("Socket connection (\(seconds): \(String(describing: socketManager?.status))")
    }
    
    private func establishConnection() {
        socketState = .connectingToServer
        addEventListeners()
        socket?.connect()
    }
    
    private func closeConnection() {
        socketState = .disconnected
        socket?.emit(SocketEvents.disconnect)
        socket?.disconnect()
    }
}
