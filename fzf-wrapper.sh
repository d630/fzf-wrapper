#!/usr/bin/env bash

# fzf-wrapper
# Copyright (C) 2015 D630, The MIT License (MIT)
# <https://github.com/D630/fzf-wrapper>

# -- DEBUGGING.

#printf '%s (%s)\n' "$BASH_VERSION" "${BASH_VERSINFO[5]}" && exit 0
#set -o errexit
#set -o errtrace
#set -o noexec
#set -o nounset
#set -o pipefail
#set -o verbose
#set -o xtrace
#trap '(read -p "[$BASH_SOURCE:$LINENO] $BASH_COMMAND?")' DEBUG
#exec 2>> ~/fzf-wrapper.sh.log
#typeset vars_base=$(set -o posix ; set)
#fgrep -v -e "$vars_base" < <(set -o posix ; set) |
#egrep -v -e "^BASH_REMATCH=" \
#         -e "^OPTIND=" \
#         -e "^REPLY=" \
#         -e "^BASH_LINENO=" \
#         -e "^BASH_SOURCE=" \
#         -e "^FUNCNAME=" |
#less

# -- FUNCTIONS.

__fzf_wrapper ()
{
    unset -v \
        f \
        flags \
        fzf_flag_ansi \
        fzf_flag_black \
        fzf_flag_exit_0 \
        fzf_flag_extended \
        fzf_flag_extended_exact \
        fzf_flag_inline_info \
        fzf_flag_insensitive \
        fzf_flag_multi \
        fzf_flag_no_hscroll \
        fzf_flag_no_mouse \
        fzf_flag_no_sort \
        fzf_flag_print_query \
        fzf_flag_reverse \
        fzf_flag_select_1 \
        fzf_flag_sensitive \
        fzf_flag_sync \
        fzf_flag_tac \
        fzf_flag_color \
        fzf_flag_delimiter \
        fzf_flag_expect \
        fzf_flag_filter \
        fzf_flag_nth \
        fzf_flag_prompt \
        fzf_flag_query \
        fzf_flag_tiebreak \
        fzf_flag_toggle_sort \
        fzf_flag_with_nth \
        v;

    (($# > 0)) && {
        unset -v arg args delim con pp;
        typeset arg= args= delim=\';
        typeset -i con= pp=1;

        for arg in "${@#--}";
        do
            ((con == 1)) && {
                con=;
                continue
            };
            case "$arg" in
                -*[dfnq])
                    args="${args}${arg} ${delim}${2}${delim} ";
                    pp=2;
                    con=1
                ;;
                -[01eimx])
                    args="${args}${arg} "
                ;;
                ansi)
                    fzf_flag_ansi=1
                ;;
                black)
                    fzf_flag_black=1
                ;;
                color=?*)
                    fzf_flag_color="${arg#*=}"
                ;;
                delimiter=?*)
                    args="${args}-d ${delim}${arg#*=}${delim} "
                ;;
                exit-0)
                    args="${args}-0 "
                ;;
                expect=?*)
                    fzf_flag_expect="${arg#*=}"
                ;;
                extended)
                    args="${args}-x "
                ;;
                extended-exact)
                    args="${args}-e "
                ;;
                filter=?*)
                    args="${args}-f ${delim}${arg#*=}${delim} "
                ;;
                +i)
                    fzf_flag_sensitive=1
                ;;
                inline-info)
                    fzf_flag_inline_info=1
                ;;
                multi)
                    args="${args}-m "
                ;;
                no-hscroll)
                    fzf_flag_no_hscroll=1
                ;;
                no-mouse)
                    fzf_flag_no_mouse=1
                ;;
                no-sort | +s)
                    fzf_flag_no_sort=1
                ;;
                nth=?*)
                    args="${args}-n ${delim}${arg#*=}${delim} "
                ;;
                print-query)
                    fzf_flag_print_query=1
                ;;
                prompt=?*)
                    fzf_flag_prompt="${arg#*=}"
                ;;
                query=?*)
                    args="${args}-q ${delim}${arg#*=}${delim} "
                ;;
                reverse)
                    fzf_flag_reverse=1
                ;;
                select-1)
                    args="${args}-1 "
                ;;
                sync)
                    fzf_flag_sync=1
                ;;
                tac)
                    fzf_flag_tac=1
                ;;
                tiebreak=?*)
                    fzf_flag_tiebreak="${arg#*=}"
                ;;
                toggle-sort=?*)
                    fzf_flag_toggle_sort="${arg#*=}"
                ;;
                with-nth=?*)
                    fzf_flag_with_nth="${arg#*=}"
                ;;
                color | color= | expect | expect= | prompt | prompt= | \
                tiebreak | tiebreak= | toggle-sort | toggle-sort= | with-nth | \
                with-nth=)
                    {
                        printf '%s\n' "Option '$1' requires an argument" 1>&2;
                        return 1
                    }
                ;;
                -)
                    {
                        printf '%s\n' "Option required: '$1'" 1>&2;
                        return 1
                    }
                ;;
                *)
                    {
                        printf '%s\n' "Unknown option: '$1'" 1>&2;
                        return 1
                    }
                ;;
            esac;
            shift "$pp" && pp=1;
        done;

        function __fzf_parse_opt ()
        {
            if [[ "$OPTARG" == \-?* ]]; then
                {
                    printf '%s\n' "Option '-${opt}' requires an argument" 1>&2;
                    return 1
                };
            else
                eval "$1";
            fi
        };

        unset -v OPTIND opt;
        typeset OPTIND=1 opt;

        eval set -- "$args";
        while getopts ":01d:ef:imn:q:x" opt; do
            case "$opt" in
                0)
                    fzf_flag_exit_0=1
                ;;
                1)
                    fzf_flag_select_1=1
                ;;
                d)
                    __fzf_parse_opt "fzf_flag_delimiter=${OPTARG}"
                ;;
                e)
                    fzf_flag_extended_exact=1
                ;;
                f)
                    __fzf_parse_opt "fzf_flag_filter=${OPTARG}"
                ;;
                i)
                    fzf_flag_insensitive=1
                ;;
                m)
                    fzf_flag_multi=1
                ;;
                n)
                    __fzf_parse_opt "fzf_flag_nth=${OPTARG}"
                ;;
                q)
                    __fzf_parse_opt "fzf_flag_query=${OPTARG}"
                ;;
                x)
                    fzf_flag_extended=1
                ;;
                :)
                    {
                        printf '%s\n' "Option '-${OPTARG}' requires an argument" 1>&2;
                        return 1
                    }
                ;;
                \?)
                    {
                        printf '%s\n' "Unknown flag: '-${OPTARG}'" 1>&2;
                        return 1
                    }
                ;;
            esac;
        done
    };

    typeset \
        fzf_flag_ansi="${FZF_FLAG_ANSI:-${fzf_flag_ansi}}" \
        fzf_flag_black="${FZF_FLAG_BLACK:-${fzf_flag_black}}" \
        fzf_flag_color="${FZF_FLAG_COLOR:-${fzf_flag_color}}" \
        fzf_flag_delimiter="${FZF_FLAG_DELIMITER:-${fzf_flag_delimiter}}" \
        fzf_flag_exit_0="${FZF_FLAG_EXIT_0:-${fzf_flag_exit_0}}" \
        fzf_flag_expect="${FZF_FLAG_EXPECT:-${fzf_flag_expect}}" \
        fzf_flag_extended="${FZF_FLAG_EXTENDED:-${fzf_flag_extended}}" \
        fzf_flag_extended_exact="${FZF_FLAG_EXTENDED_EXACT:-${fzf_flag_extended_exact}}" \
        fzf_flag_filter="${FZF_FLAG_FILTER:-${fzf_flag_filter}}" \
        fzf_flag_inline_info="${FZF_FLAG_INLINE_INFO:-${fzf_flag_inline_info}}" \
        fzf_flag_insensitive="${FZF_FLAG_INSENSITIVE:-${fzf_flag_insensitive}}" \
        fzf_flag_multi="${FZF_FLAG_MULTI:-${fzf_flag_multi}}" \
        fzf_flag_no_hscroll="${FZF_FLAG_NO_HSCROLL:-${fzf_flag_no_hscroll}}" \
        fzf_flag_no_mouse="${FZF_FLAG_NO_MOUSE:-${fzf_flag_no_mouse}}" \
        fzf_flag_no_sort="${FZF_FLAG_NO_SORT:-${fzf_flag_no_sort}}" \
        fzf_flag_nth="${FZF_FLAG_NTH:-${fzf_flag_nth}}" \
        fzf_flag_print_query="${FZF_FLAG_PRINT_QUERY:-${fzf_flag_print_query}}" \
        fzf_flag_prompt="${FZF_FLAG_PROMPT:-${fzf_flag_prompt}}" \
        fzf_flag_query="${FZF_FLAG_QUERY:-${fzf_flag_query}}" \
        fzf_flag_reverse="${FZF_FLAG_REVERSE:-${fzf_flag_reverse}}" \
        fzf_flag_select_1="${FZF_FLAG_SELECT_1:-${fzf_flag_select_1}}" \
        fzf_flag_sensitive="${FZF_FLAG_SENSITIVE:-${fzf_flag_sensitive}}" \
        fzf_flag_sync="${FZF_FLAG_SYNC:-${fzf_flag_sync}}" \
        fzf_flag_tac="${FZF_FLAG_TAC:-${fzf_flag_tac}}" \
        fzf_flag_tiebreak="${FZF_FLAG_TIEBREAK:-${fzf_flag_tiebreak}}" \
        fzf_flag_toggle_sort="${FZF_FLAG_TOGGLE_SORT:-${fzf_flag_toggle_sort}}" \
        fzf_flag_with_nth="${FZF_FLAG_WITH_NTH:-${fzf_flag_with_nth}}" ;

   for f in ${!fzf_flag_exit_0*} ${!fzf_flag_extended*} ${!fzf_flag_extended_exact*} ${!fzf_flag_multi*} ${!fzf_flag_select_1*} ${!fzf_flag_ansi*} ${!fzf_flag_black*} ${!fzf_flag_inline_info*} ${!fzf_flag_no_hscroll*} ${!fzf_flag_no_mouse*} ${!fzf_flag_no_sort*} ${!fzf_flag_print_query*} ${!fzf_flag_reverse*} ${!fzf_flag_sync*} ${!fzf_flag_tac*};
    do
        if [[ ${!f} -eq 1 ]]; then
            v="${f#fzf_flag_}";
            eval typeset "${f}=--\${v//_/-}";
        else
            unset -v "$f";
        fi;
    done;

    if [[ "${fzf_flag_sensitive}" == 1 ]]; then
        fzf_flag_sensitive="+i";
    else
        unset -v "fzf_flag_sensitive";
    fi;

    if [[ "${fzf_flag_insensitive}" == 1 ]]; then
        fzf_flag_insensitive="-i";
    else
        unset -v "fzf_flag_insensitive";
    fi;

    for f in ${!fzf_flag_color*} ${!fzf_flag_delimiter*} ${!fzf_flag_expect*} ${!fzf_flag_filter*} ${!fzf_flag_nth*} ${!fzf_flag_prompt*} ${!fzf_flag_query*} ${!fzf_flag_tiebreak*} ${!fzf_flag_toggle_sort*} ${!fzf_flag_with_nth*};
    do
        if [[ -n "${!f}" ]]; then
            v="${f#fzf_flag_}";
            eval typeset "${f}=--\${v//_/-}=\\'\${!f}\\'";
        else
            unset -v "$f";
        fi;
    done;

    flags="${fzf_flag_sensitive} ${fzf_flag_insensitive} ${fzf_flag_exit_0} ${fzf_flag_extended} ${fzf_flag_extended_exact} ${fzf_flag_multi} ${fzf_flag_select_1} ${fzf_flag_ansi} ${fzf_flag_black} ${fzf_flag_inline_info} ${fzf_flag_no_hscroll} ${fzf_flag_no_mouse} ${fzf_flag_no_sort} ${fzf_flag_print_query} ${fzf_flag_reverse} ${fzf_flag_sync} ${fzf_flag_tac} ${fzf_flag_color} ${fzf_flag_delimiter} ${fzf_flag_expect} ${fzf_flag_filter} ${fzf_flag_nth} ${fzf_flag_prompt} ${fzf_flag_query} ${fzf_flag_tiebreak} ${fzf_flag_toggle_sort} ${fzf_flag_with_nth}";

    eval fzf "$flags"
}
