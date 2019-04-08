#!/usr/bin/bash

# use TERM to exit on error
trap "exit 1" TERM
export TOP_PID=$$

# Blob hashes for validation

#
# Librem 13 v1 and Librem 15 v2 binary blob hashes
#
# microcode cpu306D4_platC0_ver0000002E_2019-06-13_PRD_88B9395D
BDW_UCODE_SHA="06eda7b55ebe50ea91636024a20176714f9daa6c6d247e154efda128dd099d1a"
# flash descriptor extracted from stock AMI firmware, unlocked, ME/BIOS regions resized
BDW_DESCRIPTOR_SHA="976209b5e2d5c19f92de770b1b619ddb38bf587cf01d8c57d70d2abd826d9e11"
# ME 10.0.32.1000 CON, run thru me_cleaner with '-S' param
BDW_ME_SHA="1e8f08c3eb31a0fdb91ec0222d4398b9192141502941a5262e9155915ffb6991"
# MRC blob, refcode extracted from google/tidus recovery image
BDW_MRC_SHA="dd05ab481e1fe0ce20ade164cf3dbef3c479592801470e6e79faa17624751343"
BDW_REFCODE_SHA="8a919ffece61ba21664b1028b0ebbfabcd727d90c1ae2f72b48152b8774323a4"

#
# Librem 13 v2/v3 and Librem 15 v3 binary blob hashes
#
# microcode cpu406E3_platC0_ver000000D4_2019-08-14_PRD_BD56B796
SKL_UCODE_SHA="e528d2ccc5d76cd04bfabb556a3fbb70b93d9aca43e291e0f0104fbaae5720fd"
# flash descriptor extracted from stock AMI firmware, unlocked, ME/BIOS regions resized
SKL_DESCRIPTOR_SHA="642ca36f52aabb5198b82e013bf64a73a5148693a58376fffce322a4d438b524"
# ME 11.0.18.1002 CON, run thru me_cleaner with '-S -w "MFS"' params
SKL_ME_SHA="cf06d3eb8b24490a1ab46fd988b6cef822e5347cd6a2e92bc332cb4a376eb8bc"

#
# Librem 13 v4 and Librem 15 v4 binary blob hashes
#
# microcode cpu806E9_platC0_ver000000C6_2019-08-14_PRD_98458A98
KBL_UCODE_SHA="bb07f0f77abe08e553f85b99d18fa129f991bf3613cf73d77c4f0ece87dd251e"
# flash descriptor extracted from stock AMI firmware, unlocked, ME/BIOS regions resized
KBL_DESCRIPTOR_SHA="642ca36f52aabb5198b82e013bf64a73a5148693a58376fffce322a4d438b524"
# ME 11.6.0.1126 CON, run thru me_cleaner  with '-S -w "MFS"' params
KBL_ME_SHA="0eec2e1135193941edd39d0ec0f463e353d0c6c9068867a2f32a72b64334fb34"

die () {
    local msg=$1

    if [ ! -z "$msg" ]; then
    echo ""
        echo -e "$msg"
    echo ""
    fi
    kill -s TERM $TOP_PID
    exit 1
}

verify_blob() {
    local filename=$1
    local hash=$2
    local description=$3

    if [[ -z "$filename" || -z "$hash" || -z "$description" ]]; then
        die "usage: verify_blob <file> <hash> <description>"
    fi
    sha=$(sha256sum "${BLOBS_DIR}/$filename" | awk '{print $1}')
    if [ "$sha" != "$hash" ]; then
        die "$description has the wrong SHA256 hash"
    fi
}

verify_blobs() {

    case $BOARD in

        "librem13v1" | "librem15v2" )
            BLOBS_DIR="3rdparty/blobs/mainboard/purism/librem_bdw"
            verify_blob cpu_microcode_blob.bin $BDW_UCODE_SHA "Intel Microcode Update"
            verify_blob descriptor.bin $BDW_DESCRIPTOR_SHA "Intel Flash Descriptor"
            verify_blob me.bin $BDW_ME_SHA "Intel ME firmware"
            verify_blob mrc.bin $BDW_MRC_SHA "Memory Reference Code"
            verify_blob refcode.elf $BDW_REFCODE_SHA "Silicon Init Reference Code"
            ;;
        "librem13v2" | "librem15v3" )
            BLOBS_DIR="3rdparty/blobs/mainboard/purism/librem_skl"
            verify_blob cpu_microcode_blob.bin $SKL_UCODE_SHA "Intel Microcode Update"
            verify_blob descriptor.bin $SKL_DESCRIPTOR_SHA "Intel Flash Descriptor"
            verify_blob me.bin $SKL_ME_SHA "Intel ME firmware"
            ;;
        "librem13v4" | "librem15v4" )
            BLOBS_DIR="3rdparty/blobs/mainboard/purism/librem_kbl"
            verify_blob cpu_microcode_blob.bin $KBL_UCODE_SHA "Intel Microcode Update"
            verify_blob descriptor.bin $KBL_DESCRIPTOR_SHA "Intel Flash Descriptor"
            verify_blob me.bin $KBL_ME_SHA "Intel ME firmware"
            ;;
    esac
}

update_crossgcc_toolchain() {
    # assume called from coreboot root dir

    local CURRENT_TOOLCHAIN_VERSION=0
    local GCC_FILE='util/crossgcc/xgcc/bin/i386-elf-gcc'
    local TARGET_TOOLCHAIN_VERSION="$(git log -n 1 --pretty=%h util/crossgcc)"

    if [ -f "${GCC_FILE}" ]; then
        CURRENT_TOOLCHAIN_VERSION=$(${GCC_FILE} --version | grep -m 1 'coreboot toolchain' | cut -f2 -d'v' | cut -f1 -d' ')
    fi
    if [ "${CURRENT_TOOLCHAIN_VERSION}" != "${TARGET_TOOLCHAIN_VERSION}" ]; then
        echo "coreboot toolchain version changed from ${CURRENT_TOOLCHAIN_VERSION} to ${TARGET_TOOLCHAIN_VERSION}"
        echo "Cleaning crossgcc compiler before rebuilding it"
        make crossgcc-clean
        make crossgcc-i386 CPUS=$(nproc)
        [ $? -ne 0 ] && die "Error building coreboot toolchain" || true
    fi
}

# check build target
build_targets=("librem13v1" "librem15v2" "librem13v2" "librem15v3" "librem13v4" "librem15v4")
if [[ ! " ${build_targets[@]} " =~ " $1 " ]]; then
    echo "You must specify a valid build target:"
    echo "${build_targets[@]}"
    exit 1
fi

BOARD=$1

verify_blobs

# check/build toolchain
update_crossgcc_toolchain || die

# do a clean build
make distclean

# copy config
cp configs/config.${BOARD} .config
make olddefconfig

# build coreboot and payload(s)
if ! make; then
    die "Error building coreboot"
fi
# get git rev
rev=$(git describe --tags --dirty)

# copy to root dir
filename="coreboot-${BOARD}-${rev}.rom"
cp build/coreboot.rom ./$filename
echo "$filename"

# print SHA for BIOS region (should match utility script)
util/ifdtool/ifdtool -x $filename >/dev/null
echo "SHA: $(sha256sum flashregion_1_bios.bin | awk '{print $1}')"
rm -f flashregion* 2>/dev/null

# add default bootorder
cbfstool $filename add -t raw -n bootorder -f bootorder.txt >/dev/null
