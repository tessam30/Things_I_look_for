### Regular Expression Matchings to classify dimensions

IF REGEXP_MATCH([District], "Phalombe|Nsanje|Neno|Mangochi|Machinga|Chikwawa|Blantyre|Balaka") AND [District] != "Blantyre City" THEN "Priority District"
ELSE "Non-Priority District"
END
