#!/bin/bash

# Update consolidated GEMINI.md in root
echo "# GEMINI.md - Consolidated Project Documentation" > GEMINI.md
echo "" >> GEMINI.md
echo "This file contains a concatenation of all markdown documentation files in the repository." >> GEMINI.md
echo "It is intended to provide a comprehensive context for the Gemini agent." >> GEMINI.md
echo "" >> GEMINI.md

for file in PROJECT_SUMMARY.md ARCHITECTURE.md DEVELOPMENT.md QUICKSTART.md README.md PROJECT_STATS.md CHANGELOG.md _TODO.md; do
    if [ -f "$file" ]; then
        echo "---" >> GEMINI.md
        echo "" >> GEMINI.md
        echo "## Content of $file" >> GEMINI.md
        echo "" >> GEMINI.md
        cat "$file" >> GEMINI.md
        echo "" >> GEMINI.md
    fi
done

# Output internal agent context file
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

for file in PROJECT_SUMMARY.md ARCHITECTURE.md DEVELOPMENT.md README.md PROJECT_STATS.md; do
    if [ -f "$file" ]; then
        echo "### Content of $file" >> "$OUTPUT_FILE"
        echo '```markdown' >> "$OUTPUT_FILE"
        cat "$file" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

echo "Context updated in GEMINI.md and $OUTPUT_FILE"