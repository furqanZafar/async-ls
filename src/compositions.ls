{fold, flip, empty} = require \prelude-ls

# returnA :: x -> CB x
returnA = (x) -> (callback) -> callback null, x

# fmapA :: (x -> y) -> CB x -> CB y
fmapA = (f, g) ->
	(callback) ->
		(err, gx) <- g!
		if !!err
			callback err, null
		else
			callback null, (f gx)


# ffmapA :: CB x -> (x -> y) -> CB y
ffmapA = flip fmapA


# bindA :: CB x -> (x -> CB y) -> CB y
bindA = (f, g) ->
	(callback) ->
		(err, fx) <- f!
		if !!err 
			callback err, null
		else
			g fx, callback


# fbindA :: (x -> CB y) -> CB x -> CB y
fbindA = flip bindA

# Left to right Kleisli composition
# kcompA :: (x -> CB y) -> (y -> CB z) -> (x -> CB z)
kcompA = (f, g) ->
	(x, callback) ->
		(err, fx) <- f x
		if !!err then 
			callback err, null
		else
			g fx, callback


# returnE :: x -> E x
returnE = (x) -> [null, x]


# fmapE :: (x -> y) -> E x -> E y
fmapE = (f, [err, x]) ->
	if !!err
		[err, null]
	else
		[null, f x]


# ffmapE :: E x -> (x -> y) -> E y
ffmapE = flip fmapE


# bindE :: E x -> (x -> E y) -> E y
bindE = ([errf, fx], g) ->
	if !!errf then [errf, null] else g fx


# bindE :: (x -> E y) -> E x -> E y
fbindE = flip bindE


# Left to right Kleisli composition
# kcompE :: (x -> E y) -> (y -> E z) -> (x -> E z)
kcompE = (f, g) ->
	(x) -> 
		[errf, fx] = f x
		if !!errf
			[errf, null]
		else
			g fx

# foldE :: (a -> b -> E a) -> a -> [b] -> E a
foldE = (f, a, [x,...xs]:list) ->
	| empty list => returnE a
	| otherwise => (f a, x) `bindE` ((fax) -> foldE f, fax, xs)



# transformAE :: CB x -> (x -> E y) -> CB y
transformAE = (f, g) ->
	(callback) ->
		(errf, fx) <- f!
		if !!errf
			callback errf, null
		else
			[errg, gfx] = g fx
			if !!errg
				callback errg, null
			else
				callback null, gfx


# ftransformAE :: (x -> E y) -> CB x -> CB y
ftransformAE = flip transformAE


# transformEA :: E x -> (x -> CB y) -> CB y
transformEA = ([errf, fx], g) ->
	(callback) ->
		if !!errf
			callback errf, null
		else
			g fx, callback


# ftransformEA :: (x -> CB y) -> E x -> CB y
ftransformEA = flip transformEA


# returnL :: x -> [x]
returnL = (x) -> [x]

# bindA :: [x] -> (x -> [y]) -> [y]
bindL = (xs, g) ->
	fold ((acc, a) -> acc ++ g a), [], xs


# returnW :: Monoid s => s -> x -> [x, s]
returnW = (mempty, x) --> [x, mempty]

# bindW :: Monoid s => s -> [x, s] -> (x -> [y, s])
bindW = (mappend, [x, xs], f) -->
	[y, ys] = f x
	[y, xs `mappend` ys]

# tellW :: Monoid s => s -> [x, s] -> s -> [x, s]
tellW = (mappend, [x, xs], s) -->
	[x, xs `mappend` s]

# returnWl :: x -> [x, []]
returnWl = returnW []

# bindWl :: [x, [s]] -> (x -> [y, [s]]) -> [y, [s]]
bindWl = bindW (++)


exports = exports or this

exports.returnA = returnA
exports.ffmapA = ffmapA
exports.bindA = bindA
empty.fbindA = fbindA
exports.kcompA = kcompA

exports.returnE = returnE
exports.fmapE = fmapE
exports.ffmapE = ffmapE
exports.bindE = bindE
exports.fbindE = fbindE
exports.kcompE = kcompE
exports.foldE = foldE

exports.transformAE = transformAE
exports.ftransformAE = ftransformAE
exports.transformEA = transformEA
exports.ftransformEA = ftransformEA

exports.returnL = returnL
exports.bindL = bindL

exports.returnW = returnW
exports.bindW = bindW
exports.tellW = tellW

exports.returnWl = returnWl
exports.bindWl = bindWl