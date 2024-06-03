-- Creating temp table of Wolves player stats from the 2023-2024 season by using CTEs and joining tables 
drop table if exists wolves_player_stats_24;

create temporary table wolves_player_stats_24 as 
with advanced_wolves_24 as (
	select 
		*
	from Advanced 
	where tm == 'MIN' and season == 2024 and player not in ('Justin Jackson', 'Shake Milton', 'Troy Brown Jr.')
	),
wolves_24 as (
	select 
		*
	from "Player Shooting" 
	where tm == 'MIN' and season == 2024 and player not in ('Justin Jackson', 'Shake Milton', 'Troy Brown Jr.')
	)
select 
	wolves_24.*, 
	advanced_wolves_24.ts_percent, 
	advanced_wolves_24.usg_percent, 
	advanced_wolves_24.dws, 
	advanced_wolves_24.ows, 
	advanced_wolves_24.ws
from wolves_24
join advanced_wolves_24 
on wolves_24.player_id = advanced_wolves_24.player_id;

select 
	*
from wolves_player_stats_24;

-- Offensive, defensive, and total win shares
select 
	player, 
	ows, 
	dws, 
	ws
from wolves_player_stats_24
order by ws desc;

-- Usage percentages
select 
	player, 
	usg_percent
from wolves_player_stats_24
order by 2 desc;

-- Minutes per game
select 
	player, 
	round((1.0 * mp / g), 1) as minutes_per_game
from wolves_player_stats_24
order by 2 desc;

-- Observing 3-point shot distribution with shooting percentages and how they relate to offensive win shares (filtering to only rotation players)
select 
	player, 
	percent_fga_from_x3p_range * 100, 
	fg_percent_from_x3p_range, 
	ows
from wolves_player_stats_24
where mp > 150
order by 2 desc;

-- Observing long mid-range shot distribution with shooting percentages and how they relate to offensive win shares (filtering to only rotation players)
select 
	player, 
	percent_fga_from_x16_3p_range, 
	fg_percent_from_x16_3p_range, 
	ows
from wolves_player_stats_24
where mp > 150
order by 2 desc;

-- Creating temp table of NBA player stats from the 2023-2024 season by using CTEs and joining tables 
drop table if exists nba_player_stats_24;

create temporary table nba_player_stats_24 as
with advanced_nba_24 as (
    select 
		*
    from advanced
    where season = 2024
),
nba_24 as (
    select 
		distinct *
    from "player shooting"
    where season = 2024
),
ranked_players as (
    select 
        nba_24.*, 
		advanced_nba_24.ts_percent, 
		advanced_nba_24.usg_percent, 
		advanced_nba_24.dws, 
		advanced_nba_24.ows, 
		advanced_nba_24.ws,
        row_number() over (partition by nba_24.player_id order by case when nba_24.tm = 'TOT' then 0 else 1 end) as rn
    from nba_24
    join advanced_nba_24 on advanced_nba_24.player_id = nba_24.player_id
)
select 
	*
from ranked_players
where rn = 1;

select 
	*
from nba_player_stats_24;

-- Usage percentages for rotational players
select 
	player, 
	usg_percent
from nba_player_stats_24
where mp > 800
order by 2 desc;

-- Shooting stats for rotational players 
select 
	player, 
	fg_percent,
	fg_percent_from_x3p_range,
	ts_percent
from nba_player_stats_24
where mp > 800
order by 4 desc;

-- Offensive, defensive, and total win shares 
select 
	player,
	ows,
	dws,
	ws
from nba_player_stats_24
order by 4 desc;

-- Rotation players who take at least 10% of their shots from the long mid-range area (16ft-3pt line) with shooting percentages
select 
	player, 
	percent_fga_from_x16_3p_range, 
	fg_percent_from_x16_3p_range
from nba_player_stats_24
where percent_fga_from_x16_3p_range not like "NA" and percent_fga_from_x16_3p_range >= .10 and mp > 800 
order by 3 desc;

-- 3-point percentage by positions (not weighted by attempts)
select 
	pos,
	avg(fg_percent_from_x3p_range) as average_3pt_percentage
from nba_player_stats_24
where mp > 800
group by 1
order by 2 desc;
