class Tournament < ApplicationRecord
    has_many :squads
    has_many :balls
    has_many :overs
    has_many :innings
    has_many :matches
    has_many :wickets
    has_many :scores
    has_many :spells
    has_many :partnerships
    has_many :performances

    def winners
        return Squad.find(self.winners_id)
    end
    def runners
        return Squad.find(self.runners_id)
    end
    def pots
        return Squad.find(self.pots_id)
    end
    def mvp
        return Squad.find(self.mvp_id)
    end
    def most_runs
        return Squad.find(self.most_runs_id)
    end
    def most_wickets
        return Squad.find(self.most_wickets_id)
    end


    def validate
        status = true
        errors = []

        unless TOURNAMENT_NAMES.include?(self.name)
            status = false
            errors << "name cannot be #{self.name}"
        end

        if self.winners_id && Squad.all.pluck(:id).exclude?(self.winners_id)
            status = false
            errors << "winners_id not a foreign key: #{self.winners_id}"
        end
        return status,errors
    end

    def get_tour_font
        return "#{self.name}_#{self.id}"
    end
end
