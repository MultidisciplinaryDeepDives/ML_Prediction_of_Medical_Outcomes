WITH Find_Num_of_Measurements AS (
  SELECT patientunitstayid, count(patientunitstayid)  AS Num_of_Measurements 
  FROM `physionet-data.eicu_crd.vitalperiodic`   
  GROUP BY patientunitstayid
  ORDER BY Num_of_Measurements)--,
--AtLeast100 AS (
SELECT *
FROM Find_Num_of_Measurements AS FNM
WHERE 
  FNM.Num_of_Measurements >= 200 AND FNM.Num_of_Measurements <= 33000  
ORDER BY FNM.Num_of_Measurements DESC;





--Find ICU Stays that have certain features/columns
WITH Find_Num_of_Measurements AS (
  SELECT patientunitstayid, count(patientunitstayid)  AS Num_of_Measurements 
  FROM `physionet-data.eicu_crd.vitalperiodic`   
  GROUP BY patientunitstayid
  ORDER BY Num_of_Measurements
),
AtLeast100 AS (
  SELECT *
  FROM Find_Num_of_Measurements AS FNM
  WHERE FNM.Num_of_Measurements >= 30 AND FNM.Num_of_Measurements <= 33000 
  ORDER BY FNM.Num_of_Measurements DESC
),
Relevant_Obs AS (
  SELECT 
    patientunitstayid, 
    observationoffset,
    Num_of_Measurements,
    LAST_VALUE(temperature IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS Temp_filled, 
    LAST_VALUE(sao2 IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS saO2_filled, 
    LAST_VALUE(heartrate IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS HR_filled,
    LAST_VALUE(respiration IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS RR_filled,
    LAST_VALUE(cvp IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS CVP_filled,
    LAST_VALUE(etco2 IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS EtCO2_filled,
    LAST_VALUE(systemicsystolic IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS SysSystolic_filled,
    LAST_VALUE(systemicdiastolic IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS SysDiastolic_filled,
    LAST_VALUE(systemicmean IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS SysMeanBP_filled,
    LAST_VALUE(pasystolic IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS PAsystolic_filled,
    LAST_VALUE(padiastolic IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS PAdiastolic_filled,
    LAST_VALUE(pamean IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS PAmeanBP_filled, 
    LAST_VALUE(st1 IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS ST1_filled, 
    LAST_VALUE(st2 IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS ST2_filled, 
    LAST_VALUE(st3 IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS ST3_filled, 
    LAST_VALUE(icp IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS ICP_filled
  FROM `physionet-data.eicu_crd.vitalperiodic` 
  INNER JOIN AtLeast100 AS a
    USING (patientunitstayid)
  WHERE st1 IS NOT NULL
    AND st2 IS NOT NULL
    AND st3 IS NOT NULL  
    AND respiration IS NOT NULL
    AND sao2 IS NOT NULL
    AND heartrate IS NOT NULL
    AND icp IS NOT NULL
  ORDER BY patientunitstayid, observationoffset, vitalperiodicid
),
ICU_Stays_with_Relevant_Obs AS (
  SELECT DISTINCT Relevant_Obs.patientunitstayid, Relevant_Obs.Num_of_Measurements
  FROM Relevant_Obs
)
SELECT *
FROM ICU_Stays_with_Relevant_Obs
INNER JOIN `physionet-data.eicu_crd_derived.pivoted_vital` 
 USING (patientunitstayid)
ORDER BY patientunitstayid, chartoffset
;






WITH Find_Num_of_Measurements AS (
  SELECT patientunitstayid, count(patientunitstayid)  AS Num_of_Measurements 
  FROM `physionet-data.eicu_crd.vitalperiodic`   
  GROUP BY patientunitstayid
  ORDER BY Num_of_Measurements
),
AtLeast100 AS (
  SELECT *
  FROM Find_Num_of_Measurements AS FNM
  WHERE FNM.Num_of_Measurements >= 200 AND FNM.Num_of_Measurements <= 33000 
  ORDER BY FNM.Num_of_Measurements DESC
)
SELECT 
  patientunitstayid, 
  observationoffset,
  Num_of_Measurements,
  LAST_VALUE(temperature IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS Temp_filled, 
  LAST_VALUE(sao2 IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS saO2_filled, 
  LAST_VALUE(heartrate IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS HR_filled,
  LAST_VALUE(respiration IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS RR_filled,
  LAST_VALUE(cvp IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS CVP_filled,
  LAST_VALUE(etco2 IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS EtCO2_filled,
  LAST_VALUE(systemicsystolic IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS SysSystolic_filled,
  LAST_VALUE(systemicdiastolic IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS SysDiastolic_filled,
  LAST_VALUE(systemicmean IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS SysMeanBP_filled,
  LAST_VALUE(pasystolic IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS PAsystolic_filled,
  LAST_VALUE(padiastolic IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS PAdiastolic_filled,
  LAST_VALUE(pamean IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS PAmeanBP_filled, 
  LAST_VALUE(st1 IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS ST1_filled, 
  LAST_VALUE(st2 IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS ST2_filled, 
  LAST_VALUE(st3 IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS ST3_filled, 
  LAST_VALUE(icp IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS ICP_filled
FROM `physionet-data.eicu_crd.vitalperiodic` 
INNER JOIN AtLeast100 AS a
  USING (patientunitstayid)
WHERE st1 IS NOT NULL
  AND st2 IS NOT NULL
  AND st3 IS NOT NULL  
  AND respiration IS NOT NULL
  AND sao2 IS NOT NULL
  AND heartrate IS NOT NULL
ORDER BY patientunitstayid, observationoffset, vitalperiodicid;