class enforceMain
    constructor:->

        @mikuObj = addObject
            motionObj: sample
            type: COLLADA
            model: 'miku'
            x: 0
            y: 100
            z: 0
            scaleX: 1.0
            scaleY: 1.0
            scaleZ: 1.0
            gravity: 0.1
