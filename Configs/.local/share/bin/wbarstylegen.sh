#!/usr/bin/env sh

########### This script was edited by https://github.com/xeyossr ##########
#################### https://github.com/xeyossr/dotfiles ###################
######### If there are errors in the script please open the issue. #########

# detect hypr theme and initialize variables

scrDir=`dirname "$(realpath "$0")"`
source $scrDir/globalcontrol.sh
waybar_dir="${confDir}/waybar"
modules_dir="$waybar_dir/modules"
conf_ctl="$waybar_dir/config.ctl"
in_file="$waybar_dir/modules/style.css"
out_file="$waybar_dir/style.css"
src_file="${confDir}/hypr/themes/theme.conf"

workspace_radius=$(grep -oP '(?<=^workspace_radius=).*' "$scrDir/wbarexports.sh")
tooltip_radius=$(grep -oP '(?<=tooltip_radius=).*' "$scrDir/wbarexports.sh")
taskbar_radius=$(grep -oP '(?<=taskbar_radius=).*' "$scrDir/wbarexports.sh")
# calculate height from control file or monitor res

b_height=`grep '^1|' $conf_ctl | cut -d '|' -f 2`

if [ -z $b_height ] || [ "$b_height" == "0" ]; then
    y_monres=`cat /sys/class/drm/*/modes | head -1 | cut -d 'x' -f 2`
    b_height=$(( y_monres*3/100 ))
fi


# calculate values based on height
if [ -n "$workspace_radius" ] && [ "$workspace_radius" != "None" ]; then
    export w_radius=$workspace_radius
    export w_paddin_left=$(( b_height*45/100 ))
    export w_paddin_right=$(( b_height*45/100 ))
    export w_padact_left=$(( b_height*45/100 ))
    export w_padact_right=$(( b_height*45/100 ))
    export w_bor_bottom=$(( b_height*10/100 ))
    export w_margin=0
    export g_margin=0
    export e_margin=0
    export e_paddin=$(( b_height*10/100 ))   

else
    export w_radius=$(( b_height*30/100 ))
    export w_paddin_left=$(( b_height*10/100 ))
    export w_paddin_right=$(( b_height*10/100 ))
    export w_padact_left=$(( b_height*40/100 ))
    export w_padact_right=$(( b_height*40/100 ))
    export w_bor_bottom=0
    export w_margin=$(( b_height*10/100 ))
    export e_margin=$(( b_height*30/100 ))
    export e_paddin=$(( b_height*10/100 ))
    export g_margin=$(( b_height*14/100 ))   

fi

if [ -n "$taskbar_radius" ] && [ "$taskbar_radius" != "None" ]; then
    export task_margin=0
    export task_radius=0
    export task_paddin_left=$(( b_height*15/100 ))
    export task_paddin_right=$(( b_height*15/100 ))
    export task_padact_left=$(( b_height*15/100 ))
    export task_padact_right=$(( b_height*15/100 )) 
else
    export task_margin=$(( b_height*10/100 ))
    export task_radius=$(( b_height*30/100 ))
    export task_paddin_left=$(( b_height*10/100 ))
    export task_paddin_right=$(( b_height*10/100 ))
    export task_padact_left=$(( b_height*10/100 ))
    export task_padact_right=$(( b_height*10/100 )) 
fi

if [ -n "$tooltip_radius" ] && [ "$tooltip_radius" != "None" ]; then
    export t_radius=$tooltip_radius
else
    export t_radius=$(( b_height*25/100 ))
fi


export b_radius=$(( b_height*70/100 ))   # block rad 70% of height (type1)
export c_radius=$(( b_height*25/100 ))   # block rad 25% of height {type2}
# export e_margin=$(( b_height*30/100 ))   # block margin 30% of height
# export e_paddin=$(( b_height*10/100 ))   # block padding 10% of height
# export g_margin=$(( b_height*14/100 ))   # module margin 14% of height
export g_paddin=$(( b_height*15/100 ))   # module padding 15% of height
# export w_margin=$(( b_height*10/100 ))   # workspace margin 10% of height
# export w_paddin=$(( b_height*10/100 ))   # workspace padding 10% of height
# export w_padact=$(( b_height*40/100 ))   # workspace active padding 40% of height
export s_fontpx=$(( b_height*34/100 ))   # font size 34% of height

if [ $b_height -lt 30 ] ; then
    export e_paddin=0
fi
if [ $s_fontpx -lt 10 ] ; then
    export s_fontpx=10
fi


# adjust values for vert/horz

export w_position=`grep '^1|' $conf_ctl | cut -d '|' -f 3`
case ${w_position} in
    top|bottom)
        export x1g_margin=${g_margin}
        export x2g_margin=0
        export x3g_margin=${g_margin}
        export x4g_margin=0
        export x1rb_radius=0
        export x2rb_radius=${b_radius}
        export x3rb_radius=${b_radius}
        export x4rb_radius=0
        export x1lb_radius=${b_radius}
        export x2lb_radius=0
        export x3lb_radius=0
        export x4lb_radius=${b_radius}
        export x1rc_radius=0
        export x2rc_radius=${c_radius}
        export x3rc_radius=${c_radius}
        export x4rc_radius=0
        export x1lc_radius=${c_radius}
        export x2lc_radius=0
        export x3lc_radius=0
        export x4lc_radius=${c_radius}
        export x1="top"
        export x2="bottom"
        export x3="left" 
        export x4="right" ;;
    left|right)
        export x1g_margin=0
        export x2g_margin=${g_margin}
        export x3g_margin=0
        export x4g_margin=${g_margin}
        export x1rb_radius=0
        export x2rb_radius=0
        export x3rb_radius=${b_radius}
        export x4rb_radius=${b_radius}
        export x1lb_radius=${b_radius}
        export x2lb_radius=${b_radius}
        export x3lb_radius=0
        export x4lb_radius=0
        export x1rc_radius=0
        export x2rc_radius=${c_radius}
        export x3rc_radius=${c_radius}
        export x4rc_radius=0
        export x1lc_radius=${c_radius}
        export x2lc_radius=0
        export x3lc_radius=0
        export x4lc_radius=${c_radius}
        export x1="left"
        export x2="right"
        export x3="top" 
        export x4="bottom" ;;
esac


# list modules and generate theme style

export modules_ls=$(grep -m 1 '".*.": {'  --exclude="$modules_dir/footer.jsonc" $modules_dir/*.jsonc | cut -d '"' -f 2 | awk -F '/' '{ if($1=="custom") print "#custom-"$NF"," ; else print "#"$NF","}')
envsubst < $in_file > $out_file


# override rounded couners

hypr_border=`awk -F '=' '{if($1~" WAYBAR-ROUNDING ") print $2}' $src_file | sed 's/ //g'`
if [ "$hypr_border" == "0" ] ; then
    sed -i "/border-radius: /c\  border-radius: 0px;" $out_file
fi


## OPTIONAL

# envsubst ile out_file oluşturulduktan sonra custom modül için CSS ekleme
echo "
#custom-menu {
    background: @wb-act-bg;
    color: @wb-act-fg;
    border-radius: 20px;
    padding-left: 11px;
    padding-right: 11px;
    margin-right: 10px;
}
" >> $out_file
