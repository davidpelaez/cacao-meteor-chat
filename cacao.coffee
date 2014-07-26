Messages = new Meteor.Collection("messages")

if Meteor.isClient

	timeDependency = new Deps.Dependency()
	currentTime = undefined
	timeCap = undefined

	refreshTime = ->
		currentTime = (new Date).getTime()
		timeCap = currentTime - 60*1000
		timeDependency.changed()

	opacityFromTime = (refTime)->
		age = currentTime - refTime
		result = 1.0 - (age*0.05)/1000
		if result < 0 then 0 else result

	Meteor.setInterval(refreshTime, 100)

	Template.chat.displayMessage = ->
		timeDependency.depend()
		opacityFromTime(this.time) > 0
	
	Template.message.rendered = ->
		scrollMessages()
	
	Template.message.opacity = ->
		timeDependency.depend()
		calculatedOpacity = opacityFromTime(this.time)
		$self = $("#"+this._id)
		if calculatedOpacity < 0.3
			$self.addClass "folded"
		calculatedOpacity

	Template.chat.sessionNickname = ->
		Session.get "nickname"

	Template.chat.messages = ->
		timeDependency.depend()
		Messages.find { time: { $gt: timeCap } }, sort: {time: 1}

	scrollMessages = ->
		$("#msgBox").animate
			scrollTop: $("#msgBox table tr:last-child").offset().top
		, 0
	
	Template.chat.events =
		"submit": (event, template)->
			event.preventDefault()
			if $("#messageBody").val()
				message =
					nickname: Session.get("nickname")
					body: $("#messageBody").val()
					time: (new Date).getTime()
				Messages.insert message, ->
					$("#messageBody").val('')
					#scrollMessages()
					$("#messageBody").focus()

	Template.login.rendered = ->
		$("#nickname").focus()

	Template.login.events =
		"submit": (event, template)->
			event.preventDefault()
			Session.set "nickname", $("#nickname").val()
			$("#login").fadeOut()
			$("#chat").fadeIn()
			$("#messageBody").focus()
