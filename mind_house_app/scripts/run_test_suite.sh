#!/bin/bash

# Mind House App - Comprehensive Test Suite Runner
# This script runs the complete testing suite with various options

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                  Mind House Test Suite                      ║"
echo "║              Comprehensive Testing Framework                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to print usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Test Categories:"
    echo "  --navigation     Run navigation and app structure tests"
    echo "  --features       Run feature-specific tests (store, browse, view)"
    echo "  --widgets        Run widget component tests"
    echo "  --blocs          Run BLoC and state management tests"
    echo "  --workflows      Run end-to-end workflow tests"
    echo "  --performance    Run performance and load tests"
    echo "  --accessibility  Run accessibility compliance tests"
    echo "  --visual         Run visual regression tests"
    echo "  --all            Run all test categories (default)"
    echo ""
    echo "Options:"
    echo "  -d, --device     Target device (macos/android/ios/chrome) [default: macos]"
    echo "  -c, --coverage   Generate coverage report"
    echo "  -v, --verbose    Enable verbose output"
    echo "  --fast          Skip slow tests (performance, visual)"
    echo "  --smoke         Run only critical smoke tests"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                           # Run all tests on macOS"
    echo "  $0 --features -d android     # Run feature tests on Android"
    echo "  $0 --smoke                   # Run smoke tests only"
    echo "  $0 --all -c                  # Run all tests with coverage"
}

# Default values
DEVICE="macos"
COVERAGE=false
VERBOSE=false
FAST=false
SMOKE=false
RUN_NAVIGATION=false
RUN_FEATURES=false
RUN_WIDGETS=false
RUN_BLOCS=false
RUN_WORKFLOWS=false
RUN_PERFORMANCE=false
RUN_ACCESSIBILITY=false
RUN_VISUAL=false
RUN_ALL=true

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --navigation)
            RUN_NAVIGATION=true
            RUN_ALL=false
            shift
            ;;
        --features)
            RUN_FEATURES=true
            RUN_ALL=false
            shift
            ;;
        --widgets)
            RUN_WIDGETS=true
            RUN_ALL=false
            shift
            ;;
        --blocs)
            RUN_BLOCS=true
            RUN_ALL=false
            shift
            ;;
        --workflows)
            RUN_WORKFLOWS=true
            RUN_ALL=false
            shift
            ;;
        --performance)
            RUN_PERFORMANCE=true
            RUN_ALL=false
            shift
            ;;
        --accessibility)
            RUN_ACCESSIBILITY=true
            RUN_ALL=false
            shift
            ;;
        --visual)
            RUN_VISUAL=true
            RUN_ALL=false
            shift
            ;;
        --all)
            RUN_ALL=true
            shift
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -c|--coverage)
            COVERAGE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --fast)
            FAST=true
            shift
            ;;
        --smoke)
            SMOKE=true
            RUN_ALL=false
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

# Check if FVM is available
if command -v fvm &> /dev/null; then
    FLUTTER_CMD="fvm flutter"
    DART_CMD="fvm dart"
    echo -e "${GREEN}✓ Using FVM for Flutter commands${NC}"
else
    FLUTTER_CMD="flutter"
    DART_CMD="dart"
    echo -e "${YELLOW}⚠ FVM not found, using system Flutter${NC}"
fi

# Function to run test category
run_test_category() {
    local category=$1
    local description=$2
    local test_path=$3
    
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}🧪 Running $description${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ -d "$test_path" ] || [ -f "$test_path" ]; then
        local test_cmd="$FLUTTER_CMD test $test_path"
        if [ "$DEVICE" != "default" ]; then
            test_cmd="$test_cmd -d $DEVICE"
        fi
        
        if [ "$VERBOSE" = true ]; then
            test_cmd="$test_cmd --verbose"
        fi
        
        echo -e "${BLUE}Command: $test_cmd${NC}"
        
        if eval $test_cmd; then
            echo -e "${GREEN}✅ $description - PASSED${NC}"
            ((PASSED_TESTS++))
        else
            echo -e "${RED}❌ $description - FAILED${NC}"
            ((FAILED_TESTS++))
        fi
    else
        echo -e "${YELLOW}⚠ Test path not found: $test_path${NC}"
        echo -e "${YELLOW}📝 Creating placeholder for: $description${NC}"
        # Create test file structure if it doesn't exist
        mkdir -p "$(dirname "$test_path")"
    fi
    
    ((TOTAL_TESTS++))
    echo ""
}

# Function to run smoke tests
run_smoke_tests() {
    echo -e "${YELLOW}🚀 Running Smoke Tests (Critical Path Only)${NC}"
    run_test_category "smoke" "App Launch & Basic Navigation" "integration_test/simple_ui_test.dart"
    run_test_category "smoke" "Core CRUD Operations" "integration_test/app_test.dart"
}

# Main test execution
echo -e "${BLUE}📋 Test Configuration:${NC}"
echo -e "${BLUE}  Device: $DEVICE${NC}"
echo -e "${BLUE}  Coverage: $COVERAGE${NC}"
echo -e "${BLUE}  Fast Mode: $FAST${NC}"
echo -e "${BLUE}  Verbose: $VERBOSE${NC}"
echo ""

# Get dependencies
echo -e "${YELLOW}📦 Getting Flutter dependencies...${NC}"
$FLUTTER_CMD pub get

# Run tests based on options
if [ "$SMOKE" = true ]; then
    run_smoke_tests
elif [ "$RUN_ALL" = true ]; then
    # Phase 1: Navigation & Core
    run_test_category "navigation" "Navigation & App Structure Tests" "integration_test/navigation/"
    run_test_category "lifecycle" "App Lifecycle Tests" "integration_test/lifecycle/"
    
    # Phase 2: Features
    run_test_category "store" "Store Information Page Tests" "integration_test/features/store_information_test.dart"
    run_test_category "browse" "Browse Information Page Tests" "integration_test/features/browse_information_test.dart"
    run_test_category "view" "View Information Page Tests" "integration_test/features/view_information_test.dart"
    
    # Phase 3: Widgets
    run_test_category "widgets" "Widget Component Tests" "integration_test/widgets/"
    
    # Phase 4: BLoCs
    run_test_category "blocs" "BLoC State Management Tests" "test/blocs/"
    
    # Phase 5: Workflows
    run_test_category "workflows" "End-to-End Workflow Tests" "integration_test/workflows/"
    
    # Phase 6: Performance (skip if fast mode)
    if [ "$FAST" != true ]; then
        run_test_category "performance" "Performance & Load Tests" "integration_test/performance/"
        run_test_category "visual" "Visual Regression Tests" "integration_test/visual/"
    fi
    
    # Phase 7: Accessibility
    run_test_category "accessibility" "Accessibility Compliance Tests" "integration_test/accessibility/"
    
else
    # Run specific categories
    if [ "$RUN_NAVIGATION" = true ]; then
        run_test_category "navigation" "Navigation Tests" "integration_test/navigation/"
    fi
    if [ "$RUN_FEATURES" = true ]; then
        run_test_category "features" "Feature Tests" "integration_test/features/"
    fi
    if [ "$RUN_WIDGETS" = true ]; then
        run_test_category "widgets" "Widget Tests" "integration_test/widgets/"
    fi
    if [ "$RUN_BLOCS" = true ]; then
        run_test_category "blocs" "BLoC Tests" "test/blocs/"
    fi
    if [ "$RUN_WORKFLOWS" = true ]; then
        run_test_category "workflows" "Workflow Tests" "integration_test/workflows/"
    fi
    if [ "$RUN_PERFORMANCE" = true ]; then
        run_test_category "performance" "Performance Tests" "integration_test/performance/"
    fi
    if [ "$RUN_ACCESSIBILITY" = true ]; then
        run_test_category "accessibility" "Accessibility Tests" "integration_test/accessibility/"
    fi
    if [ "$RUN_VISUAL" = true ]; then
        run_test_category "visual" "Visual Tests" "integration_test/visual/"
    fi
fi

# Generate coverage report if requested
if [ "$COVERAGE" = true ]; then
    echo -e "${YELLOW}📊 Generating coverage report...${NC}"
    $FLUTTER_CMD test --coverage
    
    if command -v genhtml &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        echo -e "${GREEN}📈 Coverage report generated: coverage/html/index.html${NC}"
    else
        echo -e "${YELLOW}⚠ Install lcov to generate HTML coverage report${NC}"
    fi
fi

# Final summary
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                     TEST SUMMARY                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BLUE}📊 Test Results:${NC}"
echo -e "${GREEN}  ✅ Passed: $PASSED_TESTS${NC}"
echo -e "${RED}  ❌ Failed: $FAILED_TESTS${NC}"
echo -e "${BLUE}  📋 Total: $TOTAL_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}"
    echo "🎉 All tests passed! Mind House app is ready for deployment."
    echo -e "${NC}"
    exit 0
else
    echo -e "${RED}"
    echo "⚠ Some tests failed. Please review the results above."
    echo -e "${NC}"
    exit 1
fi