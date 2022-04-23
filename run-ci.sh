FIRST_COMMIT_HASH=$( git log master..$( git branch --show-current ) --pretty=oneline | tail -1 | awk '{ print $1 }' )
LAST_COMMIT_HASH=$( git rev-parse HEAD )
ARTICLES=$( git diff --diff-filter=d --name-only ^${FIRST_COMMIT_HASH}~ ${LAST_COMMIT_HASH} "wiki/**/*.md" "news/*.md" )

echo -e "\n--- Binary file size check ---\n"
bash .github/scripts/ci/inspect_binary_file_sizes.sh ${FIRST_COMMIT_HASH} ${LAST_COMMIT_HASH}

echo -e "\n--- Run remark ---\n"
git diff --diff-filter=d --name-only ${FIRST_COMMIT_HASH}..${LAST_COMMIT_HASH} '*.md' | xargs -d '\n' npx remark -qf --no-stdout --silently-ignore --report=vfile-reporter-position --color

echo -e "\n--- Run yamllint ---\n"
python .github/scripts/ci/run_yamllint.py --config .yamllint.yaml

echo -e "\n--- Broken wikilink check ---\n"
python .github/scripts/ci/find_broken_wikilinks.py --target ${ARTICLES}

echo -e "\n--- Outdated tag check ---\n"
bash .github/scripts/ci/check_outdated_tags.sh ${FIRST_COMMIT_HASH} ${LAST_COMMIT_HASH}
