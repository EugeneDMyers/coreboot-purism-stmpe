#!/usr/bin/bash

# use TERM to exit on error
trap "exit 1" TERM
export TOP_PID=$$

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
BOARD=$1
if [[ ! -f configs/config.${BOARD} ]]; then
	echo "Error: You must specify a valid build target"
	exit 1
fi

# checkout/update submodules
make gitconfig || true
git submodule update --init 2>/dev/null || die "unable to update submodules"

# verify submodules clean
git submodule foreach 'git reset --hard' >/dev/null 2>&1
if [[ "`git diff 3rdparty`" != "" ]]; then
	git sup  >/dev/null 2>&1
	[[ "`git diff 3rdparty`" != "" ]] && \
		die "submodules have been modified; build would not be reproducible"
fi

# check/build toolchain
update_crossgcc_toolchain || die

# do a clean build
rm -rf ./build || true
#make distclean

# copy config
cp configs/config.${BOARD} .config
make olddefconfig >/dev/null

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

# add an 8s boot delay for the Librem Mini so splash screen
# actually shown on displays with sluggish init
if [[ ${BOARD^^} == "LIBREM_MINI" ]]; then
	cbfstool $filename add-int -i 8000 -n etc/boot-menu-wait >/dev/null
fi
