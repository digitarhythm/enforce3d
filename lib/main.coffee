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
COLLADA             = 10

# グローバル初期化

# センサー系
MOTION_ACCEL        = [x:0, y:0, z:0]
MOTION_GRAVITY      = [x:0, y:0, z:0]
MOTION_ROTATE       = [alpha:0, beta:0, gamma:0]

# User Agent
_useragent = window.navigator.userAgent.toLowerCase()
# 標準ブラウザ
if (_useragent.match(/^.*android.*mobile safari.*$/i) && !_useragent.match(/^.*[^0.9] chrome.*/i))
    _standardbrowser = true
else
    _standardbrowser = false

# ゲーム起動時からの経過時間（秒）
LAPSEDTIME          = 0

# 3D系
RENDERER            = undefined
CAMERA              = undefined
LIGHT               = undefined

# オブジェクトが入っている配列
_objects            = []

# 起動時に生成されるスタートオブジェクト
_main               = undefined

# 3Dのscene
rootScene         = undefined

#******************************************************************************
# 起動時の処理
#******************************************************************************

# ゲーム起動時の処理
window.onload = ->
    if (MEDIALIST?)
        imagearr = []
        i = 0
        for obj of MEDIALIST
            imagearr[i++] = MEDIALIST[obj]

    window.addEventListener 'devicemotion', (e)=>
        MOTION_ACCEL = e.acceleration
        MOTION_GRAVITY = e.accelerationIncludingGravity
    window.addEventListener 'deviceorientation', (e)=>
        MOTION_ROTATE.alpha = e.alpha
        MOTION_ROTATE.beta = e.beta
        MOTION_ROTATE.gamma = e.gamma

    # Three.jsのレンダラー初期化
    RENDERER = new THREE.WebGLRenderer({ antialias:true })
    RENDERER.setSize(SCREEN_WIDTH, SCREEN_HEIGHT)
    RENDERER.setClearColorHex(0x000000, 1.0)
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
    rootScene = new THREE.Scene()
    # デフォルトカメラ生成
    CAMERA = new THREE.PerspectiveCamera(24, SCREEN_WIDTH / SCREEN_HEIGHT)
    CAMERA.position = new THREE.Vector3(0, 100, 1000)
    CAMERA.lookAt(new THREE.Vector3(0, 0, 0))
    rootScene.add(CAMERA)
    # デフォルトライト生成
    LIGHT = new THREE.DirectionalLight(0xffffff)
    LIGHT.position = new THREE.Vector3(0.577, 0.577, 0.577)
    rootScene.add(LIGHT)

    for i in [0...OBJECTNUM]
        _objects[i] = new _originObject()
    _main = new enforceMain()
    enterframe()

enterframe = ->
    for obj in _objects
        if (obj.active == true && obj.motionObj != undefined && typeof(obj.motionObj.behavior) == 'function')
            obj.motionObj.behavior()
    RENDERER.render(rootScene, CAMERA)
    setTimeout(enterframe, 1000 / FPS)


#******************************************************************************
# 共用オブジェクト生成メソッド
#******************************************************************************
addObject = (param)->
    # パラメーター
    motionObj = if (param.motionObj?) then param.motionObj else undefined
    _type = if (param.type?) then param.type else GLSPHERE
    x = if (param.x?) then param.x else 0.0
    y = if (param.y?) then param.y else 0.0
    z = if (param.z?) then param.z else 0.0
    xs = if (param.xs?) then param.xs else 0.0
    ys = if (param.ys?) then param.ys else 0.0
    zs = if (param.zs?) then param.zs else 0.0
    gravity = if (param.gravity?) then param.gravity else 0.0
    image = if (param.image?) then param.image else undefined
    opacity = if (param.opacity?) then param.opacity else 1.0
    visible = if (param.visible?) then param.visible else true
    scaleX = if (param.scaleX?) then param.scaleX else 1.0
    scaleY = if (param.scaleY?) then param.scaleY else 1.0
    scaleZ = if (param.scaleZ?) then param.scaleZ else 1.0
    alpha = if (param.alpha?) then param.alpha else 0.0
    beta = if (param.beta?) then param.beta else 0.0
    gamma = if (param.gamma?) then param.gamma else 0.0

    if (motionObj == undefined)
        motionObj = undefined

    # スプライトを生成
    switch (_type)
        when COLLADA
            if (MEDIALIST[image]?)
                loader = new THREE.ColladaLoader()
                loader.options.convertUpAxis = true
                motionsprite = undefined
                retobject = undefined
                loader.load MEDIALIST[image], (collada)=>
                    motionsprite = collada.scene
                    motionsprite.position.set(x, y, z)
                    motionsprite.scale.set(scaleX, scaleY, scaleZ)
                    rootScene.add(motionsprite)
                    # 動きを定義したオブジェクトを生成する
                    retObject = @setMotionObj(x, y, z, xs, ys, zs, visible, scaleX, scaleY, scaleZ, gravity, opacity, _type, motionsprite, motionObj, alpha, beta, gamma)
                    return retObject
        else
            retobject = undefined
            motionsprite = undefined

    return retobject

setMotionObj = (x, y, z, xs, ys, zs, visible, scaleX, scaleY, scaleZ, gravity, opacity, _type, motionsprite, motionObj, alpha, beta, gamma)->
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
    initparam['alpha'] = alpha
    initparam['beta'] = beta
    initparam['gamma'] = gamma
    initparam['gravity'] = gravity
    initparam['intersectFlag'] = true
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
    obj.motionObj._type = _type

    return obj.motionObj

#**********************************************************************
# オブジェクト削除（画面からも消える）
#**********************************************************************
removeObject = (motionObj)->
    if (!motionObj?)
        return

    # 削除しようとしているmotionObjがオブジェクトリストのどこに入っているか探す
    ret = false
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

    rootScene.removeChild(object.motionObj.sprite)
    object.motionObj.sprite = undefined

    object.motionObj = undefined
    object.active = false

#**********************************************************************
# オブジェクトリストの指定した番号のオブジェクトを返す
#**********************************************************************
getObject = (id)->
    ret = undefined
    for i in [0..._objects.length]
        if (!_objects[i]?)
            continue
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
