#***********************************************************************
# enchant.js game engine
#
# 2013.12.28 ver0.1
# 2014.01.09 ver0.2
#
# Coded by Kow Sakazaki
#***********************************************************************

#******************************************************************************
# 初期化処理
#******************************************************************************

# 定数定義

# オブジェクトの種類
CONTROL             = 0
SPRITE              = 1
# Sceneの種類
BGSCENE             = 0
BGSCENE_SUB1        = 1
BGSCENE_SUB2        = 2
GAMESCENE           = 3
GAMESCENE_SUB1      = 4
GAMESCENE_SUB2      = 5
TOPSCENE            = 6

# グローバル初期化

# センサー系
MOTION_ACCEL        = [x:0, y:0, z:0]
MOTION_GRAVITY      = [x:0, y:0, z:0]
MOTION_ROTATE       = [alpha:0, beta:0, gamma:0]
# ゲーム起動時からの経過時間（秒）
LAPSEDTIME          = 0
# 3D系
CAMERA              = undefined
# オブジェクトが入っている配列
_objects            = []
# Scene格納用配列
_scenes             = []
# 起動時に生成されるスタートオブジェクト
_main               = null
# デバッグ用LABEL
_DEBUGLABEL         = null
# enchantのcoreオブジェクト
core                = null
# box2dのworldオブジェクト
box2dworld          = null
# 3Dのscene
rootScene3D         = null
# enchantのrootScene
rootScene           = null

#******************************************************************************
# 起動時の処理
#******************************************************************************

# enchantのオマジナイ
enchant()
enchant.Sound.enabledInMobileSafari = true
enchant.ENV.MOUSE_ENABLED = false
# ゲーム起動時の処理
window.onload = ->
    # enchant初期化
    core = new Core(SCREEN_WIDTH, SCREEN_HEIGHT)
    core.rootScene.backgroundColor = BGCOLOR
    core.fps = FPS
    if (MEDIALIST?)
        imagearr = []
        i = 0
        for obj of MEDIALIST
            imagearr[i++] = MEDIALIST[obj]
        core.preload(imagearr)
    rootScene = core.rootScene
    window.addEventListener 'devicemotion', (e)=>
        MOTION_ACCEL = e.acceleration
        MOTION_GRAVITY = e.accelerationIncludingGravity
    window.addEventListener 'deviceorientation', (e)=>
        MOTION_ROTATE.alpha = e.alpha
        MOTION_ROTATE.beta = e.beta
        MOTION_ROTATE.gamma = e.gamma

    # シーングループを生成
    for i in [0...(TOPSCENE+1)]
        scene = new Group()
        scene.backgroundColor = "black"
        _scenes[i] = scene
        rootScene.addChild(scene)

    core.onload = ->
        for i in [0...OBJECTNUM]
            _objects[i] = new _originObject()
        _main = new enforceMain()
        rootScene.addEventListener 'enterframe', (e)->
            LAPSEDTIME = parseFloat((core.frame / FPS).toFixed(2))
    core.start()

#******************************************************************************
# 2D/3D共用オブジェクト生成メソッド
#******************************************************************************
addObject = (param)->
    # 2D用パラメーター
    motionObj = if (param.motionObj?) then param.motionObj else undefined
    _type = if (param.type?) then param.type else SPRITE
    x = if (param.x?) then param.x else 0.0
    y = if (param.y?) then param.y else 0.0
    xs = if (param.xs?) then param.xs else 0.0
    ys = if (param.ys?) then param.ys else 0.0
    gravity = if (param.gravity?) then param.gravity else 0.0
    image = if (param.image?) then param.image else undefined
    width = if (param.width?) then param.width else 0.0
    height = if (param.height?) then param.height else 0.0
    opacity = if (param.opacity?) then param.opacity else 1.0
    animlist = if (param.animlist?) then param.animlist else undefined
    animnum = if (param.animnum?) then param.animnum else 0
    visible = if (param.visible?) then param.visible else true
    scene = if (param.scene?) then param.scene else -1
    model = if (param.model?) then param.model else undefined
    density = if (param.density?) then param.density else 1.0
    friction = if (param.friction?) then param.friction else 0.5
    restitution = if (param.restitution?) then param.restitution else 0.1
    move = if (param.move?) then param.move else false
    scaleX = if (param.scaleX?) then param.scaleX else 1.0
    scaleY = if (param.scaleY?) then param.scaleY else 1.0

    if (motionObj == null)
        motionObj = undefined

    objnum = _getNullObject()
    if (objnum < 0)
        return undefined

    obj = _objects[objnum]
    obj.active = true

    # スプライトを生成
    switch (_type)
        when CONTROL, SPRITE
            motionsprite = new Sprite()
            if (scene < 0)
                scene = GAMESCENE_SUB1
        else
            motionsprite = undefined
            if (scene < 0)
                scene = GAMESCENE_SUB1

    # TimeLineを時間ベースにする
    motionsprite.tl.setTimeBased()

    # _typeによってスプライトを初期化する
    switch (_type)
        when SPRITE
            # パラメータ初期化
            #motionsprite.originX = 0
            #motionsprite.originY = 0
            animtmp = animlist[animnum]
            motionsprite.frame = animtmp[1][0]
            motionsprite.blendMode = "lighter"
            motionsprite.backgroundColor = "transparent"
            motionsprite.width = width
            motionsprite.height = height
            motionsprite.diffx = parseInt(width / 2)
            motionsprite.diffy = parseInt(height / 2)
            motionsprite._x_ = x - motionsprite.diffx
            motionsprite._y_ = y - motionsprite.diffy
            motionsprite.x = Math.floor(motionsprite._x_)
            motionsprite.y = Math.floor(motionsprite._y_)
            motionsprite.xback = motionsprite.x
            motionsprite.yback = motionsprite.y
            motionsprite.opacity = opacity
            motionsprite.rotation = 0.0
            motionsprite.scaleX = scaleX
            motionsprite.scaleY = scaleY
            motionsprite.visible = visible
            motionsprite.intersectFlag = true
            motionsprite.animlist = animlist
            motionsprite.animnum = animnum
            motionsprite.xs = xs
            motionsprite.ys = ys
            motionsprite.gravity = gravity

    # スプライトを表示
    _scenes[scene].addChild(motionsprite)

    # 動きを定義したオブジェクトを生成する
    if (motionObj != undefined)
        obj.motionObj = new motionObj(motionsprite)
    else
        obj.motionObj = new _stationary(motionsprite)

    uid = uniqueID()
    obj.motionObj._uniqueID = uid
    obj.motionObj._scene = scene

    if (motionsprite != undefined)
        # イベント定義
        motionsprite.addEventListener 'enterframe', ->
            if (obj.motionObj != undefined && typeof(obj.motionObj.behavior) == 'function')
                obj.motionObj.behavior()

    # 画像割り当て
    if (MEDIALIST[image]? && animlist?)
        img = MEDIALIST[image]
        motionsprite.image = core.assets[img]

    # 初期画像
    if (animlist?)
        animtmp = animlist[animnum]
        animpattern = animtmp[1]
        motionsprite.frame = animpattern[0]

    obj.motionObj._type = _type

    return obj.motionObj

#**********************************************************************
# オブジェクト削除（画面からも消える）
#**********************************************************************
removeObject = (motionObj)->
    if (!motionObj?)
        return
    ret = false
    # 削除しようとしているmotionObjがオブジェクトリストのどこに入っているか探す
    for object in _objects
        if (!object.motionObj?)
            continue
        if (object.motionObj._uniqueID == motionObj._uniqueID)
            ret = true
            break
    if (ret == false)
        return

    if (typeof(motionObj.destructor) == 'function')
        motionObj.destructor()

    if (motionObj._type == DSPRITE_BOX || motionObj._type == DSPRITE_CIRCLE || motionObj._type == SSPRITE_BOX || motionObj._type == SSPRITE_CIRCLE)
        object.motionObj.sprite.destroy()
    else
        _scenes[object.motionObj._scene].removeChild(object.motionObj.sprite)
    object.motionObj.sprite = 0

    object.motionObj = 0
    object.active = false

#**********************************************************************
# オブジェクトリストの指定した番号のオブジェクトを返す
#**********************************************************************
getObject = (id)->
    ret = undefined
    for i in [0..._objects.length]
        if (!_objects[i].motionObj?)
            continue
        if (_objects[i].motionObj._uniqueID == id)
            ret = _objects[i].motionObj
            break
    return ret

#**********************************************************************
#**********************************************************************
#**********************************************************************
# 以下は内部使用ライブラリ関数
#**********************************************************************
#**********************************************************************
#**********************************************************************

#**********************************************************************
# オブジェクトリストの中で未使用のものの配列番号を返す。
# 無かった場合は-1を返す
#**********************************************************************
_getNullObject = ->
    ret = -1
    for i in [0..._objects.length]
        if (_objects[i].active == false)
            ret = i
            break
    return ret

