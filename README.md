# Why I Built This

> *It started with a scenario I think every analyst knows well.*

Your boss pulls you aside, clearly running on two hours of sleep and three too many meetings. They hand you a list of questions and say, "Can you get me answers on these?" — and before you can ask a single follow-up, they're gone.

The easiest thing to do is open your SQL editor and start answering the questions exactly as written. That's the job, right?

I wasn't so sure. This project is what happens when you treat the questions as a starting point, not a finish line.

---

## The Dataset

**Diabetes 130 US Hospitals, 1999–2008**

| Metric | Value |
|---|---|
| Patient encounters | 136,339 |
| Unique patients | 71,518 |
| Hospitals covered | 130 U.S. hospitals |
| Time span | 1999–2008 |

The dataset includes demographic details (race, age, admission type), clinical data (lab procedures, medical specialty, medications including metformin, length of stay), and readmission records (within 30 days, after 30 days, or not at all).

This isn't synthetic data. These are real encounters, real patients, real outcomes.

---

## The Analysis

### 1. Do Lab Procedure Counts Differ by Race?

The nurse director raised this question — not to prove bias, but to see if the numbers warrant a closer look. I queried the average number of lab procedures per encounter, broken out by race.

```sql
SELECT
    race,
    AVG(num_lab_procedures) AS avg_lab_procedures,
    COUNT(*) AS encounter_count
FROM diabetic_data
GROUP BY race
ORDER BY avg_lab_procedures DESC;
```

**Takeaway:** Disparities in procedure counts can reflect many things — disease severity, access patterns, documentation differences — and SQL alone cannot tell you which. But it can tell you whether the numbers look uneven, and hand that finding to someone equipped to dig deeper.

---

### 2. More Procedures = Longer Stays?

I segmented patients into three groups — few procedures, average procedures, and many procedures — and calculated average length of stay for each.

```sql
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
```

**Takeaway:** More procedures correlated with longer stays — but the jump from "average" to "many" is far steeper than from "few" to "average." That nonlinearity matters for capacity modeling and bed utilization forecasting.

---

### 3. Which Medical Specialties Are the Most Procedure-Intensive?

The hospital director needed a filtered list: specialties where the average procedures per encounter exceeded 2.5, and where there were at least 50 encounters on record.

```sql
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
```

**Takeaway:** Filtering for statistical significance before surfacing findings keeps your analysis from sending leadership chasing ghosts.

---

### 4. Emergency Patients Who Left Faster Than Average

I pulled a list of all patients admitted through the emergency department who were discharged faster than the average ER stay.

```sql
SELECT *
FROM diabetic_data
WHERE admission_type_id = 1
  AND time_in_hospital < (
      SELECT AVG(time_in_hospital)
      FROM diabetic_data
      WHERE admission_type_id = 1
  );
```

**Takeaway:** Efficiency isn't just about fixing what's slow — it's about understanding what's working and scaling it.

---

### 5. Targeted Patient Lists: When SQL Logic Has to Be Exact

The research team needed a targeted patient list: anyone identified as African American or whose metformin dosage was marked as increased.

```sql
SELECT *
FROM diabetic_data
WHERE race = 'AfricanAmerican'
   OR metformin = 'Up';
```

**Takeaway:** Sometimes the most important thing in a query is making sure the logic matches the intent — especially when patient identification is involved.

---

### 6. Hospital Stay Distribution — And the 7-Day Line

My boss wanted a distribution of time spent in the hospital: do most patients leave within 7 days?

```sql
SELECT
    time_in_hospital,
    COUNT(*) AS patient_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM diabetic_data
GROUP BY time_in_hospital
ORDER BY time_in_hospital;
```

**Takeaway:** The majority of encounters resolve within a week. For patients who stay longer than 7 days, the goal is to confirm those cases are genuinely high-acuity — not the result of process bottlenecks or discharge delays.

---

### 7. The Question Nobody Asked — Readmission Rates by Race

Nobody asked about 30-day readmissions — one of the most expensive, most telling, and most preventable events in the healthcare system.

```sql
-- Overall sub-30-day readmission rate
SELECT
    ROUND(
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS readmission_rate_pct
FROM diabetic_data;

-- Readmission rate broken down by race
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
```

**Takeaway:** The results showed uneven readmission rates across demographic groups. That's not a conclusion about causation — but it is a flag worth raising. My boss didn't ask for it. But I think they needed it.

---

## Key Takeaways

- **Efficiency metrics alone don't tell the full story.** Speed and volume are easy to measure. Equity and outcomes are harder — and more important.
- **Readmissions are the missing metric.** Optimizing for fast discharges without tracking who comes back within 30 days is optimizing for the wrong thing.
- **Demographic breakdowns matter at every step.** Disaggregating by race isn't about blame — it's about finding the gaps that aggregate numbers hide.
- **Context makes queries useful.** The best SQL is purposeful SQL.
- **The analyst's job is interpretation, not just execution.** The value comes from understanding what the output means — and what it should prompt next.

---

## What's Next

This analysis is a starting point, not a finish line. The immediate next step would be a deeper readmission study — specifically exploring whether demographic disparities correlate with discharge protocols, follow-up appointment rates, or geographic access to post-acute care.

Questions worth adding to your own analysis:
- What is the 90-day readmission rate, and does it tell a different story than 30 days?
- Are there specific attending physicians or departments driving the fastest — or slowest — outcomes?
- Does insurance type or payer class affect length of stay or readmission risk?

---

## Dataset and Tools

| Item | Detail |
|---|---|
| Dataset | Diabetes 130 US Hospitals, 1999-2008 |
| Tools | SQL |
| Author | Aristotle Polites |
