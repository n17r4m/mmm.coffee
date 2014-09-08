


class PQueue


	constructor: (@priority = 10, @key = Math.random()) ->

		@head = null
		@previous = null
		@next = null


	queue: (value) ->

		if not @head?
			@head = value
			return

		cursor = @head
		while cursor.priority >= value.priority

			if not cursor?.next?
				cursor.next = value
				value.previous = cursor
				return
			cursor = cursor.next

		if not cursor.previous
			
			value.next = cursor
			value.next.previous = value
			@head = value
			return

		cursor.previous.next = value
		value.previous = cursor.previous
		value.next = cursor
		cursor.previous = value


	length: ->

		if not @head?
			return 0

		count = 1
		cursor = @head
		while cursor.next
			count += 1
			cursor = cursor.next
		return count


	peek: -> @head


	dequeue: ->

		if not @head?
			throw new Error('Queue empty')

		value = self.head
		self.head = self.head.next
		if self.head
			self.head.previous = null
		return value


	setKeyPriority: (key, priority) ->

		if not @searchKey(key)
			throw new Error("Value (#{key}) not in queue")

		cursor = @head
		while cursor.key isnt key
			cursor = cursor.next
		cursor.priority = priority


	sortedCheck: ->

		if not @head?
			return true

		cursor = @head
		while cursor.next?
			if cursor.next.priority > cursor.priority
				return false
			cursor = cursor.next
		return true


	searchKey: (key) ->

		if not @head?
			return false

		cursor = @head
		while cursor?
			if cursor.key == key
				return true
			cursor = cursor.next
		return false


	removeKey: (key) ->

		if not @searchKey(key)
			throw new Error('Value not in queue')

		cursor = @head
		while cursor.key isnt key
			cursor = cursor.next

		if cursor.previous?
			cursor.previous.next = cursor.next
			if cursor.next
				cursor.next.previous = cursor.previous
				
		else if cursor.next?
			cursor.next.previous = null
			@head = cursor.next
		else
			@head = null

		cursor.previous = null
		cursor.next = null
		return cursor

	refresh: ->

		if not @head?
			return true

		cursor = @head.next
		while cursor
			if cursor.priority > cursor.previous.priority
				@queue(@removeKey(cursor.key))
				return @refresh()
			cursor = cursor.next
		return true

	toString: -> "Priority Queue with head (#{@head})"

	@testrange: (x,y) ->

		X = new PQueue(0,0)

		for i in [x..y]
			X.queue(new PQueue(i,i))

		if not X.sortedCheck()
			throw new Error('Sorting not working')

		for i in [x..y]
			console.info i
			console.info X.searchKey(i)
			if not X.searchKey(i)
				throw new Error('Search not working')

		for i in [x..y]
			try
				X.removeKey(i)
			catch e
				throw new Error("Remove not working (#{e})")

		for i in [x..y]
			X.queue(new PQueue(i,i))

		for i in [x..y]
			z = Math.round(Math.random() * 1000)
			X.setKeyPriority(i,z)
	
		X.refresh()
		if not X.sortedCheck()
			throw new Error('Refresh not working')


