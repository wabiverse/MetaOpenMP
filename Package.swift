// swift-tools-version: 5.10
import PackageDescription

var openmpExclude = [
  "runtime/extractExternal.cpp",
  "runtime/kmp_stub.cpp",
  "runtime/kmp_import.cpp",
  "runtime/test-touch.c",
]
#if !os(Windows)
  openmpExclude += [
    "runtime/z_Windows_NT_util.cpp",
    "runtime/z_Windows_NT-586_util.cpp",
    "runtime/z_Windows_NT-586_asm.asm",
  ]
#endif
#if os(Windows)
  openmpExclude += [
    "runtime/z_Linux_util.cpp",
    "runtime/z_Linux_asm.S",
    "runtime/kmp_gsupport.cpp"
  ]
#endif

let package = Package(
  name: "MetaOpenMP",
  platforms: [
    .macOS(.v14),
    .visionOS(.v1),
    .iOS(.v17),
    .tvOS(.v17),
    .watchOS(.v10),
  ],
  products: [
    .library(
      name: "OpenMP",
      type: .dynamic,
      targets: ["OpenMP"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/wabiverse/MetaMicrosoftSTL.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "OpenMP",
      dependencies: [
        .product(name: "MicrosoftSTL", package: "MetaMicrosoftSTL", condition: .when(platforms: [.windows])),
      ],
      exclude: openmpExclude,
      publicHeadersPath: "include",
      cxxSettings: [
        .headerSearchPath("runtime"),
        .define("_ALLOW_COMPILER_AND_STL_VERSION_MISMATCH", .when(platforms: [.windows])),
        .define("_ALLOW_KEYWORD_MACROS", to: "1", .when(platforms: [.windows])),
        .define("static_assert(_conditional, ...)", to: "", .when(platforms: [.windows])),
        .define("RTLD_NEXT", to: "", .when(platforms: [.windows]))
      ]
    ),
  ],
  cLanguageStandard: .gnu17,
  cxxLanguageStandard: .cxx17
)
