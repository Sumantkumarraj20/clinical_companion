import os

# Dynamically look for the path where this script is running
PROJECT_ROOT = os.path.dirname(os.path.abspath(__file__))
PUBSPEC_PATH = os.path.join(PROJECT_ROOT, "pubspec.yaml")
LAUNCHER_ICONS_CONFIG_PATH = os.path.join(PROJECT_ROOT, "flutter_launcher_icons.yaml")
LINUX_CC_PATH = os.path.join(PROJECT_ROOT, "linux", "my_application.cc")

# Source icon file path (verify this folder path matches your assets)
ICON_SOURCE_PATH = "assets/icon/icon.png"  

print(f"🚀 Starting Universal App Icon Configuration inside: {PROJECT_ROOT}")

# ---------------------------------------------------------
# Step 1: Update pubspec.yaml dev_dependencies
# ---------------------------------------------------------
if os.path.exists(PUBSPEC_PATH):
    print("📝 Modifying pubspec.yaml to add flutter_launcher_icons...")
    with open(PUBSPEC_PATH, "r") as f:
        content = f.read()

    if "dev_dependencies:" in content:
        if "flutter_launcher_icons:" not in content:
            updated_content = content.replace(
                "dev_dependencies:",
                "dev_dependencies:\n  flutter_launcher_icons: ^0.13.1"
            )
            with open(PUBSPEC_PATH, "w") as f:
                f.write(updated_content)
            print("  ✅ Added flutter_launcher_icons to dev_dependencies.")
        else:
            print("  ℹ️ flutter_launcher_icons already exists in pubspec.yaml.")
else:
    print(f"  ❌ Error: pubspec.yaml not found at {PUBSPEC_PATH}!")

# ---------------------------------------------------------
# Step 2: Generate flutter_launcher_icons.yaml
# ---------------------------------------------------------
print("📝 Creating flutter_launcher_icons.yaml configuration...")
launcher_config = f"""flutter_launcher_icons:
  android: "launcher_icon"
  ios: true
  image_path: "{ICON_SOURCE_PATH}"
  
  windows:
    generate: true
    image_path: "{ICON_SOURCE_PATH}"
    icon_size: 48

  macos:
    generate: true
    image_path: "{ICON_SOURCE_PATH}"
"""

with open(LAUNCHER_ICONS_CONFIG_PATH, "w") as f:
    f.write(launcher_config)
print("  ✅ Created flutter_launcher_icons.yaml successfully.")

# ---------------------------------------------------------
# Step 3: Inject Dynamic Taskbar Icon into Linux Source
# ---------------------------------------------------------
if os.path.exists(LINUX_CC_PATH):
    print("📝 Patching linux/my_application.cc for window icons...")
    with open(LINUX_CC_PATH, "r") as f:
        cc_content = f.read()

    if "gtk_window_set_default_icon_from_file" not in cc_content:
        target_marker = "gtk_window_set_default_size"
        if target_marker in cc_content:
            injection_code = (
                f'gtk_window_set_default_icon_from_file("{PROJECT_ROOT}/{ICON_SOURCE_PATH}", NULL);\n  '
                f'gtk_window_set_default_size'
            )
            updated_cc = cc_content.replace(target_marker, injection_code)
            with open(LINUX_CC_PATH, "w") as f:
                f.write(updated_cc)
            print("  ✅ Linux window title/taskbar icon code injected successfully.")
        else:
            print("  ⚠️ Could not find exact injection point in my_application.cc automatically.")
    else:
        print("  ℹ️ Linux window icon logic already exists.")
else:
    print("  ℹ️ Linux folder or my_application.cc not present. Skipping Linux C++ modification.")

print("\n🎉 File editing complete! Please run the terminal commands next.")
