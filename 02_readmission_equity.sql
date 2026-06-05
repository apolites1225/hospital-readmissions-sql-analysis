-- ============================================================
-- 02_readmission_equity.sql
-- Hospital Readmissions: Equity Analysis
-- Dataset: Diabetes 130 US Hospitals, 1999-2008
-- Author: Aristotle Polites
-- ============================================================
-- Query 7: The question nobody asked.
--
-- My boss's questions were all oriented around efficiency:
-- how fast are patients moving through the system, how many
-- procedures, how long are they staying? All valid, all useful.
--
-- But nobody asked about 30-day readmissions — one of the most
-- expensive, most telling, and most preventable events in the
-- healthcare system. And nobody asked whether that rate was
-- even across every patient demographic.
--
-- I built these queries anyway. I think they needed them.
-- ============================================================


-- ------------------------------------------------------------
-- Context: What is a 30-day readmission?
-- A patient is counted as readmitted if they returned to the
-- hospital within 30 days of discharge. In US healthcare,
-- 30-day readmission rates are:
--   - A CMS quality metric tied to hospital reimbursement
--   - A signal for incomplete care or inadequate discharge
--     planning
--   - Disproportionately concentrated in certain populations
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- Query 7a: Overall 30-Day Readmission Rate
-- Baseline: What percentage of all encounters result in a
-- readmission within 30 days?
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmissions_within_30_days,
    ROUND(
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate_pct
FROM diabetic_data;


-- ------------------------------------------------------------
-- Query 7b: 30-Day Readmission Rate by Race
-- The unsolicited question: Is the readmission rate consistent
-- across demographic groups, or does it vary?
--
-- This is not a causal analysis. SQL cannot tell you WHY the
-- numbers differ. But it can tell you WHETHER they differ —
-- and that is enough to warrant a serious conversation about
-- discharge planning, follow-up care, and post-visit support.
-- ------------------------------------------------------------

SELECT
    race,
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmissions_within_30_days,
    ROUND(
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate_pct,
    ROUND(
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
        - (SELECT SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
           FROM diabetic_data),
        2
    ) AS diff_from_overall_avg
FROM diabetic_data
WHERE race IS NOT NULL
  AND race != '?'
GROUP BY race
ORDER BY readmission_rate_pct DESC;


-- ------------------------------------------------------------
-- Query 7c: Readmission Rate by Race and Age Group
-- Drilling deeper: Does the pattern hold across age groups,
-- or is it driven by a particular cohort?
-- ------------------------------------------------------------

SELECT
    race,
    age,
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmissions,
    ROUND(
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate_pct
FROM diabetic_data
WHERE race IS NOT NULL
  AND race != '?'
  AND age IS NOT NULL
GROUP BY race, age
HAVING COUNT(*) >= 50  -- Filter to groups with enough data to be meaningful
ORDER BY race, age;


-- ------------------------------------------------------------
-- Query 7d: Follow-up Framing Questions
-- These queries are the "what next" — not answers, but prompts
-- for the next investigation.
-- ------------------------------------------------------------

-- Are readmitted patients being seen by different specialties?
SELECT
    readmitted,
    medical_specialty,
    COUNT(*) AS encounter_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY readmitted), 2) AS pct_within_readmission_group
FROM diabetic_data
WHERE readmitted = '<30'
  AND medical_specialty IS NOT NULL
  AND medical_specialty != '?'
GROUP BY readmitted, medical_specialty
HAVING COUNT(*) >= 30
ORDER BY encounter_count DESC;

-- Do readmitted patients have different medication change patterns?
SELECT
    race,
    change AS medication_changed,
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmissions,
    ROUND(
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate_pct
FROM diabetic_data
WHERE race IS NOT NULL
  AND race != '?'
GROUP BY race, change
ORDER BY race, readmission_rate_pct DESC;
