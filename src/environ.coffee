#**********************************************************************************************************
# enforce game engine
#
# 2014.04.04 ver2.0
#
# Coded by Kow Sakazaki
#**********************************************************************************************************

# static values setting ***********************************************************************************
DEBUG           = true                      # デバッグモード
BGCOLOR         = "black"                   # 背景色
OBJECTNUM       = 256                       # キャラの最大数
GRAVITY         = 9.8                       # 重力（box2dで使用）
FOGCOLOR        = "#ffffff"                 # フォグの色
FOGLEVEL        = 0.0                       # フォルの量
FPS             = 30                        # frame per second
VIEWANGLE       = 50                        # 視野角
VIEWNEAR        = 1                         # 最短描画距離
VIEWFAR         = 1000                      # 最長描画距離

# preloading image list ***********************************************************************************
MEDIALIST       = {
    droid   : 'media/model/droid.dae'
    miku    : 'media/model/negimiku.dae'
}
