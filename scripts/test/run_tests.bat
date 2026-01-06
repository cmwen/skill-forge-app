@echo off
REM Run all tests with coverage

echo Running Skill Forge Tests...
echo.

REM Clean previous coverage
if exist coverage rmdir /s /q coverage

REM Run tests with coverage
flutter test --coverage

echo.
echo Tests complete!
echo Coverage report: coverage\lcov.info
echo.
echo To view coverage in VS Code:
echo 1. Install "Coverage Gutters" extension
echo 2. Open Command Palette (Ctrl+Shift+P)
echo 3. Run "Coverage Gutters: Display Coverage"
