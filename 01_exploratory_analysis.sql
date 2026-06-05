-- ============================================================
-- 01_exploratory_analysis.sql
-- Hospital Readmissions: Exploratory Analysis
-- Dataset: Diabetes 130 US Hospitals, 1999-2008
-- Author: Aristotle Polites
-- ============================================================
-- Queries 1-6: Operational and efficiency-focused analysis
-- commissioned by hospital leadership.
-- ============================================================


-- ------------------------------------------------------------
-- Query 1: Lab Procedure Counts by Race
-- Stakeholder: Nurse Director
-- Question: Do lab procedure counts differ by race?
-- Purpose: Surface a signal for further investigation —
--          not a conclusion, but a starting point.
-- ------------------------------------------------------------

SELECT
    race,
    ROUND(AVG(num_lab_procedures), 2) AS avg_lab_procedures,
    COUNT(*) AS encounter_count
FROM diabetic_data
WHERE race IS NOT NULL
  AND race != '?'
GROUP BY race
ORDER BY avg_lab_procedures DESC;


-- ------------------------------------------------------------
-- Query 2: Procedure Volume vs. Length of Stay
-- Stakeholder: Hospital Leadership
-- Question: Do more procedures correlate with longer stays?
-- Purpose: Understand the degree and shape of that relationship
--          for capacity modeling and bed utilization forecasting.
-- ------------------------------------------------------------

SELECT
    CASE
        WHEN num_lab_procedures <= 25 THEN '1. Few (25 or fewer)'
        WHEN num_lab_procedures <= 54 THEN '2. Average (26 to 54)'
        ELSE '3. Many (55+)'
    END AS procedure_group,
    ROUND(AVG(time_in_hospital), 2) AS avg_length_of_stay,
    COUNT(*) AS patient_count
FROM diabetic_data
GROUP BY procedure_group
ORDER BY procedure_group;


-- ------------------------------------------------------------
-- Query 3: Procedure-Intensive Medical Specialties
-- Stakeholder: Hospital Director
-- Question: Which specialties average more than 2.5 procedures
--           per encounter, with at least 50 encounters on record?
-- Purpose: Guide staffing decisions, supply chain, and budgeting.
--          The 50-encounter threshold filters out statistical noise.
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
-- Stakeholder: Operations Team
-- Question: Which ER patients were discharged below average ER
--           length of stay?
-- Purpose: Identify benchmarks — what made their care efficient?
--          Admission type 1 = Emergency.
-- ------------------------------------------------------------

SELECT
    patient_nbr,
    race,
    gender,
    age,
    admission_type_id,
    time_in_hospital,
    num_lab_procedures,
    num_procedures,
    medical_specialty,
    readmitted
FROM diabetic_data
WHERE admission_type_id = 1
  AND time_in_hospital < (
      SELECT AVG(time_in_hospital)
      FROM diabetic_data
      WHERE admission_type_id = 1
  )
ORDER BY time_in_hospital;


-- ------------------------------------------------------------
-- Query 5: Targeted Patient List
-- Stakeholder: Research Team
-- Question: List all patients who are African American OR whose
--           metformin dosage was increased.
-- Purpose: Feed downstream research protocols or outreach
--          programs. OR logic is inclusive — precision matters.
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
   OR metformin = 'Up'
ORDER BY race, patient_nbr;


-- ------------------------------------------------------------
-- Query 6: Hospital Stay Distribution and the 7-Day Line
-- Stakeholder: Hospital Leadership
-- Question: What is the distribution of time in hospital?
--           Do most patients leave within 7 days?
-- Purpose: Confirm efficient throughput and flag potential
--          bottlenecks for extended stays.
-- ------------------------------------------------------------

-- Full distribution
SELECT
    time_in_hospital,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM diabetic_data
GROUP BY time_in_hospital
ORDER BY time_in_hospital;

-- Summary: within 7 days vs. beyond
SELECT
    CASE
        WHEN time_in_hospital <= 7 THEN '7 days or fewer'
        ELSE 'More than 7 days'
    END AS stay_category,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM diabetic_data
GROUP BY stay_category
ORDER BY stay_category;
