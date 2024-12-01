;WITH
    lastWishes
    AS
    (
        SELECT  list_id, 
        child_id,
        wishes,
        ROW_NUMBER() OVER (PARTITION BY child_id ORDER BY child_id, submitted_date DESC) rw
        FROM wish_lists

    ),
    correctedWishes
    AS
    (
        SELECT wl.list_id, wl.child_id, wish.favorite_color, wish.first_choice, wish.second_choice, COUNT(1) color_count
        FROM lastWishes wl
        CROSS APPLY OPENJSON(wishes)
            WITH (
                favorite_color NVARCHAR(50) '$.colors[0]',
                first_choice NVARCHAR(50) '$.first_choice',
                second_choice NVARCHAR(50) '$.second_choice') wish
        CROSS APPLY OPENJSON(wishes, '$.colors') wishClrs
        --WHERE wl.rw = 1
        GROUP BY wl.list_id, wl.child_id, wish.favorite_color, wish.first_choice, wish.second_choice
    )
SELECT TOP(10)
        chld.name, 
        cw.first_choice,
        cw.second_choice,
        cw.favorite_color,
        cw.color_count,
        CASE tc.difficulty_to_make 
            WHEN 1 THEN 'Simple Gift'
            WHEN 2 THEN 'Moderate Gift'
            ELSE 'Complex Gift'
        END gift_complexity,
        CASE tc.category
            WHEN 'outdoor' THEN 'Outside Workshop'
            WHEN 'educational' THEN 'Learning Workshop'
            ELSE 'General Workshop'
        END workshop_assignment        
FROM correctedWishes cw
INNER JOIN dbo.children chld
    ON chld.child_id = cw.child_id
INNER JOIN dbo.toy_catalogue tc
    ON tc.toy_name = cw.first_choice
ORDER BY chld.name

/*
Answer:
name,first_choice,second_choice,favorite_color,color_count,gift_complexity,workshop_assignment
Abagail,Building sets,LEGO blocks,Blue,1,Complex Gift,Learning Workshop
Abbey,Toy trains,Toy trains,Pink,2,Complex Gift,General Workshop
Abbey,Yo-yos,Building blocks,Blue,5,Simple Gift,General Workshop
Abbey,Barbie dolls,Play-Doh,Purple,1,Moderate Gift,General Workshop
*/