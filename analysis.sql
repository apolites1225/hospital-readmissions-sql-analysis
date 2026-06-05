-- ============================================================
-- Hospital Readmissions SQL Analysis
-- Dataset: Diabetes 130 US Hospitals, 1999-2008
-- Author: Aristotle Polites
-- ============================================================


-- ------------------------------------------------------------
-- Query 1: Lab Procedure Counts by Race
-- Question: Do lab procedure counts differ by race?
-- ------------------------------------------------------------

SELECT
    race,
    ROUND(AVG(num_lab_procedures), 2) AS avg_lab_procedures,
    COUNT(*) AS encounter_count
FROM diabetic_data
GROUP BY race
ORDER BY avg_lab_procedures DESC;


-- ------------------------------------------------------------
-- Query 2: Procedure Volume vs. Length of Stay
-- Question: Do more procedures correlate with longer stays?
-- ------------------------------------------------------------

SELECT
    CASE
        WHEN num_lab_procedures <= 25 THEN 'Few (25 or fewer)'
        WHEN num_lab_procedures <= 54 THEN 'Average (26 to 54)'
        ELSE 'Many (55+)'
    END AS procedure_group,
    ROUND(AVG(time_in_hospital), 2) AS avg_length_of_stay,
    COUNT(*) AS patient_count
FROM diabetic_data
GROUP BY procedure_group
ORDER BY avg_length_of_stay;


-- ------------------------------------------------------------
-- Query 3: Procedure-Intensive Medical Specialties
-- Question: Which specialties average >2.5 procedures per encounter?
-- Filter: Minimum 50 encounters to ensure statistical significance.
-- ------------------------------------------------------------

SELECT
    medical_specialty,
    ROUND(AVG(num_procedures), 2) AS avg_procedures,
    COUNT(*) AS encounter_count
FROM diabetic_data
WHERE medical_specialty IS NOT NULL
  AND medical_specialty != '?'
GROUP BY medical_specialty
HAVING AVG(num_procedures) > 2.5
   AND COUNT(*) >= 50
ORDER BY avg_procedures DESC;


-- ------------------------------------------------------------
-- Query 4: Emergency Patients Discharged Faster Than Average
-- Question: Which ER patients were discharged below avg ER stay?
-- Admission type 1 = Emergency
-- ------------------------------------------------------------

SELECT *
FROM diabetic_data
WHERE admission_type_id = 1
  AND time_in_hospital < (
      SELECT AVG(time_in_hospital)
      FROM diabetic_data
      WHERE admission_type_id = 1
  );


-- ------------------------------------------------------------
-- Query 5: Targeted Patient List
-- Question: African American patients OR patients with increased metformin
-- ------------------------------------------------------------

SELECT
    patient_nbr,
    race,
    gender,
    age,
    metformin,
    readmitted
FROM diabetic_data
WHERE race = 'AfricanAmerican'
   OR metformin = 'Up';


-- ------------------------------------------------------------
-- Query 6: Hospital Stay Distribution
-- Question: What is the distribution of time in hospital?
--           Do most patients leave within 7 days?
-- ------------------------------------------------------------

SELECT
    time_in_hospital,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM diabetic_data
GROUP BY time_in_hospital
ORDER BY time_in_hospital;

-- Summary: stays within 7 days vs. beyond
SELECT
    CASE
        WHEN time_in_hospital <= 7 THEN '7 days or fewer'
        ELSE 'More than 7 days'
    END AS stay_category,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM diabetic_data
GROUP BY stay_category;


-- ------------------------------------------------------------
-- Query 7: 30-Day Readmission Rates by Race (unsolicited)
-- Question nobody asked: Are readmission rates even across demographics?
-- ------------------------------------------------------------

-- Overall 30-day readmission rate
SELECT
    ROUND(
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS overall_readmission_rate_pct,
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS total_readmissions
FROM diabetic_data;

-- Readmission rate broken down by race
SELECT
    race,
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmissions_within_30_days,
    ROUND(
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate_pct
FROM diabetic_data
GROUP BY race
ORDER BY readmission_rate_pct DESC;
