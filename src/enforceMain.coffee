class enforceMain
    constructor:->
        obj = addObject
            motionObj: sample
            type: SPRITE
            x: 160
            y: 100 
            gravity: 3.0
            xs: rand(16) - 8
            image: 'chara1'
            cellx: 32
            celly: 32
            opacity: 1.0
            animlist: [
                [50, [0, 0, 1, 1, 2, 2, 1, 1]]
            ]

