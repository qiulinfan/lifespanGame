GameDirector = {
    screen = "title",
    chapter_index = 1,
    moment_index = 1,
    belief = "Not answered",
    progress = 18,
    confidence = 55,
    independence = 50,
    stress = 30,

    OnStart = function(self)
        Camera.SetPosition(0.0, 0.0)
        Camera.SetZoom(1.0)
        self:ResetGame()
    end,

    ResetGame = function(self)
        self.screen = "title"
        self.chapter_index = 1
        self.moment_index = 1
        self.belief = "Not answered"
        self.progress = Shared.chapters[1].start_progress
        self.confidence = 55
        self.independence = 50
        self.stress = 30
        self.patterns = {responsive = 0, fixer = 0, distant = 0}
        self.last_action = nil
        self.ending_key = "responsive"
    end,

    StartBeliefQuestion = function(self)
        self.screen = "myth"
    end,

    SetBelief = function(self, belief)
        self.belief = belief
        self.screen = "intro"
    end,

    BeginStory = function(self)
        self.chapter_index = 1
        self.moment_index = 1
        self.progress = Shared.chapters[1].start_progress
        self.screen = "chapter_intro"
    end,

    BeginChapter = function(self)
        self.screen = "choice"
    end,

    GetChapter = function(self)
        return Shared.chapters[self.chapter_index]
    end,

    GetMoment = function(self)
        local chapter = self:GetChapter()
        if chapter == nil then return nil end
        return chapter.moments[self.moment_index]
    end,

    Choose = function(self, index)
        if self.screen ~= "choice" then return end
        local moment = self:GetMoment()
        if moment == nil then return end
        local action = moment.actions[index]
        if action == nil then return end

        self.progress = Shared.Clamp(self.progress + action.progress, 0, 100)
        self.confidence = Shared.Clamp(self.confidence + action.confidence, 0, 100)
        self.independence = Shared.Clamp(
                                self.independence + action.independence, 0, 100)
        self.stress = Shared.Clamp(self.stress + action.stress, 0, 100)
        self.patterns[action.style] = self.patterns[action.style] + 1
        self.last_action = action
        self.screen = "feedback"
    end,

    ContinueAfterFeedback = function(self)
        local chapter = self:GetChapter()
        if self.moment_index < #chapter.moments then
            self.moment_index = self.moment_index + 1
            self.screen = "choice"
        else
            self.screen = "chapter_summary"
        end
    end,

    ContinueAfterSummary = function(self)
        if self.chapter_index < #Shared.chapters then
            self.chapter_index = self.chapter_index + 1
            self.moment_index = 1
            self.progress = Shared.chapters[self.chapter_index].start_progress
            self.stress = Shared.Clamp(self.stress - 12, 18, 100)
            self.screen = "chapter_intro"
        else
            self:CalculateEnding()
            self.screen = "ending"
        end
    end,

    CalculateEnding = function(self)
        local responsive = self.patterns.responsive
        local fixer = self.patterns.fixer
        local distant = self.patterns.distant
        if fixer >= responsive + 2 and fixer > distant then
            self.ending_key = "fixer"
        elseif distant >= responsive + 2 and distant > fixer then
            self.ending_key = "distant"
        else
            self.ending_key = "responsive"
        end
    end,

    GetEchoLine = function(self)
        if self.patterns.fixer > self.patterns.responsive and
            self.patterns.fixer >= self.patterns.distant then
            return "Can you tell me exactly what to do?"
        elseif self.patterns.distant > self.patterns.responsive then
            return "Never mind. I can handle it alone."
        end
        return "I have an idea. Can I talk it through with you?"
    end,

    OpenConcepts = function(self)
        self.screen = "concepts"
    end,

    CloseConcepts = function(self)
        self.screen = "ending"
    end
}
