
select *from ipl.dbo.balls
select *from ipl.dbo.matches


---max toss winner  top 5 teams
select top 5 toss_winner, count(*) as toss_count from ipl.dbo.matches group by toss_winner order by toss_count desc;
select top 10 toss_winner, count(*) as toss_count from ipl.dbo.matches where toss_decision ='bat' group by toss_winner  order by toss_count desc;

---count match win by toss decision
select count(winner) as win_count, toss_decision, toss_winner from ipl.dbo.matches group by toss_decision, toss_winner order by win_count desc

---- count total matches played by teams
SELECT team1 AS team, COUNT(*) AS matches_played
FROM ipl.dbo.matches
GROUP BY team1

UNION ALL

SELECT team2 AS team, COUNT(*) AS matches_played
FROM ipl.dbo.matches
GROUP BY team2

ORDER BY matches_played DESC

---count winning team
select winner, count(winner) as win_count from ipl.dbo.matches group by winner order by win_count desc
---------WHAT IS THE NUMBER OF MATCHES WON BY EACH TEAM BATTING FIRST VERSUS BATTING SECOND?
select team,
	sum (case when toss_decision='bat'  and toss_winner = team then 1 else 0 end) as match_win_by_bat_team,
	sum (case when toss_decision='field' and winner=team then 1 else 0 end) as match_win_by_field_team

from( select 
		case when winner = team1 then team1
		else team2
		end as team, 
		toss_decision, toss_winner, winner
		from ipl.dbo.matches
) as subquery group by team;

SELECT team1 AS team, 
    COUNT(case when toss_decision='bat' and toss_winner=team1 then 1 end) as match_won_batting_team,
    COUNT(case when toss_decision='field' and toss_winner=team1 then 1 end) as match_win_field_team
FROM ipl.dbo.matches
GROUP BY team1

UNION ALL

SELECT team2 AS team, 
    COUNT(case when toss_decision='bat' and toss_winner=team2 then 1 end) as match_won_batting_team,
    COUNT(case when toss_decision='field' and toss_winner=team2 then 1 end) as match_win_field_team
FROM ipl.dbo.matches
GROUP BY team2

ORDER BY match_won_batting_team DESC, match_win_field_team DESC


-----------totoal runs by each batsmen
select  batsman, sum(batsman_runs) as total_score from ipl.dbo.balls group by batsman order by total_score desc

-----HOW MANY TIMES HAS EACH BATSMAN BEEN DISMISSED BY THE BOWLER 'MALINGA'
select batsman, count(*) as dismessed_by_bowler from ipl.dbo.balls where bowler='SL Malinga'
and is_wicket=1 group by batsman order by dismessed_by_bowler desc

----WHAT IS THE AVERAGE PERCENTAGE OF BOUNDARIES (FOURS AND SIXES COMBINED) HIT BY EACH BATSMAN

select batsman, ROUND(cast(sum(case when batsman_runs=4 or batsman_runs=6 then 1 else 0 end)as float) /count(*)*100,2)
as avg_bound_perc_batsman
from ipl.dbo.balls group by batsman order by avg_bound_perc_batsman desc

---WHAT IS THE AVERAGE NUMBER OF BOUNDARIES HIT BY EACH TEAM 

SELECT 
    batting_team,
    SUM(CASE WHEN batsman_runs = 4 OR batsman_runs = 6 THEN 1 ELSE 0 END) AS total_boundaries,
    ROUND(
        CAST(SUM(CASE WHEN batsman_runs = 4 OR batsman_runs = 6 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(DISTINCT id),
        2
    ) AS avg_perc_bound_match
FROM 
    ipl.dbo.balls
GROUP BY 
    batting_team;

--------------WHAT IS THE HIGHEST PARTNERSHIP (RUNS) FOR EACH TEAM IN EACH SEASON?

SELECT 
    batting_team,
    YEAR(matches.date) AS season,
    MAX(partnership_runs) AS highest_partnership_runs
FROM (
    SELECT 
        batting_team,
        SUM(batsman_runs) AS partnership_runs,
        id
    FROM 
        ipl.dbo.balls
    GROUP BY 
        batting_team, id, inning


) AS partnerships
INNER JOIN 
    ipl.dbo.matches ON partnerships.id = matches.id
GROUP BY 
    YEAR(matches.date), batting_team;

-------HOW MANY EXTRAS (WIDES & NO-BALLS) WERE BOWLED BY EACH TEAM IN EACH MATCH

select 
	matches.id as match_id,
	matches.team1 as team1,
	matches.team2 as team2,
	balls.batting_team as batting_team,
	balls.bowling_team as bowling_team,
	sum(case when balls.extras_type in ('wides', 'noballs') then 1 else 0 end) as totoal_extras
from ipl.dbo.balls balls
join
    ipl.dbo.matches matches ON balls.id = matches.id
group by matches.id, matches.team1,matches.team2,balls.batting_team,balls.bowling_team
order by totoal_extras desc

----find most wickets taken by bowler

select bowler, count(*) as total_wickets
from ipl.dbo.balls where is_wicket =1  group by bowler order by total_wickets desc 

---WHAT IS THE AVERAGE NUMBER OF RUNS SCORED IN EACH OVER OF THE INNINGS IN EACH MATCH
select inning, id, overs, avg(total_runs) as avg_runns
from ipl.dbo.balls group by id, overs,inning order by avg_runns desc

