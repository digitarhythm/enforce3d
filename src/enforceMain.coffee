class enforceMain
    constructor:->

        mikuObj = addObject
            type: COLLADA
            model: 'miku'
            motionObj: sample
            x: 30
            y: 50
            z: -100
            gravity: 1
            alpha: 0.0
            beta: 0.0
            gamma: 0.0
            scaleX: 3.0
            scaleY: 3.0
            scaleZ: 3.0

        droidobj = addObject
            type: COLLADA
            model: 'droid'
            motionObj: sample
            x: -30
            y: 50
            z: -100
            beta: 90
            gravity: 1
            scaleX: 30.0
            scaleY: 30.0
            scaleZ: 30.0

        sphereobj = addObject
            type: PRIMITIVE
            model: SPHERE
            x: -50
            y: 0
            z: -100
            radius: 20
            width: 30
            height: 30

        torusobj = addObject
            type: PRIMITIVE
            model: TORUS
            x: 50
            y: 0
            z: -100
            radius: 20
            radius2: 4
            gamma: 45
