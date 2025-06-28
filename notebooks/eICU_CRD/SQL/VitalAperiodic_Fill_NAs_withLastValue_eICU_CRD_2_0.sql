SELECT 
  patientunitstayid, 
  observationoffset, 
  LAST_VALUE(noninvasivesystolic IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS NonInvSystolic_filled, 
  LAST_VALUE(noninvasivediastolic IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS NonInvDiastolic_filled, 
  LAST_VALUE(noninvasivemean IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS NonInvMeanBP_filled, 
  LAST_VALUE(paop IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS Pulm_Art_Occlusion_Pressure_filled,
  LAST_VALUE(cardiacoutput IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS CardiacOuput_filled,
  LAST_VALUE(cardiacinput IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS CardiacInput_filled,
  LAST_VALUE(svr IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS SystemicVascResistance_filled,
  LAST_VALUE(svri IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS SystemicVascResistanceIndex_filled,
  LAST_VALUE(pvr IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS PulmVascResistance_filled,
  LAST_VALUE(pvri IGNORE NULLS) OVER (PARTITION BY patientunitstayid ORDER BY observationoffset) AS PulmVascResistanceIndex_filled
FROM `physionet-data.eicu_crd.vitalaperiodic`  
ORDER BY patientunitstayid, observationoffset, vitalaperiodicid;