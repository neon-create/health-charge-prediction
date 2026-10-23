CREATE DATABASE UrbanNest_Health_Analytics;
USE UrbanNest_Health_Analytics;
SELECT * FROM Insurance_data;
/*Since we have already established that there are duplicates in our data set from the python analysis,
We will first remove the duplicate row to avoid any error in our analysis*/
SELECT age,
	sex,
    bmi,
    children,
    smoker,
    region,
    charges,
	COUNT(*)
FROM Insurance_data
GROUP BY age,sex,bmi,children,smoker,region,charges
HAVING COUNT(*) > 1;

CREATE TABLE cleaned_insurance_data AS
SELECT DISTINCT *
FROM insurance_data;

DROP TABLE Insurance_data;

SELECT age,
	sex,
    bmi,
    children,
    smoker,
    region,
    charges,
	COUNT(*)
FROM cleaned_Insurance_data
GROUP BY age,sex,bmi,children,smoker,region,charges
HAVING COUNT(*) > 1;

/*1. What is the average insurance charge across all patients in the dataset?
Analytical Finding: It Establishes the overall baseline (mean) insurance cost for the entire customer portfolio.
Business Purpose: It Serves as a benchmark line. Any pricing model or subgroup analysis needs this 
overall baseline to determine whether a specific patient segment is above or below average.*/

SELECT 
	ROUND(AVG(charges),2) AS average_charges
FROM cleaned_insurance_data;

/*What is the average insurance charge for male patients versus female patients?
Analytical Finding: It Reveals whether gender alone acts as a direct cost driver in health insurance pricing.
Business Purpose: It Demonstrates that gender has minimal independent effect on 
cost, helping the firm avoid bias or unfair demographic markups.*/

SELECT 
	sex,
    ROUND(AVG(charges),2) AS average_charges_by_sex
FROM cleaned_insurance_data
GROUP BY sex;

/*How many total patients are there in each region (southwest, southeast, northwest, northeast)?
Analytical Finding: It Evaluates sample size distribution across geographic zones.
Business Purpose: It Checks for data balance across regions to ensure market representation before making regional pricing decisions.*/

SELECT all
	region,
    COUNT(*) AS count_of_patient_per_region
FROM cleaned_insurance_data
GROUP BY region
ORDER BY count_of_patient_per_region ASC;

/*Which region has the highest average insurance charge?
Analytical Finding: It Identifies geographic cost disparities across customer regions.
Business Purpose: It Highlights regional cost differences (e.g., higher mean charges in the Southeast due to 
regional health factors or high-cost outliers) so underwriters can set regional risk factors.*/

SELECT 
	region,
	ROUND(AVG(charges),2) AS avg_charges_per_region
FROM cleaned_insurance_data
GROUP BY region
ORDER BY avg_charges_per_region DESC
LIMIT 1;

/*What is the average insurance charge for patients who have children versus patients with no children?
Analytical Finding: It Measures the financial impact of having dependents on overall insurance claims.
Business Purpose: It Determines whether family size requires higher baseline premiums 
or if costs are primarily driven by personal health habits rather than dependents.*/

SELECT 
    CASE 
		WHEN children = 0
			THEN 'Has no children'
		ELSE 'Has children(1 or more)'
    END AS Family_status,
    ROUND(AVG(Charges),2) AS avg_charges   
FROM cleaned_insurance_data
GROUP  BY Family_status;

/*What are the minimum, maximum, and average ages of patients in the dataset?
Analytical Finding: It Shows the demographic age boundary and average age of policyholders.
Business Purpose: It Confirms the population range (e.g., adults aged 18 to 58) and provides a 
reference point for age-based pricing brackets.*/

SELECT 
	MIN(Age) AS minimum_age,
    MAX(Age) AS maximum_age,
    ROUND(AVG(age)) AS avg_age
FROM cleaned_insurance_data;

/*8. How many total patients are smokers, and how many are non-smokers?
Analytical Finding: It Calculates the proportion of high-risk (smoking) vs. low-risk (non-smoking) customers.
Business Purpose: It Evaluates portfolio risk exposure by showing what percentage of customers fall into the highest-cost category.*/

SELECT
	Smoker,
    COUNT(Smoker) AS count_of_patients_by_smoker
FROM cleaned_insurance_data
GROUP BY smoker;

/*How many patients have insurance charges greater than $30,000?
Analytical Finding: It Isolates the high-cost customer segment (extreme tail of the distribution).
Business Purpose: It Helps the analytics team focus on the specific attributes 
(e.g., smoking combined with high BMI) that push a patient into the top expense bracket.*/

SELECT *
FROM cleaned_insurance_data
WHERE charges > 30000;

/*How does BMI category affects average charges
Analytical Finding: Categorizing patients into health tiers (Underweight, Normal, Overweight, Obese) 
reveals that average charges remain relatively flat across lower tiers but surge 
dramatically once patients cross the clinical obesity threshold ($\text{BMI} \ge 30$).
Business Purpose: Helps UrbanNest Health Analytics transition from arbitrary pricing 
formulas to clear, data-driven weight risk brackets for policyholders*/

SELECT
	CASE
		WHEN bmi < 18.5
        THEN 'Underweight'
        WHEN bmi BETWEEN 18.5 AND 24.9
        THEN 'Normal Weight'
        WHEN bmi BETWEEN 25.0 AND 29.0
        THEN 'Overweight'
        ELSE 'Obese'
	END AS bmi_category,
    ROUND(AVG(charges),2) AS avg_charges_by_bmi,
    COUNT(*) AS Patient_count
FROM cleaned_insurance_data
GROUP BY bmi_category
ORDER BY Patient_count DESC;

/*Which age groups have the highest average insurance cost?
Analytical Finding: Categorizing policyholders into age brackets reveals a steady, direct upward progression 
in average medical charges as age increases, with the 50–64 age group consistently incurring the highest average insurance costs.
Business Purpose: It Prevents cross-subsidization in pricing, ensuring younger policyholders receive fair, competitive rates while 
older age tiers generate sufficient pool reserves to cover higher expected payout claims.*/

SELECT
	CASE
		WHEN age BETWEEN 15 AND 29
        THEN '15-29 years'
        WHEN age BETWEEN 30 AND 44
        THEN '30-44 years'
        WHEN age BETWEEN 45 AND 59
        THEN '45-59 years'
        ELSE '60+ years'
	END AS age_category,
    ROUND(AVG(charges),2) AS avg_charges_by_age_category
FROM cleaned_insurance_data
GROUP BY age_category
ORDER BY avg_charges_by_age_category DESC;

/*What is the average insurance charge for smokers vs non-smokers?
Analytical Finding: It establishes smoking status as the single strongest individual 
determinant of high medical bills, dwarfing all demographic variables like gender, region, or family size.
Business Purpose: It Protects company profitability by ensuring high-risk smokers fund their elevated claim 
probabilities while keeping baseline rates affordable for non-smoking clients.*/

SELECT
	smoker,
    ROUND(AVG(charges),2) AS avg_charges_by_smokers
FROM cleaned_insurance_data
GROUP BY smoker;
    