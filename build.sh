#!/bin/sh

TESSFONT=`echo "$(pwd)" | sed -e "s/data\/fonts/bin\/amd64\/tessfont.exe/"`

make_font() {
    r="${2}"
    if [ -n "${4}" ]; then r="${r}/${4}"; fi
    echo mkdir -pv "${r}"
    echo "${TESSFONT}" "${3}" "${1}/${r}" ${5} "fonts/${1}/${r}/"
    echo mv -vf package.cfg "${r}/"
    echo mv -vf image*.png "${r}/"
}

for i in *; do
    if [ -d "${i}" ] && [ -d "${i}/static" ]; then
        pushd "${i}"
        for j in static/*.ttf; do
            k=`echo "${j}" | sed -e "s/^.*-//;s/\.ttf$//;s/\([a-z]\)\([A-Z]\)/\1\/\2/g" | tr A-Z a-z`
            if [ "${k}" = "regular" ]; then k=""; fi
            echo "${i} - ${j} = ${k}"
            make_font "${i}" "clear" "${j}" "${k}" "8 0.4:0.5:0.42:0.52 10 5 0.75:2.5 1.25 30 30 512 512 20 40 64"
        done
        popd
    fi
done
