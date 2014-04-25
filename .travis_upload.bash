GIT_TAG=`git tag --points-at HEAD`

# Temporary !=
if [[ "$TRAVIS_BRANCH" != "master" ]]; then
	cake build:dist

	cd build
	mv dist batman.js
	tar cvzf batman-master.tar.gz batman.js
	travis-artifacts upload --path batman-master.tar.gz --target-path '' --cache-control no-cache

	if [[ -n "$GIT_TAG" ]]; then
		NAME_WITH_TAG="batman-${GIT_TAG}.tar.gz"
		mv batman-master.tar.gz "$NAME_WITH_TAG"
		travis-artifacts upload --path "$NAME_WITH_TAG" --target-path '' --cache-control no-cache
	fi
fi
