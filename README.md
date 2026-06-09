# Diabetes 130-Hospital Readmissions — SQL Analysis

## Executive Summary

This project analyzes 136,339 patient encounters across 130 U.S. hospitals (1999–2008) using SQL, with a focus on operational efficiency, clinical resource utilization, and 30-day readmission patterns.

The analysis began with six operational questions from hospital leadership — and identified a seventh that nobody asked for but that has material implications for care quality and equity.

Three material findings emerged:

- Procedure volume strongly correlates with length of stay, but the relationship is nonlinear — patients with 55+ procedures stay 61% longer than those with 25 or fewer, suggesting compounding complexity beyond a threshold.
- 75.6% of patient encounters resolve within 7 days, but the 24.4% that exceed 7 days warrant investigation to distinguish high-acuity cases from process bottlenecks.
- Sub-30-day readmission rates vary meaningfully by race (9.1% to 11.8%), a finding not requested but surfaced proactively — highlighting a potential equity gap in discharge planning or follow-up care access.

---

## Business Questions

The original six questions from hospital leadership, plus one added proactively:

1. Do lab procedure counts differ by race — and does the distribution warrant further investigation?
2. Does higher procedure volume correlate with longer hospital stays?
3. Which medical specialties are most procedure-intensive (avg > 2.5 procedures, 50+ encounters)?
4. Which emergency patients were discharged faster than the average ER stay?
5. Among African American patients and those with increased metformin dosage, how many encounters are in the dataset?
6. What share of patients are discharged within 7 days vs. longer stays?
7. *(Proactive)* Do 30-day readmission rates differ across racial groups?

---

## Data Sources

| Dataset | Description |
|---|---|
| diabetic_data | 136,339 patient encounters from 130 U.S. hospitals, 1999–2008 |
| Source | UCI ML Repository — Diabetes 130-US Hospitals (publicly available, de-identified) |

**Key fields used:**
- Demographics: race, age, admission type
- Clinical: num_lab_procedures, num_procedures, medical_specialty, time_in_hospital
- Medications: metformin dosage flag
- Outcomes: readmitted (< 30 days, > 30 days, or none)

---

## Tools & Skills Used

- **SQL (PostgreSQL):** Aggregations, CASE logic, subqueries, window functions, HAVING filters
- **Analytical approach:** Business question framing, proactive insight generation beyond the stated brief, equity-aware analysis

---

## Key Findings

**1. Lab Procedures by Race**
Average lab procedures per encounter ranged across racial groups. Disparities in procedure counts can reflect disease severity, access patterns, or documentation differences — SQL surfaces the gap; investigation determines the cause.

**2. Procedure Volume vs. Length of Stay**

| Procedure Group | Avg Length of Stay | Patient Count |
|---|---|---|
| Few (25 or fewer) | 3.68 days | 29,337 |
| Average (26–54) | 4.55 days | 79,440 |
| Many (55+) | 5.92 days | 27,562 |

The jump from "average" to "many" is steeper than from "few" to "average" — a nonlinearity that matters for capacity modeling and bed utilization forecasting.

**3. High-Procedure Specialties**
Filtering for specialties with avg procedures > 2.5 and at least 50 encounters surfaces the most resource-intensive clinical areas — relevant for staffing, supply chain, and cost-per-encounter analysis.

**4. Fast-Track Emergency Discharges**
Patients admitted through the emergency department and discharged faster than the average ER stay represent a benchmark cohort — understanding what they have in common can inform discharge protocol improvements.

**5. Targeted Patient Cohorts**
African American patients and those with increased metformin dosage represent specific sub-populations relevant to clinical targeting, research enrollment, and care gap analysis.

**6. 7-Day Discharge Distribution**

| Stay Category | Patient Count | % of Total |
|---|---|---|
| 7 days or fewer | ~103,000 | 75.56% |
| More than 7 days | ~33,339 | 24.44% |

Three-quarters of encounters resolve within a week. Patients staying longer than 7 days should be reviewed to confirm high-acuity necessity vs. discharge process delays.

**7. Sub-30-Day Readmission Rates by Race** *(Proactive finding)*

| Race | Total Encounters | Readmissions | Readmission Rate |
|---|---|---|---|
| AfricanAmerican | 19,210 | 2,263 | 11.78% |
| Caucasian | 76,099 | 8,461 | 11.12% |
| Hispanic | 2,037 | 209 | 10.26% |
| Other | 1,506 | 157 | 10.43% |
| Asian | 641 | 58 | 9.05% |
| Overall | — | — | ~11.2% |

Uneven readmission rates across demographic groups do not establish causation — but they flag a gap that should prompt review of discharge planning effectiveness, follow-up appointment rates, and post-acute care access by population.

---

## Key Business Recommendations

| Priority | Recommendation |
|---|---|
| 📋 Investigate readmission equity gap | The 2.7pp spread in sub-30-day readmission rates warrants a deeper study into discharge protocols and follow-up care access by demographic group |
| 🛏️ Audit 7-day-plus stays | 24.4% of encounters exceed 7 days — distinguish high-acuity necessity from process bottlenecks to identify capacity and cost improvement opportunities |
| 📊 Act on procedure-concentration risk | High-procedure specialties represent concentrated cost and staffing demands; flag for resource planning and efficiency review |
| 🔬 Expand readmission analysis | Next step: correlate readmission rates with discharge protocols, follow-up scheduling rates, and geographic access to post-acute care |

---

## Data Cleaning, Assumptions & Limitations

- Race and medical specialty fields contain '?' values treated as NULL and excluded from group-level aggregations.
- Procedure group thresholds (≤25, 26–54, 55+) are based on approximate tertile distribution of num_lab_procedures in the dataset.
- Readmission rate analysis reflects the full encounter dataset; individual patients may appear multiple times.
- Analysis does not control for confounding variables (e.g., disease severity, insurance type, geographic region) — demographic disparities in readmission rates should not be interpreted as direct evidence of inequitable care without further investigation.
- Dataset covers 1999–2008 and may not reflect current clinical practices or demographic distributions.

---

## Project Structure

```
hospital-readmissions-sql-analysis/
├── 01_exploratory_analysis.sql    # Queries 1–6: operational and efficiency analysis
├── 02_readmission_equity.sql      # Query 7: proactive readmission equity analysis
└── README.md
```
