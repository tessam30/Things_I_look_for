##### Regular Expression Matchings to classify dimensions

IF REGEXP_MATCH([District], "Phalombe|Nsanje|Neno|Mangochi|Machinga|Chikwawa|Blantyre|Balaka") AND [District] != "Blantyre City" THEN "Priority District"
ELSE "Non-Priority District"
END


###### Making filled Gantt Bars
1. Create two measures, one that takes the value of 1 (max value) and one that takes the value of -1 (min value). If not using percentages, the max value is the max value of the range of measures to be used.
2. Create a Gantt chart. Then _drag and drop_ the measure of interest on the top axis of the gantt figure.
3. Synchronize axes, hide, and change the mark type.

###### Process for making small multiples
from [Ryan Sleeper](https://www.ryansleeper.com/how-to-make-trellis-tile-small-multiple-maps-in-tableau/)

Enter the x and y dimensions for the placement of each small multiple.  
[X case_when](https://user-images.githubusercontent.com/5873344/49155819-e3537780-f2e9-11e8-977c-39918c2947a2.png)

[Y case_when](https://user-images.githubusercontent.com/5873344/49155834-e8b0c200-f2e9-11e8-9dab-85971165bfa0.png)

After completing the case_when statements add the calculated fields to basic map and change the pills from continuous to discrete.
