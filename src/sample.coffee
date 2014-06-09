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
                if (@y < -40)
                    @y = -40
                    @ys2 = @ys
                    @ys *= -1
                    JSLog("ys2=%@, ys=%@", @ys2, @ys)

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

