//
//  Target.swift
//  DemoApp
//
//  Created by Oleksandr Chernov on 12/09/2024.
//

import bLinkupSDK
import UIKit

enum Target {
    static let customers = [
        AppCustomer(cid: "Ph_yH2e8JRpc0WBKiNNOYUYJs03kNEY3DXh7WIrXlJo=",
                    name: "Chicago Demo",
                    primary: "00244D",
                    secondary: "CC0D33",
                    logo: "logoDemo",
                    pub: true),
        AppCustomer(cid: "Ph1bFOq1moKmm0in2lxsfZ5v-No-Og6wWxEKM-6F1OM=",
                    name: "Milwaukee Bucks",
                    primary: "004020",
                    secondary: "CC0D33",
                    logo: "logoDemo",
                    font: "AmericanTypewriter",
                    pub: true),
        AppCustomer(cid: "iqPbaubl_9FtQTTBGrueAdom0TnlSbTPZO675ZLQS1o=",
                    name: "Charlotte Hornets",
                    primary: "008AA3",
                    secondary: "CC0D33",
                    logo: "logoHornets",
                    font: "GillSans",
                    pub: true),
        AppCustomer(cid: "uzU20c9Zs6_-Sn3o_lv9jrPM4kZeH5nnnn05iNfc1FE=",
                    name: "Atlanta Braves",
                    primary: "BF0533",
                    secondary: "CC0D33",
                    logo: "logoAtlanta",
                    font: "HelveticaNeue",
                    pub: true),
        AppCustomer(cid: "ssD1qVnNw1KFPT3eFFtquHiSo0qlZzcK783Kwku9xWU=",
                    name: "Clemson Tigers",
                    primary: "E6732E",
                    secondary: "CC0D33",
                    logo: "logoTigers",
                    pub: true),
        AppCustomer(cid: "7x1oDfFEpUj4LVIzz8XSskomH5dINsRZmLY6XZSfPvE=",
                    name: "Test",
                    primary: "004020",
                    secondary: "CC0D33",
                    logo: "logoDemo",
                    pub: true),
        AppCustomer(cid: "blXZyvR8f2s54U948MuU9rSxeinYE1G1sYGq0V2P0GM=",
                    name: "Scrut.io",
                    logo: "logoDemo",
                    pub: true),
        AppCustomer(cid: "0-gbcEdQqg8G9dB_XSm-JkLZ5ZC4uIwfHMiy-nbT3sk=",
                    name: "Kit Carson",
                    pub: true),
        AppCustomer(cid: "92ppXgmdlRJ2kkTolS2JD2KCBXehREbpybhsOHqblnw=",
                    name: "Encinitas Ranch",
                    pub: true),
        AppCustomer(cid: "h9AQnvY33HmMLhYD88lyFFcrp4WqjhW-2PVwlmzo6kE=",
                    name: "Milwaukee Bucks (Official)",
                    pub: true),
        AppCustomer(cid: "Mb9QPCopsCNBr8QI8jAZ0qqUWrAXIMCgkr_PuvaUY08=",
                    name: "HOCR",
                    pub: true),
        AppCustomer(cid: "845hxVpXeRyfJ2IlVfF6fNSNfUU3w0V3W1VZ0R6bhlI=",
                    name: "Marquette University",
                    pub: true),
    ]
    
    static var hosts = [
        "https://blinkup.fly.dev/api/",
    ]
}
