#!/bin/bash

# Function to convert filename to LaTeX format
format_latex() {
    local filename="$1"
    # Replace 'in' with '\in'
    filename=$(echo "$filename" | sed 's/ in / \\in /g')
    # Escape # characters for LaTeX math mode using \sharp with space
    filename=$(echo "$filename" | sed 's/#/\\sharp /g')
    # Wrap in LaTeX math delimiters
    echo "\$${filename}\$"
}

# Function to URL encode filename
url_encode() {
    local filename="$1"
    # Use printf to properly URL encode special characters
    printf '%s\n' "$filename" | sed '
        s/ /%20/g
        s/#/%23/g
        s/|/%7C/g
        s/(/%28/g
        s/)/%29/g
        s/+/%2B/g
        s/\[/%5B/g
        s/\]/%5D/g
        s/{/%7B/g
        s/}/%7D/g
        s/&/%26/g
        s/?/%3F/g
        s/=/%3D/g
    '
}

# Create temporary file for new README content
temp_file=$(mktemp)

# Check if README.md exists
if [[ ! -f "README.md" ]]; then
    echo "README.md not found in current directory!"
    exit 1
fi

# Copy everything before "# Files" to temp file
sed '/^# Files/,$d' README.md > "$temp_file"

# Add the Files section header
echo "# Files" >> "$temp_file"
echo "" >> "$temp_file"

# Get all files except README.md, files.sh, and LICENSE and format them
for file in *; do
    # Skip README.md, files.sh, LICENSE files and directories
    if [[ "$file" != "README.md" && "$file" != "files.sh" && "$file" != "LICENSE" && -f "$file" ]]; then
        formatted=$(format_latex "$file")
        # URL encode the filename for proper GitHub linking
        encoded_file=$(url_encode "$file")
        echo "- $formatted: [qui](./$encoded_file)" >> "$temp_file"
    fi
done

# Replace the original README.md
mv "$temp_file" README.md

echo "README.md updated successfully!"
echo ""
echo "Added files:"
for file in *; do
    if [[ "$file" != "README.md" && "$file" != "files.sh" && "$file" != "LICENSE" && -f "$file" ]]; then
        formatted=$(format_latex "$file")
        # URL encode the filename for proper GitHub linking
        encoded_file=$(url_encode "$file")
        echo "  $formatted: [qui](./$encoded_file)"
    fi
done