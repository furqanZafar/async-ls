{odd} = require \prelude-ls
{returnL, bindL, ffmapA, returnA, bindA}  = require \./../build/compositions
{
	parallel-map-limited, serial-map, parallel-map, 
	parallel-filter, serial-filter, parallel-limited-filter,
	parallel-any, serial-any, parallel-limited-any, 
	parallel-all, serial-all, parallel-limited-all
} = require \./../build/lists  

assert = require 'assert'
_it = it

n-times = (n, p) --> [p*i for i to n]
doubleA = (x, callback) --> setTimeout (-> callback null, 2*x), 10
less-than6A = (x, callback) --> setTimeout (-> callback null, x<6), 10

describe 'Compositions', ->

	describe 'bindL', ->
		_it 'on [] should be []', ->
			assert.deep-equal [], ([] `bindL` (n-times 3))

		_it 'should be [ 0, 4, 8, 12, 0, 6, 12, 18 ]', ->
			assert.deep-equal [ 0, 4, 8, 12, 0, 6, 12, 18 ], ([4, 6] `bindL` (n-times 3))

describe 'Map', ->

	describe 'parallel-map', ->
		_it 'on [] should be []', (done) ->
			(err, res) <- parallel-map doubleA, []
			assert.deep-equal [], res
			done!

		_it 'on [1,2,3] should be [2,4,6]', (done) ->
			(err, res) <- parallel-map doubleA, [1,2,3]
			assert.deep-equal [2,4,6], res
			done!


	describe 'serial-map', ->
		_it 'on [] should be []', (done) ->
			(err, res) <- serial-map doubleA, []
			assert.deep-equal [], res
			done!

		_it 'on [1,2,3] should be [2,4,6]', (done) ->
			(err, res) <- serial-map doubleA, [1,2,3]
			assert.deep-equal [2,4,6], res
			done!

describe 'Filter', ->

	describe 'parallel-filter', ->
		_it 'on [] should be []', (done) ->
			(err, res) <- parallel-filter less-than6A, []
			assert.deep-equal [], res
			done!

		_it 'on [1,2,3,4,5,6,7,8,9,10] should be [1,2,3,4,5]', (done) ->
			(err, res) <- parallel-filter less-than6A, [1 to 10]
			assert.deep-equal [1 to 5], res
			done!

describe 'Any', ->

	describe 'parallel-any', ->

		_it 'on [] should be false', (done) ->
			count = 0
			more-than3A = (x, callback) --> 
				count := count + 1
				setTimeout (-> callback null, x>3), 10
			(err, res) <- parallel-any more-than3A, []
			assert.deep-equal false, res
			assert.equal 0, count
			done!


	describe 'serial-any', ->
		_it 'on [] should be false', (done) ->
			count = 0
			more-than3A = (x, callback) --> 
				count := count + 1
				setTimeout (-> callback null, x>3), 10
			(err, res) <- serial-any more-than3A, []
			assert.deep-equal false, res
			assert.equal 0, count
			done!

	describe 'parallel-limited-any', ->

		_it 'on [] should be false', (done) ->
			count = 0
			more-than3A = (x, callback) --> 
				count := count + 1
				setTimeout (-> callback null, x>3), 10
			(err, res) <- parallel-limited-any 2, more-than3A, []
			assert.deep-equal false, res
			assert.equal 0, count
			done!

		_it 'on [1 to 100] should be true', (done) ->
			count = 0
			more-than3A = (x, callback) --> 
				count := count + 1
				setTimeout (-> callback null, x>3), 10
			(err, res) <- parallel-limited-any 3, more-than3A, [1 to 100]
			assert.deep-equal true, res
			assert.equal 6, count
			done!


describe 'All', ->

	describe 'parallel-all', ->

		_it 'on [] should be true', (done) ->
			count = 0
			more-than3A = (x, callback) --> 
				count := count + 1
				setTimeout (-> callback null, x>3), 10
			(err, res) <- parallel-all more-than3A, []
			assert.deep-equal true, res
			assert.equal 0, count
			done!


	describe 'serial-all', ->
		_it 'on [] should be true', (done) ->
			count = 0
			more-than3A = (x, callback) --> 
				count := count + 1
				setTimeout (-> callback null, x>3), 10
			(err, res) <- serial-all more-than3A, []
			assert.deep-equal true, res
			assert.equal 0, count
			done!

	describe 'parallel-limited-all', ->

		_it 'on [] should be true', (done) ->
			count = 0
			more-than3A = (x, callback) --> 
				count := count + 1
				setTimeout (-> callback null, x>3), 10
			(err, res) <- parallel-limited-all 2, more-than3A, []
			assert.deep-equal true, res
			assert.equal 0, count
			done!

		_it 'on [4 to 10] should be true', (done) ->
			count = 0
			more-than3A = (x, callback) --> 
				count := count + 1
				setTimeout (-> callback null, x>3), 10
			(err, res) <- parallel-limited-all 3, more-than3A, [4 to 10]
			assert.deep-equal true, res
			assert.equal 7, count
			done!

		_it 'on [1 to 10] should be false', (done) ->
			count = 0
			more-than3A = (x, callback) --> 
				count := count + 1
				setTimeout (-> callback null, x<3), 10
			(err, res) <- parallel-limited-all 3, more-than3A, [1 to 10]
			assert.deep-equal false, res
			assert.equal 3, count
			done!

return

arr = [\a \b \c \d \e \f \g \h \i \j]
(err, res) <- parallel-map-limited 3, ((x, callback) -> callback(null, x + "!")), arr
console.log err, res


f1 = (x, callback) -> setTimeout (-> callback null, x*x), 200
f2 = (x, callback) -> setTimeout (-> callback (if x == 7 then 'ERROR at 7' else null), (odd x*x)), 100
f3 = (x, callback) --> setTimeout (-> callback null, (odd x*x)), 100
f4 = (x, callback) -> setTimeout (-> callback null, (x*x > (-1))), 100
f5 = (x, callback) --> setTimeout (-> callback null, x<=5), 100


(err, res) <- parallel-filter f3, [0 to 10]
console.log 'parallel-filter', err, res

(err, res) <- serial-filter f3, [0 to 10]
console.log 'serial-filter', err, res

(err, res) <- parallel-limited-filter 3, f3, [0 to 10]
console.log 'parallel-limited-filter', err, res

(err, res) <- parallel-any f3, [0 to 10]
console.log err, res

(err, res) <- parallel-limited-any 3, f3, [0 to 10]
console.log 'parallel-limited-any', err, res

(err, res) <- parallel-all f3, [0 to 10]
console.log 'parallel-all', err, res

(err, res) <- serial-all f3, [0 to 10]
console.log 'serial-all', err, res

(err, res) <- parallel-limited-all 3, f5, [0 to 5]
console.log 'parallel-limited-all', err, res