class Spell < ApplicationRecord
    belongs_to :player
    belongs_to :squad
    belongs_to :inning
    belongs_to :match
    belongs_to :tournament

    def get_overs
        return Over.where(inning_id: self.inning_id, bowler_id: self.player_id)
    end
    def get_fig
        return "#{self.wickets} - #{self.runs}"
    end

    def spell_box
        hash = {}
        hash["type"] = 'spell'
        hash["tour"] = self.match.get_tour_font
        hash["name"] = Util.case(self.player.fullname, self.match.tournament_id)
        hash["fig"] = self.get_fig
        hash["wickets"] = self.wickets
        hash["runs"] = self.runs
        hash["overs"] = self.overs
        hash["dots"] = self.dots
        hash["ones"] = self.c1
        hash["fours"] = self.c4
        hash["sixes"] = self.c6
        hash["economy"] = self.economy
        hash["maidens"] = self.maidens
        # hash["color"] = self.squad.abbrevation
        hash["color"] = Util.get_team_color(self.tournament_id, self.squad.abbrevation)
        hash["p_id"] = self.player_id
        hash["vs_team"] = self.inning.bat_team.get_abb
        hash["venue"] = self.match.venue.upcase
        hash["id"] = self.id
        hash["match_id"] = self.match_id
        hash["points"] = PlayerMatchPoint.find_by(player_id: self.player_id, match_id: self.match_id, rtype: RTYPE_BALL)&.points || 0
        return hash
    end

    def get_mvp_points_spell(match_eco, match_bow_sr)
        # Points = (O*E) + (W*S1)
        rel_eco = (match_eco/self.economy).round(2)
        rel_sr = self.sr.nil? ? 0 : (match_bow_sr/self.sr).round(2)
        rel_eco = 0 if rel_eco < 0.85
        points = (Util.overs_to_balls(self.overs) * rel_eco * 0.8) + (self.wickets * rel_sr)
        return points.round(2)
    end

    def self.get_better_spell(spell1, spell2)
        return spell2 if spell1.nil?
        return spell1 if spell1.wickets > spell2.wickets
        return spell2 if spell1.wickets < spell2.wickets
        return spell1 if spell1.runs < spell2.runs
        return spell2 if spell1.runs > spell2.runs
        return spell1
    end

    def phase_box(overs)
        h = {}
        h['powerplay'] = self.phase_box_hash(overs, 'powerplay')
        h['middle'] = self.phase_box_hash(overs, 'middle')
        h['death'] = self.phase_box_hash(overs, 'death')
        return h
    end

    def phase_box_hash(overs, phase)
        case phase
        when "powerplay"
            overs = overs.where('over_no <= 6')
        when "middle"
            overs = overs.where('over_no > 6 and over_no <= 15')
        when "death"
            overs = overs.where('over_no >= 16')
        end
        return nil unless overs.present?
        hash = Spell.empty_spell_hash
        overs.each do |over|
            hash = Spell.update_spell_hash(over, hash)
        end
        hash["overs"] = Util.balls_to_overs(hash["balls"])
        hash["economy"] = Util.get_economy(hash["runs"], hash["overs"])
        if hash["wickets"] > 0
            hash["sr"] = Util.get_bow_sr(hash["overs"], hash["wickets"])
            hash["avg"] = Util.get_bow_avg(hash["runs"], hash["wickets"])
        end

        hash["color"] = Util.get_team_color(self.tournament_id, self.squad.abbrevation)
        return hash
    end

    def vs_batsmen(balls)
        arr = []
        batsmen = {}
        balls.each do |ball|
            batsman_id = ball.batsman_id
            batsmen[batsman_id] = Spell.empty_spell_hash unless batsmen.has_key? batsman_id
            batsmen[batsman_id] = Spell.update_spell_hash_ball(ball, batsmen[batsman_id])
        end
        batsmen.each do |k,v|
            v["sr"] = Util.get_sr(v["runs"], v["balls"])
            v["color"] = Util.get_team_color(self.tournament_id, self.squad.abbrevation)
            v["batsman_id"] = k
            v["batsman_name"] = Player.find(k).name.titleize
            v["batsman_color"] = Util.get_team_color(self.tournament_id, self.inning.bat_team.abbrevation)
            arr << v
        end
        return arr
    end

    def get_points(benchmark, player_bat_ratings, batting_team_strength)
        inn = self.inning
        spell_balls = Util.overs_to_balls(self.overs)
        bpo =  spell_balls / self.wickets.to_f
        part1 = benchmark['bpw'] / bpo
        part2 = benchmark['economy'] / self.economy
        total_balls = (Util.overs_to_balls(self.inning.overs).to_f/5).round(2)
        bat_rat = []
        inn.wickets.where(bowler_id: self.player_id).each do |wicket|
          bat_rat << wicket.get_wicket_weight(player_bat_ratings)
        end
        avg_wicket_weight = bat_rat.present? ? (bat_rat.sum.to_f/bat_rat.length).round(2) : 0
        
        calculated_points = (((part2*spell_balls*10) + (part1*avg_wicket_weight*(spell_balls.to_f/total_balls))) / 2).round(2)
        
        if ["league", "group"].exclude? inn.match.stage
          if inn.match.stage == "final"
            factor = 1.2
          else
            factor = 1.1
          end
          calculated_points = (calculated_points*factor).round(2)
        end
        points = ((calculated_points*TEAM_STRENGTH_WEIGHTAGE*batting_team_strength) + (calculated_points*(0.9))).round(2)
        return points.round(2)
    end

    private

    def self.empty_spell_hash
        h = {}
        h["runs"] = 0
        h["balls"] = 0
        h["wickets"] = 0
        h["maidens"] = 0
        h["fours"] = 0
        h["sixes"] = 0
        h["dots"] = 0
        h
    end

    def self.update_spell_hash(over, hash)
        hash["runs"] += over.bow_runs
        hash["balls"] += over.balls
        hash["dots"] += over.dots
        hash["fours"] += over.c4
        hash["sixes"] += over.c6
        hash["wickets"] += over.wickets
        hash["maidens"] += 1 if over.bow_runs == 0
        return hash
    end

    def self.update_spell_hash_ball(ball, hash)
        hash["runs"] += ball.bow_runs
        hash["balls"] += 1 if ball.extra_type != "wd"
        hash["dots"] += 1 if ball.category == "c0"
        hash["fours"] += 1 if ball.category == "c4"
        hash["sixes"] += 1 if ball.category == "c6"
        hash["wickets"] = 1 if ball.wicket_ball
        return hash
    end

end
