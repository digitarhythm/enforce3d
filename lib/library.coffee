# ライブラリの種類
LIBRARY = undefined

# random
rand = (n)->
	return Math.floor(Math.random() * (n + 1))

# debug write
JSLog = (a, b...)-> 
	if (DEBUG == true)
		for data in b
			a = a.replace('%@', data)
		console.log(a)

# format strings
sprintf = (a, b...)-> 
	for data in b
		a = a.replace('%@', data)
	return a

# create unique ID
uniqueID =->
	S4 = ->
		return (((1+Math.random())*0x10000)|0).toString(16).substring(1)
	return (S4()+S4()+"-"+S4()+"-"+S4()+"-"+S4()+"-"+S4()+S4()+S4())

getBounds =->
	frame = [parseInt(document.documentElement.clientWidth - 1), parseInt(document.documentElement.clientHeight - 1)]
	return frame

_setEnchant =->
    LIBRARY = "enchant"

_setTmlib =->
    LIBRARY = "tmlib"

getKeyDirection =->
    if (LIBRARY == "tmlib")
        dir = core.keyboard.getKeyDirection()
    else if (LIBRARY == "enchant")
        dir = {
            x: 0
            y: 0
        }
        if (core.input.up)
            dir['y'] = -1
        if (core.input.down)
            dir['y'] = 1
        if (core.input.right)
            dir['x'] = 1
        if (core.input.left)
            dir['x'] = -1
    return dir

# do noting
nop =->
