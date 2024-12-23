create database IPL;
use IPL;
show tables;

CREATE TABLE matches (
    id INT,
    season VARCHAR(255),
    city VARCHAR(255),
    date DATE,
    team1 VARCHAR(255),
    team2 VARCHAR(255),
    toss_winner VARCHAR(255),
    toss_decision VARCHAR(255),
    result VARCHAR(255),
    dl_applied TINYINT,
    winner VARCHAR(255),
    win_by_runs INT,
    win_by_wickets INT,
    player_of_match VARCHAR(255),
    venue VARCHAR(255),
    umpire1 VARCHAR(255),
    umpire2 VARCHAR(255)
);

SHOW VARIABLES LIKE 'secure_file_priv';
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\matches - Copy.csv"
INTO TABLE matches
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(id, season, city, @date_column, team1, team2, toss_winner, toss_decision, result, dl_applied, winner, win_by_runs, win_by_wickets, player_of_match, venue, umpire1, umpire2)
SET date = STR_TO_DATE(@date_column, '%d-%m-%Y');

select * from matches
limit 20;

select * from matches
where result = 'tie'
order by season desc;

select count(distinct city) 
from matches;

select * from matches
order by city desc, winner desc, venue desc
limit 50;

select distinct venue as  Stadium, city from matches
where venue like '%Association%'
order by venue desc, city desc;

-- Team that wons the most tosses.

select toss_winner, count(*) as toss_wins
from matches
group by toss_winner
order by toss_wins desc
limit 5;

-- Who won the most "Man of the Match" awards top 5 players.

select player_of_match, count(*) as awards
from matches
group by player_of_match
order by awards desc
limit 5;

-- The matches that were decided by a DL method.

select id, team1, team2, winner, dl_applied, player_of_match
from matches
where dl_applied != 0;

-- Teams that played the most matches only top 10.

select team, count(*) as matches_played
from (select team1 as team from matches
    union all
select team2 as team from matches) as all_teams
group by team
order by matches_played desc
limit 10; 

-- Find the number of matches that tie.

select season, team1, team2, count(*) as tied_matches
from matches
where result = 'tie'
group by season, team1, team2;

-- Umpires Who Officiated the Most Matches

select umpire1 as umpire, count(id) as matches
from matches
group by umpire1
union
select umpire2 as umpire, count(id) as matches
from matches
group by umpire2
order by matches desc;

-- Determine each match's average margin of victory in runs.

select 
avg(win_by_runs) as avg_win_by_runs 
from matches;

select SUM(case when win_by_runs > 0 then 1 else 0 end) as win_by_runs,
       SUM(case when win_by_wickets > 0 then 1 else 0 end) as win_by_wickets
from matches;

-- The player who has won the most Player of the Match awards.

select player_of_match, count(*) as awards_count 
from matches 
group by player_of_match 
order by awards_count desc 
limit 1;

-- Matches where Royal Challengers Bangalore played either as team1 or team2.

select *
from matches 
where team1 = 'Royal Challengers Bangalore' or team2 = 'Royal Challengers Bangalore';

-- Query: Identify all matches where the toss winner did not win the match.

select * 
from matches 
where toss_winner != winner;
-- Output shows that only data where who won the toss but not win the match. 

-- ----------------------------------------------------------- BALLS ---------------------------------------------------------------
use IPL;


CREATE TABLE balls(
    id INT,
    inning INT,
    ball_over INT,
    ball INT,
    batsman VARCHAR(255),
    non_striker VARCHAR(255),
    bowler VARCHAR(255),
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    non_boundary INT,
    is_wicket INT,
    dismissal_kind VARCHAR(255),
    player_dismissed VARCHAR(255),
    fielder VARCHAR(255),
    extras_type VARCHAR(255),
    batting_team VARCHAR(255),
    bowling_team VARCHAR(255)
);

SHOW VARIABLES LIKE 'secure_file_priv';
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\IPL_Ball-by-Ball_2008-2020.csv"
INTO TABLE balls
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

select count(*) as total_data from balls;

-- Discover the Top 5 Batsmen by Total Runs Scored in Matches.

select batsman, sum(batsman_runs) as total_runs
from balls
group by batsman
order by total_runs desc
limit 5;

-- Find top 5 Bowlers Who Has Taken the Most Wickets

select bowler, count(*) as wickets
from balls
where is_wicket = 1
group by bowler
order by wickets desc
limit 5;

-- Find Matches with the Highest Total Runs Scored in a Single Inning

select id, inning, sum(total_runs) as inning_total
from balls
group by id, inning
order by inning_total desc
limit 5;

-- Find the Most Common Type of Dismissal

select dismissal_kind, count(*) as dismissal_count
from balls
where dismissal_kind is not null
group by dismissal_kind
order by dismissal_count desc;

-- Calculate the Strike Rate of a Specific Batsman ('V Kohli') Across All Matches

select batsman,(sum(batsman_runs) / count(*)) * 100 as strike_rate
from balls
where batsman = 'V Kohli';

-- List of Batsmen Who Scored 100 or More Runs in a Single Match

select id, batsman, sum(batsman_runs) as runs
from balls
group by id, batsman
having runs >= 100;

-- Find the Team with the Most Extras Given runs

select bowling_team, sum(extra_runs) as total_extras
from balls
group by bowling_team
order by total_extras desc;

-- Identify the Bowler Who Has Bowled the Most Dot Balls

select bowler, count(*) as dot_balls
from balls
where batsman_runs = 0 and extra_runs = 0
group by bowler
order by dot_balls DESC
limit 5;

-- Determine the Average Runs Per Over Allowed to Each Bowler.

select bowler,
(sum(total_runs) / count(distinct concat(id , 'over'))) as average_runs_per_over
from balls
group by bowler
order by average_runs_per_over asc;

-- The number of sixes hit by each batsman.

select batsman, count(*) as sixes 
from balls 
where batsman_runs = 6 
group by batsman 
order by sixes desc;

-- Total number of boundaries (4s and 6s) hit in each match.

select id, 
sum(case when batsman_runs = 4 or batsman_runs = 6 then 1 else 0 end) as total_boundaries 
from balls 
group by id;

-- The match where the highest total number of runs were scored.

select id, 
sum(total_runs) as match_total_runs 
from balls
group by id 
order by match_total_runs desc 
limit 1;

-- Players Who Got Out to the Same Bowler Twice in a Match

select b.player_dismissed, b.bowler, count(*) as dismissals
from Balls b
join matches m on b.id = m.id
where b.is_wicket = 1
group by b.player_dismissed, b.bowler
having dismissals >= 2;

select matches.id, matches.player_of_match, balls.batsman, balls.bowler
from matches
left join balls
on matches.id = balls.id
limit 50;
















