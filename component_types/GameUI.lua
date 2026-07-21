GameUI = {
    OnUpdate = function(self)
        local director = Shared.GetDirector()
        if director == nil then return end

        if director.screen == "title" then
            self:DrawTitle(director)
        elseif director.screen == "myth" then
            self:DrawMyth(director)
        elseif director.screen == "intro" then
            self:DrawIntro(director)
        elseif director.screen == "chapter_intro" then
            self:DrawChapterIntro(director)
        elseif director.screen == "choice" then
            self:DrawChoice(director)
        elseif director.screen == "feedback" then
            self:DrawFeedback(director)
        elseif director.screen == "chapter_summary" then
            self:DrawChapterSummary(director)
        elseif director.screen == "ending" then
            self:DrawEnding(director)
        elseif director.screen == "concepts" then
            self:DrawConcepts(director)
        end
    end,

    DrawDimmer = function(self, alpha)
        Shared.DrawRect(0, 0, 960, 540, Shared.palette.shadow, alpha or 150, 900)
    end,

    DrawButton = function(self, x, y, width, height, label, key_hint)
        local hover = Shared.MouseInRect(x, y, width, height)
        local color = hover and Shared.palette.amber or Shared.palette.sage
        Shared.DrawRect(x, y, width, height, color, 245, 1600)

        local key_area_width = key_hint ~= nil and 58 or 0
        local label_left = x + 14
        local label_width = width - 28 - key_area_width
        local label_size = Shared.FitTextSize(label, 20, 12, label_width)
        local label_center_x = label_left + label_width * 0.5
        local label_y = y + (height - label_size) * 0.5 - 2
        Shared.DrawCenteredText(label, label_center_x, label_y, label_size,
                                Shared.palette.cream)
        if key_hint ~= nil then
            local key_size = 13
            local key_center_x = x + width - key_area_width * 0.5
            local key_y = y + (height - key_size) * 0.5 - 1
            Shared.DrawCenteredText(key_hint, key_center_x, key_y, key_size,
                                    Shared.palette.paper)
        end
        return hover
    end,

    DrawTitle = function(self, director)
        self:DrawDimmer(122)
        Shared.DrawRect(165, 72, 630, 360, Shared.palette.ink, 235, 1200)
        Shared.DrawCenteredText("ROOM TO GROW", 480, 126, 44,
                                Shared.palette.cream)
        Shared.DrawCenteredText("HELP ENOUGH. THEN STEP BACK.", 480, 184, 18,
                                Shared.palette.amber)
        Shared.DrawWrappedText(
            "A short caregiving story about struggle, support, and growing independence.",
            258, 242, 19, Shared.palette.paper, 50, 27)
        local hover = self:DrawButton(330, 348, 300, 62, "BEGIN THE STORY", "ENTER")
        if (hover and Input.GetMouseButtonDown(1)) or
            Input.GetKeyDown("enter") or Input.GetKeyDown("space") then
            director:StartBeliefQuestion()
        end
    end,

    DrawMyth = function(self, director)
        self:DrawDimmer(155)
        Shared.DrawRect(120, 66, 720, 410, Shared.palette.ink, 244, 1200)
        Shared.DrawCenteredText("BEFORE WE BEGIN...", 480, 105, 25,
                                Shared.palette.amber)
        Shared.DrawWrappedText(
            "A good caregiver should prevent children from struggling whenever possible.",
            205, 165, 24, Shared.palette.cream, 47, 34)
        local labels = {"AGREE", "NOT SURE", "DISAGREE"}
        for index = 1, 3 do
            local x = 175 + (index - 1) * 210
            local hover = self:DrawButton(x, 330, 190, 58, labels[index],
                                          tostring(index))
            if (hover and Input.GetMouseButtonDown(1)) or
                Input.GetKeyDown(tostring(index)) then
                director:SetBelief(labels[index])
            end
        end
        Shared.DrawCenteredText("There is no grade for this answer.", 480,
                                420, 16, Shared.palette.paper)
    end,

    DrawIntro = function(self, director)
        self:DrawDimmer(138)
        Shared.DrawRect(275, 54, 630, 430, Shared.palette.ink, 242, 1200)
        Shared.DrawCenteredText("MEET ALEX", 590, 91, 30,
                                Shared.palette.cream)
        Shared.DrawWrappedText(
            "Across eleven years, Alex will face three ordinary challenges. Your choices affect task progress, confidence, independence, and stress.",
            348, 148, 19, Shared.palette.paper, 57, 28)
        Shared.DrawWrappedText(
            "There is no single action that is always correct. Observe what Alex can do now, offer the next useful step, and notice when it is time to step back.",
            348, 245, 19, Shared.palette.paper, 57, 28)
        Shared.DrawText("Your starting answer: " .. director.belief, 348, 346,
                        17, Shared.palette.amber)
        local hover = self:DrawButton(462, 398, 260, 58, "WATCH AND RESPOND", "ENTER")
        if (hover and Input.GetMouseButtonDown(1)) or
            Input.GetKeyDown("enter") then
            director:BeginStory()
        end
    end,

    DrawChapterIntro = function(self, director)
        self:DrawDimmer(120)
        local chapter = director:GetChapter()
        Shared.DrawRect(290, 72, 620, 390, Shared.palette.ink, 240, 1200)
        Shared.DrawCenteredText(chapter.title, 600, 112, 26,
                                Shared.palette.cream)
        Shared.DrawCenteredText(chapter.concept, 600, 156, 17,
                                Shared.palette.amber)
        Shared.DrawWrappedText(chapter.opening, 344, 211, 21,
                               Shared.palette.paper, 52, 31)
        if director.chapter_index > 1 then
            Shared.DrawText("Alex says:", 344, 289, 16, Shared.palette.sage_light)
            Shared.DrawWrappedText('"' .. director:GetEchoLine() .. '"',
                                   344, 316, 21, Shared.palette.cream, 48, 30)
        end
        local hover = self:DrawButton(478, 385, 245, 55, "ENTER THIS MOMENT", "ENTER")
        if (hover and Input.GetMouseButtonDown(1)) or
            Input.GetKeyDown("enter") then
            director:BeginChapter()
        end
    end,

    DrawStatus = function(self, director)
        Shared.DrawRect(14, 10, 932, 78, Shared.palette.ink, 238, 1200)
        local chapter = director:GetChapter()
        Shared.DrawText(chapter.title, 32, 18, 17, Shared.palette.cream)
        local bars = {
            {"PROGRESS", director.progress, Shared.palette.amber},
            {"CONFIDENCE", director.confidence, Shared.palette.sage_light},
            {"INDEPENDENCE", director.independence, Shared.palette.blue},
            {"STRESS", director.stress, Shared.palette.stress}
        }
        for index = 1, #bars do
            local x = 32 + (index - 1) * 226
            local bar_width = 190
            Shared.DrawText(bars[index][1], x, 43, 11, Shared.palette.paper)
            local value = tostring(math.floor(bars[index][2]))
            local value_width = Shared.EstimateTextWidth(value, 11)
            Shared.DrawText(value, x + bar_width - value_width, 43, 11,
                            bars[index][3])
            Shared.DrawRect(x, 65, bar_width, 8, Shared.palette.shadow, 230, 1400)
            Shared.DrawRect(x, 65, bar_width * bars[index][2] / 100, 8,
                            bars[index][3], 255, 1500)
        end
    end,

    DrawChoice = function(self, director)
        self:DrawStatus(director)
        local moment = director:GetMoment()
        Shared.DrawRect(285, 96, 655, 132, Shared.palette.ink, 236, 1200)
        Shared.DrawText("ALEX", 310, 112, 14, Shared.palette.amber)
        Shared.DrawWrappedText('"' .. moment.speech .. '"', 310, 139, 20,
                               Shared.palette.cream, 58, 27)
        Shared.DrawWrappedText(moment.prompt, 310, 190, 15,
                               Shared.palette.paper, 72, 21)

        for index = 1, #moment.actions do
            local x = 285
            local y = 240 + (index - 1) * 69
            local width = 655
            local height = 59
            local hover = Shared.MouseInRect(x, y, width, height)
            local color = hover and Shared.palette.sage or Shared.palette.ink
            Shared.DrawRect(x, y, width, height, color, hover and 250 or 226, 1300)
            Shared.DrawRect(x, y, 42, height, hover and Shared.palette.amber or
                            Shared.palette.blue, 250, 1400)
            Shared.DrawCenteredText(tostring(index), x + 21,
                                    y + (height - 18) * 0.5 - 1, 18,
                                    Shared.palette.cream)
            Shared.DrawWrappedTextInRect(moment.actions[index].label,
                                         x + 58, y, width - 76, height,
                                         16, Shared.palette.cream, 68, 20)
            if (hover and Input.GetMouseButtonDown(1)) or
                Input.GetKeyDown(tostring(index)) then
                director:Choose(index)
            end
        end
    end,

    DrawFeedback = function(self, director)
        self:DrawStatus(director)
        local action = director.last_action
        Shared.DrawRect(285, 103, 655, 344, Shared.palette.ink, 244, 1300)
        Shared.DrawText("WHAT HAPPENED", 318, 132, 18, Shared.palette.amber)
        Shared.DrawWrappedText(action.result, 318, 174, 22,
                               Shared.palette.cream, 54, 31)
        Shared.DrawRect(318, 257, 589, 112, Shared.palette.blue, 215, 1450)
        Shared.DrawText("DEVELOPMENT NOTE", 338, 276, 14,
                        Shared.palette.cream)
        Shared.DrawWrappedText(action.lesson, 338, 307, 17,
                               Shared.palette.cream, 61, 23)
        local hover = self:DrawButton(632, 383, 275, 48, "CONTINUE", "ENTER")
        if (hover and Input.GetMouseButtonDown(1)) or
            Input.GetKeyDown("enter") or Input.GetKeyDown("space") then
            director:ContinueAfterFeedback()
        end
    end,

    DrawChapterSummary = function(self, director)
        self:DrawDimmer(130)
        local chapter = director:GetChapter()
        Shared.DrawRect(268, 61, 650, 420, Shared.palette.ink, 245, 1300)
        Shared.DrawCenteredText("CHAPTER COMPLETE", 593, 96, 25,
                                Shared.palette.cream)
        Shared.DrawText(chapter.concept, 331, 145, 18, Shared.palette.amber)
        Shared.DrawWrappedText(chapter.concept_text, 331, 184, 19,
                               Shared.palette.paper, 57, 27)
        Shared.DrawText("Support pattern so far", 331, 307, 15,
                        Shared.palette.sage_light)
        local total = math.max(1, director.patterns.responsive +
                                  director.patterns.fixer +
                                  director.patterns.distant)
        local labels = {
            {"RESPONSIVE", director.patterns.responsive, Shared.palette.sage_light},
            {"TAKE OVER", director.patterns.fixer, Shared.palette.amber},
            {"STEP AWAY", director.patterns.distant, Shared.palette.stress}
        }
        for index = 1, 3 do
            local y = 336 + (index - 1) * 29
            Shared.DrawText(labels[index][1], 331, y, 13, Shared.palette.paper)
            Shared.DrawRect(443, y + 3, 250, 10, Shared.palette.shadow, 240, 1400)
            Shared.DrawRect(443, y + 3, 250 * labels[index][2] / total, 10,
                            labels[index][3], 255, 1500)
        end
        local label = director.chapter_index < #Shared.chapters and
                          "MOVE FORWARD IN TIME" or "SEE THE PATTERN"
        local hover = self:DrawButton(684, 404, 212, 55, label, "ENTER")
        if (hover and Input.GetMouseButtonDown(1)) or
            Input.GetKeyDown("enter") then
            director:ContinueAfterSummary()
        end
    end,

    DrawEnding = function(self, director)
        self:DrawDimmer(145)
        Shared.DrawRect(235, 37, 690, 468, Shared.palette.ink, 246, 1300)
        local endings = {
            fixer = {
                title = "THE FIXER",
                text = "You often protected Alex from frustration by making the path smoother. Tasks moved quickly, but some chances to practice competence and self-direction disappeared."
            },
            distant = {
                title = "THE DISTANT GUIDE",
                text = "You offered considerable freedom, but Alex sometimes faced a difficult next step without enough responsive support. Independence is not the same as handling every challenge alone."
            },
            responsive = {
                title = "THE RESPONSIVE GUIDE",
                text = "You often adjusted support to Alex's current need, then made room for independent action. Effective help changed as the learner changed."
            }
        }
        local ending = endings[director.ending_key]
        Shared.DrawCenteredText("YOUR SUPPORT PATTERN", 580, 69, 16,
                                Shared.palette.amber)
        Shared.DrawCenteredText(ending.title, 580, 105, 31,
                                Shared.palette.cream)
        Shared.DrawWrappedText(ending.text, 300, 159, 18,
                               Shared.palette.paper, 62, 26)
        Shared.DrawRect(288, 265, 584, 107, Shared.palette.sage, 215, 1450)
        Shared.DrawWrappedText(
            "Children do not develop best with maximum help or zero help. They develop through responsive support that changes with ability, relationship, and context.",
            313, 288, 18, Shared.palette.cream, 59, 25)
        Shared.DrawText("A few moments do not determine a life. Development remains plastic.",
                        287, 390, 14, Shared.palette.sage_light)

        local concept_hover = self:DrawButton(287, 426, 250, 55,
                                               "VIEW CONCEPTS", "C")
        local replay_hover = self:DrawButton(557, 426, 155, 55,
                                              "REPLAY", "R")
        local quit_hover = self:DrawButton(732, 426, 140, 55,
                                            "QUIT", "Q")
        if (concept_hover and Input.GetMouseButtonDown(1)) or
            Input.GetKeyDown("c") then
            director:OpenConcepts()
        elseif (replay_hover and Input.GetMouseButtonDown(1)) or
            Input.GetKeyDown("r") then
            director:ResetGame()
        elseif (quit_hover and Input.GetMouseButtonDown(1)) or
            Input.GetKeyDown("q") then
            Application.Quit()
        end
    end,

    DrawConcepts = function(self, director)
        self:DrawDimmer(165)
        Shared.DrawRect(92, 30, 776, 480, Shared.palette.ink, 250, 1300)
        Shared.DrawCenteredText("CONCEPTS BEHIND THE GAME", 480, 61, 27,
                                Shared.palette.cream)
        local concepts = {
            {"ZONE OF PROXIMAL DEVELOPMENT", "What a learner can do with guidance, but not yet independently."},
            {"SCAFFOLDING", "Temporary, adjustable help that is reduced as competence grows."},
            {"INDUSTRY VS. INFERIORITY", "School-age children build competence through meaningful work, feedback, and improvement."},
            {"IDENTITY + AUTONOMY", "Adolescents need exploration, connection, reasonable structure, and gradually increasing freedom."},
            {"BIDIRECTIONAL DEVELOPMENT", "Adults affect children, while children's needs and responses also shape adult behavior."},
            {"PLASTICITY", "Development is influenced by patterns and contexts, but it is not permanently fixed by one moment."}
        }
        for index = 1, #concepts do
            local column = (index - 1) % 2
            local row = math.floor((index - 1) / 2)
            local x = 135 + column * 360
            local y = 120 + row * 103
            Shared.DrawText(concepts[index][1], x, y, 13,
                            Shared.palette.amber)
            Shared.DrawWrappedText(concepts[index][2], x, y + 25, 14,
                                   Shared.palette.paper, 40, 18)
        end
        Shared.DrawText("Observe before intervening. Help with the next step, not the whole task.",
                        135, 445, 14, Shared.palette.sage_light)
        local hover = self:DrawButton(704, 438, 132, 45, "BACK", "ESC")
        if (hover and Input.GetMouseButtonDown(1)) or
            Input.GetKeyDown("escape") then
            director:CloseConcepts()
        end
    end
}
