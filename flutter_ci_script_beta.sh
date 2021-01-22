#!/usr/bin/env bash

set -e -o pipefail

if  [[ -n "$(type -t flutter)" ]]; then
  : ${FLUTTER:=flutter}
fi
echo "== FLUTTER: $FLUTTER"

FLUTTER_VERS=`$FLUTTER --version | head -1`
echo "== FLUTTER_VERS: $FLUTTER_VERS"

# plugin_codelab is a special case since it's a plugin.  Analysis doesn't seem to be working.
pushd $PWD
echo "== TESTING plugin_codelab"
cd ./plugin_codelab
$FLUTTER format --dry-run --set-exit-if-changed .;
popd

declare -ar CODELABS=(
  # Tracking issue: https://github.com/flutter/flutter/issues/74174
  # "add_flutter_to_android_app" 
  # Tracking issue: https://github.com/flutter/flutter/issues/74203
  # "cupertino_store" 
  # Tracking issue: https://github.com/flutter/flutter/issues/74204
  # "firebase-get-to-know-flutter" 
  # Tracking issue: https://github.com/flutter/flutter/issues/74205
  # "github-graphql-client"
  # Tracking issue: https://github.com/flutter/flutter/issues/74206
  # "google-maps-in-flutter" 
  # Tracking issue: https://github.com/flutter/flutter/issues/74207
  # "plugin_codelab" 
  # Tracking issue: https://github.com/flutter/flutter/issues/74208
  # "startup_namer" 
  # Tracking issue: https://github.com/flutter/flutter/issues/74209
  # "testing_codelab"
  )

declare -a PROJECT_PATHS=($(
  for CODELAB in "${CODELABS[@]}"
  do 
    find $CODELAB -not -path './flutter/*' -not -path './plugin_codelab/pubspec.yaml' -name pubspec.yaml -exec dirname {} \; 
  done
  ))

for PROJECT in "${PROJECT_PATHS[@]}"; do
  echo "== TESTING $PROJECT"
  $FLUTTER create --no-overwrite "$PROJECT"
  (
    cd "$PROJECT";
    set -x;
    $FLUTTER analyze;
    $FLUTTER format --dry-run --set-exit-if-changed .;
    $FLUTTER test
  )
done

echo "== END OF TESTS"