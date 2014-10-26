#! /bin/bash

# vimgolf
VGOLF="$PWD"
echo $VGOLF

select_action() {

    while true
    do PS3="What you're gonna do? "
        echo ""
        select option in  "Play Challenge" "Add Challenge" "Edit Challenge" "Show Tips" "Quit"
        do
            case $REPLY in
                1) select_challenge
                    chall_play
                    ;;
                2) chall_add
                    ;;
                3) select_challenge
                    chall_edit
                    ;;
                4) vim $VGOLF/tricks_dot_macros.vg
                    break
                    ;;
                5) echo "See you old friend, now save some keystrokes in the real world ;)"
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

remove_challenge() {

    # rename challenge
    mv "$VGOLF/$chall" "$VGOLF/$chall".done
    select_challenge

}

chall_play() {

    while true
    do
        if test -f /tmp/.foo.golf.swp; then rm /tmp/.foo.golf.swp; fi
        vim -u ./vimrc_vimgolf -W ./vim-last-scriptout $VGOLF/${chall%.*}.notes -O /tmp/foo.solution.golf -c '30split /tmp/foo.golf'
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
                echo "[r]emove challenge"
                echo ""
                read -p "[Ctrl + C] to exit vimgolf: " answ
                case $answ in
                    C|c|"") select_challenge
                        ;;
                    P|p) chall_downl
                        ;;
                    R|r) remove_challenge
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

    chkVimg=$(egrep "^vimgolf put" "$VGOLF/$chall"| wc -l)
    if [[ $chkVimg = 1 ]]; then
        sudo $(egrep "^vimgolf put" "$VGOLF/$chall")
    else
        sudo $(cat "$VGOLF/$chall" | grep ^http | sed 's/^.*\///g;s/^/vimgolf put /g')
    fi
    echo "See you old friend, now save some keystrokes in the real world ;)"
    exit 0

}

chall_edit() {

    while true
    do
        read -p "You're sure you wanna edit this challenge: $chall (Y|n)? " answer
        case "$answer" in
            Yes|yes|Y|y|"")
                vim $VGOLF/$chall
                echo ""
                echo "successfully edited challenge $chall"
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

chall_add() {

    read -p "Name of new challenge " newchall
    newchall=$(echo "$newchall" | sed -r 's/./\L&/g;s/ /_/g')
    vim -u ./vimrc_vimgolf chall_"$newchall".vg
    select_action

}

select_action
