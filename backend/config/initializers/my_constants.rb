
TOURNAMENT_NAMES = ['wt20', 'ipl', 'csl']

GEMS_LIST = [35,147,226,55,39,301]

# paths
ROOT_DIR = Dir.pwd
SEED_CSV_PATH = ROOT_DIR + '/_files/seed/csv'
SEED_JSON_PATH = ROOT_DIR + '/_files/seed/json'
NEW_MATCH = ROOT_DIR + '/_files/new.txt'
NEW_MATCH_JSON = ROOT_DIR + '/_files/new.json'
MATCH_JSON_PATH = "#{Dir.pwd}/_files/temp/magic.json"
MATCH_INGEST_JSON_PATH = "#{Dir.pwd}/_files/temp/ingest.json"
MATCH_CSV_PATH = "#{Dir.pwd}/_files/temp/match_data"
PLAYERS_JSON_PATH = "#{Dir.pwd}/_files/static/players.json"
TOURNAMENT_JSON_PATH = "#{Dir.pwd}/_files/static/tournaments.json"
SQUADS_JSON_PATH = "#{Dir.pwd}/_files/static/squads.json"
SCHEDULE_JSON_PATH = "#{Dir.pwd}/_files/static/schedule.json"
TEAM_MEDALS = "#{Dir.pwd}/_files/static/team_medals.json"
ARGS_JSON_PATH = "#{Dir.pwd}/_files/static/match_args"
MATCH_TEXT_FILE_PATH = "#{Dir.pwd}/_files/static/txt"

# vars
NILL = nil
WT20_IDS = [1,4,5]
IPL_IDS = [2]
CSL_IDS = [3,6]
TEAM_NAMES = %w[ind pak aus nz wi sa eng ban afg sl nep zim ire srh csk rcb mi rr pbks dc kkr jan feb mar apr may june july aug sept oct nov dec]
PLAYER_TROPHIES_INIT = {
  "motm" => 0,
  "pots" => 0,
  "mvp" => 0,
  "most_runs" => 0,
  "most_wickets" => 0,
  "gold" => 0,
  "silver" => 0,
  "bronze" => 0,
  "gem" => 0,
}
