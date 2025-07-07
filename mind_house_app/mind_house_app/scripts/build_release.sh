#!/bin/bash

# Build release script for Mind House application
# This script handles building release versions for all supported platforms

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="Mind House"
VERSION=$(grep "version:" pubspec.yaml | cut -d: -f2 | tr -d ' ')
BUILD_DIR="build/release"
ARTIFACT_DIR="artifacts"

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_requirements() {
    log_info "Checking build requirements..."
    
    # Check Flutter
    if ! command -v fvm &> /dev/null && ! command -v flutter &> /dev/null; then
        log_error "Flutter or FVM not found. Please install Flutter or FVM."
        exit 1
    fi
    
    # Use FVM if available, otherwise use flutter
    if command -v fvm &> /dev/null; then
        FLUTTER_CMD="fvm flutter"
    else
        FLUTTER_CMD="flutter"
    fi
    
    # Check Flutter doctor
    log_info "Running Flutter doctor..."
    $FLUTTER_CMD doctor
    
    log_success "Requirements check passed"
}

clean_build() {
    log_info "Cleaning previous builds..."
    
    $FLUTTER_CMD clean
    rm -rf $BUILD_DIR
    rm -rf $ARTIFACT_DIR
    mkdir -p $BUILD_DIR
    mkdir -p $ARTIFACT_DIR
    
    log_success "Clean completed"
}

run_tests() {
    log_info "Running tests..."
    
    # Run unit tests
    log_info "Running unit tests..."
    $FLUTTER_CMD test --reporter expanded
    
    # Run integration tests if available
    if [ -d "integration_test" ]; then
        log_info "Running integration tests..."
        $FLUTTER_CMD test integration_test/ --verbose
    fi
    
    log_success "All tests passed"
}

analyze_code() {
    log_info "Analyzing code..."
    
    $FLUTTER_CMD analyze --fatal-infos
    
    log_success "Code analysis passed"
}

build_macos() {
    log_info "Building macOS release..."
    
    $FLUTTER_CMD build macos --release \
        --build-name=$VERSION \
        --obfuscate \
        --split-debug-info=$BUILD_DIR/macos/debug-info
    
    # Create DMG (requires create-dmg tool)
    if command -v create-dmg &> /dev/null; then
        log_info "Creating macOS DMG..."
        create-dmg \
            --volname "$APP_NAME" \
            --window-pos 200 120 \
            --window-size 600 300 \
            --icon-size 100 \
            --icon "$APP_NAME.app" 175 120 \
            --hide-extension "$APP_NAME.app" \
            --app-drop-link 425 120 \
            "$ARTIFACT_DIR/mind-house-macos-$VERSION.dmg" \
            "build/macos/Build/Products/Release/"
    else
        log_warning "create-dmg not found, skipping DMG creation"
        cp -r "build/macos/Build/Products/Release/mind_house_app.app" "$ARTIFACT_DIR/"
    fi
    
    log_success "macOS build completed"
}

build_ios() {
    log_info "Building iOS release..."
    
    # Check if iOS build tools are available
    if ! command -v xcodebuild &> /dev/null; then
        log_warning "Xcode not found, skipping iOS build"
        return
    fi
    
    $FLUTTER_CMD build ios --release \
        --build-name=$VERSION \
        --obfuscate \
        --split-debug-info=$BUILD_DIR/ios/debug-info
    
    # Create IPA (requires Xcode)
    log_info "Creating iOS IPA..."
    $FLUTTER_CMD build ipa --release \
        --build-name=$VERSION \
        --obfuscate \
        --split-debug-info=$BUILD_DIR/ios/debug-info
    
    cp "build/ios/ipa/mind_house_app.ipa" "$ARTIFACT_DIR/mind-house-ios-$VERSION.ipa"
    
    log_success "iOS build completed"
}

build_android() {
    log_info "Building Android release..."
    
    # Build APK
    $FLUTTER_CMD build apk --release \
        --build-name=$VERSION \
        --obfuscate \
        --split-debug-info=$BUILD_DIR/android/debug-info
    
    # Build AAB (Android App Bundle)
    $FLUTTER_CMD build appbundle --release \
        --build-name=$VERSION \
        --obfuscate \
        --split-debug-info=$BUILD_DIR/android/debug-info
    
    cp "build/app/outputs/flutter-apk/app-release.apk" "$ARTIFACT_DIR/mind-house-android-$VERSION.apk"
    cp "build/app/outputs/bundle/release/app-release.aab" "$ARTIFACT_DIR/mind-house-android-$VERSION.aab"
    
    log_success "Android build completed"
}

build_web() {
    log_info "Building Web release..."
    
    $FLUTTER_CMD build web --release \
        --build-name=$VERSION \
        --web-renderer canvaskit \
        --base-href "/mind-house/"
    
    # Create web archive
    cd build/web
    tar -czf "../../$ARTIFACT_DIR/mind-house-web-$VERSION.tar.gz" .
    cd ../..
    
    log_success "Web build completed"
}

generate_checksums() {
    log_info "Generating checksums..."
    
    cd $ARTIFACT_DIR
    
    for file in *; do
        if [ -f "$file" ]; then
            sha256sum "$file" > "$file.sha256"
            log_info "Generated checksum for $file"
        fi
    done
    
    cd ..
    log_success "Checksums generated"
}

create_release_notes() {
    log_info "Creating release notes..."
    
    cat > "$ARTIFACT_DIR/RELEASE_NOTES.md" << EOF
# Mind House v$VERSION Release Notes

## Build Information
- Version: $VERSION
- Build Date: $(date)
- Flutter Version: $($FLUTTER_CMD --version | head -n 1)
- Dart Version: $($FLUTTER_CMD --version | grep "Dart" | head -n 1)

## Features
- Tags-first information management
- Offline-first design
- Fast search and filtering
- Material Design 3 UI
- Cross-platform support

## Supported Platforms
- macOS (Intel & Apple Silicon)
- iOS (iPhone & iPad)
- Android (API 21+)
- Web (Modern browsers)

## Installation
### macOS
- Download the DMG file or app bundle
- Drag to Applications folder

### iOS
- Install via TestFlight or App Store

### Android
- Install APK directly or via Play Store (AAB)

### Web
- Extract tar.gz and serve from web server

## Technical Details
- Built with obfuscation enabled
- Split debug info for crash reporting
- Optimized for performance and size

## Security
- All data stored locally
- No network connections required
- Privacy-focused design

Generated on $(date)
EOF
    
    log_success "Release notes created"
}

print_summary() {
    log_info "Build Summary:"
    echo "================================"
    echo "App: $APP_NAME"
    echo "Version: $VERSION"
    echo "Build Directory: $BUILD_DIR"
    echo "Artifacts Directory: $ARTIFACT_DIR"
    echo ""
    echo "Artifacts created:"
    ls -la $ARTIFACT_DIR/
    echo "================================"
}

# Main execution
main() {
    log_info "Starting release build for $APP_NAME v$VERSION"
    
    # Parse command line arguments
    PLATFORMS="all"
    SKIP_TESTS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --platforms)
                PLATFORMS="$2"
                shift 2
                ;;
            --skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            --help)
                echo "Usage: $0 [options]"
                echo "Options:"
                echo "  --platforms PLATFORMS  Comma-separated list of platforms (macos,ios,android,web) or 'all'"
                echo "  --skip-tests           Skip running tests"
                echo "  --help                 Show this help"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Execute build steps
    check_requirements
    clean_build
    
    if [ "$SKIP_TESTS" = false ]; then
        run_tests
    else
        log_warning "Skipping tests as requested"
    fi
    
    analyze_code
    
    # Build for specified platforms
    if [[ "$PLATFORMS" == "all" || "$PLATFORMS" == *"macos"* ]]; then
        build_macos
    fi
    
    if [[ "$PLATFORMS" == "all" || "$PLATFORMS" == *"ios"* ]]; then
        build_ios
    fi
    
    if [[ "$PLATFORMS" == "all" || "$PLATFORMS" == *"android"* ]]; then
        build_android
    fi
    
    if [[ "$PLATFORMS" == "all" || "$PLATFORMS" == *"web"* ]]; then
        build_web
    fi
    
    generate_checksums
    create_release_notes
    print_summary
    
    log_success "Release build completed successfully!"
}

# Run main function
main "$@"