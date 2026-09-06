cat << 'EOF' > deploy_local.sh
#!/usr/bin/env bash
set -e

echo "==> 1. Checking build prerequisites in Codespace..."
sudo apt-get update -qq
sudo apt-get install -y -qq libgtk-3-dev libsqlite3-dev ninja-build pkg-config cmake liblzma-dev > /dev/null

echo "==> 2. Building standalone Linux release in Codespace (Cloud VM)..."
flutter build linux --release

echo "==> 3. Bundling application payload..."
BUNDLE_DIR="build/linux/x64/release/bundle"
ARCHIVE_NAME="clinical_companion_bundle.tar.gz"

# Pack the pre-compiled binary and libraries
tar -czf "$ARCHIVE_NAME" -C "$BUNDLE_DIR" .

echo "==> 4. Prepared $ARCHIVE_NAME in workspace root."
echo "====================================================================="
echo "BUILD COMPLETE!"
echo "To stream and launch directly on your laptop without freezing:"
echo "Run the one-liner command below on your LOCAL LAPTOP TERMINAL:"
echo "====================================================================="
echo ""
echo "gh codespace cp -e 'remote:/workspaces/clinical_companion/$ARCHIVE_NAME' /tmp/$ARCHIVE_NAME && mkdir -p /tmp/clinical_companion && tar -xzf /tmp/$ARCHIVE_NAME -C /tmp/clinical_companion && /tmp/clinical_companion/clinical_companion &"
echo ""
echo "====================================================================="
EOF

chmod +x deploy_local.sh