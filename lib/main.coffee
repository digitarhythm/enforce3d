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
PRIMITIVE           = 20

# プリミティブ
PLANE               = 0
CUBE                = 1
CIRCLE              = 2
CYLINDER            = 3
SPHERE              = 4
ICOSAHEDRON         = 5
TORUS               = 6
TORUSKNOT           = 7
BUFFER              = 8

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
EFFECT              = undefined

# オブジェクトが入っている配列
_objects            = []

# 起動時に生成されるスタートオブジェクト
_main               = undefined

# 3Dのscene
rootScene           = undefined

# スクリーンサイズ
PIXELRATIO          = window.devicePixelRatio
SCREEN_WIDTH        = window.innerWidth
SCREEN_HEIGHT       = window.innerHeight
ASPECT              = SCREEN_WIDTH / SCREEN_HEIGHT

# OculusRiftEffect
WORLD_FACTOR        = 1.0

#******************************************************************************
# 起動時の処理
#******************************************************************************

# ゲーム起動時の処理
window.onload = ->
    if (MEDIALIST?)
        modelarr = []
        i = 0
        for obj of MEDIALIST
            modelarr[i++] = MEDIALIST[obj]

    window.addEventListener 'devicemotion', (e)=>
        MOTION_ACCEL = e.acceleration
        MOTION_GRAVITY = e.accelerationIncludingGravity
    window.addEventListener 'deviceorientation', (e)=>
        MOTION_ROTATE.alpha = e.alpha
        MOTION_ROTATE.beta = e.beta
        MOTION_ROTATE.gamma = e.gamma

    RENDERER = new THREE.WebGLRenderer()
    RENDERER.setClearColor(0x303030)
    RENDERER.setSize(SCREEN_WIDTH, SCREEN_HEIGHT)
    document.getElementById('webgl').appendChild(RENDERER.domElement)

    CAMERA = new THREE.PerspectiveCamera(90, ASPECT, 0.1, 1000)
    CAMERA.position.set(0, 200, 900)

    rootScene = new THREE.Scene()
    rootScene.fog = new THREE.FogExp2( FOGCOLOR, FOGLEVEL );

    # カメラ設定
    if (OCULUS == true)
        # OculusRiftEffect設定
        OculusRift = {
            hResolution: SCREEN_WIDTH
            vResolution: SCREEN_HEIGHT
            hScreenSize: 0.14976
            vScreenSize: 0.0936
            interpupillaryDistance: 0.064
            lensSeparationDistance: 0.064
            eyeToScreenDistance: 0.041
            distortionK: [1.0, 0.22, 0.24, 0.0]
            chromaAbParameter: [0.996, -0.004, 1.014, 0.0]
        }
        EFFECT = new THREE.OculusRiftEffect(RENDERER, {
            HMD: OculusRift
            worldFactor: WORLD_FACTOR
        })
        CAMERA.position = new THREE.Vector3(0, 200, 900)
    else
        CAMERA.position = new THREE.Vector3(0, 0, 1024)
    CAMERA.lookAt(new THREE.Vector3(0, 0, 0))
    rootScene.add(CAMERA)

    # デフォルトライト生成
    LIGHT = new THREE.DirectionalLight(0x303030)
    LIGHT.position = new THREE.Vector3(0.577, 0.577, 0.577)
    LIGHT.castShadow = true
    rootScene.add(LIGHT)
    # 環境光オブジェクト(LIGHT2)の設定　
    LIGHT2 = new THREE.AmbientLight(0xffffff)
    # sceneに環境光オブジェクト(LIGHT2)を追加                
    rootScene.add(LIGHT2)

#    geometry = new THREE.SphereGeometry(10, 100, 100)
#    material = new THREE.MeshPhongMaterial({color: 'white'})
#    motionsprite = new THREE.Mesh(geometry, material)
#    rootScene.add(motionsprite)

    for i in [0...OBJECTNUM]
        _objects[i] = new _originObject()
    _main = new enforceMain()
    enterframe()

enterframe = ->
    for obj in _objects
        if (obj.active == true && obj.motionObj != undefined && typeof(obj.motionObj.behavior) == 'function')
            obj.motionObj.behavior()

    if (OCULUS == true)
        EFFECT.render(rootScene, CAMERA)
    else
        RENDERER.render(rootScene, CAMERA)

    setTimeout(enterframe, 1000 / 60)


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
    radius = if (param.radius?) then param.radius else 10.0
    width = if (param.width?) then param.width else 10.0
    height = if (param.height?) then param.height else 10.0
    depth = if (param.depth?) then param.depth else 10.0
    color = if (param.color?) then param.color else 'gray'
    gravity = if (param.gravity?) then param.gravity else 0.0
    model = if (param.model?) then param.model else undefined
    opacity = if (param.opacity?) then param.opacity else 1.0
    visible = if (param.visible?) then param.visible else true
    scaleX = if (param.scaleX?) then param.scaleX else 1.0
    scaleY = if (param.scaleY?) then param.scaleY else 1.0
    scaleZ = if (param.scaleZ?) then param.scaleZ else 1.0
    alpha = if (param.alpha?) then param.alpha else 0.0
    beta = if (param.beta?) then param.beta else 0.0
    gamma = if (param.gamma?) then param.gamma else 0.0
    divx = if (param.divx?) then param.divx else 64
    divy = if (param.divy?) then param.divy else 64
    texture = if (param.texture?) then param.texture else undefined

    if (motionObj == undefined)
        motionObj = undefined

    # スプライトを生成
    switch (_type)
        when COLLADA
            if (MEDIALIST[model]?)
                loader = new THREE.ColladaLoader()
                loader.options.convertUpAxis = true
                loader.load MEDIALIST[model], (collada)=>
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

        when PRIMITIVE
            switch (model)
                when PLANE
                    geometry = new THREE.PlaneGeometry(width, height, divx, divy)
                when CUBE
                    geometry = new THREE.CubeGeometry(width, height, depth)
                    nop()
                when CIRCLE
                    nop()
                when CYLINDER
                    nop()
                when SPHERE
                    geometry = new THREE.SphereGeometry(radius, width, height)
                when ICOSAHEDRON
                    nop()
                when TORUS
                    nop()
                when TORUSKNOT
                    nop()
                when BUFFER
                    nop()

            if (texture?)
                map = THREE.ImageUtils.loadTexture(MEDIALIST[texture])
                material = new THREE.MeshLambertMaterial {
                    map: map
                }
            else
                material = new THREE.MeshPhongMaterial({color: color})
            motionsprite = new THREE.Mesh(geometry, material)
            motionsprite.position.set(x, y, z)
            rootScene.add(motionsprite)
            retObject = @setMotionObj(x, y, z, xs, ys, zs, visible, scaleX, scaleY, scaleZ, gravity, opacity, _type, motionsprite, motionObj, alpha, beta, gamma)

    return retObject

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
