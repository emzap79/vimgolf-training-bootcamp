#! /bin/bash

# vimgolf
VGOLF="$DOK/Linux/Vim/vimgolf"

select_challenge() {

    loc=$(ls -ltc $VGOLF/chall* | awk '{print substr($0, index($0, "chall"))}')
    locnr=$(echo $loc | tr ' ' '\n' | wc -l)
    locnr=$(( $locnr+1 ))
    PS3="Choose one of the challenges: "
    echo ""
    select chall in $loc "Go Back"
    do
        case $REPLY in
            $locnr )
                select_action
                ;;
            *)
                if [[ $REPLY -gt $locnr ]]; then
                    echo "wrong selection, please try again!"
                else
                    echo "you picked challenge: ${chall#chall_}"
                    cp $VGOLF/$chall /tmp/foo.golf
                    break
                fi
                ;;
        esac
    done

}

select_action() {

    while true
    do PS3="What you're gonna do? "
        echo ""
        select option in  "Remove Challenge" "Play Challenge" "Show Tips" "Quit"
        do
            case $REPLY in
                1) select_challenge
                    chall_remove
                    ;;
                2) select_challenge
                    chall_play
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

chall_play() {

    while true
    do
        keystrokes=$(cat ~/.vim-last-scriptout | wc -c)
        vim -u ~/.vim/vimrc_vimgolf -W ~/.vim-last-scriptout \
            /tmp/foo.golf -O $VGOLF/$chall
        echo "This attempt took you == $keystrokes == keystrokes"
        read -p "Continue playing (Y|n)? " answer
        case "$answer" in
            Yes|yes|Y|y|"")
                # break
                ;;
            No|no|N|n)
                echo ""
                echo "[r]emove this challenge,"
                echo "[c]hange to a new golf course,"
                read -p "or [q]uit? " answ
                case $answ in
                    C|c) select_challenge
                        ;;
                    R|r) chall_remove
                        ;;
                    Q|q|"")
                        echo "See you old friend, now save some keystrokes in the real world ;)"
                        exit 0
                esac
                ;;
            *)
                echo "your selection is not valid, try again"
                ;;
        esac
    done

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
