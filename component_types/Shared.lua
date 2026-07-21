Shared = Shared or {}

Shared.font = "NotoSans-Regular"

Shared.palette = {
    ink = {33, 43, 41},
    cream = {246, 235, 205},
    paper = {223, 210, 176},
    sage = {92, 126, 101},
    sage_light = {142, 169, 137},
    amber = {205, 151, 66},
    terracotta = {169, 91, 64},
    blue = {72, 100, 112},
    stress = {184, 83, 65},
    shadow = {22, 29, 28}
}

Shared.chapters = {
    {
        age = 4,
        title = "AGE 4  |  THE CROOKED BRIDGE",
        concept = "ZPD + SCAFFOLDING",
        opening = "Alex is building a bridge for toy animals. It has fallen three times.",
        concept_text = "Scaffolding is temporary support inside the zone of proximal development: what a child can do with help, but not yet alone. Good support changes as skill grows.",
        start_progress = 18,
        moments = {
            {
                speech = "Big one... little one... Oh. It fell again!",
                prompt = "Alex looks at you, then at the blocks. What do you do?",
                actions = {
                    {
                        label = "Ask: What could make the bottom stronger?",
                        progress = 10, confidence = 8, independence = 7, stress = -5,
                        style = "responsive",
                        result = "Alex studies the base and points to two wider blocks.",
                        lesson = "A question keeps the thinking with Alex while directing attention to the next useful feature."
                    },
                    {
                        label = "Show how to place the first two blocks.",
                        progress = 18, confidence = 5, independence = 4, stress = -8,
                        style = "responsive",
                        result = "Alex watches closely, then reaches for the next block.",
                        lesson = "A brief model can be effective scaffolding when it leaves the remaining work to the learner."
                    },
                    {
                        label = "Build the bridge so Alex will not feel frustrated.",
                        progress = 34, confidence = -4, independence = -11, stress = -12,
                        style = "fixer",
                        result = "The bridge is finished quickly. Alex puts the blocks down and watches you.",
                        lesson = "Completing the product removed frustration, but also removed the chance to practice."
                    },
                    {
                        label = "Say: You need to figure it out yourself.",
                        progress = 2, confidence = -8, independence = 0, stress = 14,
                        style = "distant",
                        result = "Alex tries once more, then pushes the blocks away.",
                        lesson = "Independence is not the same as facing a task beyond current ability without support."
                    }
                }
            },
            {
                speech = "I think the wide blocks go here. Should I try?",
                prompt = "Alex now has a workable idea. What kind of help fits this moment?",
                actions = {
                    {
                        label = "Wait, watch, and let Alex test the idea.",
                        progress = 28, confidence = 11, independence = 13, stress = 2,
                        style = "responsive",
                        result = "The bridge wobbles, but Alex adjusts one block and finishes it.",
                        lesson = "Withdrawing support is part of scaffolding. The child needs room to use the new strategy."
                    },
                    {
                        label = "Give several more instructions, just in case.",
                        progress = 22, confidence = 1, independence = -5, stress = -2,
                        style = "fixer",
                        result = "Alex follows each direction and stops making independent choices.",
                        lesson = "Helpful guidance can become over-support when it continues after the learner is ready."
                    },
                    {
                        label = "Finish the difficult half of the bridge.",
                        progress = 32, confidence = -2, independence = -9, stress = -7,
                        style = "fixer",
                        result = "The bridge is neat, but Alex says, 'You are better at it.'",
                        lesson = "Fast completion and developmental learning are not always the same outcome."
                    },
                    {
                        label = "Leave the room without responding.",
                        progress = 8, confidence = -6, independence = 1, stress = 10,
                        style = "distant",
                        result = "Alex keeps looking toward the doorway instead of testing the blocks.",
                        lesson = "Responsive presence can matter even when the adult is not giving direct instructions."
                    }
                }
            }
        }
    },
    {
        age = 9,
        title = "AGE 9  |  THE SCHOOL POSTER",
        concept = "INDUSTRY VS. INFERIORITY",
        opening = "Five years later, Alex is making a habitat poster for school.",
        concept_text = "School-age children build competence through meaningful tasks, usable feedback, and chances to improve. Social comparison can motivate, but it can also undermine confidence.",
        start_progress = 24,
        moments = {
            {
                speech = "Maya's poster looks perfect. Maybe I'm just bad at this.",
                prompt = "Alex is comparing the unfinished poster with a classmate's work.",
                actions = {
                    {
                        label = "Ask: Which part of your poster is working already?",
                        progress = 9, confidence = 11, independence = 8, stress = -6,
                        style = "responsive",
                        result = "Alex identifies the research section and notices real progress.",
                        lesson = "Specific reflection creates a more realistic sense of competence than a global label."
                    },
                    {
                        label = "Say: Don't worry, you're naturally very smart.",
                        progress = 4, confidence = 4, independence = -2, stress = -1,
                        style = "fixer",
                        result = "Alex smiles briefly, but still does not know what to change next.",
                        lesson = "Positive labels can feel good without providing a strategy for improvement."
                    },
                    {
                        label = "Say: Maya probably worked harder than you.",
                        progress = 1, confidence = -12, independence = -5, stress = 14,
                        style = "distant",
                        result = "Alex hides the poster under a notebook.",
                        lesson = "Unfavorable comparison can turn a learning task into evidence of inferiority."
                    },
                    {
                        label = "Redesign the messy section yourself.",
                        progress = 29, confidence = -3, independence = -12, stress = -8,
                        style = "fixer",
                        result = "The poster looks polished, but Alex cannot explain the new layout.",
                        lesson = "A better-looking product does not necessarily represent the child's learning."
                    }
                }
            },
            {
                speech = "I have all the facts, but I don't know how to organize them.",
                prompt = "The difficulty is now specific. Choose the next step.",
                actions = {
                    {
                        label = "Suggest three sections, then let Alex sort the facts.",
                        progress = 26, confidence = 9, independence = 10, stress = -8,
                        style = "responsive",
                        result = "Alex sorts the facts and invents a title for each section.",
                        lesson = "A small structure can reduce cognitive load while preserving ownership of the task."
                    },
                    {
                        label = "Organize every fact into the correct section.",
                        progress = 32, confidence = 0, independence = -10, stress = -7,
                        style = "fixer",
                        result = "Everything is organized, but Alex waits for the next instruction.",
                        lesson = "Support becomes control when the adult makes every meaningful decision."
                    },
                    {
                        label = "Say: This is schoolwork, so do it alone.",
                        progress = 5, confidence = -7, independence = 0, stress = 11,
                        style = "distant",
                        result = "Alex rereads the same facts without choosing a structure.",
                        lesson = "A task can be appropriate overall while one step still lies inside the ZPD."
                    },
                    {
                        label = "Ask Alex to choose one section to solve first.",
                        progress = 20, confidence = 10, independence = 12, stress = -5,
                        style = "responsive",
                        result = "One finished section becomes a strategy for the remaining two.",
                        lesson = "Breaking a task into manageable steps supports both progress and self-efficacy."
                    }
                }
            }
        }
    },
    {
        age = 15,
        title = "AGE 15  |  THE AUDITION",
        concept = "AUTONOMY + IDENTITY EXPLORATION",
        opening = "Six years later, Alex is considering an audition for the school music group.",
        concept_text = "Healthy adolescent autonomy grows through connection, respect, reasonable boundaries, and gradually increasing freedom. Identity exploration can look uncertain while serving an important developmental function.",
        start_progress = 20,
        moments = {
            {
                speech = "I want to audition... but everyone will be watching me.",
                prompt = "Alex is excited and anxious. How do you enter the conversation?",
                actions = {
                    {
                        label = "Ask: What kind of support would actually help?",
                        progress = 12, confidence = 10, independence = 10, stress = -7,
                        style = "responsive",
                        result = "Alex asks you to listen once, but not to manage every practice.",
                        lesson = "Asking before helping respects growing autonomy and makes support more accurate."
                    },
                    {
                        label = "Create a complete daily practice schedule.",
                        progress = 27, confidence = 1, independence = -11, stress = 4,
                        style = "fixer",
                        result = "There is now a plan, but Alex says it feels like your audition.",
                        lesson = "Structure is most effective when adolescents have meaningful participation in it."
                    },
                    {
                        label = "Suggest avoiding the audition to prevent embarrassment.",
                        progress = -5, confidence = -13, independence = -6, stress = 8,
                        style = "fixer",
                        result = "Alex puts the guitar pick away and changes the subject.",
                        lesson = "Protection from every risk can also close opportunities for identity exploration."
                    },
                    {
                        label = "Say: You're old enough. This is entirely your problem.",
                        progress = 2, confidence = -7, independence = 2, stress = 12,
                        style = "distant",
                        result = "Alex nods, but no longer talks about the audition with you.",
                        lesson = "Autonomy develops within relationships; emotional withdrawal is not the same as freedom."
                    }
                }
            },
            {
                speech = "Could we agree on practice time, then let me decide how to use it?",
                prompt = "Alex proposes a plan. What happens next?",
                actions = {
                    {
                        label = "Agree on the boundary, then let Alex lead the practice.",
                        progress = 30, confidence = 12, independence = 14, stress = -5,
                        style = "responsive",
                        result = "Alex practices, changes one song choice, and signs up for the audition.",
                        lesson = "Connection and reasonable structure can coexist with real adolescent autonomy."
                    },
                    {
                        label = "Agree, but check and correct every ten minutes.",
                        progress = 24, confidence = -1, independence = -9, stress = 7,
                        style = "fixer",
                        result = "Alex practices, but focuses more on your reactions than on the music.",
                        lesson = "Monitoring can become intrusive when it does not decrease with demonstrated responsibility."
                    },
                    {
                        label = "Refuse because adults know what schedule works best.",
                        progress = 13, confidence = -6, independence = -10, stress = 10,
                        style = "fixer",
                        result = "Alex follows the schedule reluctantly and stops experimenting with the song.",
                        lesson = "Control may produce compliance without supporting identity or self-direction."
                    },
                    {
                        label = "Tell Alex not to involve you at all.",
                        progress = 5, confidence = -5, independence = 1, stress = 9,
                        style = "distant",
                        result = "Alex practices alone, but does not ask for feedback when stuck.",
                        lesson = "Growing independence does not eliminate the need for a responsive relationship."
                    }
                }
            }
        }
    }
}

function Shared.Clamp(value, minimum, maximum)
    if value < minimum then return minimum end
    if value > maximum then return maximum end
    return value
end

function Shared.GetWindowSize()
    local width = 960
    local height = 540
    if Application.GetWindowWidth ~= nil then
        width = Application.GetWindowWidth()
        height = Application.GetWindowHeight()
    end
    return width, height
end

function Shared.ScreenToWorld(x, y)
    local width, height = Shared.GetWindowSize()
    local zoom = math.max(0.01, Camera.GetZoom())
    return Camera.GetPositionX() + (x - width * 0.5) / (100.0 * zoom),
           Camera.GetPositionY() + (y - height * 0.5) / (100.0 * zoom)
end

function Shared.DrawRect(x, y, width, height, color, alpha, order)
    local world_x, world_y = Shared.ScreenToWorld(x + width * 0.5,
                                                   y + height * 0.5)
    Image.DrawEx("panel", world_x, world_y, 0.0, width, height, 0.5, 0.5,
                 color[1], color[2], color[3], alpha or 255, order or 1000)
end

function Shared.DrawText(content, x, y, size, color, alpha)
    Text.Draw(content, x, y, Shared.font, size, color[1], color[2], color[3],
              alpha or 255)
end

function Shared.EstimateTextWidth(content, size)
    local units = 0.0
    for index = 1, #(content or "") do
        local character = string.sub(content, index, index)
        if string.find(" Iil.,:;'!|", character, 1, true) ~= nil then
            units = units + (character == " " and 0.34 or 0.31)
        elseif string.find("MWmw@%", character, 1, true) ~= nil then
            units = units + 0.84
        else
            units = units + 0.58
        end
    end
    return math.floor(units * size + 0.5)
end

function Shared.FitTextSize(content, preferred_size, minimum_size, max_width)
    local size = preferred_size
    while size > minimum_size and
        Shared.EstimateTextWidth(content, size) > max_width do
        size = size - 1
    end
    return size
end

function Shared.DrawCenteredText(content, center_x, y, size, color, alpha)
    local width = Shared.EstimateTextWidth(content, size)
    Shared.DrawText(content, center_x - width * 0.5, y, size, color, alpha)
end

function Shared.WrapText(content, max_characters)
    local lines = {}
    local current = ""
    for word in string.gmatch(content or "", "%S+") do
        if current == "" then
            current = word
        elseif #current + #word + 1 <= max_characters then
            current = current .. " " .. word
        else
            lines[#lines + 1] = current
            current = word
        end
    end
    if current ~= "" then lines[#lines + 1] = current end
    return lines
end

function Shared.DrawWrappedText(content, x, y, size, color, max_characters,
                                line_height, alpha)
    local lines = Shared.WrapText(content, max_characters)
    for index = 1, #lines do
        Shared.DrawText(lines[index], x, y + (index - 1) * line_height,
                        size, color, alpha)
    end
    return #lines * line_height
end

function Shared.DrawWrappedTextInRect(content, x, y, width, height, size,
                                      color, max_characters, line_height,
                                      alpha)
    local lines = Shared.WrapText(content, max_characters)
    local text_height = #lines * line_height
    local start_y = y + math.max(0, (height - text_height) * 0.5)
    for index = 1, #lines do
        Shared.DrawText(lines[index], x,
                        start_y + (index - 1) * line_height,
                        size, color, alpha)
    end
    return text_height
end

function Shared.MouseInRect(x, y, width, height)
    local mouse = Input.GetMousePosition()
    return mouse.x >= x and mouse.x <= x + width and
           mouse.y >= y and mouse.y <= y + height
end

function Shared.GetDirector()
    local actor = Actor.Find("director")
    if actor == nil then return nil end
    return actor:GetComponent("GameDirector")
end
