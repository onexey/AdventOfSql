DROP TABLE IF EXISTS #ValidChars
DROP TABLE IF EXISTS #Numbers

CREATE TABLE #ValidChars(
    CharValue int
)

SELECT TOP 122 IDENTITY(int,1,1) AS Number
INTO #Numbers
FROM sys.objects s1       --use sys.columns if you don't get enough rows returned to generate all the numbers you need
CROSS JOIN sys.objects s2 --use sys.columns if you don't get enough rows returned to generate all the numbers you need

INSERT INTO #ValidChars (CharValue)
SELECT [Number]
FROM #Numbers
WHERE [Number] BETWEEN 65 AND 90 --A-Z
    OR [Number] BETWEEN 97 AND 122 --a-z

INSERT INTO #ValidChars (CharValue)
VALUES
('32'), --space
('33'), --!
('34'), --"
('39'), --'
('40'), --(
('41'), --)
('44'), --
('45'), ---
('46'), --.
('58'), --:
('59'), --;
('63') --?

DECLARE @Result NVARCHAR(MAX);

SELECT @Result = STRING_AGG(CHAR(a.[value]), '') WITHIN GROUP (ORDER BY a.id)
FROM letters_a a
WHERE EXISTS (
    SELECT * 
    FROM #ValidChars
    WHERE CharValue = a.[value])

SELECT @Result = CONCAT(@Result, STRING_AGG(CHAR(b.[value]), '') WITHIN GROUP (ORDER BY b.id))
FROM letters_b b
WHERE EXISTS (
    SELECT * 
    FROM #ValidChars
    WHERE CharValue = b.[value])

SELECT @Result Result

/*
Answer: Dear Santa, I hope this letter finds you well in the North Pole! I want a SQL course for Christmas!
*/