### Regular Expression Matchings to classify dimensions

IF REGEXP_MATCH([District], "Phalombe|Nsanje|Neno|Mangochi|Machinga|Chikwawa|Blantyre|Balaka") AND [District] != "Blantyre City" THEN "Priority District"
ELSE "Non-Priority District"
END


###### Making filled Gantt Bars
1. Create two measures, one that takes the value of 1 (max value) and one that takes the value of -1 (min value). If not using percentages, the max value is the max value of the range of measures to be used.
2. Create a Gantt chart. Then _drag and drop_ the measure of interest on the top axis of the gantt figure.
3. Synchronize axes, hide, and change the mark type.


