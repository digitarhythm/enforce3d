# motionObj, kind, x, y, xs, ys, g, image, chara_w, chara_h, opacity, animlist, anime, visible
class sample extends _stationary
    #**************************
    # character constructor
    #**************************
    constructor:(@sprite)->
        super(@sprite)

    #**************************
    # character destructor
    #**************************
    destructor:->
        super()

    #**************************
    # character behavior
    #**************************
    behavior:->
        super()
        switch @_processnumber
            when 0
                param = @getParameter()
                if (param.y > (SCREEN_HEIGHT - (param.height / 2)))
                    @setParameter
                        y: (SCREEN_HEIGHT - (param.height / 2))
                        ys: -param.ys

                if (param.x > SCREEN_WIDTH - param.width / 2)
                    param.x = SCREEN_WIDTH - param.width / 2
                    @sprite.xs *= -1
                    @setParameter
                        scaleX: -param.scaleX
                if (param.x < param.width / 2)
                    @setParameter
                        x: param.width / 2
                        xs: -param.xs
                        scaleX: -param.scaleX


    #**************************
    # touch event
    #**************************
    #touchesBegan:(pos)->
    #   super(pos)

    #**************************
    # swipe event
    #**************************
    #touchesMoved:(pos)->
    #   super(pos)

    #**************************
    # detouch event
    #**************************
    #touchesEnded:(pos)->
    #   super(pos)

    #**************************
    # touch cancel event
    #**************************
    #touchesCanceled:(pos)->
    #   super(pos)

