#***********************************************************************
# enforce game engine(enchant)
#
# 2014.04.04 ver2.0
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
DSPRITE_BOX         = 2
DSPRITE_CIRCLE      = 3
SSPRITE_BOX         = 4
SSPRITE_CIRCLE      = 5
WEBGL               = 6

# Sceneの種類
BGSCENE             = 0
BGSCENE_SUB1        = 1
BGSCENE_SUB2        = 2
GAMESCENE           = 3
GAMESCENE_SUB1      = 4
GAMESCENE_SUB2      = 5
TOPSCENE            = 6
WEBGLSCENE          = 7

# グローバル初期化

# センサー系
MOTION_ACCEL        = [x:0, y:0, z:0]
MOTION_GRAVITY      = [x:0, y:0, z:0]
MOTION_ROTATE       = [alpha:0, beta:0, gamma:0]

# ゲーム起動時からの経過時間（秒）
LAPSEDTIME          = 0

# 3D系
RENDERER            = undefined
CAMERA              = undefined
LIGHT               = undefined

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
    for i in [0..TOPSCENE]
        scene = new Group()
        scene.backgroundColor = "black"
        _scenes[i] = scene
        rootScene.addChild(scene)

    ###
    # Three.jsのレンダラー初期化
    RENDERER = new THREE.WebGLRenderer({ antialias:true })
    RENDERER.setSize(SCREEN_WIDTH, SCREEN_HEIGHT)
    RENDERER.setClearColorHex(0x000000, 0.0)
    document.getElementById('webgl').appendChild(RENDERER.domElement)
    scale = Math.min(
        innerWidth / SCREEN_WIDTH
        innerHeight / SCREEN_HEIGHT
    )
    scrwidth = Math.floor(SCREEN_WIDTH * scale)
    scrheight = Math.floor(SCREEN_HEIGHT * scale)
    left = Math.floor((window.innerWidth - scrwidth) / 2)
    top = Math.floor((window.innerHeight - scrheight) / 2)
    webglelm = document.querySelector('#webgl')
    webglelm.style.webkitTransformOrigin = left+"px "+top+"px"
    webglelm.style.webkitTransform = "scale("+scale+", "+scale+") translate("+left+"px, "+top+"px)"
    # シーン生成
    glscene = new THREE.Scene()
    _scenes[WEBGLSCENE] = glscene
    # デフォルトカメラ生成
    CAMERA = new THREE.PerspectiveCamera(24, SCREEN_WIDTH / SCREEN_HEIGHT)
    CAMERA.position = new THREE.Vector3(0, 100, 100)
    CAMERA.lookAt(new THREE.Vector3(0, 0, 0))
    glscene.add(CAMERA)
    # デフォルトライト生成
    LIGHT = new THREE.DirectionalLight(0xffffff)
    LIGHT.position = new THREE.Vector3(0.577, 0.577, 0.577)
    glscene.add(LIGHT)
    ###

    core.onload = ->
        for i in [0...OBJECTNUM]
            _objects[i] = new _originObject()
        _main = new enforceMain()
        rootScene.addEventListener 'enterframe', (e)->
            #RENDERER.render(_scenes[WEBGLSCENE], CAMERA)
            LAPSEDTIME = parseFloat((core.frame / FPS).toFixed(2))
            for obj in _objects
                if (obj._type == WEBGL)
                    continue
                if (obj.motionObj != undefined && typeof(obj.motionObj.behavior) == 'function')
                    obj.motionObj.behavior()
                if (obj.motionObj? && obj.motionObj.sprite?)
                    obj.motionObj.sprite.visible = false
                    #_scenes[obj.motionObj._scene].removeChild(obj.motionObj.sprite)

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
                if (obj._type == WEBGL)
                    continue
                if (obj.motionObj? && obj.motionObj.sprite?)
                    #_scenes[obj.motionObj._scene].addChild(obj.motionObj.sprite)
                    obj.motionObj.sprite.visible = obj.motionObj.visible
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
    model = if (param.model?) then param.model else undefined
    density = if (param.density?) then param.density else 1.0
    friction = if (param.friction?) then param.friction else 0.5
    restitution = if (param.restitution?) then param.restitution else 0.1
    move = if (param.move?) then param.move else false
    scaleX = if (param.scaleX?) then param.scaleX else 1.0
    scaleY = if (param.scaleY?) then param.scaleY else 1.0
    scaleZ = if (param.scaleZ?) then param.scaleZ else 1.0

    if (motionObj == null)
        motionObj = undefined

    # スプライトを生成
    switch (_type)
        when CONTROL, SPRITE
            motionsprite = new Sprite()
            if (scene < 0)
                scene = GAMESCENE_SUB1
            # TimeLineを時間ベースにする
            motionsprite.tl.setTimeBased()

            if (animlist?)
                animtmp = animlist[animnum]
                motionsprite.frame = animtmp[1][0]

                motionsprite.backgroundColor = "transparent"
                motionsprite.x = x - Math.floor(width / 2)
                motionsprite.y = y - Math.floor(height / 2) - Math.floor(z)
                motionsprite.opacity = opacity
                motionsprite.rotation = 0.0
                motionsprite.scaleX = scaleX
                motionsprite.scaleY = scaleY
                motionsprite.visible = visible
                motionsprite.width = width
                motionsprite.height = height

                # 画像割り当て
                if (MEDIALIST[image]? && animlist?)
                    img = MEDIALIST[image]
                    motionsprite.image = core.assets[img]

                # スプライトを表示
                if (_type != WEBGL)
                    _scenes[scene].addChild(motionsprite)

            # 動きを定義したオブジェクトを生成する
            retObject = @setMotionObj(x, y, z, xs, ys, zs, visible, scaleX, scaleY, scaleZ, gravity, width, height, animlist, animnum, opacity, scene, _type, motionsprite, motionObj)

        when WEBGL
            if (MEDIALIST[image]?)
                loader = new THREE.ColladaLoader()
                loader.options.convertUpAxis = true
                motionsprite = undefined
                loader.load MEDIALIST[image], (collada)=>
                    motionsprite = collada.scene
                    motionsprite.position.set(x, y, z)
                    motionsprite.scale.set(scaleX, scaleY, scaleZ)
                    _scenes[WEBGLSCENE].add(motionsprite)
                    # 動きを定義したオブジェクトを生成する
                    retObject = @setMotionObj(x, y, z, xs, ys, zs, visible, scaleX, scaleY, scaleZ, gravity, width, height, animlist, animnum, opacity, scene, _type, motionsprite, motionObj)
        else
            motionsprite = undefined
            if (scene < 0)
                scene = GAMESCENE_SUB1

    return retObject

setMotionObj = (x, y, z, xs, ys, zs, visible, scaleX, scaleY, scaleZ, gravity, width, height, animlist, animnum, opacity, scene, _type, motionsprite, motionObj)->
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
    initparam['scaleZ'] = scaleZ
    initparam['gravity'] = gravity
    initparam['intersectFlag'] = true
    initparam['width'] = width
    initparam['height'] = height
    initparam['diffx'] = Math.floor(width / 2)
    initparam['diffy'] = Math.floor(height / 2)
    initparam['animlist'] = animlist
    initparam['animnum'] = animnum
    initparam['opacity'] = opacity
    initparam['motionsprite'] = motionsprite

    objnum = _getNullObject()
    if (objnum < 0)
        return undefined

    obj = _objects[objnum]
    obj.active = true

    if (motionObj?)
        obj.motionObj = new motionObj(initparam)
    else
        obj.motionObj = new _stationary(initparam)

    uid = uniqueID()
    obj.motionObj._uniqueID = uid
    obj.motionObj._scene = scene
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
# サウンド再生
#**********************************************************************
playSound = (name)->
    soundfile = MEDIALIST[name]
    soundassets = core.assets[soundfile].clone()
    soundassets.play()
    return soundassets

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
