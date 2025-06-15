WITH Num_of_Hospital_Adm AS (
  SELECT subject_id, COUNT(DISTINCT hadm_id) AS Num_of_Hospital_Admissions
  FROM `physionet-data.mimiciv_note.discharge`  
  GROUP BY subject_id
),
DenseRank_HospAdmin AS (
  SELECT subject_id, hadm_id, DENSE_RANK() OVER (PARTITION BY subject_id ORDER BY hadm_id) AS AdminNum
FROM `physionet-data.mimiciv_note.discharge`  
),
Max_AdminNum AS (
  SELECT subject_id, MAX(AdminNum) AS Max_AdminNum
  FROM DenseRank_HospAdmin
  GROUP BY subject_id
),
Connect_MaxAdminNum AS (
SELECT subject_id, hadm_id, AdminNum, Max_AdminNum  
FROM Num_of_Hospital_Adm
INNER JOIN DenseRank_HospAdmin 
 USING (subject_id) 
INNER JOIN Max_AdminNum
 USING (subject_id)
ORDER BY subject_id, hadm_id
)
SELECT subject_id, hadm_id, AdminNum, Max_AdminNum.Max_AdminNum
FROM Connect_MaxAdminNum
WHERE AdminNum != Max_AdminNum.Max_AdminNum -- deactivate this line querying all Hospital Admissions as recorded by Discharge Notes
;