FreeType 2.14.3

PURPOSE:
FreeType is a software font rasterization engine used by TQCanvas to parse 
and render TrueType (TTF), OpenType (OTF), and TrueType Collection (TTC) fonts 
directly in system RAM. It provides vector glyph outline extraction, subpixel 
anti-aliasing, hinting, and kerning without relying on OS-level text APIs 
like Windows GDI/GDI+ or macOS CoreText.


OUTPUT LIBRARIES BY OPERATING SYSTEM:

1. Microsoft Windows
   * Output File: freetype.dll
   * Architectures:
     - x86_64 (64-bit AMD/Intel)
     - x86 / i386 (32-bit legacy)
     - ARM64 (Windows on ARM)

2. Linux & BSD
   * Output File: libfreetype.so.6
   * Architectures:
     - x86_64 (Standard 64-bit desktop/server)
     - i686 / x86 (32-bit Linux)
     - aarch64 / ARM64 (Raspberry Pi, servers, embedded)
     - armhf / armel (32-bit ARM SBCs and IoT)
     - riscv64 (64-bit RISC-V)

3. Apple macOS
   * Output File: libfreetype.dylib
   * Architectures:
     - arm64 (Apple Silicon M1/M2/M3/M4)
     - x86_64 (Intel 64-bit Macs)
     - Universal Binary ("fat" binary combining arm64 + x86_64)

4. Android
   * Output File: libfreetype.so
   * Architectures:
     - arm64-v8a (Modern 64-bit devices)
     - armeabi-v7a (32-bit ARM)
     - x86_64 (Emulators and ChromeOS)
     - x86 (Legacy 32-bit emulators)

5. Apple iOS
   * Output File: libfreetype.a (static) or FreeType.framework
   * Architectures:
     - arm64 (Physical iOS devices)
     - arm64 + x86_64 (iOS Simulator)
