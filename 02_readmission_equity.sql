-- ============================================================
-- 02_readmission_equity.sql
-- Hospital Readmissions: The Question Nobody Asked
-- Dataset: Diabetes 130 US Hospitals, 1999-2008
-- Author: Aristotle Polites
-- ============================================================


-- ------------------------------------------------------------
-- Query 7a: Overall 30-Day Readmission Rate
-- ------------------------------------------------------------

SELECT
    ROUND(
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate_pct
FROM diabetic_data;


-- ------------------------------------------------------------
-- Query 7b: 30-Day Readmission Rate by Race
-- ------------------------------------------------------------

SELECT
    race,
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmissions,
    ROUND(
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate_pct
FROM diabetic_data
GROUP BY race
ORDER BY readmission_rate_pct DESC;
