class _stationary
  #***************************************************************
  # コンストラクター
  #***************************************************************
  constructor:(@initparam)->
    @_processnumber = 0
    @_waittime = 0.0
    @_dispframe = 0
    @_endflag = false
    @_returnflag = false
    @_autoRemove = false
    @_animTime = LAPSEDTIME * 1000
    @sprite = @initparam.motionsprite
    @active = @initparam.active

    @setupSprite()

  #***************************************************************
  # スプライト初期化
  #***************************************************************
  setupSprite:->
    @type           = @initparam.type
    @x              = @initparam.x
    @y              = @initparam.y
    @z              = @initparam.z
    @oldx           = @initparam.x
    @oldy           = @initparam.y
    @oldz           = @initparam.z
    @xs             = @initparam.xs
    @ys             = @initparam.ys
    @zs             = @initparam.zs
    @oldys          = @initparam.ys
    @visible        = @initparam.visible
    @scaleX         = @initparam.scaleX
    @scaleY         = @initparam.scaleY
    @scaleZ         = @initparam.scaleZ
    @alpha          = @initparam.alpha
    @beta           = @initparam.beta
    @gamma          = @initparam.gamma
    @vcanvas        = @initparam.vcanvas
    @vtexture       = @initparam.vtexture
    @gravity        = @initparam.gravity
    @intersectFlag  = @initparam.intersectFlag
    @opacity        = @initparam.opacity
    @parent         = @initparam.parent
    @intersectFlag  = true
    @active         = true

    if (@sprite?)
      @sprite.ontouchstart = (e)=>
        pos = {x:e.x, y:e.y}
        if (typeof @touchesBegan == 'function')
          @touchesBegan(pos)
      @sprite.ontouchmove = (e)=>
        pos = {x:e.x, y:e.y}
        if (typeof @touchesMoved == 'function')
          @touchesMoved(pos)
      @sprite.ontouchend = (e)=>
        pos = {x:e.x, y:e.y}
        if (typeof @touchesEnded == 'function')
          @touchesEnded(pos)
      @sprite.ontouchcancel = (e)=>
        pos = {x:e.x, y:e.y}
        if (typeof @touchesCanceled == 'function')
          @touchesCanceled(pos)
      @sprite.castShadow = true
      @sprite.receiveShadow = true
    @initparam = {} if (@type != COLLADA)

  #***************************************************************
  # デストラクター
  #***************************************************************
  destructor:->

  #***************************************************************
  # ビヘイビアー
  #***************************************************************
  behavior:->
    # スプライトの座標等パラメータを更新する
    if (@sprite?)
      @sprite.position.set(Math.floor(@x), Math.floor(@y), Math.floor(@z))
      @sprite.visible = @visible
      @sprite.scale.set(@scaleX, @scaleY, @scaleZ)
      if (@alpha < 0)
        @alpha = 360 + @alpha
      if (@alpha > 360)
        @alpha %= 360
      if (@beta < 0)
        @beta = 360 + @beta
      if (@beta > 360)
        @beta %= 360
      if (@gamma < 0)
        @gamma = 360 + @gamma
      if (@gamma > 360)
        @gamma %= 360
      @sprite.rotation.set(@alpha * RAD, @beta * RAD, @gamma * RAD)
      @ys -= @gravity
      @x += @xs
      @y += @ys
      @z += @zs
      @sprite.x = Math.floor(@x)
      @sprite.y = Math.floor(@y)
      @sprite.z = Math.floor(@z)
      @sprite.opacity = @opacity

    if (@_waittime > 0 && LAPSEDTIME > @_waittime)
      @_waittime = 0
      @_processnumber = @_nextprocessnum

  #***************************************************************
  # タッチ開始
  #***************************************************************
  touchesBegan:(e)->

  #***************************************************************
  # タッチしたまま移動
  #***************************************************************
  touchesMoved:(e)->

  #***************************************************************
  # タッチ終了
  #***************************************************************
  touchesEnded:(e)->

  #***************************************************************
  # タッチキャンセル
  #***************************************************************
  touchesCanceled:(e)->

  #***************************************************************
  # 次のプロセスへ
  #***************************************************************
  nextjob:->
    @_processnumber++

  #***************************************************************
  # 指定した秒数だけ待って次のプロセスへ
  #***************************************************************
  waitjob:(wtime)->
    @_waittime = LAPSEDTIME + wtime
    @_nextprocessnum = @_processnumber + 1
    @_processnumber = -1
  
  #***************************************************************
  # プロセス番号を設定
  #***************************************************************
  setProcessNumber:(num)->
    @_processnumber = num

  #***************************************************************
  # スプライト同士の衝突判定(withIn)
  #***************************************************************
  isWithIn:(motionObj, range = -1)->
    ret = true
    if (!motionObj?)
      ret = false
    return ret

  #***************************************************************
  # スプライト同士の衝突判定(intersect)
  #***************************************************************
  isIntersect:(motionObj)->
    ret = true
    if (!motionObj.sprite?)
      ret = false
    return ret

  #***************************************************************
  # 3DスプライトにColladaモデルを設定する
  #***************************************************************
  setModel:(name)->
    model = MEDIALIST[name]
    @set(core.assets[model])

