with cte as (
    select pl.match_id,
           localized_name,
           case when pl.player_slot <= 4 then 'Radiant' else 'Dire' end as team,     --определение команды игрока
           case
               when (pl.player_slot <= 4 and m.radiant_win = 'True')
                   or (pl.player_slot >= 128 and m.radiant_win = 'False')
                   then 'True'
               else 'False' end                                         as did_win   --победил ли игрок
    from players pl
             join hero_names hn on pl.hero_id = hn.hero_id
             join match m on pl.match_id = m.match_id
    ),

     cte_winrate_total as (
         select localized_name,
                count(distinct match_id)                     as games_played,       --подсчёт сыгранных игр
                count(case when did_win = 'True' then 1 end) as games_won           --подсчёт побед
         from cte
         group by localized_name
     ),

     cte_wr as (
         select tot.localized_name                                                        as hero_name,
                games_played,
                to_char((tot.games_won + 0.0) / (tot.games_played + 0.0) * 100, '99.99%') as overall_winrate
                                                                                    --процент побед
         from cte_winrate_total tot
         where tot.games_played >= 500
     )

    select *,
           row_number() over (order by overall_winrate desc)        as wr_rating,
           dense_rank() over (order by games_played desc)                      as pick_rating

    from cte_wr
    order by hero_name;
