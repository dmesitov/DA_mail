-- Построить по каждому тарифу воронку (посчитать кол-во
-- на всех этапах) от просмотра цены, до успешной поездки
-- – каждый шаг, отдельное поле. Напишите на каких 2 шага
-- теряем больше всего клиентов? (Воронка: просмотр
-- цены – заказ – водитель назначен – машина подана –
-- клиент сел – успешная поездка)

select tariff,
       uniqExact(v.idhash_view)                    as unique_views,
       countIf(v.idhash_order, v.idhash_order > 0) as unique_orders,
       count(o.da_dttm)                            as driver_assignments,
       count(o.rfc_dttm)                           as mawina_podana,
       count(o.cc_dttm)                            as client_zalez,
       count(o.finish_dttm)                        as order_complete
from data_analysis.views v
         left join orders o on v.idhash_order = o.idhash_order
group by tariff;

-- больше всего клиентов теряется между просмотром цен и собственно заказом,
-- на втором месте -- между заказом и назначением водителя, т.е. на первых двух этапах цепочки


-------------------------------------------------------------------------------------

-- По каждому клиенту вывести топ используемых им
-- тарифов по убыванию в массиве, а также подсчитать
-- сколькими тарифами он пользуется.
select idhash_client,
       arrayReverseSort((x, y) -> y,
                        ['Эконом', 'Комфорт', 'Комфорт+', 'Бизнес'], jj) as tariffs_sorted,
       arrayCount(elem -> elem > 0, jj)                                  as tariffs_used
from (
      select idhash_client,
             countIf(tariff == 'Эконом')           as econom_orders,
             countIf(tariff == 'Комфорт')          as comfort_orders,
             countIf(tariff == 'Комфорт+')         as c_plus_orders,
             countIf(tariff == 'Бизнес')           as business_orders,
             array(econom_orders, comfort_orders,
                   c_plus_orders, business_orders) as jj
      from data_analysis.views v
      where idhash_order > 0
      group by idhash_client
         );


-------------------------------------------------------------------------------------

-- Вывести топ 10 гексагонов (размер 7) из которых уезжают
-- с 7 до 10 утра и в которые едут с 18-00 до 20-00 в сумме
-- по всем дням


select A.h3                              as hex_id,
       orders_from_hex + orders_to_hex as orders_total
from ( select geoToH3(longitude, latitude, 7)                                   as h3,
              countIf(toHour(o.order_dttm) >= 7 and toHour(o.order_dttm) <= 10) as orders_from_hex
       from data_analysis.views
                join data_analysis.orders o
                     on views.idhash_order = o.idhash_order
       group by h3
         ) A
         join
     ( select geoToH3(del_longitude, del_latitude, 7)                            as h3,
              countIf(toHour(o.order_dttm) >= 18 and toHour(o.order_dttm) <= 22) as orders_to_hex
       from data_analysis.views
                join data_analysis.orders o
                     on views.idhash_order = o.idhash_order
       group by h3
         ) B
     on A.h3 = B.h3

order by orders_total desc
limit 10;


-------------------------------------------------------------------------------------

-- Вывести медиану и 95 квантиль времени поиска
-- водителя.

select median(time_to_assign)         as tta_median,
       quantile(0.95)(time_to_assign) as tta_95_quantile
from (select (da_dttm - order_dttm) as time_to_assign
      from data_analysis.orders
      where (da_dttm IS NOT NULL))
where time_to_assign <= 1000;   --отбрасываем выбросы (отложенные заказы. 1000 секунд
                                --это скорее всего отложенный заказ)
