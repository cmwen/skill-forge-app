#!/bin/bash
# Run all tests with coverage

echo "🧪 Running Skill Forge Tests..."
echo ""

# Clean previous coverage
rm -rf coverage

# Run tests with coverage
flutter test --coverage

# Check if lcov is installed
if command -v lcov &> /dev/null; then
    echo ""
    echo "📊 Generating coverage report..."
    
    # Generate HTML report
    genhtml coverage/lcov.info -o coverage/html
    
    echo "✅ Coverage report generated at: coverage/html/index.html"
    
    # Show coverage summary
    echo ""
    echo "📈 Coverage Summary:"
    lcov --summary coverage/lcov.info
else
    echo ""
    echo "ℹ️  Install lcov to generate HTML coverage reports:"
    echo "   macOS: brew install lcov"
    echo "   Ubuntu: sudo apt-get install lcov"
    echo "   Windows: choco install lcov"
fi

echo ""
echo "✅ Tests complete!"
