

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
		
	end,
	
	getText = function(self)
		return self.text
	end,
	
	-- return true if text passes challenge
	check = function(self, input)
		return input:find(self.letter) == nil
	end

}


function generateChallenge()

	local rand = math.random(1, 1)
	
	if rand == 1 then return NoLetter() end

end
