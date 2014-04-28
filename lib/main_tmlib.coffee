#******************************************************************************
# enforce game engine
#
# 2014.04.04 ver2.0
#
# Coded by Kow Sakazaki
#******************************************************************************

#******************************************************************************
# 初期化処理
#******************************************************************************

# アプリケーションオブジェクト
core                = null
# オブジェクトリスト
_objects            = []
# Scene格納用配列
_scenes             = []
# 経過時間
LAPSEDTIME          = 0
# センサー系
MOTION_ACCEL        = [x:0, y:0, z:0]
MOTION_GRAVITY      = [x:0, y:0, z:0]
MOTION_ROTATE       = [alpha:0, beta:0, gamma:0]

#******************************************************************************
# 定数定義
#******************************************************************************

# オブジェクトの種類
CONTROL             = 0
SPRITE              = 1
LABEL               = 2
PHYSICAL            = 3
GLMODEL             = 4
# Sceneの種類
BGSCENE             = 0
BGSCENE_SUB1        = 1
BGSCENE_SUB2        = 2
GAMESCENE           = 3
GAMESCENE_SUB1      = 4
GAMESCENE_SUB2      = 5
TOPSCENE            = 6

#******************************************************************************
# ゲーム起動処理
#******************************************************************************
tm.main ->
    core = tm.display.CanvasApp("#stage")
    core.background = BGCOLOR
    core.fps = FPS
    core.resize(SCREEN_WIDTH, SCREEN_HEIGHT)
    core.fitWindow()

    window.addEventListener 'devicemotion', (e)=>
        MOTION_ACCEL = e.acceleration
        MOTION_GRAVITY = e.accelerationIncludingGravity
    window.addEventListener 'deviceorientation', (e)=>
        MOTION_ROTATE.alpha = e.alpha
        MOTION_ROTATE.beta = e.beta
        MOTION_ROTATE.gamma = e.gamma

    core.replaceScene customLoadingScene
        assets: MEDIALIST
        nextScene: mainScene
        width: SCREEN_WIDTH
        height: SCREEN_HEIGHT
    core.run()

#******************************************************************************
# スプラッシュ表示
#******************************************************************************
tm.define "customLoadingScene",
    superClass: "tm.app.Scene"
    init: (param) ->
        @superInit()

        @bg = tm.display.Shape(param.width, param.height).addChildTo(this)
        @bg.canvas.clearColor "#000000"
        #@bg.setOrigin 0, 0
        label = tm.display.Label("loading")
        label.x = param.width / 2
        label.y = param.height / 2
        label.width = param.width
        label.align = "center"
        label.baseline = "middle"
        label.fontSize = 24
        label.setFillStyle "#ffffff"
        label.counter = 0
        label.update = (app) ->
            if app.frame % 30 is 0
                @text += "."
                @counter += 1
                if @counter > 3
                    @counter = 0
                    @text = "loading"
            return
        label.addChildTo @bg
        @bg.tweener.clear().fadeIn(100).call (->
            if param.assets
                loader = tm.asset.Loader()
                loader.onload = (->
                    @bg.tweener.clear().wait(300).fadeOut(300).call (->
                        @app.replaceScene param.nextScene()  if param.nextScene
                        e = tm.event.Event("load")
                        @fire e
                        return
                    ).bind(this)
                    return
                ).bind(this)
                loader.onprogress = ((e) ->
                    event = tm.event.Event("progress")
                    event.progress = e.progress
                    @fire event
                    return
                ).bind(this)
                loader.load param.assets
            return
        ).bind(this)
        return

#******************************************************************************
# メインシーンの定義
#******************************************************************************
tm.define "mainScene", {
    superClass : "tm.app.Scene"
    init:->
        this.superInit()
        rootScene = this

        # シーングループを生成
        for i in [0...(TOPSCENE + 1)]
            scene = tm.display.CanvasElement().addChildTo(rootScene)
            _scenes[i] = scene
            
        # オブジェクトリストを生成
        for i in [0...OBJECTNUM]
            _objects[i] = new _originObject()

        # アプリケーションクラスを生成
        _main = new enforceMain()

    onenterframe:->
        LAPSEDTIME = parseFloat((core.frame / FPS).toFixed(2))
        for obj in _objects
            if (obj.motionObj != undefined && typeof(obj.motionObj.behavior) == 'function')
                if (obj.motionObj.sprite?)
                    obj.motionObj.sprite.visible = false
                obj.motionObj.behavior()
        _objects.sort (a, b)->
            if (a.motionObj? && b.motionObj? && a.motionObj.sprite? && b.motionObj.sprite?)
                a_z = a.motionObj.z
                b_z = b.motionObj.z
                if(a_z < b_z)
                    return 1
                else if (a_z > b_z)
                    return -1
                else
                    return 0
        for obj in _objects
            if (obj.motionObj? && obj.motionObj.sprite?)
                _scenes[obj.motionObj._scene].removeChild(obj.motionObj.sprite)
                _scenes[obj.motionObj._scene].addChild(obj.motionObj.sprite)
                obj.motionObj.sprite.visible = obj.motionObj.visible
}

#**********************************************************************
# スプライトを生成しオブジェクトに登録する
#**********************************************************************
addObject = (param)->
    motionObj = if (param.motionObj?) then param.motionObj else undefined
    type = if (param.type?) then param.type else SPRITE
    x = if (param.x?) then param.x else 0.0
    y = if (param.y?) then param.y else 0.0
    z = if (param.z?) then param.z else 0.0
    xs = if (param.xs?) then param.xs else 0.0
    ys = if (param.ys?) then param.ys else 0.0
    zs = if (param.zs?) then param.zs else 0.0
    gravity = if (param.gravity?) then param.gravity else 0.0
    image = if (param.image?) then param.image else undefined
    width = if (param.width?) then param.width else 0.0
    height = if (param.height?) then param.height else 0.0
    opacity = if (param.opacity?) then param.opacity else 1.0
    animlist = if (param.animlist?) then param.animlist else undefined
    animnum = if (param.animnum?) then param.animnum else 0
    visible = if (param.visible?) then param.visible else true
    scene = if (param.scene?) then param.scene else -1
    scaleX = if (param.scaleX?) then param.scaleX else 1.0
    scaleY = if (param.scaleY?) then param.scaleY else 1.0

    if (scene < 0)
        scene = GAMESCENE

    # オブジェクトリスト内の空いている場所を探す
    objnum = _getNullObject()
    if (objnum < 0)
        return undefined
    obj = _objects[objnum]
    obj.active = true

    # スプライト生成
    switch (type)
        when SPRITE
            motionsprite = tm.display.Sprite(image, width, height)
            animtmp = animlist[animnum]
            motionsprite.frameIndex = animtmp[1][0]
            motionsprite.x = x
            motionsprite.y = y - Math.floor(z)
            motionsprite.alpha = opacity
            motionsprite.rotation = 0.0
            motionsprite.scaleX = scaleX
            motionsprite.scaleY = scaleY
            motionsprite.visible = visible
            motionsprite.width = width
            motionsprite.height = height
            motionsprite.blendMode = "source-over"
            motionsprite.checkHierarchy = true
            motionsprite.setInteractive(true)
        else
            motionsprite = undefined

    # スプライトを表示
    if (motionsprite?)
        _scenes[scene].addChild(motionsprite)

    # 動きを定義したオブジェクトを生成する
    initparam = []
    initparam['x'] = x
    initparam['y'] = y
    initparam['z'] = z
    initparam['oldx'] = x
    initparam['oldy'] = y
    initparam['oldz'] = z
    initparam['xs'] = xs
    initparam['ys'] = ys
    initparam['zs'] = zs
    initparam['oldys'] = ys
    initparam['visible'] = visible
    initparam['scaleX'] = scaleX
    initparam['scaleY'] = scaleY
    initparam['gravity'] = gravity
    initparam['intersectFlag'] = true
    initparam['width'] = width
    initparam['height'] = height
    initparam['diffx'] = 0
    initparam['diffy'] = 0
    initparam['animlist'] = animlist
    initparam['animnum'] = animnum
    initparam['opacity'] = opacity
    initparam['motionsprite'] = motionsprite

    if (motionObj?)
        obj.motionObj = new motionObj(initparam)
    else
        obj.motionObj = new _stationary(initparam)
    uid = uniqueID()
    obj.motionObj._uniqueID = uid
    obj.motionObj._scene = scene
    obj.motionObj._type = type

    return obj.motionObj

#**********************************************************************
# オブジェクト削除（画面からも消える）
#**********************************************************************
removeObject = (motionObj)->
    if (!motionObj?)
        return
    ret = false
    for parent in _objects
        if (!parent.motionObj?)
            continue
        if (parent.motionObj._uniqueID == motionObj._uniqueID)
            ret = true
            break
    if (ret == false)
        return

    if (typeof(motionObj.destructor) == 'function')
        motionObj.destructor()

    _scenes[parent.motionObj._scene].removeChild(parent.motionObj.sprite)
    parent.motionObj.sprite = 0

    parent.motionObj = 0
    parent.active = false
                
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

