GameDirector = {
    screen = "title",
    chapter_index = 1,
    moment_index = 1,
    belief = "Not answered",
    progress = 18,
    confidence = 55,
    independence = 50,
    stress = 30,
    click_sound = "block_click.ogg",
    click_channel = 1,
    click_volume = 62,
    music_volume = 46,
    current_music = nil,
    music_tracks = {
        curious = "mind_curious",
        supported = "mind_supported",
        anxious = "mind_anxious",
        uncertain = "mind_uncertain",
        confident = "mind_confident"
    },

    OnStart = function(self)
        Camera.SetPosition(0.0, 0.0)
        Camera.SetZoom(1.0)
        self:ResetGame(true)
        self:PreloadAudio()
        self:UpdateMusic()
    end,

    OnUpdate = function(self)
        self:UpdateMusic()
    end,

    ResetGame = function(self, silent)
        if silent ~= true then self:PlayClick() end
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

    PreloadAudio = function(self)
        Audio.Preload(self.click_sound, false)
        for _, track in pairs(self.music_tracks) do
            Audio.Preload(track, true)
        end
    end,

    PlayClick = function(self)
        Audio.Play(self.click_channel, self.click_sound, false)
        Audio.SetVolume(self.click_channel, self.click_volume)
    end,

    GetMusicMood = function(self)
        if self.screen == "title" or self.screen == "myth" or
            self.screen == "intro" then
            return "curious"
        end

        if self.screen == "ending" or self.screen == "concepts" then
            if self.ending_key == "fixer" then return "uncertain" end
            if self.ending_key == "distant" then return "anxious" end
            return "confident"
        end

        if self.screen == "feedback" and self.last_action ~= nil then
            if self.last_action.style == "responsive" then return "supported" end
            if self.last_action.style == "fixer" then return "uncertain" end
            if self.last_action.style == "distant" then return "anxious" end
        end

        if self.stress >= 55 then return "anxious" end
        if self.confidence <= 42 or self.independence <= 38 then
            return "uncertain"
        end
        if self.confidence >= 68 and self.independence >= 65 then
            return "confident"
        end
        return "curious"
    end,

    UpdateMusic = function(self)
        local mood = self:GetMusicMood()
        local track = self.music_tracks[mood]
        if track == nil then return end

        local stopped = Audio.IsPlaybackEnabled() and not Music.IsPlaying()
        if track ~= self.current_music or stopped then
            self.current_music = track
            Music.Play(track, true)
            Music.SetVolume(self.music_volume)
        end
    end,

    StartBeliefQuestion = function(self)
        self:PlayClick()
        self.screen = "myth"
    end,

    SetBelief = function(self, belief)
        self:PlayClick()
        self.belief = belief
        self.screen = "intro"
    end,

    BeginStory = function(self)
        self:PlayClick()
        self.chapter_index = 1
        self.moment_index = 1
        self.progress = Shared.chapters[1].start_progress
        self.screen = "chapter_intro"
    end,

    BeginChapter = function(self)
        self:PlayClick()
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

        self:PlayClick()
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
        self:PlayClick()
        local chapter = self:GetChapter()
        if self.moment_index < #chapter.moments then
            self.moment_index = self.moment_index + 1
            self.screen = "choice"
        else
            self.screen = "chapter_summary"
        end
    end,

    ContinueAfterSummary = function(self)
        self:PlayClick()
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
        self:PlayClick()
        self.screen = "concepts"
    end,

    CloseConcepts = function(self)
        self:PlayClick()
        self.screen = "ending"
    end
}
