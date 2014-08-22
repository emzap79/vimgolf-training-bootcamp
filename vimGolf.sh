#! /bin/bash

# vimgolf
VGOLF="$PWD"
echo $VGOLF

select_action() {

    while true
    do PS3="What you're gonna do? "
        echo ""
        select option in  "Play Challenge" "Remove Challenge" "Show Tips" "Quit"
        do
            case $REPLY in
                1) select_challenge
                    chall_play
                    ;;
                2) select_challenge
                    chall_remove
                    ;;
                3) vim $VGOLF/tricks_dot_macros.vg
                    break
                    ;;
                4) echo "See you old friend, now save some keystrokes in the real world ;)"
                    exit 0
                    ;;
            esac
        done
    done


}

select_challenge() {

    loc=$(ls -ltc $VGOLF/chall*.vg | awk '{print substr($0, index($0, "chall"))}')
    locnr=$(echo $loc | tr ' ' '\n' | wc -l)
    locnr=$(( $locnr+1 ))
    locnr_last=$(( $locnr+1 ))
    PS3="Choose one of the challenges: "
    echo ""
    select chall in $loc "Go Back to Menu" "Quit"
    do
        case $REPLY in
            $locnr )
                select_action
                ;;
            $locnr_last )
                echo "See you old friend, now save some keystrokes in the real world ;)"
                exit 0
                ;;
            *)
                if [[ $REPLY -gt $locnr ]]; then
                    echo "wrong selection, please try again!"
                else
                    create_challenge
                    echo "you picked challenge: ${chall#chall_}"
                    break
                fi
                ;;
        esac
    done

}

create_challenge() {

    # parse start file only
    cat $VGOLF/$chall | sed '/^start\ file/I,/^end\ file/I!d' | head -n -2 | tail -n +3 > /tmp/foo.golf
    cat $VGOLF/$chall | sed '/^end\ file/I,$!d' > /tmp/foo.solution.golf

}

chall_play() {

    while true
    do
        if test -f /tmp/.foo.golf.swp; then rm /tmp/.foo.golf.swp; fi
        vim -u ./vimrc_vimgolf -W ./vim-last-scriptout /tmp/foo.golf -O /tmp/foo.solution.golf
        keystrokes=$(cat ./vim-last-scriptout | wc -c)
        echo ""
        echo "This attempt took you == $keystrokes == keystrokes"
        read -p "Continue with this challenge (Y|n)? " answer
        case "$answer" in
            Yes|yes|Y|y|"")
                create_challenge
                # break
                ;;
            No|no|N|n)
                echo ""
                echo "[p]lay challenge from vimgolf.com"
                echo "[c]hange to a new golf course"
                echo ""
                read -p "[Ctrl + C] to exit vimgolf: " answ
                case $answ in
                    C|c|"") select_challenge
                        ;;
                    P|p) chall_downl
                        ;;
                esac
                ;;
            *)
                echo "your selection is not valid, try again"
                ;;
        esac
    done

}

chall_downl() {

    chkVimg=$(grep put "$VGOLF/$chall"| wc -l)
    if [[ $chkVimg = 1 ]]; then
        sudo $(grep put "$VGOLF/$chall")
    else
        sudo $(cat "$VGOLF/$chall" | grep ^http | sed 's/^.*\///g;s/^/vimgolf put /g')
    fi
    echo "See you old friend, now save some keystrokes in the real world ;)"
    exit 0

}

chall_remove() {

    while true
    do
        read -p "You're sure you wanna delete this challenge: $chall (Y|n)? " answer
        case "$answer" in
            Yes|yes|Y|y|"")
                mv $VGOLF/$chall /tmp/
                echo ""
                echo "successfully removed challenge $chall from directory"
                select_action
                ;;
            No|no|N|n)
                echo ""
                echo "nothing removed!"
                select_action
                ;;
            *)
                echo "your selection is not valid, try again"
                exit 1
                ;;
        esac; break
    done

}

select_action
