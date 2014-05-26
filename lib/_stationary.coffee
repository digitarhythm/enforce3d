class _stationary
    #***************************************************************
    # コンストラクター
    #***************************************************************
    constructor:(initparam)->
        @_processnumber = 0
        @_waittime = 0.0
        @_dispframe = 0
        @_endflag = false
        @_returnflag = false
        @_autoRemove = false
        @_animTime = LAPSEDTIME * 1000
        @sprite = initparam['motionsprite']

        if (@sprite?)
            @x = initparam['x']
            @y = initparam['y']
            @z = initparam['z']
            @oldx = initparam['x']
            @oldy = initparam['y']
            @oldz = initparam['z']
            @xs = initparam['xs']
            @ys = initparam['ys']
            @zs = initparam['zs']
            @oldys = initparam['ys']
            @visible = initparam['visible']
            @scaleX = initparam['scaleX']
            @scaleY = initparam['scaleY']
            @scaleZ = initparam['scaleZ']
            @gravity = initparam['gravity']
            @intersectFlag = initparam['intersectFlag']
            @width = initparam['width']
            @height = initparam['height']
            @diffx = initparam['diffx']
            @diffy = initparam['diffy']
            @animlist = initparam['animlist']
            @animnum = initparam['animnum']
            @opacity = initparam['opacity']

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

            @intersectFlag = true

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
            switch (@_type)
                when SPRITE
                    @sprite.x = Math.floor(@x - @diffx)
                    @sprite.y = Math.floor(@y - @diffy - @z)

                    @ys += @gravity

                    @x += @xs
                    @y += @ys
                    @z += @zs

                    if (@opacity != @sprite.opacity && @sprite.opacity == @opacity_back)
                        @sprite.opacity = @opacity
                    else
                        @opacity = @sprite.opacity
                    @opacity_back = @sprite.opacity

                    @sprite.visible = @visible
                    @sprite.scaleX  = @scaleX
                    @sprite.scaleY  = @scaleY
                    @sprite.width = @width
                    @sprite.height = @height

                    if (@_type == SPRITE)
                        # 画面外に出たら自動的に消滅する
                        if (@sprite.x < -@sprite.width || @sprite.x > SCREEN_WIDTH || @sprite.y < -@sprite.height || @sprite.y > SCREEN_HEIGHT || @_autoRemove == true)
                            if (typeof(@autoRemove) == 'function')
                                @autoRemove()
                                removeObject(@)

                        if (@animlist?)
                            animtmp = @animlist[@animnum]
                            animtime = animtmp[0]
                            animpattern = animtmp[1]
                            if (LAPSEDTIME * 1000 > @_animTime + animtime)
                                @sprite.frameIndex = animpattern[@_dispframe]
                                @sprite.frame = animpattern[@_dispframe]
                                @_animTime = LAPSEDTIME * 1000
                                @_dispframe++
                                if (@_dispframe >= animpattern.length)
                                    if (@_endflag == true)
                                        @_endflag = false
                                        removeObject(@)
                                        return
                                    else if (@_returnflag == true)
                                        @_returnflag = false
                                        @animnum = @_beforeAnimnum
                                        @_dispframe = 0
                                    else
                                        @_dispframe = 0

                when WEBGL
                    @sprite.position.set(@x, @y, @z)
                    @sprite.scale.set(@scaleX, @scaleY, @scaleZ)
                    @ys += @gravity
                    @x += @xs
                    @y += @ys
                    @z += @zs

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
        if (@intersectFlag == true && motionObj.intersectFlag == true)
            ret = @sprite.within(motionObj.sprite, range)
        else
            ret = false
        return ret

    #***************************************************************
    # スプライト同士の衝突判定(intersect)
    #***************************************************************
    isIntersect:(motionObj)->
        if (!motionObj.sprite?)
            return false
        if (@intersectFlag == true && motionObj.intersectFlag == true)
            ret = @sprite.intersect(motionObj.sprite)
        else
            ret = false
        return ret

    #***************************************************************
    # 指定されたアニメーションを再生した後オブジェクト削除
    #***************************************************************
    setAnimationToRemove:(animnum)->
        @animnum = animnum
        @_dispframe = 0
        @_endflag = true

    #***************************************************************
    # 指定したアニメーションを一回だけ再生し指定したアニメーションに戻す
    #***************************************************************
    setAnimationToOnce:(animnum, animnum2)->
        @_beforeAnimnum = animnum2
        @animnum = animnum
        @_dispframe = 0
        @_returnflag = true

    #***************************************************************
    # 3DスプライトにColladaモデルを設定する
    #***************************************************************
    setModel:(name)->
        model = MEDIALIST[name]
        @set(core.assets[model])

    #***************************************************************
    # 角度を設定する
    #***************************************************************
    setRotate:(rad)->
        @sprite.rotation = rad

    #***************************************************************
    # スプライトを回転させる
    #***************************************************************
    spriteRotation:(rad)->
        @sprite.rotate(rad)

#*******************************************************************
# TimeLine 制御
#*******************************************************************

    #***************************************************************
    # スプライトをfadeInさせる
    #***************************************************************
    fadeIn:(time)->
        @sprite.tl.fadeIn(time)
        return @

    #***************************************************************
    # スプライトをフェイドアウトする
    #***************************************************************
    fadeOut:(time)->
        @sprite.tl.fadeOut(time)
        return @

    #***************************************************************
    # タイムラインをループさせる
    #***************************************************************
    loop:->
        @sprite.tl.loop()

    #***************************************************************
    # ライムラインをクリアする
    #***************************************************************
    clear:->
        @sprite.tl.clear()

