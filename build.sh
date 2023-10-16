#!/bin/sh

TESSFONT=`echo "$(pwd)" | sed -e "s/data\/fonts/bin\/amd64\/tessfont.exe/"`
FONTDEFS="clear outline"

make_font() {
    r="${2}"
    if [ -n "${4}" ]; then r="${r}/${4}"; fi
    echo "BUILDING: ${1}/${3} = ${1}/${r}"
    mkdir -pv "${r}"
    rm -vf "${r}/package.cfg" "${r}/image"*
    echo "GENERATING: ${1}/${r} = ${5}"
    "${TESSFONT}" "${3}" "${1}/${r}" ${5} "fonts/${1}/${r}/"
    mv -vf "package.cfg" "${r}/"
    mv -vf "image"* "${r}/"
}

parse_font() {
    k=`echo "${2}" | sed -e "s/^.*-//;s/\.ttf$//;s/\([a-z]\)\([A-Z]\)/\1\/\2/g" | tr A-Z a-z`
    if [ "${k}" = "regular" ]; then k=""; fi
    for m in ${FONTDEFS}; do
        case ${m} in
            clear)
                make_font "${1}" "clear" "${2}" "${k}" "8 0.4:0.5:0.42:0.52 10 5 0.75:2.5 1.25 30 30 512 512 20 40 64"
                ;;
            outline)
                make_font "${1}" "outline" "${2}" "${k}" "8 0.15:0.35:0.35:0.55 5 5 0.75:2.5 1.25 30 30 512 512 20 40 64"
                ;;
            *)
                echo "Unknown font type: ${m}"
                ;;
        esac
    done
}

iterate_font() {
    if [ -d "${1}" ] && [ -d "${1}/static" ]; then
        pushd "${1}"
        if [ -z "${2}" ]; then
            for j in static/*.ttf; do
                parse_font "${1}" "${j}"
            done
        else
            parse_font "${1}" "${2}"
        fi
        popd
    fi
}

if [ -n "${3}" ]; then
    FONTDEFS="${3}"
fi

if [ -z "${1}" ]; then
    for i in *; do
        iterate_font "${i}" "${2}"
    done
else
    iterate_font "${1}" "${2}"
fi
