
class "Bot" {

	name = "Bot",
	host = nil,
	client = nil,
	reactChance = 0, -- percentage change of answering something
	reactSpeed = 0, -- average answering speed in seconds
	reaction = -1,
	textSpeed = 0, -- average text speed
	text = -1,

	__init__ = function(self)
		
		local ind = math.random(1, #nameslist)
		self.name = nameslist[ind]
		print("Created new bot with name "..self.name)
		self.host = enet.host_create()
		self.client = self.host:connect("localhost:4419")
		self.reactChance = 0--math.random(50)
		self.reactSpeed = math.random(1, 10)
		self.alive = math.random(800)
		self.text = 10 + math.random(20)
		self.textSpeed = math.random(30)
		
	end,
	
	-- returns true if the bot is still alive
	update = function(self, dt)
	
		-- handle reactions
		if self.reaction >= 0 then
			self.reaction = self.reaction - dt
			if self.reaction < 0 then
				self.client:send("7#"..self.name.."#"..self:getReaction())
			end
		end
		
		if self.text >= 0 then
			self.text = self.text - dt
			if self.text < 0 then
				self.client:send("7#"..self.name.."#"..self:getReaction())
				self.text = math.random(self.textSpeed * 2) + 5
			end
		end
	
		-- handle network
		local event = self.host:service()
		if event then
			if event.type == "connect" then
				self.client:send("6#"..self.name.."#true")
			elseif event.type == "receive" then
				if self.reaction < 0 and math.random(100) < self.reactChance then
					self.reaction = math.random(self.reactSpeed * 2)
				end
			end
		end
		
		--handle timeout
		self.alive = self.alive - dt
		if self.alive < 0 then
			self.client:disconnect()
			self.host:flush()
			return false
		end
		
		return true
	end,
	
	getReaction = function(self)
		return mssgk[math.random(1, #mssgk)]
	end

}
