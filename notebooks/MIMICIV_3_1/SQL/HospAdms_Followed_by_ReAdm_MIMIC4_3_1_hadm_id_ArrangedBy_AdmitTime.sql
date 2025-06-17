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