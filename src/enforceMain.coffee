class enforceMain
    constructor:->
        dir = rand(16) - 8
        obj = addObject
            motionObj: sample
            type: SPRITE
            x: 160
            y: 100 
            gravity: 3.0
            xs: dir
            image: 'chara1'
            width: 32
            height: 32
            opacity: 1.0
            scaleX: if (dir < 0) then -1 else 1
            animlist: [
                [50, [0, 0, 1, 1, 2, 2, 1, 1]]
            ]

