class Player < ApplicationRecord
    has_many :scores
    has_many :spells
    has_one :bat_stats
    has_one :ball_stats
    has_many :performances
    def country
        return Team.find_by(id: self.country_team_id)
    end

    def tour_individual_awards_to_hash(t_id, award="")
        hash = {}
        hash["name"] = self.fullname.upcase
        hash["p_id"] = self.id
        squad = Squad.find(Score.find_by(tournament_id: t_id, player_id: self.id).squad_id)
        hash["color"] = squad.abbrevation
        hash["teamname"] = squad.get_abb
        hash["data2"] = "Mat: #{Score.where(tournament_id: t_id, player_id: self.id).count}"
        case award
        when "most_runs"
            runs_array = Score.where(batted: 'true', player_id: self.id, tournament_id: t_id, ).pluck(:runs)
            hash["data"] = "#{runs_array.sum} Runs"
        when "most_wickets"
            wickets_array = Spell.where(tournament_id: t_id, player_id: self.id).pluck(:wickets)
            hash["data"] = "#{wickets_array.sum} Wickets"
        when "mvp"
            points = 0
            p = Player.find(hash["p_id"])
            scores = Score.where(player_id: hash["p_id"], tournament_id: t_id)
            matches = 0
            scores.each do|score|
                matches += 1
                points += p.get_mvp_points(score.match_id)
            end
            hash["data"] = "#{points.round(1)} @#{(points/matches).round(1)}"

        when "pots"
            runs_array = Score.where(batted: 'true', player_id: self.id, tournament_id: t_id, ).pluck(:runs)
            hash["data"] = ""
            hash["data"] += "#{runs_array.sum.to_s} Runs" if runs_array.sum > 0
            wickets_array = Spell.where(tournament_id: t_id, player_id: self.id).pluck(:wickets)
            hash["data"] += " & #{wickets_array.sum.to_s} Wickets" if wickets_array.sum > 0
        end
        hash
    end

    def get_tour_mvp_points(t_id)
        points = 0
        batting_balls = Ball.where(tournament_id: t_id, batsman_id: self.id)
        bowling_balls = Ball.where(tournament_id: t_id, bowler_id: self.id)
        points += batting_balls.where(category: "c6").count * 3.5
        points += batting_balls.where(category: "c4").count * 2.5
        points += bowling_balls.where(category: "c0").count * 1
        points += bowling_balls.where(wicket_ball: true).count * 4
        # puts batting_balls.where(category: "c6").count
        # puts batting_balls.where(category: "c4").count
        # puts bowling_balls.where(category: "c0").count
        # puts bowling_balls.where(wicket_ball: true).count
        points += Score.where('runs >= 30').where(player_id: self.id, tournament_id: t_id).count * 1
        points += Score.where('runs >= 50').where(player_id: self.id, tournament_id: t_id).count * 2
        points += Score.where('runs >= 100').where(player_id: self.id, tournament_id: t_id).count * 2
        points += Spell.where('wickets >=3').where(player_id: self.id, tournament_id: t_id).count * 3
        points += Spell.where('wickets >=5').where(player_id: self.id, tournament_id: t_id).count * 2
        points += Match.where(tournament_id: t_id, motm_id: self.id).count * 3
        return points
    end

    def get_mvp_points(m_id)
        inn = Inning.where(match_id: m_id)
        inn1 = inn[0]
        inn2 = inn[1]
        t_runs = inn1.score + inn2.score
        t_balls = Util.overs_to_balls(inn1.overs) + Util.overs_to_balls(inn2.overs)
        t_wickets = inn1.for + inn2.for
        match_sr = (t_runs.to_f*100/t_balls.to_f).round(2)
        match_eco = (t_runs.to_f*6/t_balls.to_f).round(2)
        match_bow_sr = (t_balls.to_f*6/t_wickets.to_f).round(2)
        score = Score.find_by(match_id: m_id, player_id: self.id, batted: true)
        spell = Spell.find_by(match_id: m_id, player_id: self.id)
        points = 0
        points += score.get_mvp_points_score(match_sr) unless score.nil?
        points += spell.get_mvp_points_spell(match_eco, match_bow_sr) unless spell.nil?
        return points.round(2)
    end

    # private
end
