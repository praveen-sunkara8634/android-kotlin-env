#!/bin/bash

# Function to check if a command exists and get its version
check_command() {
    local name="$1"
    local cmd="$2"
    if command -v "$cmd" >/dev/null 2>&1; then
        local version=$($cmd --version | head -n 1)
        echo "$name: Installed ($version)"
    else
        echo "$name: Not Installed"
    fi
}

# Function to check Kotlin version specifically
check_kotlin_version() {
    if command -v kotlinc >/dev/null 2>&1; then
        local version=$(kotlinc -version 2>&1 | head -n 1)
        echo "Kotlin Compiler: Installed ($version)"
    else
        echo "Kotlin Compiler: Not Installed"
    fi
}

# Function to install a package if it's missing
install_package() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "$1 is not installed. Installing..."
        sudo apt-get update
        sudo apt-get install -y "$2"
    else
        echo "$1 is already installed."
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

# Function to verify installations and environment variables
verify_setup() {
    echo "Verifying installations and environment variables..."

    # Verify Java
    check_command "Java (JDK 11)" "java"

    # Verify Gradle
    check_command "Gradle" "gradle"

    # Verify Kotlin
    check_kotlin_version

    # Verify zip
    check_command "zip" "zip"

    # Verify environment variables
    echo
    echo "Checking environment variables..."
    if [ -n "$ANDROID_HOME" ]; then
        echo "ANDROID_HOME: $ANDROID_HOME"
    else
        echo "ANDROID_HOME: Not Set"
    fi

    if [ -n "$JAVA_HOME" ]; then
        echo "JAVA_HOME: $JAVA_HOME"
    else
        echo "JAVA_HOME: Not Set"
    fi
}

# Install zip
install_package zip zip

# Install SDKMAN if not already installed
if ! command -v sdk >/dev/null 2>&1; then
    echo "SDKMAN is not installed. Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
    source "$HOME/.sdkman/bin/sdkman-init.sh"
else
    echo "SDKMAN is already installed."
fi

# Install Gradle via SDKMAN
if ! command -v gradle >/dev/null 2>&1; then
    echo "Attempting to install Gradle via SDKMAN..."
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk install gradle
else
    echo "Gradle is already installed."
fi

# Install Kotlin Compiler via SDKMAN
if ! command -v kotlinc >/dev/null 2>&1; then
    echo "Attempting to install Kotlin Compiler via SDKMAN..."
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk install kotlin
else
    echo "Kotlin Compiler is already installed."
fi

# Install essential Linux utilities if missing
install_package curl curl
install_package wget wget
install_package unzip unzip
install_package git git

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

# Final verification of the setup
verify_setup

# Summary of whether you can proceed
echo
echo "Summary:"
if command -v java >/dev/null 2>&1 && command -v gradle >/dev/null 2>&1 && command -v kotlinc >/dev/null 2>&1 && [ -n "$ANDROID_HOME" ] && [ -n "$JAVA_HOME" ]; then
    echo "You are good to proceed with Android app development!"
else
    echo "Some components or environment variables are missing. Please install or set them before proceeding."
fi

echo "System setup complete."
