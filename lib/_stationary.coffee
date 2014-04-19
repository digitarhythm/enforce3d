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
        if (@_type == SPRITE && @sprite?)
            @sprite.x = Math.floor(@x - @diffx)
            @sprite.y = Math.floor(@y - @diffy)

            @ys += @gravity

            @x += @xs
            @y += @ys

            if (LIBRARY == "tmlib")
                @sprite.alpha = @opacity
            else if (LIBRARY == "enchant")
                @sprite.opacity = @opacity

            @sprite.visible = @visible
            @sprite.scaleX  = @scaleX
            @sprite.scaleY  = @scaleY

        if (@_type == SPRITE)
            # 画面外に出たら自動的に消滅する
            if (@sprite.x < -@sprite.width || @sprite.x > SCREEN_WIDTH || @sprite.y < -@sprite.height || @sprite.y > SCREEN_HEIGHT || @_autoRemove == true)
                if (typeof(@autoRemove) == 'function')
                    @autoRemove()
                    removeObject(@)

            if (@animlist?)
                #JSLog("frame=%@, x=%@, y=%@", @_dispframe, @sprite.x, @sprite.y)
                animtmp = @animlist[@animnum]
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
                        @animnum = @_beforeAnimnum
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
        if (@intersectFlag == true && motionObj.intersectFlag == true)
            ret = @sprite.within(motionObj.sprite, range)
        else
            ret = false
        return ret

    #***************************************************************
    # スプライト同士の衝突判定(intersect)
    #***************************************************************
    isIntersect:(motionObj, method = undefined)->
        if (LIBRARY == "tmlib")
            if (!motionObj.sprite?)
                return false
            if (@intersectFlag == true && motionObj.intersectFlag == true)
                ret = @sprite.isHitElement(motionObj.sprite)
            else
                ret = false
        else if (LIBRARY == "enchant")
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
    # スプライトをfadeInさせる（現在はenchantのみ）
    #***************************************************************
    fadeIn:(time)->
        if (LIBRARY == "enchant")
            @sprite.tl.fadeIn(time)
        else if (LIBRARY == "tmlib")
            @sprite.timeline
                .to(0, {
                    alpha: 1.0
                }, time)
        return @

    #***************************************************************
    # スプライトをフェイドアウトする（現在はenchantのみ）
    #***************************************************************
    fadeOut:(time)->
        if (LIBRARY == "enchant")
            @sprite.tl.fadeOut(time)
        else if (LIBRARY == "tmlib")
            @sprite.timeline
                .to(0, {
                    alpha: 0.0
                }, time)
        return @

    #***************************************************************
    # タイムラインをループさせる（現在はenchantのみ）
    #***************************************************************
    loop:->
        if (LIBRARY == "enchant")
            @sprite.tl.loop()

    #***************************************************************
    # ライムラインをクリアする（現在はenchantのみ）
    #***************************************************************
    clear:->
        if (LIBRARY == "enchant")
            @sprite.tl.clear()

