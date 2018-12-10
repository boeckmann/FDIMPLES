#!/bin/sh

# PRERELEASE='.pre'
PRERELEASE=''

DESTINATION='Downloads'
RELEASE=0
FORMAT='zip'
PROJECT=$(echo ${PWD##*/})
TODAY=$(date +'%Y-%m-%d')
# VERSION=$(date +'%y.%m.%d')
VERSION=$(grep -i AppVersion SOURCE/VERSION.INC | cut -d "'" -f 2);

rm SOURCE/*.EXE >/dev/null
rm SOURCE/*.TPU >/dev/null

[[ -d "${HOME}/${DESTINATION}/${PROJECT}" ]] && rm -rf "${HOME}/${DESTINATION}/${PROJECT}"

# Standard binaries release

mkdir -p "${HOME}/${DESTINATION}/${PROJECT}"
cp -r BIN/* "${HOME}/${DESTINATION}/${PROJECT}/"

# ARCHIVE="${PROJECT}-${VERSION}-${RELEASE}${PRERELEASE}.${FORMAT}"
[[ "${PRERELEASE}" == "" ]] && ARCHIVE="${PROJECT}-${VERSION}.${FORMAT}" || ARCHIVE="${PROJECT}-${VERSION}-${PRERELEASE}.${FORMAT}"

while [[ -f "${HOME}/${DESTINATION}/${ARCHIVE}" ]] ; do
	(( RELEASE++ ))
	ARCHIVE="${PROJECT}-${VERSION}-${RELEASE}${PRERELEASE}.${FORMAT}"
done

if [[ -f 'README.txt' ]] ; then
	cp 'README.txt' "${HOME}/${DESTINATION}/${PROJECT}-README.txt"
fi;

CURDIR="$PWD"
cd "${HOME}/${DESTINATION}"
if [[ "$FORMAT" == "zip" ]] ; then
	zip -9 -r "${ARCHIVE}" "${PROJECT}/"*
fi;
cd "${CURDIR}"

rm -rf "${HOME}/${DESTINATION}/${PROJECT}"

# Package Release
mkdir -p "${HOME}/${DESTINATION}/${PROJECT}"
mkdir -p "${HOME}/${DESTINATION}/${PROJECT}/APPINFO"
[[ ${RELEASE} == 0 ]] && RNAME=${VERSION} || RNAME=${VERSION}-${RELEASE}
cat SOURCE/APPINFO.LSM | sed 's/\$VERSION\$/'${RNAME}/g | sed 's/\$DATE\$/'${TODAY}/g > "${HOME}/${DESTINATION}/${PROJECT}/APPINFO/${PROJECT}.LSM"

mkdir -p "${HOME}/${DESTINATION}/${PROJECT}/BIN"
cp -r BIN/*.EXE "${HOME}/${DESTINATION}/${PROJECT}/BIN"
mkdir -p "${HOME}/${DESTINATION}/${PROJECT}/NLS"
cp -r BIN/*.* "${HOME}/${DESTINATION}/${PROJECT}/NLS"
rm "${HOME}/${DESTINATION}/${PROJECT}/NLS/"*.EXE
[[ -e "${HOME}/${DESTINATION}/${PROJECT}/BIN/LICENSE" ]] && rm "${HOME}/${DESTINATION}/${PROJECT}/BIN/LICENSE"
mkdir -p "${HOME}/${DESTINATION}/${PROJECT}/DOC/${PROJECT}"
cp -r *.txt   "${HOME}/${DESTINATION}/${PROJECT}/DOC/${PROJECT}"
cp -r LICENSE "${HOME}/${DESTINATION}/${PROJECT}/DOC/${PROJECT}"
mkdir -p "${HOME}/${DESTINATION}/${PROJECT}/SOURCE/${PROJECT}"
cp -r * "${HOME}/${DESTINATION}/${PROJECT}/SOURCE/${PROJECT}"
rm -rf "${HOME}/${DESTINATION}/${PROJECT}/SOURCE/${PROJECT}/BIN"

mkdir -p "${HOME}/${DESTINATION}/${PROJECT}/SOURCE/${PROJECT}/SOURCE"
cp -r SOURCE/* "${HOME}/${DESTINATION}/${PROJECT}/SOURCE/${PROJECT}/SOURCE"

cd "${HOME}/${DESTINATION}"
[[ -f "${PROJECT}.zip" ]] && rm "${PROJECT}.zip"
cd "${PROJECT}"
zip -9 -r -k "../${PROJECT}.zip" *
cd "${CURDIR}"

rm -rf "${HOME}/${DESTINATION}/${PROJECT}"

echo "${HOME}/${DESTINATION}/${ARCHIVE}"
echo "${HOME}/${DESTINATION}/${PROJECT}.zip"
