.PHONY: build run clean install release help

APP_NAME = MiniNote
BUILD_DIR = .build
RELEASE_DIR = $(BUILD_DIR)/release
DEBUG_DIR = $(BUILD_DIR)/debug
INSTALL_DIR = /Applications

help:
	@echo "MiniNote - Makefile"
	@echo ""
	@echo "Available commands:"
	@echo "  make build      - Build the app in debug mode"
	@echo "  make release    - Build the app in release mode (optimized)"
	@echo "  make run        - Build and run the app"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make install    - Install the app to /Applications"
	@echo "  make context    - Update Gemini Agent context from docs"
	@echo "  make help       - Show this help message"

context:
	@echo "Updating Gemini Agent context..."
	@./.gemini/update_context.sh

build:
	@echo "Building $(APP_NAME) in debug mode..."
	swift build

release:
	@echo "Building $(APP_NAME) in release mode..."
	swift build -c release
	@echo ""
	@echo "Build complete! Binary located at: $(RELEASE_DIR)/$(APP_NAME)"

run: build
	@echo "Running $(APP_NAME)..."
	@pkill $(APP_NAME) || true
	@sleep 1
	@$(DEBUG_DIR)/$(APP_NAME) &

clean:
	@echo "Cleaning build artifacts..."
	swift package clean
	rm -rf $(BUILD_DIR)

install: release
	@echo "Installing $(APP_NAME) to $(INSTALL_DIR)..."
	@if [ ! -d "$(INSTALL_DIR)" ]; then \
		echo "Error: $(INSTALL_DIR) does not exist"; \
		exit 1; \
	fi
	cp $(RELEASE_DIR)/$(APP_NAME) $(INSTALL_DIR)/$(APP_NAME)
	@echo "$(APP_NAME) installed successfully!"
	@echo "You can now run it from $(INSTALL_DIR)/$(APP_NAME)"
	@echo ""
	@echo "⚠️  Don't forget to grant Accessibility permissions:"
	@echo "   System Preferences > Privacy & Security > Accessibility"
