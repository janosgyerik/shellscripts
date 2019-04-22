#!/usr/bin/env bash
#
# SCRIPT: extract-audio-from-video.sh
# AUTHOR: janos <janos@kronos>
# DATE:   2019-04-22
#
# PLATFORM: Not platform dependent
#

set -euo pipefail

fatal() {
    echo "Error: $@"
    exit 1
}

require() {
    local program all_ok=1
    for program; do
        if ! type "$program" &>/dev/null; then
            echo "Error: the required program '$program' is not installed or not in PATH"
            all_ok=
        fi
    done
    test "$all_ok" || exit 1
}

require ffmpeg

usage() {
    local exitcode=0
    if test $# != 0; then
        echo "$@"
        exitcode=1
    fi
    cat << EOF
Usage: $0 [OPTION]... [--mp3|--ogg] [VIDEO-FILE]...

Extract audio content from video files

Options:
  -m, --mp3          Use libmp3lame audio codec
  -o, --ogg          Use libvorbis audio codec

  -d, --dir DIR      Target directory to create audio files

  -h, --help         Print this help

EOF
    exit $exitcode
}

check_no_acodec() {
    test "$acodec" && fatal "audio codec already specified as $acodec" || :
}

args=()
acodec=
ext=
targetDir=
while test $# != 0; do
    case $1 in
    -h|--help) usage ;;
    -m|--mp3) check_no_acodec; acodec=libmp3lame; ext=mp3 ;;
    -o|--ogg) check_no_acodec; acodec=libvorbis; ext=ogg ;;
    -d|--dir) shift; targetDir=$1 ;;
    --) shift; while test $# != 0; do args+=("$1"); shift; done; break ;;
    -|-?*) usage "Unknown option: $1" ;;
    *) args+=("$1") ;;
    esac
    shift
done

set -- "${args[@]}"

test $# != 0 || fatal "specify video files from which to extract audio"
test "$acodec" || fatal "specify audio codec to use to encode extracted audio content"

for path; do
    target=${path%.*}.$ext
    if test "$targetDir"; then
        target=$targetDir/$(basename "$target")
    fi
    ffmpeg -i "$path" -vn -acodec "$acodec" "$target"
done
