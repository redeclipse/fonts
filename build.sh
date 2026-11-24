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
    if [ -n "${6}" ]; then sed -i -e "s/^fontradius .*/&\nfontthicken ${6}/" "${r}/package.cfg"; fi
}

parse_font() {
    k=`echo "${2}" | sed -e "s/^.*-//;s/\.ttf$//;s/\([a-z]\)\([A-Z]\)/\1\/\2/g" | tr A-Z a-z`
    if [ "${k}" = "regular" ]; then k=""; fi
    # heavier weights take lighter edges and less of the engine's small text thickening, as their gaps close first
    case ${k} in
        black*)
            clearedge="0.47:0.53:0.47:0.53"; outlineedge="0.15:0.35:0.45:0.55"; thicken="0"
            ;;
        semibold*)
            clearedge="0.44:0.5:0.44:0.5"; outlineedge="0.15:0.35:0.42:0.52"; thicken="0.5"
            ;;
        bold*)
            clearedge="0.45:0.51:0.45:0.51"; outlineedge="0.15:0.35:0.43:0.53"; thicken="0.5"
            ;;
        *)
            clearedge="0.43:0.49:0.43:0.49"; outlineedge="0.15:0.35:0.4:0.5"; thicken=""
            ;;
    esac
    for m in ${FONTDEFS}; do
        case ${m} in
            clear)
                make_font "${1}" "clear" "${2}" "${k}" "8 ${clearedge} 10 5 0.75:2.5 1.25 30 30 512 512 20 40 64" "${thicken}"
                ;;
            outline)
                make_font "${1}" "outline" "${2}" "${k}" "8 ${outlineedge} 5 5 0.75:2.5 1.25 30 30 512 512 20 40 64" "${thicken}"
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
