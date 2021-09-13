#!/bin/bash

# Environment Constants
# To update this constant, type in `date +%s` in your terminal and replace this number
CACHE_CLEARING_NEEDED_AT=1593312004

# Helper functions
pushd () {
    command pushd "$@" > /dev/null
}
popd () {
    command popd "$@" > /dev/null
}

bold=$(tput bold)
normal=$(tput sgr0)

red_echo() {
  RED='\033[0;31m'
  NC='\033[0m' # No Color
    echo -e "$RED$1$NC"
}

green_echo() {
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color
    echo -e "$GREEN${1}$NC"
}

yellow_echo() {
  YELLOW='\033[1;33m'
  NC='\033[0m' # No Color
    echo -e "$YELLOW$1$NC"
}

blue_echo() {
  BLUE='\033[0;34m'
  NC='\033[0m' # No Color
    echo -e "$BLUE$1$NC"
}

purple_echo() {
  PURPLE='\033[0;35m'
  NC='\033[0m' # No Color
    echo -e "$PURPLE$1$NC"
}

cyan_echo() {
  CYAN='\033[0;36m'
  NC='\033[0m' # No Color
    echo -e "$CYAN$1$NC"
}

white_echo() {
  WHITE='\033[1;37m'
  NC='\033[0m' # No Color
    echo -e "$WHITE$1$NC"
}

# Go to script directory
pushd "${0%/*}"

SECONDS=0

if [[ $1 = "" ]]; then
    
    echo "Generating......."
    python3 ./autobuild.py -w cabinet.xcworkspace -o ipas -i ipa -e appstore
    echo ""
    
    echo "Validating"
    xcrun altool --validate-app -f ./ipas/appstore/cabinet.ipa -t ios --apiKey 53668R5QZD --apiIssuer 53bf89c6-b9dd-43b5-906e-dbd0ed71648a --verbose
    echo ""
    
    echo "Uploading"
    xcrun altool --upload-app -f ./ipas/appstore/cabinet.ipa -t ios --apiKey 53668R5QZD --apiIssuer 53bf89c6-b9dd-43b5-906e-dbd0ed71648a --verbose
    echo ""

else
    echo " * Invalid command."
    exit 1
fi

duration=$SECONDS
echo
echo " * Hurray! * "
echo " * $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed. * "
echo
echo " * Finished! * "
