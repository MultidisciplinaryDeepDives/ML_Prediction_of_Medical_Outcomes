SELECT * FROM `physionet-data.eicu_crd_derived.pivoted_vital`  
--ORDER BY chartoffset;
ORDER BY patientunitstayid, chartoffset, entryoffset;


WITH Find_Num_of_Measurements AS (
  SELECT patientunitstayid, count(patientunitstayid)  AS Num_of_Measurements 
  FROM `physionet-data.eicu_crd_derived.pivoted_vital`   
  --ORDER BY chartoffset;
  GROUP BY patientunitstayid
  ORDER BY Num_of_Measurements),
AtLeast100 AS (
  SELECT *
  FROM Find_Num_of_Measurements AS FNM
  WHERE FNM.Num_of_Measurements >= 100 
  ORDER BY FNM.Num_of_Measurements DESC
)
SELECT *
FROM `physionet-data.eicu_crd_derived.pivoted_vital`   
INNER JOIN AtLeast100 AS a
  USING (patientunitstayid)
ORDER BY patientunitstayid, chartoffset
;

-- DESC --, chartoffset, entryoffset;