;

WITH RawData AS
    (SELECT guestCount::text::int guestCount,
            food_item_id::text::int food_item_id
     FROM christmas_menus
     CROSS JOIN LATERAL unnest(xpath('/northpole_database/annual_celebration/event_metadata/dinner_details/guest_registry/total_count/text()', menu_data)) guestCount
     CROSS JOIN LATERAL unnest(xpath('//food_item_id/text()', menu_data)) food_item_id
     WHERE guestCount::text::int > 78
     UNION ALL 
     SELECT guestCount::text::int guestCount,
                      food_item_id::text::int food_item_id
     FROM christmas_menus
     CROSS JOIN LATERAL unnest(xpath('/polar_celebration/event_administration/participant_metrics/attendance_details/headcount/total_present/text()', menu_data)) guestCount
     CROSS JOIN LATERAL unnest(xpath('//food_item_id/text()', menu_data)) food_item_id
     WHERE guestCount::text::int > 78
     UNION ALL 
     SELECT guestCount::text::int guestCount,
                      food_item_id::text::int food_item_id
     FROM christmas_menus
     CROSS JOIN LATERAL unnest(xpath('/christmas_feast/organizational_details/attendance_record/total_guests/text()', menu_data)) guestCount
     CROSS JOIN LATERAL unnest(xpath('//food_item_id/text()', menu_data)) food_item_id
     WHERE guestCount::text::int > 78 )
SELECT food_item_id,
       COUNT(food_item_id)
FROM RawData
GROUP BY food_item_id
ORDER BY COUNT(food_item_id) DESC
LIMIT 1 /*
XML Root elements
{northpole_database}
{polar_celebration}
{christmas_feast}
*/ /*
Result 493
*/