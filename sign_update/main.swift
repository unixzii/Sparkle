//
//  main.swift
//  sign_update
//
//  Created by Kornel on 16/09/2018.
//  Copyright © 2018 Sparkle Project. All rights reserved.
//

import Foundation
import Security

func findKeys() -> (Data, Data) {
    var item: CFTypeRef?;
    let res = SecItemCopyMatching([
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: "https://sparkle-project.org",
        kSecAttrAccount as String: "ed25519",
        kSecAttrProtocol as String: kSecAttrProtocolSSH,
        kSecReturnData as String: kCFBooleanTrue,
        ] as CFDictionary, &item);
    if res == errSecSuccess, let encoded = item as? Data, let keys = Data(base64Encoded: encoded) {
        return (keys[0..<64], keys[64..<(64+32)])
    }
    else if res == errSecItemNotFound {
        print("ERROR! Signing key not found. Please run generate_keys tool first.");
    }
    else if res == errSecAuthFailed {
        print("ERROR! Access denied. Can't get keys from the keychain.");
        print("Go to Keychain Access.app, lock the login keychain, then unlock it again.");
    }
    else if res == errSecUserCanceled {
        print("ABORTED! You've cancelled the request to read the key from the Keychain. Please run the tool again.");
    } else {
        print("ERROR! Unable to access required key in the Keychain", res, "(you can look it up at osstatus.com)");
    }
    exit(1)
}

func edSignature(data: Data, publicEdKey: Data, privateEdKey: Data) -> String {
    assert(publicEdKey.count == 32)
    assert(privateEdKey.count == 64)
    let len = data.count;
    var output = Data(count: 64);
    output.withUnsafeMutableBytes({ (output: UnsafeMutablePointer<UInt8>) in
        data.withUnsafeBytes({ (data: UnsafePointer<UInt8>) in
            publicEdKey.withUnsafeBytes({ (publicEdKey: UnsafePointer<UInt8>) in
                privateEdKey.withUnsafeBytes({ (privateEdKey: UnsafePointer<UInt8>) in
                    ed25519_sign(output, data, len, publicEdKey, privateEdKey)
                });
            });
        })
    });
    return output.base64EncodedString();
}

let args = CommandLine.arguments;
if args.count != 2 {
    print("Usage: \(args[0]) <archive to sign>\nPrivavte EdDSA (ed25519) key is automatically read from the Keychain.\n");
    exit(1)
}

let(priv, pub) = findKeys();

do {
    let data = try Data.init(contentsOf: URL.init(fileURLWithPath: args[1]), options: .mappedIfSafe);
    let sig = edSignature(data:data , publicEdKey: pub, privateEdKey: priv);
    print("sparkle:edSignature=\"\(sig)\" length=\"\(data.count)\"");
} catch {
    print("ERROR: ", error)
}
