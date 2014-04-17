class _stationary
    #***************************************************************
    # コンストラクター
    #***************************************************************
    constructor:(@sprite)->
        @_processnumber = 0
        @_waittime = 0.0
        @_dispframe = 0
        @_endflag = false
        @_returnflag = false
        @_autoRemove = false
        @_animTime = LAPSEDTIME * 1000

        if (LIBRARY == "enchant")
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
        else if (LIBRARY == "tmlib")
            @sprite.onpointingstart = (e)=>
                pos = {x:e.pointing.position.x, y:e.pointing.position.y}
                if (typeof @touchesBegan == 'function')
                    @touchesBegan(pos)
            @sprite.onpointingmove = (e)=>
                pos = {x:e.pointing.position.x, y:e.pointing.position.y}
                if (typeof @touchesMoved == 'function')
                    @touchesMoved(pos)
            @sprite.onpointingend = (e)=>
                pos = {x:e.pointing.position.x, y:e.pointing.position.y}
                if (typeof @touchesEnded == 'function')
                    @touchesEnded(pos)
            @sprite.onpointingcancel = (e)=>
                pos = {x:e.pointing.position.x, y:e.pointing.position.y}
                if (typeof @touchesCanceled == 'function')
                    @touchesCanceled(pos)



        if (@sprite?)
            @sprite.intersectFlag = true

    #***************************************************************
    # デストラクター
    #***************************************************************
    destructor:->

    #***************************************************************
    # ビヘイビアー
    #***************************************************************
    behavior:->
        if (@_type == SPRITE && @sprite?)
            if (@sprite.x != @sprite.xback)
                @sprite._x_ = @sprite.x
            if (@sprite.y != @sprite.yback)
                @sprite._y_ = @sprite.y
            if (@sprite.z != @sprite.zback)
                @sprite._z_ = @sprite.z
            @sprite.ys += @sprite.gravity
            @sprite._x_ += @sprite.xs
            @sprite._y_ += @sprite.ys
            @sprite._z_ += @sprite.zs
            @sprite.x = Math.round(@sprite._x_)
            @sprite.y = Math.round(@sprite._y_)
            @sprite.z = Math.round(@sprite._z_)
            @sprite.xback = @sprite.x
            @sprite.yback = @sprite.y
            @sprite.zback = @sprite.z

        if (@_type < 5)
            # 画面外に出たら自動的に消滅する
            if (@sprite.x < -@sprite.width || @sprite.x > SCREEN_WIDTH || @sprite.y < -@sprite.height || @sprite.y > SCREEN_HEIGHT || @_autoRemove == true)
                if (typeof(@autoRemove) == 'function')
                    @autoRemove()
                    removeObject(@)

            if (@sprite.animlist?)
                #JSLog("frame=%@, x=%@, y=%@", @_dispframe, @sprite.x, @sprite.y)
                animtmp = @sprite.animlist[@sprite.animnum]
                animtime = animtmp[0]
                #JSLog("lap=%@, animtime=%@", LAPSEDTIME * 1000, @_animTime)
                animpattern = animtmp[1]
                if (LAPSEDTIME * 1000 > @_animTime + animtime)
                    @sprite.frameIndex = animpattern[@_dispframe++]
                    @sprite.frame = animpattern[@_dispframe++]
                    @_animTime = LAPSEDTIME * 1000
                if (@_dispframe >= animpattern.length)
                    if (@_endflag == true)
                        @_endflag = false
                        removeObject(@)
                        return
                    else if (@_returnflag == true)
                        @_returnflag = false
                        @sprite.animnum = @_beforeAnimnum
                        @_dispframe = 0
                    else
                        @_dispframe = 0

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
        if (!motionObj?)
            return false
        if (range < 0)
            range = motionObj.sprite.width / 2
        if (@sprite.intersectFlag == true && motionObj.sprite.intersectFlag == true)
            ret = @sprite.within(motionObj.sprite, range)
        else
            ret = false
        return ret

    #***************************************************************
    # スプライト同士の衝突判定(intersect)
    #***************************************************************
    isIntersect:(motionObj, method = undefined)->
        if (!motionObj.sprite?)
            return false
        if (@sprite.intersectFlag == true && motionObj.sprite.intersectFlag == true)
            ret = @sprite.intersect(motionObj.sprite)
        else
            ret = false
        return ret

    #***************************************************************
    # 指定されたアニメーションを再生した後オブジェクト削除
    #***************************************************************
    setAnimationToRemove:(animnum)->
        @sprite.animnum = animnum
        @_dispframe = 0
        @_endflag = true

    #***************************************************************
    # 指定したアニメーションを一回だけ再生し指定したアニメーションに戻す
    #***************************************************************
    setAnimationToOnce:(animnum, animnum2)->
        @_beforeAnimnum = animnum2
        @sprite.animnum = animnum
        @_dispframe = 0
        @_returnflag = true

    #***************************************************************
    # 3DスプライトにColladaモデルを設定する
    #***************************************************************
    setModel:(num)->
        model = MEDIALIST[num]
        @set(core.assets[model])

