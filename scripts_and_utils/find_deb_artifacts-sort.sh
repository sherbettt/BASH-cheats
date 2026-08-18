#!/bin/bash

# alias ll='ls -alFS --group-directories-first --si --sort=version'

echo "TXT список"
    find ../deb_artifacts -name "runtel-*.deb" -type f | \
    sort -V | \
    awk -F'[_/]' '{
      pkg = $0
      sub(/_[^_]*$/, "", pkg)
      if (pkg != last) {
        print
        last = pkg
      }
    }' > /tmp/latest_files.txt
echo ""

echo "JSON список"
    find ../deb_artifacts -name "runtel-*.deb" -type f | \
    sort -V | \
    awk -F'[_/]' '{
      pkg = $0
      sub(/_[^_]*$/, "", pkg)
      if (pkg != last) {
        print
        last = pkg
      }
    }' | \
    jq -R -s -c 'split("\n") | map(select(length>0))' > /tmp/latest_files.json
echo ""

# Reverse
find /opt/runtel/robot/deb_artifacts -name "runtel-*.deb" -type f | \
sort -V | \
awk -F'[_/]' '{pkg=$0; sub(/_[^_]*$/, "", pkg); if (pkg != last) {print; last=pkg}}' | \
sort -rV
echo ""


echo "Получение только последних версий"
find ../deb_artifacts -name "runtel-*.deb" -type f | \
sort -rV | \
awk -F'/' '{
    file = $NF
    # Имя пакета - все ДО первого подчеркивания
    split(file, parts, "_")
    pkg = parts[1]
    # Если в имени пакета есть подчеркивания, собираем их обратно
    for (i = 2; i <= length(parts)-2; i++) {
        pkg = pkg "_" parts[i]
    }
    if (!seen[pkg]++) {
        print
    }
}' | sort -V
echo ""

echo "Получение только последних версий (2)"
find /opt/runtel/robot/deb_artifacts/ -name "runtel-*.deb" | sort -r | awk -F'/' '{print $NF}' | awk -F'_' '{pkg=$1; if (!seen[pkg]++) print}'


