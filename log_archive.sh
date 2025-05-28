#!/bin/bash

# Log Archive Tool
# Usage: log-archive <log-directory>
# Compresses logs and stores them with timestamp

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
show_usage() {
    echo "Usage: $0 <log-directory>"
    echo "Example: $0 /var/log"
    echo "Description: Archives logs by compressing them into a tar.gz file with timestamp"
}

# Function to log messages
log_message() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message"
}

# Function to display colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if correct number of arguments provided
if [ $# -ne 1 ]; then
    print_status $RED "Error: Incorrect number of arguments"
    show_usage
    exit 1
fi

LOG_DIRECTORY="$1"

# Check if log directory exists
if [ ! -d "$LOG_DIRECTORY" ]; then
    print_status $RED "Error: Directory '$LOG_DIRECTORY' does not exist"
    exit 1
fi

# Check if directory is readable
if [ ! -r "$LOG_DIRECTORY" ]; then
    print_status $RED "Error: No read permission for directory '$LOG_DIRECTORY'"
    exit 1
fi

# Check if directory contains any files
if [ -z "$(ls -A "$LOG_DIRECTORY" 2>/dev/null)" ]; then
    print_status $YELLOW "Warning: Directory '$LOG_DIRECTORY' is empty"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status $BLUE "Operation cancelled"
        exit 0
    fi
fi

# Generate timestamp for archive filename
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"

# Create archives directory if it doesn't exist
ARCHIVE_DIR="./log_archives"
if [ ! -d "$ARCHIVE_DIR" ]; then
    mkdir -p "$ARCHIVE_DIR"
    log_message "Created archive directory: $ARCHIVE_DIR"
fi

# Get absolute paths
LOG_DIR_ABS=$(realpath "$LOG_DIRECTORY")
ARCHIVE_DIR_ABS=$(realpath "$ARCHIVE_DIR")
ARCHIVE_PATH="$ARCHIVE_DIR_ABS/$ARCHIVE_NAME"

print_status $BLUE "Starting log archive process..."
log_message "Archiving logs from: $LOG_DIR_ABS"

# Create the tar.gz archive
print_status $BLUE "Compressing logs..."
if tar -czf "$ARCHIVE_PATH" -C "$(dirname "$LOG_DIR_ABS")" "$(basename "$LOG_DIR_ABS")" 2>/dev/null; then
    ARCHIVE_SIZE=$(du -h "$ARCHIVE_PATH" | cut -f1)
    print_status $GREEN "✓ Archive created successfully: $ARCHIVE_NAME ($ARCHIVE_SIZE)"
    log_message "Archive created: $ARCHIVE_PATH (Size: $ARCHIVE_SIZE)"
else
    print_status $RED "✗ Failed to create archive"
    log_message "ERROR: Failed to create archive $ARCHIVE_PATH"
    exit 1
fi

# Create/update archive log file
ARCHIVE_LOG_FILE="$ARCHIVE_DIR/archive_log.txt"
{
    echo "==========================================="
    echo "Archive Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Source Directory: $LOG_DIR_ABS"
    echo "Archive File: $ARCHIVE_NAME"
    echo "Archive Size: $ARCHIVE_SIZE"
    echo "Archive Location: $ARCHIVE_PATH"
    echo "Files Archived:"
    tar -tzf "$ARCHIVE_PATH" | head -20
    if [ $(tar -tzf "$ARCHIVE_PATH" | wc -l) -gt 20 ]; then
        echo "... and $(($(tar -tzf "$ARCHIVE_PATH" | wc -l) - 20)) more files"
    fi
    echo "==========================================="
    echo ""
} >> "$ARCHIVE_LOG_FILE"

print_status $GREEN "✓ Archive log updated: $ARCHIVE_LOG_FILE"

# Display summary
echo ""
print_status $BLUE "=== Archive Summary ==="
echo "Source: $LOG_DIR_ABS"
echo "Archive: $ARCHIVE_PATH"
echo "Size: $ARCHIVE_SIZE"
echo "Files: $(tar -tzf "$ARCHIVE_PATH" | wc -l)"
echo "Log: $ARCHIVE_LOG_FILE"

print_status $GREEN "Archive process completed successfully!"

# Optional: Ask if user wants to remove original logs (uncomment if needed)
# echo ""
# read -p "Remove original log files? (y/N): " -n 1 -r
# echo
# if [[ $REPLY =~ ^[Yy]$ ]]; then
#     print_status $YELLOW "Removing original log files..."
#     rm -rf "$LOG_DIRECTORY"/*
#     log_message "Original log files removed from $LOG_DIRECTORY"
#     print_status $GREEN "✓ Original log files removed"
# fi