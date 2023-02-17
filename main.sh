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

# import config
conf=()
panel_number=0
while IFS="" read -r l || [ -n "$l" ]; do
    conf+=("$l")
    let panel_number++
done < "$SCRIPT_DIR/presentation.tigui"

declare -A panel_title
panel_title["git-diff"]="diff"
panel_title["git-log"]="commit log"
panel_title["git-status"]="git status"

get_output() {
    case "$1" in
        "git-diff")
            echo $(git diff)
        ;;
        "git-log")
            echo $(git log)
        ;;
        "git-status")
            echo $(git status -s)
        ;;
    esac
}

tip_bar() {
    case "$1" in
        "home")
            echo "[q]uit [c]ommit"
        ;;
    esac
}

render() {
    if [[ "$tigui_scene" == "home" ]]; then
        clear
        tput cup 0 0
        echo "${LIME_YELLOW}${REVERSE}TIGUI v$__TIGUI_VERSION$NORMAL ${BLUE}${REVERSE}in $BRIGHT$git_name$NORMAL"

        # calculate cols of each panel
        local cols=$(tput cols)
        local cols_per_panel=$(($cols/$panel_number))

        # display panels
        local panel_num=0
        for panel in "${conf[@]}"; do
            tput cup 1 $(($panel_num*$cols_per_panel))
            let title=${panel_title["$panel"]}
            echo -e "$LIME_YELLOW$REVERSE$panel_num $BRIGHT${panel_title["$panel"]}$NORMAL"

            while IFS="" read -r l || [ -n "$l" ]; do
                tput cup 2 $(($panel_num*$cols_per_panel))
                if [[ "${#l}" -ge "$cols_per_panel" ]]; then
                    local c=$(($cols_per_panel-1))
                    echo "${l:0:$c}$RED|$NORMAL"
                else
                    echo "${l:0:$cols_per_panel}"
                fi
            done <<< "$(get_output $panel)"

            let panel_num++
        done

        # display tip bar
        local lines=$(tput lines)
        local h=$(($lines-1))
        tput cup $h 0
        echo -n -e "$BLUE$(tip_bar $tigui_scene)$NORMAL"
    fi
}

while true; do
    render
    read -n 1 -s act
    case "$act" in
        q)
            clear
            exit
        ;;
    esac
done