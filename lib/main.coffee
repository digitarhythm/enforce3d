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
BOX                 = 0
CIRCLE              = 1
CUBE                = 2
CYLINDER            = 3
DODECAHEDRON        = 4
EXTRUDE             = 5
ICOSAHEDRON         = 6
LATHE               = 7
OCTAHEDRON          = 8
PARAMETRIC          = 9
PLANE               = 10
POLYHEDRON          = 11
RING                = 12
SHAPE               = 13
SPHERE              = 14
TETRAHEDRON         = 15
TEXT                = 16
TORUS               = 17
TORUSKNOT           = 18
TUBE                = 19

# グローバル初期化

# ゲームパッド情報格納変数
HORIZONTAL          = 0
VERTICAL            = 1
_keyinput           = []
_GAMEPADSINFO       = []
PADBUTTONS          = []
PADBUTTONS[0]       = [false, false]
PADAXES             = []
PADAXES[0]          = [0, 0]
ANALOGSTICK         = []
ANALOGSTICK[0]      = [0, 0, 0, 0]

# センサー系
MOTION_ACCEL        = [x:0, y:0, z:0]
#MOTION_GRAVITY      = [x:0, y:0, z:0]
#MOTION_ROTATE       = [alpha:0, beta:0, gamma:0]
_SENSOR              = undefined

# トラックボール
_TRACKBALLOBJ        = undefined

# 数学式
RAD                 = (Math.PI / 180.0)
DEG                 = (180.0 / Math.PI)

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
_RENDERER            = undefined
_CAMERA              = undefined
_LIGHT1              = undefined
_LIGHT2              = undefined
_LIGHT3              = undefined
_LIGHT4              = undefined
_LIGHTA              = undefined
_EFFECT              = undefined

# オブジェクトが入っている配列
_objects            = []

# 起動時に生成されるスタートオブジェクト
_main               = undefined

# 3Dのscene
rootScene           = undefined

# OculusRiftEffect
WORLD_FACTOR        = 1.0
VRSTATE             = undefined

# User Agent
_useragent = window.navigator.userAgent.toLowerCase()
# 標準ブラウザ
if (_useragent.match(/^.*android.*?mobile safari.*$/i) != null && _useragent.match(/^.*\) chrome.*/i) == null)
    _defaultbrowser = true
else
    _defaultbrowser = false
# ブラウザ大分類
if (_useragent.match(/.* firefox\/.*/))
    _browserMajorClass = "firefox"
else if (_useragent.match(/.*version\/.* safari\/.*/))
    _browserMajorClass = "safari"
else if (_useragent.match(/.*chrome\/.* safari\/.*/))
    _browserMajorClass = "chrome"
else
    _browserMajorClass = "unknown"

# スクリーンサイズ
PIXELRATIO          = window.devicePixelRatio
SCREEN_WIDTH        = window.innerWidth
SCREEN_HEIGHT       = window.innerHeight + if (_browserMajorClass == "chrome") then 48 else 0
ASPECT              = SCREEN_WIDTH / SCREEN_HEIGHT

#******************************************************************************
# 起動時の処理
#******************************************************************************

# ゲーム起動時の処理
window.onload = ->
    # Status Area
    STATUSAREA = document.getElementById('status')

    #STATUSAREA.innerHTML = "pixelratio="+PIXELRATIO

    if (MEDIALIST?)
        modelarr = []
        i = 0
        for obj of MEDIALIST
            modelarr[i++] = MEDIALIST[obj]

    _RENDERER = new THREE.WebGLRenderer()
    _RENDERER.shadowMapEnabled = true
    _RENDERER.setSize(SCREEN_WIDTH, SCREEN_HEIGHT)
    renderelm = _RENDERER.domElement
    webglelm = document.getElementById('webgl')
    webglelm.appendChild(renderelm)

    _CAMERA = new THREE.PerspectiveCamera(90, ASPECT, 1, 3000)
    _CAMERA.up.set(0, 1, 0)
    _CAMERA.position.set(0, 0, 0)

    rootScene = new THREE.Scene()
    rootScene.fog = new THREE.FogExp2( FOGCOLOR, FOGLEVEL );

    # カメラ設定
    if (VRMODE == true)
        vr.load (error)->
            #if (error)
            #    STATUSAREA.innerHTML = 'Plugin error'
        VRSTATE = new vr.State()

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
        _EFFECT = new THREE.OculusRiftEffect(_RENDERER, {
            HMD: OculusRift
            worldFactor: WORLD_FACTOR
        })
    else
        _CAMERA.lookAt(new THREE.Vector3(0, 0, -100))
        #_CAMERA.lookAt(_CAMERA.position)

    rootScene.add(_CAMERA)
    #createTrackball()

    # デフォルトライト生成
    _LIGHT1 = new THREE.DirectionalLight(0xffffff, 0.25)
    _LIGHT1.position = new THREE.Vector3(3000.0, 0.0, 0.0)
    _LIGHT1.castShadow = true
    rootScene.add(_LIGHT1)
    _LIGHT2 = new THREE.DirectionalLight(0xffffff, 0.25)
    _LIGHT2.position = new THREE.Vector3(0.0, 0.0, 3000.0)
    _LIGHT2.castShadow = true
    rootScene.add(_LIGHT2)
    _LIGHT3 = new THREE.DirectionalLight(0xffffff, 0.25)
    _LIGHT3.position = new THREE.Vector3(0.0, 0.0, -3000.0)
    _LIGHT3.castShadow = true
    rootScene.add(_LIGHT3)
    _LIGHT4 = new THREE.DirectionalLight(0xffffff, 0.25)
    _LIGHT4.position = new THREE.Vector3(-3000.0, 0.0, 0.0)
    _LIGHT4.castShadow = true
    rootScene.add(_LIGHT4)
    # 環境光オブジェクト(LIGHT2)の設定
    _LIGHTA = new THREE.AmbientLight(0xffffff)
    _LIGHTA.castShadow = true
    # sceneに環境光オブジェクト(LIGHT2)を追加
    rootScene.add(_LIGHTA)

    # スマートフォンのモーションセンサー
    _SENSOR = new THREE.DeviceOrientationControls(_CAMERA)

    for i in [0...OBJECTNUM]
        _objects[i] = new _originObject()
    _main = new enforceMain()

    enterframe()

#******************************************************************************
# 各種イベント登録
#******************************************************************************
    # keyDownイベント
    document.addEventListener 'keydown', (e)->
        if (!e?)
            e = window.event
        keycode = e.keyCode
        _keyinput[keycode] = true
        # フルスクリーン処理
        if (_keyinput[32])
            e.preventDefault()
            vr.resetHmdOrientation()
        if (_keyinput[70])
            e.preventDefault()
            if (vr.isFullScreen() == true)
                vr.exitFullScreen()
            else
                vr.enterFullScreen(true)

    # keyUpイベント
    document.addEventListener 'keyup', (e)->
        if (!e?)
            e = window.event
        keycode = e.keyCode
        _keyinput[keycode] = false

    # resizeイベント
    window.addEventListener 'resize', ->
        STATUSAREA.innerHTML = "width="+SCREEN_WIDTH+", height="+SCREEN_HEIGHT+", raitio="+PIXELRATIO
        SCREEN_WIDTH = window.innerWidth
        SCREEN_HEIGHT = window.innerHeight + if (_browserMajorClass == "chrome") then 48 else 0
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
        ASPECT = SCREEN_WIDTH / SCREEN_HEIGHT
        _CAMERA.aspect = ASPECT
        _CAMERA.updateProjectionMatrix()
        _RENDERER.setSize(SCREEN_WIDTH, SCREEN_HEIGHT)
        _EFFECT = new THREE.OculusRiftEffect(_RENDERER, {
            HMD: OculusRift
            worldFactor: WORLD_FACTOR
        })
    , false

    STATUSAREA.innerHTML = "width="+SCREEN_WIDTH+", height="+SCREEN_HEIGHT+", raitio="+PIXELRATIO

#******************************************************************************
# フレーム毎に実行する処理
#******************************************************************************

enterframe = ->
    for obj in _objects
        if (obj.active == true && obj.motionObj != undefined && typeof(obj.motionObj.behavior) == 'function')
            obj.motionObj.behavior()
            if (obj.motionObj.vcanvas?)
                if (obj.motionObj.vcanvas.readyState == obj.motionObj.vcanvas.HAVE_ENOUGH_DATA)
                    if (obj.motionObj.vtexture)
                        obj.motionObj.vtexture.needsUpdate = true

            # ジョイパッド処理
            if (typeof gamepadProcedure == 'function')
                _GAMEPADSINFO = gamepadProcedure()
                for num in [0..._GAMEPADSINFO.length]
                    if (!_GAMEPADSINFO[num]?)
                        continue
                    padobj = _GAMEPADSINFO[num]
                    PADBUTTONS[num] = _GAMEPADSINFO[num].padbuttons
                    PADAXES[num] = _GAMEPADSINFO[num].padaxes
                    ANALOGSTICK[num] = _GAMEPADSINFO[num].analogstick
            if (_keyinput[90] || _keyinput[32])
                PADBUTTONS[0][0] = true
            else if (!_GAMEPADSINFO[0]?)
                PADBUTTONS[0][0] = false
            if (_keyinput[88])
                PADBUTTONS[0][1] = true
            else if (!_GAMEPADSINFO[0]?)
                PADBUTTONS[0][1] = false
            if (_keyinput[37])
                PADAXES[0][HORIZONTAL] = -1
            else if (_keyinput[38])
                PADAXES[0][HORIZONTAL] = 1
            else if (!_GAMEPADSINFO[0]?)
                PADAXES[0][HORIZONTAL] = 0
            if (_keyinput[39])
                PADAXES[0][VERTICAL] = -1
            else if (_keyinput[40])
                PADAXES[0][VERTICAL] = 1
            else if (!_GAMEPADSINFO[0]?)
                PADAXES[0][VERTICAL] = 0

    if (VRMODE == true)
        if (!vr.pollState(VRSTATE))
            return

        if (VRSTATE.hmd.present)
            _CAMERA.quaternion.x = VRSTATE.hmd.rotation[0];
            _CAMERA.quaternion.y = VRSTATE.hmd.rotation[1];
            _CAMERA.quaternion.z = VRSTATE.hmd.rotation[2];
            _CAMERA.quaternion.w = VRSTATE.hmd.rotation[3];
            #STATUSAREA.innerHTML = ''
        else
            _SENSOR.update()
            #status.innerHTML = 'OculusRift not found.'
        _EFFECT.render(rootScene, _CAMERA)
    else
        _RENDERER.render(rootScene, _CAMERA)

    if (_TRACKBALLOBJ?)
        _TRACKBALLOBJ.update()

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
    radius = if (param.radius?) then param.radius else 10.0
    radius2 = if (param.radius2?) then param.radius2 else 10.0
    width = if (param.width?) then param.width else 10.0
    height = if (param.height?) then param.height else 10.0
    depth = if (param.depth?) then param.depth else 10.0
    segments = if (param.segments?) then param.segments else 128
    segments2 = if (param.segments2?) then param.segments2 else 128
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
    texture = if (param.texture?) then param.texture else undefined
    video = if (param.video?) then param.video else undefined
    videoautoplay = if (param.videoautoplay?) then param.videoautoplay else false
    videoloop = if (param.videoloop?) then param.videoloop else false
    start = if (param.start?) then param.start else 0.0
    length = if (param.length?) then param.length else 360.0
    start2 = if (param.start2?) then param.start2 else 0.0
    length2 = if (param.length2?) then param.length2 else 360.0
    textparam = if (param.textparam?) then param.textparam else []
    text = if (param.text?) then param.text else "TEXT"

    if (motionObj == undefined)
        motionObj = undefined

    # スプライトを生成
    switch (_type)
        when COLLADA
            if (MEDIALIST[model]?)
                loader = new THREE.ColladaLoader()
                loader.options.convertUpAxis = true
                loader.load(MEDIALIST[model])
                loader.load MEDIALIST[model], (collada)=>
                    motionsprite = collada.scene
                    motionsprite.position.set(x, y, z)
                    motionsprite.scale.set(scaleX, scaleY, scaleZ)
                    motionsprite.scale.x = scaleX
                    motionsprite.scale.y = scaleY
                    motionsprite.scale.z = scaleZ
                    motionsprite.rotation.set(alpha * RAD, beta * RAD, gamma * RAD)
                    motionsprite.updateMatrix()
                    rootScene.add(motionsprite)
                    retObject = @setMotionObj
                        x: x
                        y: y
                        z: z
                        xs: xs
                        ys: ys
                        zs: zs
                        visible: visible
                        scaleX: scaleX
                        scaleY: scaleY
                        scaleZ: scaleZ
                        gravity: gravity
                        opacity: opacity
                        _type: _type
                        motionsprite: motionsprite
                        motionObj: motionObj
                        alpha: alpha
                        beta: beta
                        gamma: gamma
                        vcanvas: vcanvas
                        vtexture: vtexture
                    return retObject
            else
                retobject = undefined
                motionsprite = undefined
                return retObject

        when PRIMITIVE
            switch (model)
                when BOX
                    geometry = new THREE.BoxGeometry(width, height, depth)
                when CIRCLE
                    geometry = new THREE.CircleGeometry(radius, segments)
                when CUBE
                    geometry = new THREE.BoxGeometry(width, height, depth)
                when CYLINDER
                    geometry = new THREE.CylinderGeometry(radius, radius2, height, segments)
                when PLANE
                    geometry = new THREE.PlaneGeometry(width, height, segments, segments2)
                when RING
                    geometry = new THREE.RingGeometry(radius, radius2, segments, segments2, start, length)
                when SPHERE
                    geometry = new THREE.SphereGeometry(radius, segments, segments2)
                    #geometry = new THREE.SphereGeometry(radius, segments, segments2, start * RAD, length * RAD, start2 * RAD, length2 * RAD)
                when TEXT
                    geometry = new THREE.TextGeometry(text, textparam)
                when TORUS
                    geometry = new THREE.TorusGeometry(radius, radius2, segments, segments2, length * RAD)
                when TORUSKNOT
                    geometry = new THREE.TorusKnotGeometry(radius, radius2, segments, segments2)

            if (texture?)
                map = THREE.ImageUtils.loadTexture(MEDIALIST[texture])
                material = new THREE.MeshLambertMaterial {
                    map: map
                    color: color
                }
            else if (video?)
                # video要素とそれをキャプチャするcanvas要素を生成
                vcanvas = document.createElement('video')
                vcanvas.src = MEDIALIST[video]
                vcanvas.load()
                vcanvas.autoplay = videoautoplay
                vcanvas.loop = videoloop

                # 生成したcanvasをtextureとしてTHREE.Textureオブジェクトを生成
                vtexture = new THREE.Texture(vcanvas)
                vtexture.minFilter = THREE.LinearFilter
                vtexture.magFilter = THREE.LinearFilter

                # 生成したvideo textureをmapに指定し、overdrawをtureにしてマテリアルを生成
                material = new THREE.MeshLambertMaterial {
                    map: vtexture
                    overdraw: true
                    side:THREE.DoubleSide
                }
            else
                material = new THREE.MeshPhongMaterial {
                    color: color
                    ambient: 0x303030
                    specular: 0xffffff
                    shininess:1
                    metal:true
                }

            motionsprite = new THREE.Mesh(geometry, material)

            motionsprite.position.set(x, y, z)
            rootScene.add(motionsprite)

            retObject = @setMotionObj
                x: x
                y: y
                z: z
                xs: xs
                ys: ys
                zs: zs
                visible: visible
                scaleX: scaleX
                scaleY: scaleY
                scaleZ: scaleZ
                gravity: gravity
                opacity: opacity
                _type: _type
                motionsprite: motionsprite
                motionObj: motionObj
                alpha: alpha
                beta: beta
                gamma: gamma
                vcanvas: vcanvas
                vtexture: vtexture
            return retObject

setMotionObj = (param)->
    if (param.x?) then x = param.x else x = 0.0
    if (param.y?) then y = param.y else y = 0.0
    if (param.z?) then z = param.z else z = 0.0
    if (param.xs?) then xs = param.xs else xs = 0.0
    if (param.ys?) then ys = param.ys else ys = 0.0
    if (param.zs?) then zs = param.zs else zs = 0.0
    if (param.visible?) then visible = param.visible else visible = true
    if (param.scaleX?) then scaleX = param.scaleX else scaleX = 1.0
    if (param.scaleY?) then scaleY = param.scaleY else scaleY = 1.0
    if (param.scaleZ?) then scaleZ = param.scaleZ else scaleZ = 1.0
    if (param.gravity?) then gravity = param.gravity else gravity = 0.0
    if (param.opacity?) then opacity = param.opacity else opacity = 1.0
    if (param._type?) then _type = param._type else _type = PRIMITIVE
    if (param.motionsprite?) then motionsprite = param.motionsprite else motionsprite = undefined
    if (param.motionObj?) then motionObj = param.motionObj else motionObj = undefined
    if (param.alpha?) then alpha = param.alpha else alpha = 0.0
    if (param.beta?) then beta = param.beta else beta = 0.0
    if (param.gamma?) then gamma = param.gamma else gamma = 0.0
    if (param.vcanvas?) then vcanvas = param.vcanvas else vcanvas = undefined
    if (param.vtexture?) then vtexture = param.vtexture else vtexture = undefined

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
    initparam['vcanvas'] = vcanvas
    initparam['vtexture'] = vtexture

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

    rootScene.remove(object.motionObj.sprite)
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
# トラックボール作成
#**********************************************************************
createTrackball = (param)->
    if (param?)
        if (param.noRotate?) then norotate = param.noRotate else norotate = false
        if (param.rotateSpeed?) then rotatespeed = param.rotateSpeed else rotatespeed = 1.0
        if (param.noZoom?) then nozoom = param.noZoom else nozoom = false
        if (param.zoomSpeed?) then zoomspeed = param.zoomSpeed else zoomspeed = 1.0
        if (param.noPan?) then nopan = param.noPan else nopan = false
        if (param.panSpeed?) then panspeed = param.panSpeed else panspeed= 1.0
        if (param.staticMoving?) then staticmoving = param.staticMoving else staticmoving = true
        if (param.dynamicDampingFactor?) then dynamicdampingfactor = param.dynamicDampingFactor else dynamicdampingfactor = 0.3
    else
        norotate = false
        rotatespeed = 1.0
        nozoom = false
        zoomspeed = 1.0
        nopan = false
        panspeed= 1.0
        staticmoving = true
        dynamicdampingfactor = 0.3

    _TRACKBALLOBJ = new THREE.TrackballControls(_CAMERA)

    ###
    _TRACKBALLOBJ.noRotate = norotate
    _TRACKBALLOBJ.rotateSpeed = rotatespeed
    _TRACKBALLOBJ.noZoom = nozoom
    _TRACKBALLOBJ.zoomSpeed = zoomspeed
    _TRACKBALLOBJ.noPan = nopan
    _TRACKBALLOBJ.panSpeed = panspeed
    _TRACKBALLOBJ.staticMoving = staticmoving
    _TRACKBALLOBJ.dynamicDampingFactor = dynamicdampingfactor
    ###


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
