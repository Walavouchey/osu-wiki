WARN_ON_SIZE=500000
ERROR_ON_SIZE=1000000
EXIT=0
FIRST_COMMIT_HASH=$1
LAST_COMMIT_HASH=$2

# https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit
function echo_red () { echo -e "\e[0;31m$1\e[m"; }
function echo_green () { echo -e "\e[0;32m$1\e[m"; }
function echo_yellow () { echo -e "\e[0;34m$1\e[m"; }

while read file
do
  echo "Checking ${file}..."
  # git ls-tree will output:
  # (file mode) (file type) (blob hash)<TAB>(file name)
  # we're interested in the hash to pull the file's size using cat-file
  hash=`git ls-tree ${LAST_COMMIT_HASH} "${file}" | awk -F ' ' '{ print $3 }'`
  filesize=`git cat-file -s ${hash} 2>/dev/null`

  if [[ ${filesize} -ge ${ERROR_ON_SIZE} ]]; then
      echo -e "$( echo_red 'Error:' ) The size of \"${file}\" exceeds 1MB. Compress it to optimise performance."
      EXIT=1
  elif [[ ${filesize} -ge ${WARN_ON_SIZE} ]]; then
      echo -e "$( echo_yellow 'Warning:' ) The size of \"${file}\" exceeds 500kB. Consider compressing it to optimise performance."
  #else
  #    echo "::debug::File ${file} is ok."
  fi
done < <(git diff --numstat --no-renames --diff-filter=d ${FIRST_COMMIT_HASH}^ ${LAST_COMMIT_HASH} | grep -Poe '-\t-\t\K.+')
# git diff --numstat will output -<TAB>-<TAB>$filename for blobs

exit ${EXIT}
