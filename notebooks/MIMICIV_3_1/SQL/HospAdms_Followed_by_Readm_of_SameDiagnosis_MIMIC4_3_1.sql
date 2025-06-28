With Num_of_Hospital_Adm AS (
  SELECT subject_id, COUNT(DISTINCT hadm_id) AS Num_of_Hospital_Admissions
  FROM `physionet-data.mimiciv_note.discharge`  
  GROUP BY subject_id
),
Prep_for_DenseRank_HospAdmin AS (
  SELECT DISTINCT d.subject_id, d.hadm_id, icd.icd_code AS ICD, ha.admittime AS AdmitTime, diag.long_title AS Diagnosis --, DENSE_RANK() OVER (PARTITION BY d.subject_id, icd.icd_code ORDER BY ha.admittime) AS AdmitNum
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
  ORDER BY subject_id, AdmitTime
),
AdmitNum_MaxAdmitNum_by_Diagnosis AS (
  SELECT DISTINCT subject_id, hadm_id, ICD, AdmitTime, Diagnosis, AdmitNum, MAX(AdmitNum) AS Max_AdmitNum
  FROM DenseRank_HospAdmin
  WHERE AdmitNum > 1
  GROUP BY subject_id, hadm_id, ICD, AdmitTime, Diagnosis, AdmitNum
  ORDER BY subject_id, AdmitTime, AdmitNum
),
Connect_MaxAdmitNum AS (
  SELECT DISTINCT subject_id, hadm_id, ICD, AdmitTime, Diagnosis, AdmitNum, Max_AdmitNum  
  FROM AdmitNum_MaxAdmitNum_by_Diagnosis
  ORDER BY subject_id, AdmitTime, AdmitNum
),
Find_Readmitting_Diagnoses AS (
  SELECT DISTINCT subject_id, hadm_id, ICD, AdmitTime, Diagnosis, AdmitNum, Max_AdmitNum, CASE WHEN AdmitNum = Max_AdmitNum THEN 1 ELSE 0 END AS Readmitting_Diagnosis  
  FROM Connect_MaxAdmitNum
  ORDER BY subject_id, AdmitTime, AdmitNum
),
LastReadmission_Filtered_by_Readmitting_Diagnoses AS (
SELECT DISTINCT subject_id, hadm_id, ICD, AdmitTime, Diagnosis, AdmitNum, Max_AdmitNum, Readmitting_Diagnosis, CASE WHEN AdmitNum = Max_AdmitNum THEN 1 ELSE 0 END AS LastAdmit
FROM Find_Readmitting_Diagnoses
WHERE Readmitting_Diagnosis = 1 
ORDER BY subject_id, AdmitTime DESC, AdmitNum DESC
)
SELECT DISTINCT hadm_id
FROM Find_Readmitting_Diagnoses
EXCEPT DISTINCT
SELECT hadm_id
FROM LastReadmission_Filtered_by_Readmitting_Diagnoses
; -- 
