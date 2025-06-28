-- Find Hosp Admissions with Any Subsequent Readmissions (of the same patient)
With Num_of_Hospital_Adm AS (
  SELECT subject_id, COUNT(DISTINCT hadm_id) AS Num_of_Hospital_Admissions
  FROM `physionet-data.mimiciv_note.discharge`  
  GROUP BY subject_id
),
DenseRank_HospAdm AS (
  SELECT subject_id, hadm_id, DENSE_RANK() OVER (PARTITION BY subject_id ORDER BY hadm_id) AS AdmNum
FROM `physionet-data.mimiciv_note.discharge`  
),
Max_AdmNum AS (
  SELECT subject_id, MAX(AdmNum) AS Max_AdmNum
  FROM DenseRank_HospAdm
  GROUP BY subject_id
),
Connect_MaxAdmNum AS (
  SELECT subject_id, hadm_id, AdmNum, Max_AdmNum  
  FROM Num_of_Hospital_Adm
  INNER JOIN DenseRank_HospAdm 
  USING (subject_id) 
  INNER JOIN Max_AdmNum
  USING (subject_id)
  ORDER BY subject_id, hadm_id
)
SELECT subject_id, hadm_id, AdmNum, Max_AdmNum.Max_AdmNum
FROM Connect_MaxAdmNum
WHERE AdmNum < Max_AdmNum.Max_AdmNum 
ORDER BY subject_id, hadm_id, AdmNum
;



--Find hosp readmissions within 30 days of discharge
With Num_of_Hospital_Adm AS (
  SELECT subject_id, COUNT(DISTINCT hadm_id) AS Num_of_Hospital_Admissions
  FROM `physionet-data.mimiciv_note.discharge`  
  GROUP BY subject_id
),
Prep_for_DenseRank_HospAdm AS (
  SELECT DISTINCT d.subject_id, d.hadm_id, ha.admittime AS AdmitTime
  FROM `physionet-data.mimiciv_note.discharge` AS d
  INNER JOIN `physionet-data.mimiciv_3_1_hosp.admissions` AS ha
    USING (hadm_id)
  ORDER BY subject_id, admittime
),
DenseRank_HospAdm AS (
  SELECT DISTINCT subject_id, hadm_id, AdmitTime, DENSE_RANK() OVER (PARTITION BY subject_id ORDER BY AdmitTime) AS AdmitNum
  FROM Prep_for_DenseRank_HospAdm
  ORDER BY subject_id, AdmitTime, hadm_id
),
Find_MaxAdmitNum AS (
  SELECT DISTINCT subject_id, MAX(AdmitNum) AS Max_AdmitNum
  FROM DenseRank_HospAdm
  GROUP BY subject_id--, hadm_id, AdmitTime, AdmitNum
  ORDER BY subject_id--, AdmitTime, hadm_id
),
Connect_MaxAdmitNum AS (
  SELECT DISTINCT subject_id, hadm_id, AdmitTime, AdmitNum, Max_AdmitNum  
  FROM DenseRank_HospAdm
  INNER JOIN Find_MaxAdmitNum
    USING (subject_id)
  WHERE Max_AdmitNum > 1
  ORDER BY subject_id, AdmitTime, AdmitNum
),
Find_HospAdmission_withEnsuingHospReadmission AS (
  SELECT DISTINCT subject_id, hadm_id, AdmitTime, AdmitNum, Max_AdmitNum, CASE WHEN AdmitNum < Max_AdmitNum THEN 1 ELSE 0 END AS HospReadmissionWillEnsue
  FROM Connect_MaxAdmitNum
  ORDER BY subject_id, AdmitTime, AdmitNum
),
Days_Calc_Prep AS (
  SELECT DISTINCT f.subject_id, hadm_id, AdmitTime, charttime AS HospDischargeTime, AdmitNum, Max_AdmitNum, HospReadmissionWillEnsue
  FROM Find_HospAdmission_withEnsuingHospReadmission AS f
  INNER JOIN `physionet-data.mimiciv_note.discharge` AS d
    USING (hadm_id)
  ORDER BY subject_id, AdmitTime, hadm_id
),
Days_btAdms_fromDischarges_Calc AS (
  SELECT DISTINCT 
    subject_id, 
    hadm_id, 
    AdmitTime, 
    HospDischargeTime,
    DATE_DIFF(AdmitTime, LAG(AdmitTime) OVER (PARTITION BY subject_id ORDER BY AdmitTime ASC), DAY) AS Days_Since_Last_Hospital_Adm,
    EXTRACT(DAY FROM HospDischargeTime - AdmitTime) AS LOS
  FROM Days_Calc_Prep
  ORDER BY subject_id, AdmitTime ASC, hadm_id
),
Days_from_Next_Hospital_Readmission_Calc AS(
SELECT DISTINCT
  subject_id, 
  hadm_id, 
  AdmitTime, 
  HospDischargeTime,
  Days_Since_Last_Hospital_Adm,
  LOS,
  LEAD(Days_Since_Last_Hospital_Adm) OVER (PARTITION BY subject_id ORDER BY AdmitTime) AS Days_from_CurrHospAdm_to_NextHospReadmission
FROM Days_btAdms_fromDischarges_Calc
ORDER BY subject_id, AdmitTime, hadm_id
),
Days_bt_Discharge_and_NextHospReadmission_Calc AS(
SELECT DISTINCT  
  subject_id, 
  hadm_id, 
  AdmitTime,
  HospDischargeTime,
  (Days_from_CurrHospAdm_to_NextHospReadmission - LOS) AS Days_bt_Discharge_and_NextHospReadmission
FROM Days_from_Next_Hospital_Readmission_Calc
ORDER BY subject_id, AdmitTime, hadm_id
)
SELECT DISTINCT  
  subject_id, 
  hadm_id, 
  AdmitTime,
--  HospDischargeTime,
  Days_bt_Discharge_and_NextHospReadmission,
  CASE WHEN Days_bt_Discharge_and_NextHospReadmission < 31 THEN 1 ELSE 0 END AS HospReadmissionWithin30Days
FROM Days_bt_Discharge_and_NextHospReadmission_Calc
ORDER BY subject_id, AdmitTime, hadm_id
--limit 200000 offset 167201
;

