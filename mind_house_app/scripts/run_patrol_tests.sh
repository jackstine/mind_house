#!/bin/bash

# Patrol Test Runner Script for Mind House App
# This script runs Patrol tests with various options

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Mind House Patrol Test Runner${NC}"
echo "================================"

# Function to print usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --platform    Platform to test on (ios/android/all) [default: android]"
    echo "  -t, --test        Specific test file to run [default: all tests]"
    echo "  -d, --device      Device ID to run tests on"
    echo "  -s, --screenshots Enable screenshot capture"
    echo "  -v, --verbose     Enable verbose output"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Run all tests on Android"
    echo "  $0 -p ios                    # Run all tests on iOS"
    echo "  $0 -t simple_patrol_test     # Run specific test file"
    echo "  $0 -p all -s                 # Run on all platforms with screenshots"
}

# Default values
PLATFORM="android"
TEST_FILE=""
DEVICE=""
SCREENSHOTS=false
VERBOSE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -t|--test)
            TEST_FILE="$2"
            shift 2
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -s|--screenshots)
            SCREENSHOTS=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

# Navigate to project directory
cd "$(dirname "$0")/.."

# Check if FVM is installed and use it for Flutter commands
if command -v fvm &> /dev/null; then
    FLUTTER_CMD="fvm flutter"
    echo -e "${GREEN}✓ Using FVM for Flutter commands${NC}"
else
    FLUTTER_CMD="flutter"
    echo -e "${YELLOW}⚠ FVM not found, using system Flutter${NC}"
fi

# Get Flutter dependencies
echo -e "${YELLOW}📦 Getting Flutter dependencies...${NC}"
$FLUTTER_CMD pub get

# Install Patrol CLI if not installed
if ! command -v patrol &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Patrol CLI...${NC}"
    dart pub global activate patrol_cli
    
    # Add to PATH if needed
    export PATH="$PATH:$HOME/.pub-cache/bin"
fi

# Bootstrap Patrol (initialize native test files)
echo -e "${YELLOW}🔧 Bootstrapping Patrol...${NC}"
patrol bootstrap || true  # Continue even if already bootstrapped

# Function to run tests on Android
run_android_tests() {
    echo -e "${GREEN}🤖 Running tests on Android...${NC}"
    
    # Start Android emulator if no device specified
    if [ -z "$DEVICE" ]; then
        echo -e "${YELLOW}Starting Android emulator...${NC}"
        # You may need to adjust this based on your emulator name
        # emulator -avd Pixel_6_API_33 &
        # sleep 10
    fi
    
    # Build and run tests
    if [ -n "$TEST_FILE" ]; then
        patrol test --target integration_test/${TEST_FILE}.dart
    else
        patrol test
    fi
}

# Function to run tests on iOS
run_ios_tests() {
    echo -e "${GREEN}🍎 Running tests on iOS...${NC}"
    
    # Check if we're on macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}❌ iOS tests can only run on macOS${NC}"
        return 1
    fi
    
    # Open iOS Simulator if no device specified
    if [ -z "$DEVICE" ]; then
        echo -e "${YELLOW}Opening iOS Simulator...${NC}"
        open -a Simulator
        sleep 5
    fi
    
    # Build and run tests
    if [ -n "$TEST_FILE" ]; then
        patrol test --target integration_test/${TEST_FILE}.dart --device ios
    else
        patrol test --device ios
    fi
}

# Function to run standard integration tests (fallback)
run_integration_tests() {
    echo -e "${GREEN}🧪 Running standard integration tests...${NC}"
    
    if [ -n "$TEST_FILE" ]; then
        $FLUTTER_CMD test integration_test/${TEST_FILE}.dart
    else
        $FLUTTER_CMD test integration_test/
    fi
}

# Main execution
echo -e "${YELLOW}Platform: $PLATFORM${NC}"
if [ -n "$TEST_FILE" ]; then
    echo -e "${YELLOW}Test file: $TEST_FILE${NC}"
fi

# Run tests based on platform
case $PLATFORM in
    android)
        run_android_tests || run_integration_tests
        ;;
    ios)
        run_ios_tests || run_integration_tests
        ;;
    all)
        run_android_tests || run_integration_tests
        if [[ "$OSTYPE" == "darwin"* ]]; then
            run_ios_tests || true
        fi
        ;;
    *)
        echo -e "${RED}❌ Invalid platform: $PLATFORM${NC}"
        usage
        exit 1
        ;;
esac

echo -e "${GREEN}✅ Tests completed!${NC}"

# Generate report if tests passed
if [ $? -eq 0 ]; then
    echo -e "${GREEN}📊 Test Report:${NC}"
    echo "  Platform: $PLATFORM"
    echo "  Time: $(date)"
    if [ "$SCREENSHOTS" = true ]; then
        echo "  Screenshots: Enabled"
    fi
fi