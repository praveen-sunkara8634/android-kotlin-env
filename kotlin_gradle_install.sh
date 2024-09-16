#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if SDKMAN is installed
check_sdkman_installed() {
    if ! command_exists sdk; then
        echo "SDKMAN is not installed. Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    else
        echo "SDKMAN is already installed."
    fi
}

# Function to install a tool via SDKMAN and explain failures
install_with_sdkman() {
    local tool="$1"
    if ! command_exists "$tool"; then
        echo "Attempting to install $tool via SDKMAN..."
        source "$HOME/.sdkman/bin/sdkman-init.sh"
        sdk install "$tool"

        # Check if the installation was successful
        if command_exists "$tool"; then
            echo "$tool successfully installed."
        else
            echo "Failed to install $tool."
            echo "Possible reasons:"
            echo "1. Internet connectivity issues: Make sure your WSL has access to the internet."
            echo "2. SDKMAN installation failed: Check if SDKMAN is installed and sourced correctly."
            echo "3. Permission issues: Run the script with appropriate permissions."
        fi
    else
        echo "$tool is already installed."
    fi
}

# Function to set environment variables in .bashrc
set_env_variable() {
    local var_name="$1"
    local var_value="$2"
    local file="$HOME/.bashrc"

    if ! grep -q "export $var_name" "$file"; then
        echo "Setting $var_name in $file..."
        echo "export $var_name=$var_value" >> "$file"
        echo "export PATH=\$$var_name/bin:\$PATH" >> "$file"
    fi
    source "$file"
}

# Install SDKMAN if not already installed
check_sdkman_installed

# Install Gradle via SDKMAN and provide feedback on failure
install_with_sdkman "gradle"

# Install Kotlin via SDKMAN and provide feedback on failure
install_with_sdkman "kotlin"

# Set ANDROID_HOME and JAVA_HOME if not already set
echo "Checking and setting environment variables..."

if [ -z "$ANDROID_HOME" ]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
    set_env_variable "ANDROID_HOME" "$HOME/Android/Sdk"
    echo "ANDROID_HOME is now set to $ANDROID_HOME"
else
    echo "ANDROID_HOME is already set to $ANDROID_HOME"
fi

if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME="$(dirname $(dirname $(readlink -f $(which java))))"
    set_env_variable "JAVA_HOME" "$JAVA_HOME"
    echo "JAVA_HOME is now set to $JAVA_HOME"
else
    echo "JAVA_HOME is already set to $JAVA_HOME"
fi

# Verify if everything is installed correctly
echo "Verifying installations and environment variables..."

# Check for Gradle
if command_exists gradle; then
    echo "Gradle is installed."
else
    echo "Gradle is still not installed. Please check internet connectivity or SDKMAN setup."
fi

# Check for Kotlin
if command_exists kotlinc; then
    echo "Kotlin Compiler is installed."
else
    echo "Kotlin Compiler is still not installed. Please check internet connectivity or SDKMAN setup."
fi

# Verify environment variables
if [ -n "$ANDROID_HOME" ]; then
    echo "ANDROID_HOME is set to $ANDROID_HOME."
else
    echo "ANDROID_HOME is not set. Please configure your Android SDK path."
fi

if [ -n "$JAVA_HOME" ]; then
    echo "JAVA_HOME is set to $JAVA_HOME."
else
    echo "JAVA_HOME is not set. Please configure your JDK path."
fi

echo "Script execution complete."

