-- количество матчей, в которых first_blood_time больше
-- 1 минуты, но меньше 3х минут;

select count(distinct match_id)
from match
where (first_blood_time > 60 and first_blood_time < 180);

-------------------------------------------

--Вывести идентификаторы участников (исключая анонимные
-- аккаунты где айдишник равен нулю), которые участвовали в
-- матчах, в которых победили силы Света и количество
-- позитивных отзывов зрителей было больше чем количество
-- негативных;

SELECT DISTINCT pl.account_id
FROM players pl
         JOIN match m ON pl.match_id = m.match_id
WHERE (pl.account_id != 0 AND upper(m.radiant_win) = 'TRUE' AND m.positive_votes > m.negative_votes);

-------------------------------------------

-- Получить идентификатор игрока и среднюю продолжительность
-- его матчей;

select pl.account_id,
       avg(duration)          as average_match_duration
from players pl, match m
WHERE m.match_id = pl.match_id
GROUP BY pl.account_id
ORDER BY pl.account_id;

---------------------------------------------

-- Получить суммарное количество потраченного золота,
-- уникальное количество использованных персонажей, среднюю
-- продолжительность матчей (в которых участвовали данные
-- игроки) для анонимных игроков;

select pl.account_id,
       sum(gold_spent)         as total_gold_spent,
       count(distinct hero_id) as unique_heroes_played,
       avg(duration)           as average_match_duration
from players pl, match m
WHERE account_id = 0 AND m.match_id = pl.match_id
GROUP BY account_id;

----------------------------------------------

-- Для каждого героя (hero_name) вывести: количество матчей в
-- которых был использован, среднее количество убийств,
-- минимальное количество смертей, максимальное количество
-- потраченного золота, суммарное количество позитивных
-- отзывов зрителей, суммарное количество негативных отзывов.

select hn.localized_name,
       count(distinct m.match_id)   as times_played,
       avg(pl.kills)                as average_kills,
       min(pl.deaths)               as min_deaths,
       max(pl.gold_spent)           as max_gold_spent,
       sum(m.positive_votes)        as total_positive_votes,
       sum(m.negative_votes)        as total_negative_votes
from players pl
         JOIN match m ON pl.match_id = m.match_id
         JOIN hero_names hn ON pl.hero_id = hn.hero_id
group by localized_name
order by localized_name;

------------------------------------------------------------------

-- Вывести матчи в которых: хотя бы одна покупка item_id = 42
-- состоялась позднее 100 секунды с начала мачта;

select distinct match_id
from purchase_log
where (item_id = 42 and time > 100);

------------------------------------------------------------------

-- получить первые 20 строк из всех данных из таблиц с матчами и
-- оплатами (purchase_log);

select *
from match, purchase_log
limit 20;
