

class "Challenge" {

	test = "default challenge";
	
	__init__ = function(self)
	
	end,
	
	-- returns if the entered text fails the challenge
	check = function(self, input)

	end,
	
	getText = function(self)
		return self.text
	end
	
}

class "NoLetter" {

	letter = nil;


	__init__ = function(self)
		
		self.letter = string.char(math.random(97, 122))
		self.text = "Don't use the letter "..self.letter
		self.timeout = math.random(20, 300)
		self.time = 0
		
	end,
	
	getText = function(self)
		return self.text
	end,
	
	-- return true if text passes challenge
	check = function(self, input)
		--return input:find(self.letter) == nil
		return true
	end,
	
	-- returns true if challenge is finished
	update = function(self, dt)
		self.time = self.time + dt
		return self.time > self.timeout
	end

}


function generateChallenge()

	local rand = math.random(1, 1)
	
	if rand == 1 then return NoLetter() end

end
