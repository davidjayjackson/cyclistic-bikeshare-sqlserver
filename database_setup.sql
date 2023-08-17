USE cyclistic
GO


-- ChatGPT
SELECT * INTO rides 
FROM (
    SELECT * FROM data2
    UNION 
    SELECT * FROM data3
    UNION
    SELECT * FROM data4
) AS combinedData;
