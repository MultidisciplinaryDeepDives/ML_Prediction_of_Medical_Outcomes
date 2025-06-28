WITH Find_Num_of_Measurements AS (
  SELECT patientunitstayid, count(patientunitstayid)  AS Num_of_Measurements 
  FROM `physionet-data.eicu_crd.vitalperiodic`   
  GROUP BY patientunitstayid
  ORDER BY Num_of_Measurements)--,
--AtLeast100 AS (
SELECT *
FROM Find_Num_of_Measurements AS FNM
WHERE FNM.Num_of_Measurements >= 100    --200 (can try higher measurement count requirements) 
ORDER BY FNM.Num_of_Measurements DESC;




WITH Find_Num_of_Measurements AS (
  SELECT patientunitstayid, count(patientunitstayid)  AS Num_of_Measurements 
  FROM `physionet-data.eicu_crd.vitalperiodic`   
  GROUP BY patientunitstayid
  ORDER BY Num_of_Measurements),
AtLeast100 AS (
  SELECT *
  FROM Find_Num_of_Measurements AS FNM
  WHERE FNM.Num_of_Measurements >= 100    --200 (can try higher measurement count requirements) 
  ORDER BY FNM.Num_of_Measurements DESC
)
SELECT 
  patientunitstayid, 
  observationoffset,
  Num_of_Measurements,
  LAST_VALUE(temperature IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS Temp_filled, 
  LAST_VALUE(sao2 IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS saO2_filled, 
  LAST_VALUE(heartrate IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS HR_filled,
  LAST_VALUE(respiration IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS Resp_filled,
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
ORDER BY patientunitstayid, observationoffset, vitalperiodicid;