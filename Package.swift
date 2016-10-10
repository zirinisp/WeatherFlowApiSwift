import PackageDescription

let package = Package(
    name: "WeatherFlowApiSwift",
    dependencies: [
        .Package(url: "https://github.com/zirinisp/CoreLinuxLocationKit.git", majorVersion: 1)],
    exclude: ["Makefile", "Package-Builder", "Carthage", "build", "Pods"]
)


