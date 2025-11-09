#!/bin/bash
#
# Behringer UMC404HD Stereo Remap Fix for PipeWire/Ubuntu
#
# This script creates a persistent configuration file for PipeWire's
# PulseAudio compatibility layer (pipewire-pulse) that forces the standard
# stereo stream (used by browsers, Spotify, etc.) to output channels 3 and 4
# (Rear Left/Right) of the UMC404HD. This resolves the common issue where 
# speakers connected to outputs 3/4 produce no sound from applications.

# --- Configuration Variables ---
# The name of the master sink (found via 'pactl list sinks short')
MASTER_SINK_NAME="alsa_output.usb-BEHRINGER_UMC404HD_192k-00.analog-surround-40"

# The friendly name for the new virtual sink
VIRTUAL_SINK_NAME="umc404hd_prime"
VIRTUAL_SINK_DESC="UMC404 Prime Output"

# File paths
CONFIG_DIR="$HOME/.config/pipewire/pipewire-pulse.conf.d"
CONFIG_FILE="$CONFIG_DIR/50-umc404hd-remap.conf"

# --- Functions ---

log_info() {
    echo -e "\n\033[1;34m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\n\033[1;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\n\033[1;31m[ERROR]\033[0m $1" >&2
}

# --- Main Script ---

log_info "Starting UMC404HD PipeWire Configuration Setup..."

# 1. Verify necessary commands are available
if ! command -v systemctl &> /dev/null || ! command -v pactl &> /dev/null; then
    log_error "Required tools (systemctl or pactl) not found. Are you on a modern Linux distro with PipeWire?"
    exit 1
fi

# 2. Stop PipeWire services gracefully
log_info "Stopping PipeWire services to apply new configuration..."
systemctl --user stop pipewire.service || log_error "PipeWire service stop failed (may be inactive)."
systemctl --user stop pipewire-pulse.service || log_error "PipeWire-Pulse service stop failed (may be inactive)."

# 3. Create necessary configuration directory
log_info "Creating configuration directory: $CONFIG_DIR"
mkdir -p "$CONFIG_DIR"

# 4. Generate the PipeWire configuration file
log_info "Generating persistent remap configuration file: $CONFIG_FILE"

# The module remaps FL/FR audio to the master sink's RL/RR channels.
CONFIG_CONTENT="
# Behringer UMC404HD Stereo Remap for PipeWire
# Automatically loads the custom remap sink on startup.

pulse.cmd = [
    {
        cmd = \"load-module\"
        args = \"module-remap-sink sink_name=${VIRTUAL_SINK_NAME} master=${MASTER_SINK_NAME} master_channel_map=rear-left,rear-right channels=2 channel_map=front-left,front-right sink_properties='device.description=\"${VIRTUAL_SINK_DESC}\"'\"
        flags = [ ]
    }
    {
        cmd = \"set-default-sink\"
        args = \"${VIRTUAL_SINK_NAME}\"
        flags = [ ]
    }
]
"

echo "$CONFIG_CONTENT" > "$CONFIG_FILE"
chmod 644 "$CONFIG_FILE"

# 5. Start PipeWire services
log_info "Starting PipeWire services to apply changes..."
systemctl --user start pipewire.service || log_error "PipeWire service failed to start."
systemctl --user start pipewire-pulse.service || log_error "PipeWire-Pulse service failed to start."

log_success "Configuration applied successfully!"
log_info "Please REBOOT your system now for a complete and persistent fix."
log_info "After reboot, open pavucontrol and check the Playback tab."
log_info "The default output should be set to: '${VIRTUAL_SINK_DESC}'"

exit 0