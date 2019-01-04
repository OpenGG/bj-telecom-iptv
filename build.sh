#!/usr/bin/env bash

set -e

serverDefault="http://192.168.198.11:8012"
server="${serverDefault}"
input=""

while getopts "i:s:" opt; do
  case ${opt} in
    i)
      input="${OPTARG}"
      ;;
    s)
      server="${OPTARG}"
      ;;
    h)
      echo ""
      echo "Usage:"
      echo "  build.sh -h                                      Display this help message."
      echo "  build.sh -i input.m3u [-s address] output.m3u    Build m3u file."
      echo ""
      echo ""
      echo "Example:"
      echo "  build.sh -i docs/iptv-multicast.m3u -s ${serverDefault} docs/iptv.m3u"
      echo ""
      exit 0
      ;;
    \?)
      echo ""
      echo "  Error: Invalid Option: -$OPTARG" 1>&2
      echo ""
      exit 1
      ;;
    :)
      echo ""
      echo "  Error: Invalid Option: -$OPTARG requires an argument" 1>&2
      echo ""
      exit 2
      ;;
  esac
done
shift $((OPTIND -1))

output="$1"

echo ""
echo "  Input m3u file: ${input}"
echo "  Output m3u file: ${output}"
echo "  Server: ${server}"
echo ""

if [ "" == "${input}" ]; then
  echo ""
  echo "  Error: Input file not provided"
  echo ""
  exit 3
fi

if [ ! -e "${input}" ]; then
  echo ""
  echo "  Error: Input file not exists: ${input}"
  echo ""
  exit 4
fi

if [ "" == "${output}" ]; then
  echo ""
  echo "  Error: Output path not provided"
  echo ""
  exit 5
fi

if [ -e "${output}" ]; then
  echo ""
  echo "  Error: Output file exists: ${output}"
  echo ""
  exit 6
fi

matchM3U=`head -n 3 "${input}" |grep -i EXTM3U`

if [ "" == "$matchM3U" ]; then
  echo ""
  echo "  Error: Input file not m3u format: ${input}"
  echo ""
  exit 7
fi

echo ""
echo "  Generating..."
echo ""

sed "s|rtp://|${server}/rtp/|g" "${input}" > "${output}"

echo ""
echo "  Done."
echo ""
