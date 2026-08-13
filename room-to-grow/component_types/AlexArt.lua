AlexArt = {
    OnStart = function(self)
        self.sprite = self.actor:GetComponent("SpriteRenderer")
        self.transform = self.actor:GetComponent("Transform")
    end,

    OnUpdate = function(self)
        if self.sprite == nil then return end
        local director = Shared.GetDirector()
        if director == nil then return end

        local column = Shared.Clamp(director.chapter_index or 1, 1, 3)
        if director.screen == "title" or director.screen == "myth" or
            director.screen == "intro" then
            column = 1
        elseif director.screen == "ending" or director.screen == "concepts" then
            column = 3
        end
        self.sprite:SetSpriteCell(1, column)

        local visible = director.screen ~= "title"
        self.sprite.a = visible and 255 or 0
        self.sprite.r = 255
        self.sprite.g = 255
        self.sprite.b = 255

        if director.stress ~= nil and director.stress >= 65 then
            self.sprite.r = 235
            self.sprite.g = 205
            self.sprite.b = 205
        elseif director.confidence ~= nil and director.confidence >= 72 then
            self.sprite.r = 255
            self.sprite.g = 246
            self.sprite.b = 220
        end

        if self.transform ~= nil then
            self.transform.x = -3.15
            self.transform.y = 0.54
        end
    end
}
