#***************************************************
# threejssprite.coffee
# 2014.05.15 coded by Kow Sakazaki
#***************************************************
class threejssprite
    constructor:(@geometry = undefined, @material = undefined)->
        if (@geometry? && @material)
            @mesh = new THREE.Mesh(@geometry, @material)
            _scenes[WEBGLSCENE].add(mesh)
    
