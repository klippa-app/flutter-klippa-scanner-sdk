#!/bin/bash

# A script to update the fallback versions of the Klippa Scanner SDK for both Android and iOS. It also updates the version number in pubspec.yaml and adds a new entry to CHANGELOG.md with the updated versions.

current_android_fallback_version=$(grep "def fallbackKlippaScannerVersion" ../android/build.gradle | awk '{print $4}' | tr -d \''"\')
echo "Current Android SDK fallback version: $current_android_fallback_version"

# Prompt user for new build.gradle fallbackKlippaScannerVersion
read -p "Enter new Android SDK fallback version: " new_android_fallback_version

if [[ -z "$new_android_fallback_version" ]]; then
  # Skip this version change
  echo "Skipping Android version change"
else
  # Update build.gradle
  sed -e "s/def fallbackKlippaScannerVersion = \"$current_android_fallback_version\"/def fallbackKlippaScannerVersion = \"$new_android_fallback_version\"/g" ../android/build.gradle > build.gradle.tmp
  mv build.gradle.tmp ../android/build.gradle
  echo "Succesfully updated Android version change"
fi

# Get current .sdk_version
current_ios_fallback_version=$(cat ../ios/.sdk_version)
echo "Current iOS SDK fallback version: $current_ios_fallback_version"

# Prompt user for new .sdk_version
read -p "Enter new iOS SDK fallback version: " new_ios_fallback_version

if [[ -z "$new_ios_fallback_version" ]]; then
  # Skip this version change
  echo "Skipping iOS version change"
else
  # Update .sdk_version
  echo "$new_ios_fallback_version" > ../ios/.sdk_version
  echo "Succesfully updated iOS version change"
fi

if [ -z "$new_android_fallback_version" ] && [ -z "$new_ios_fallback_version" ]; then
  # new_android_fallback_version and new_ios_fallback_version are both empty, so don't update the changelog
  echo "Error: Nothing was incremented. Exiting."
  exit 1
fi

# Get current pubspec.yaml version
current_package_version=$(yq -r '.version' ../pubspec.yaml)
echo "Current pubspec.yaml version: $current_package_version"

# Prompt user for new pubspec.yaml version
while true; do
  read -r -p "Enter new pubspec.yaml version: " new_package_version
  if [ -z "$new_package_version" ]; then
    # new_package_version is empty, so ask the user again
    echo "Error: Please enter a valid version."
  else
    # new_package_version is not empty, so break out of the loop
    break
  fi
done

# Update pubspec.yaml version
yq -i ".version = \"$new_package_version\"" ../pubspec.yaml # > pubspec.yaml.tmp
# mv pubspec.yaml.tmp ../pubspec.yaml
echo "Succesfully updated pubspec.yaml"


# Save the contents of CHANGELOG.md to a variable
changelog=$(cat ../CHANGELOG.md)

# Add the new markdown at the top of the file

if [ -z "$new_android_fallback_version" ]; then
  # new_android_fallback_version is empty, so don't include it in the changelog
  echo "## $new_package_version

* Bump iOS to $new_ios_fallback_version

$changelog" > ../CHANGELOG.md
elif [ -z "$new_ios_fallback_version" ]; then
  # new_ios_fallback_version is empty, so don't include it in the changelog
  echo "## $new_package_version

* Bump Android to $new_android_fallback_version

$changelog" > ../CHANGELOG.md
else
  # new_android_fallback_version and new_ios_fallback_version are both not empty, so include both in the changelog
  echo "## $new_package_version

* Bump Android to $new_android_fallback_version
* Bump iOS to $new_ios_fallback_version

$changelog" > ../CHANGELOG.md
fi

echo "Succesfully updated CHANGELOG.md"
echo "Script completed successfully"
