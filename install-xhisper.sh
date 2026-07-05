#!/bin/bash
set -euo pipefail

echo "=== TuxSpeak - One-Click Installer ==="
echo ""

# Check dependencies
echo "Checking dependencies..."
MISSING=""
for dep in curl jq ffmpeg gcc make yad xdotool xclip; do
  if ! command -v "$dep" &>/dev/null; then
    MISSING="$MISSING $dep"
  fi
done

if [ -n "$MISSING" ]; then
  echo "Installing missing packages:$MISSING"
  sudo apt update -qq
  sudo apt install -y $MISSING
else
  echo "All dependencies present."
fi

# Ensure pipewire tools are available (for pw-record)
if ! command -v pw-record &>/dev/null; then
  echo "Installing pipewire tools..."
  sudo apt install -y pipewire-utils 2>/dev/null || sudo apt install -y pipewire 2>/dev/null || true
fi

# Create directories
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/xhisper
mkdir -p ~/.local/share/applications
mkdir -p ~/.config/xhisper
mkdir -p ~/.config/autostart

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Copy scripts
echo "Installing scripts..."
cp "$SCRIPT_DIR/scripts/xhisper-gemini" ~/.local/bin/
cp "$SCRIPT_DIR/scripts/xhisper-gui" ~/.local/bin/
cp "$SCRIPT_DIR/scripts/xhisper-history" ~/.local/bin/
cp "$SCRIPT_DIR/scripts/xhisper-last" ~/.local/bin/
cp "$SCRIPT_DIR/scripts/xhisper-polished" ~/.local/bin/
chmod +x ~/.local/bin/xhisper-*

# Copy desktop entries
echo "Installing desktop entries..."
cp "$SCRIPT_DIR/desktop/xhisper-quick.desktop" ~/.local/share/applications/
cp "$SCRIPT_DIR/desktop/xhisper-history.desktop" ~/.local/share/applications/
chmod +x ~/.local/share/applications/xhisper-*.desktop

# Copy autostart
cp "$SCRIPT_DIR/desktop/xhispertoold.desktop" ~/.config/autostart/

# Prompt for API keys
echo "Setting up API keys..."
touch ~/.env

if ! grep -q "GROQ_API_KEY" ~/.env 2>/dev/null; then
  echo ""
  echo "============================================"
  echo "  API keys needed:"
  echo "  - Groq API key (free): https://console.groq.com/keys"
  echo "  - Gemini API key (free): https://aistudio.google.com/apikey"
  echo "============================================"
  echo ""
  read -rp "Enter your Groq API key: " GROQ_KEY
  read -rp "Enter your Gemini API key: " GEMINI_KEY
  [ -n "$GROQ_KEY" ] && echo "GROQ_API_KEY=$GROQ_KEY" >> ~/.env
  [ -n "$GEMINI_KEY" ] && echo "GEMINI_API_KEY=$GEMINI_KEY" >> ~/.env
  echo "  API keys saved to ~/.env"
else
  echo "  API keys already in ~/.env"
fi

# Build and install xhisper C tools from source
echo "Building xhisper from source..."
if [ -d "$SCRIPT_DIR/xhisper-src" ]; then
  cd "$SCRIPT_DIR/xhisper-src"
  make clean 2>/dev/null || true
  make
  sudo make install
  echo "  xhispertool and xhispertoold installed to /usr/local/bin/"
else
  echo "WARNING: xhisper source not found. Cloning from GitHub..."
  cd /tmp
  rm -rf xhisper-build
  git clone https://github.com/imaginalnika/xhisper.git xhisper-build
  cd xhisper-build
  make
  sudo make install
  echo "  xhispertool and xhispertoold installed to /usr/local/bin/"
fi

# Set up udev rule for uinput
echo "Setting up uinput access..."
sudo bash -c 'echo "KERNEL==\"uinput\", MODE=\"0660\", GROUP=\"input\", OPTIONS+=\"static_node=uinput\"" > /etc/udev/rules.d/99-uinput.rules'
sudo udevadm control --reload-rules
sudo udevadm trigger

# Add user to input group
if ! groups | grep -q input; then
  echo "Adding $USER to input group..."
  sudo usermod -aG input "$USER"
  NEED_REBOOT=true
else
  NEED_REBOOT=false
fi

# Ensure ~/.local/bin is in PATH
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
  export PATH="$HOME/.local/bin:$PATH"
fi

# Start the daemon
echo "Starting xhispertoold daemon..."
nohup xhispertoold &>/dev/null &

echo ""
echo "============================================"
echo "  TuxSpeak installed successfully!"
echo "============================================"
echo ""
echo "API keys: DONE (Groq + Gemini baked in)"
echo ""
echo "Set up keyboard shortcut:"
echo "  Settings > Keyboard > Custom Shortcuts > +"
echo "  Name: xhisper-gemini"
echo "  Command: xhisper-gemini"
echo "  Shortcut: Alt+Space"
echo ""
if [ "$NEED_REBOOT" = true ]; then
  echo "*** REBOOT REQUIRED for uinput group access ***"
else
  echo "Ready to use! Try running: xhisper-gemini"
fi
