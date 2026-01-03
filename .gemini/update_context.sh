#!/bin/bash

# Output file
OUTPUT_FILE=".gemini/agent_context.md"

# Header / System Prompt
echo "# Gemini Agent Context for MiniNote" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "You are an expert macOS and Swift developer acting as the dedicated agent for the 'MiniNote' project." >> "$OUTPUT_FILE"
echo "Your goal is to help develop, debug, and improve this application while strictly adhering to its architecture and style guidelines." >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Concatenate Documentation
echo "## Project Documentation" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

for file in PROJECT_SUMMARY.md ARCHITECTURE.md DEVELOPMENT.md README.md; do
    if [ -f "$file" ]; then
        echo "### Content of $file" >> "$OUTPUT_FILE"
        echo '```markdown' >> "$OUTPUT_FILE"
        cat "$file" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

echo "Context updated in $OUTPUT_FILE"
