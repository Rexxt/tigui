# constants
__TIGUI_VERSION="0.1.0"
BLACK=$(tput setaf 0)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
BLINK=$(tput blink)
REVERSE=$(tput smso)
UNDERLINE=$(tput smul)
DIM=$(tput dim)
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

trap render WINCH
tigui_scene="home"

# figuring out repo path
if [[ ! -z "$1" ]]; then
    tigui_path="$1"
else
    tigui_path="$PWD"
fi
if [[ ! -d "$tigui_path" ]]; then
    echo -e "tigui error\n time: load\n type: PATH_NOT_DIR\n -> Path '$tigui_path' is not a directory.\n consequence: exit"
    exit 1
fi
if ! git ls-files >& /dev/null; then
    echo -e "tigui error\n time: load\n type: PATH_NOT_GIT_REPO\n -> Path '$tigui_path' is not a git repository.\n consequence: exit"
    exit 1
fi

git_name=`basename -s .git $(git config --get remote.origin.url)`

render() {
    if [[ "$tigui_scene" == "home" ]]; then
        clear
        tput cup 0 0
        echo "${LIME_YELLOW}${REVERSE}TIGUI v$__TIGUI_VERSION$NORMAL ${BLUE}${REVERSE}in $BRIGHT$git_name$NORMAL"
    fi
}

render
while true; do
    :
done