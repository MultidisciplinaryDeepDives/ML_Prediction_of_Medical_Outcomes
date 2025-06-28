With Num_of_Hospital_Adm AS (
  SELECT subject_id, COUNT(DISTINCT hadm_id) AS Num_of_Hospital_Admissions
  FROM `physionet-data.mimiciv_note.discharge`  
  GROUP BY subject_id
),
Prep_for_DenseRank_HospAdmin AS (
  SELECT DISTINCT d.subject_id, d.hadm_id, icd.icd_code AS ICD, ha.admittime AS AdmitTime, diag.long_title AS Diagnosis  
  FROM `physionet-data.mimiciv_note.discharge` AS d
  INNER JOIN `physionet-data.mimiciv_3_1_hosp.admissions` AS ha
    USING (hadm_id)
  INNER JOIN `physionet-data.mimiciv_3_1_hosp.diagnoses_icd` AS icd
    USING (hadm_id)
  LEFT JOIN `physionet-data.mimiciv_3_1_hosp.d_icd_diagnoses` AS diag
    USING (icd_code)
  ORDER BY subject_id, admittime
),
DenseRank_HospAdmin AS (
  SELECT DISTINCT subject_id, hadm_id, ICD, AdmitTime, Diagnosis, DENSE_RANK() OVER (PARTITION BY subject_id, ICD ORDER BY AdmitTime) AS AdmitNum
  FROM Prep_for_DenseRank_HospAdmin
  ORDER BY subject_id, AdmitTime, hadm_id
),
AdmitNum_MaxAdmitNum_by_Diagnosis AS (
  SELECT DISTINCT subject_id, hadm_id, ICD, AdmitTime, Diagnosis, AdmitNum, MAX(AdmitNum) AS Max_AdmitNum
  FROM DenseRank_HospAdmin
  GROUP BY subject_id, hadm_id, ICD, AdmitTime, Diagnosis, AdmitNum
  ORDER BY subject_id, AdmitTime, hadm_id
),
Connect_MaxAdmitNum AS (
  SELECT DISTINCT subject_id, hadm_id, ICD, AdmitTime, Diagnosis, AdmitNum, Max_AdmitNum  
  FROM AdmitNum_MaxAdmitNum_by_Diagnosis
  WHERE Max_AdmitNum > 1
  ORDER BY subject_id, AdmitTime, AdmitNum
),
Find_Readmitting_Diagnoses AS (
  SELECT DISTINCT subject_id, hadm_id, ICD, AdmitTime, Diagnosis, AdmitNum, Max_AdmitNum, CASE WHEN AdmitNum = Max_AdmitNum THEN 1 ELSE 0 END AS Readmitting_Diagnosis  
  FROM Connect_MaxAdmitNum
  ORDER BY subject_id, AdmitTime, AdmitNum
),
Days_Interval_Calc_Prep AS (
  SELECT DISTINCT subject_id, hadm_id, AdmitTime
  FROM Find_Readmitting_Diagnoses
  ORDER BY subject_id, AdmitTime, hadm_id
),
Days_Interval_Calc AS (
  SELECT DISTINCT subject_id, hadm_id, AdmitTime, DATE_DIFF(AdmitTime, LAG(AdmitTime) OVER (PARTITION BY subject_id ORDER BY AdmitTime ASC), DAY) AS Days_Interval
  FROM Days_Interval_Calc_Prep
  ORDER BY subject_id, AdmitTime ASC, hadm_id
),
Label_Readmission_Within30Days AS (
SELECT DISTINCT subject_id, hadm_id, AdmitTime, Days_Interval, CASE WHEN Days_Interval <= 30 THEN 1 ELSE 0 END AS Readmission_Within_30Days
FROM Days_Interval_Calc
ORDER BY subject_id, AdmitTime, hadm_id
)
SELECT subject_id, hadm_id, AdmitTime, Days_Interval, LEAD(Readmission_Within_30Days) OVER(ORDER BY hadm_id) AS Followed_by_Readmission_Within_30Days
FROM Label_Readmission_Within30Days
ORDER BY subject_id, AdmitTime, hadm_id
;