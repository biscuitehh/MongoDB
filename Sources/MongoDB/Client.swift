//
//  Client.swift
//  MongoDB
//
//  Created by Alsey Coleman Miller on 12/13/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

import SwiftFoundation
import BinaryJSON
import CMongoC
import CBSON

public extension MongoDB {
    
    public final class Client {
        
        // MARK: - Internal Properties
        
        internal let internalPointer: COpaquePointer
        
        // MARK: - Initialization
        
        deinit {
            
            mongoc_client_destroy(internalPointer)
        }
        
        public init(URL: String) {
            
            self.internalPointer = mongoc_client_new(URL)
        }
        
        // MARK: - Public Properties
        
        public var maximumBSONSize: Int {
            
            return Int(mongoc_client_get_max_bson_size(internalPointer))
        }
        
        // MARK: - Methods
        
        /// Sends a simple command to the server.
        public func command(command: BSON.Document, databaseName: String) throws -> BSON.Document? {
            
            guard let commandPointer = BSON.unsafePointerFromDocument(command)
                else { fatalError("Could not convert BSON document to bson_t") }
            
            defer { bson_destroy(commandPointer) }
            
            var responseBSON = UnsafeMutablePointer<bson_t>()
            
            // conditionally destroy
            defer { if responseBSON != nil { bson_destroy(responseBSON) } }
            
            var errorBSON = bson_error_t()
            
            guard mongoc_client_command_simple(internalPointer, databaseName, commandPointer, nil, responseBSON, &errorBSON)
                else { throw BSON.Error(unsafePointer: &errorBSON) }
            
            guard responseBSON != nil else { return nil }
            
            let responseDocument = BSON.documentFromUnsafePointer(responseBSON)!
            
            return responseDocument
        }
    }
}