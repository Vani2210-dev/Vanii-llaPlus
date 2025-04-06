--- STEAMODDED HEADER
--- MOD_NAME: Vanii-llaPlus
--- MOD_ID: Vanii-llaPlus-main
--- MOD_AUTHOR: [Vanii]
--- MOD_DESCRIPTION: A Joker that only gains Mult when scoring Diamonds or Hearts.

----------------------------------------------
------------MOD CODE -------------------------

-- Define localization
local jokers = {
    lovejester = {
        name = "Love Jester",
        text = {
            "Gains {X:red,C:white}X#1#{} for",
            "each {C:red}Ace of Heart{}",
            "in your {C:attention}full deck{}",
            "{C:inactive}(Currently {X:red,C:white}X#2#{} Mult){}"
        },
        config = { extra = { mult = 0.5, x_mult = 1 } },
        pos = { x = 0, y = 0 },
        rarity = 2,
        cost = 6,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            self.ability.extra.x_mult = 1
            for k, v in pairs(G.playing_cards) do
                if v:get_id() == 14 and v.base.suit == 'Hearts' then
                    self.ability.extra.x_mult = self.ability.extra.x_mult + self.ability.extra.mult
                end
            end
            if SMODS.end_calculate_context(context) then
                return {
                    x_mult = self.ability.extra.x_mult,
                    card = self,
                }
            end
        end,

        loc_def = function(self) --defines variables to use in the UI. you can use #1# for example to show the mult variable, and #2# for x_mult
            return { self.ability.extra.mult, self.ability.extra.x_mult }
        end,
    },

    fiveghost = {
        name = "Five Ghost Joker",
        text = {
            "Get {C:attention}one{} of the effects",
            "when {C:spectral}Spectral{} is used:",
            "{C:mult}+5{} Mult, {C:chips}+25{} Chips",
            "{X:red,C:white}X0.25{}, {C:attention}$10{} or {C:attention}Nothing{}",
            "{C:inactive}(Currently{} {C:chips}+#1#{}, {C:mult}+#2#{}, {X:red,C:white}X#3#{}{C:inactive}){}"
        },
        config = { extra = { chips = 0, mult = 0, x_mult = 1 } },
        pos = { x = 0, y = 0 },
        rarity = 2,
        cost = 5,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if context.using_consumeable then
                if not context.blueprint and (context.consumeable.ability.set == "Spectral") then
                    local rand = math.random(1, 5)
                    if rand == 1 then
                        -- multiplier
                        self.ability.extra.mult = self.ability.extra.mult + 5
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_mult',vars={5}}});
                                return true
                            end
                        }))
                    elseif rand == 2 then
                        -- chips
                        self.ability.extra.chips = self.ability.extra.chips + 25
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_chips',vars={10}}});
                                return true
                            end
                        }))
                    elseif rand == 3 then
                        -- x_mult
                        self.ability.extra.x_mult = self.ability.extra.x_mult + 0.25
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize{type='variable',key='a_xmult',vars={0.25}}});
                                return true
                            end
                        }))
                    elseif rand == 4 then
                        -- money
                        ease_dollars(10)
                        G.GAME.dollar_buffer = (G.GAME.dollar_buffer or 0) + 10
                        G.E_MANAGER:add_event(Event({func = (function() G.GAME.dollar_buffer = 0; return true end)}))
                    else
                        -- badluck
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_nope_ex')});
                                return true
                            end
                        }))
                    end
                end
            end
            if SMODS.end_calculate_context(context) then
                return {
                    chips = self.ability.extra.chips,
                    mult = self.ability.extra.mult,
                    x_mult = self.ability.extra.x_mult,
                    card = self,
                }
            end
        end,

        loc_def = function(self) --defines variables to use in the UI. you can use #1# for example to show the mult variable, and #2# for x_mult
            return {self.ability.extra.chips, self.ability.extra.mult, self.ability.extra.x_mult}
        end,
    },

    tripleseven = {
        name = "777 Joker",
        text = {
            "Each {C:attention}Lucky 7{}",
            "permanently gains",
            "{C:chips}+#1#{} Chips when",
            "{C:green}successfully{} triggered"
        },
        config = { extra = { x_chips = 77 } },
        pos = { x = 0, y = 0 },
        rarity = 1,
        cost = 4,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if context.individual and context.cardarea == G.play then
                if context.other_card:get_id() == 7 and context.other_card.lucky_trigger then
                    context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
                    context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + self.ability.extra.x_chips
                    return {
                        extra = { message = localize('k_upgrade_ex'), colour = G.C.CHIPS },
                        card = self
                    }
                end
            end
        end,

        loc_def = function(self) --defines variables to use in the UI. you can use #1# for example to show the mult variable, and #2# for x_mult
            return { self.ability.extra.x_chips }
        end,
    },

    wildreversal = {
        name = "Wild Reversal",
        text = {
            "Starts {C:attention}retriggering{}",
            "all played cards",
            "after {C:attention}2{} rounds",
            "{C:inactive}(Currently{} {C:attention}#1#{}{C:inactive}/#2#){}"
        },
        config = { extra = { round_tally = 0, round = 2} },
        pos = { x = 0, y = 0 },
        rarity = 3,
        cost = 7,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if context.repetition and self.ability.extra.round_tally == self.ability.extra.round then
                if context.cardarea == G.play then
                    return {
                        extra = { message = localize('k_again_ex') },
                        repetitions = 1,
                        card = self
                    }
                end
            end
            if self.ability.extra.round_tally < self.ability.extra.round then
                if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
                    self.ability.extra.round_tally = self.ability.extra.round_tally + 1
                end
            end
        end,

        loc_def = function(self) --defines variables to use in the UI. you can use #1# for example to show the mult variable, and #2# for x_mult
            return { self.ability.extra.round_tally, self.ability.extra.round }
        end,
    },

    spreader = {
        name = "Spreader",
        text = {
            "Pass the {C:spectral}seal{}",
            "of {C:attention}first{} played",
            "card to the {C:attention}second{}"
        },
        config = { extra = { mult = 0, chips = 0 } },
        pos = { x = 0, y = 0 },
        rarity = 2,
        cost = 6,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if context.individual and context.cardarea == G.play then
                if #context.scoring_hand >= 2 and context.scoring_hand[1]:get_seal() ~= nil then
                    G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.4,
                        func = function()
                            context.scoring_hand[2]:set_seal(context.scoring_hand[1]:get_seal())
                            play_sound('tarot1')
                        return true
                    end }))
                end
            end
        end,

        loc_def = function(self) --defines variables to use in the UI. you can use #1# for example to show the mult variable, and #2# for x_mult
            return { self.ability.extra.mult, self.ability.extra.chips }
        end,
    },

    themountain = {
        name = "The Mountain",
        text = {
            "Played {C:attention}Stone{} cards",
            "give {X:red,C:white}X#1#{} Mult",
            "when scored"
        },
        config = { extra = { x_mult = 1.25 } },
        pos = { x = 0, y = 0 },
        rarity = 1,
        cost = 4,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if context.individual and context.cardarea == G.play then
                if context.other_card.ability.effect == 'Stone Card' then
                    return {
                        extra = { x_mult = self.ability.extra.x_mult },
                        card = self
                    }
                end
            end
        end,

        loc_def = function(self) --defines variables to use in the UI. you can use #1# for example to show the mult variable, and #2# for x_mult
            return { self.ability.extra.x_mult }
        end,
    },

    whitehole = {
        name = "White Hole",
        text = {
            "{C:attention}Downgrade{} level of first",
            "{C:attention}played hand{} of round and",
            "gain this card {X:red,C:white}X#1#{} Mult",
            "{C:inactive}(Currently {X:red,C:white}X#2#{} Mult){}",
        },
        config = { extra = { mult = 0.5, x_mult = 1 } },
        pos = { x = 0, y = 0 },
        rarity = 2,
        cost = 5,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if context.before then
                if not context.blueprint_card and G.GAME.current_round.hands_played <= 0 then
                    local text, disp_text = G.FUNCS.get_poker_hand_info(context.scoring_hand)
                    local level = G.GAME.hands[text].level
                    if level > 1 then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                level_up_hand(context.blueprint_card or self, text, nil, -1)
                                self.ability.extra.x_mult = self.ability.extra.x_mult + self.ability.extra.mult
                                card_eval_status_text(self, 'extra', nil, nil, nil, {message = localize('k_upgrade_ex')});
                                update_hand_text({sound = 'button', volume = 0.7, pitch = 1.1, delay = 0}, {mult = 0, chips = 0, handname = '', level = ''})
                            return true
                        end}))
                    end
                end
            end
            if SMODS.end_calculate_context(context) then
                return {
                    x_mult = self.ability.extra.x_mult,
                    card = self
                }
            end
        end,

        loc_def = function(self) --defines variables to use in the UI. you can use #1# for example to show the mult variable, and #2# for x_mult
            return { self.ability.extra.mult, self.ability.extra.x_mult }
        end,
    },

    clover = {
        name = "Clover",
        text = {
            "All played cards",
            "become {C:attention}Lucky{} cards",
            "every {C:attention}4{} hands played",
            "{C:inactive}(Currently{} {C:attention}#1#{}{C:inactive}/4){}"
        },
        config = { extra = { hands = 0 } },
        pos = { x = 0, y = 0 },
        rarity = 2,
        cost = 5,
        blueprint_compat = true,
        eternal_compat = true,
        unlocked = true,
        discovered = true,
        atlas = nil,
        soul_pos = nil,

        calculate = function(self, context)
            if self.ability.extra.hands == 4 then
                local eval = function(card) return (self.ability.extra.hands == 4) end
                    juice_card_until(self, eval, true)
                if context.before and not context.blueprint then
                    for k, v in ipairs(context.scoring_hand) do
                        v.ability.effect = 'Lucky Card'
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                v:juice_up()
                            return true
                        end}))
                    end
                end
            end
            if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
                self.ability.extra.hands = self.ability.extra.hands + 1
                if self.ability.extra.hands >= 4 then
                    self.ability.extra.hands = 0
                end
            end
        end,

        loc_def = function(self) --defines variables to use in the UI. you can use #1# for example to show the mult variable, and #2# for x_mult
            return { self.ability.extra.hands }
        end,
    },
}

-- Start the mod
function SMODS.INIT.VaniillaPlus()
    --Create and register jokers
    for k, v in pairs(jokers) do --for every object in 'jokers'
        local joker = SMODS.Joker:new(v.name,k,v.config,v.pos,{ name = v.name, text = v.text },v.rarity,v.cost,
            v.unlocked, v.discovered, v.blueprint_compat, v.eternal_compat, v.effect, v.atlas, v.soul_pos)
        joker:register()

        if not v.atlas then
            SMODS.Sprite:new("j_" .. k, SMODS.findModByID("Vanii-llaPlus-main").path, "j_" .. k .. ".png", 71, 95, "asset_atli")
                :register()
        end

        SMODS.Jokers[joker.slug].calculate = v.calculate
        SMODS.Jokers[joker.slug].loc_def = v.loc_def
        if (v.tooltip ~= nil) then
            SMODS.Jokers[joker.slug].tooltip = v.tooltip
        end
    end
end

----------------------------------------------
------------MOD CODE END----------------------