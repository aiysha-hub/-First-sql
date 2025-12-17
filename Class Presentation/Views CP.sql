-- Q1 What is the average number of functional beds per facility, and which facilities fall below the median 
CREATE VIEW view_bed_analysis AS
WITH ranked AS (
    SELECT 
        e.facility_id,
        e.functional_beds,
        ROW_NUMBER() OVER (ORDER BY e.functional_beds) AS rn,
        COUNT(*) OVER () AS total_count
    FROM silver_equipment e
)
SELECT 
    f.facility_name,
    f.facility_type,
    e.functional_beds,
    avg_data.avg_functional_beds,
    median_data.median_functional_beds,
    CASE 
        WHEN e.functional_beds < avg_data.avg_functional_beds THEN 'Below Average'
        ELSE 'Above or Equal Average'
    END AS avg_flag,
    CASE 
        WHEN e.functional_beds < median_data.median_functional_beds THEN 'Below Median'
        ELSE 'Above or Equal Median'
    END AS median_flag
FROM silver_equipment e
JOIN silver_facility f ON e.facility_id = f.facility_id
CROSS JOIN (
    SELECT AVG(functional_beds) AS avg_functional_beds
    FROM silver_equipment
) avg_data
CROSS JOIN (
    SELECT AVG(functional_beds) AS median_functional_beds
    FROM ranked
    WHERE rn IN (FLOOR((total_count+1)/2.0), CEIL((total_count+1)/2.0))
) median_data;

-- Q2
CREATE VIEW view_equipment_capacity_analysis AS
WITH stats AS (
    SELECT
        AVG(functional_beds) AS avg_beds,
        AVG(functional_baby_cots) AS avg_cots,
        AVG(functional_maternity_beds) AS avg_maternity_beds
    FROM silver_equipment
),

facility_stats AS (
    SELECT
        e.facility_id,
        e.functional_beds,
        e.functional_baby_cots,
        e.functional_maternity_beds,
        s.avg_beds,
        s.avg_cots,
        s.avg_maternity_beds
    FROM silver_equipment e
    CROSS JOIN stats s
)

SELECT
    facility_id,
    functional_beds,
    functional_baby_cots,
    functional_maternity_beds,

    CASE 
        WHEN functional_beds > avg_beds THEN 'Above Average'
        WHEN functional_beds < avg_beds THEN 'Below Average'
        ELSE 'Average'
    END AS bed_capacity_position,

    CASE 
        WHEN functional_baby_cots > avg_cots THEN 'Above Average'
        WHEN functional_baby_cots < avg_cots THEN 'Below Average'
        ELSE 'Average'
    END AS baby_cot_position,

    CASE 
        WHEN functional_maternity_beds > avg_maternity_beds THEN 'Above Average'
        WHEN functional_maternity_beds < avg_maternity_beds THEN 'Below Average'
        ELSE 'Average'
    END AS maternity_bed_position

FROM facility_stats
ORDER BY facility_id;

-- Q3 which facilities perform better,rural or urban?
CREATE VIEW view_rural_urban_performance AS
SELECT 
    f.rural_urban,
    SUM(
        CASE 
            WHEN f.patients_admitted_yesterday <= (e.functional_beds + e.functional_maternity_beds) 
            THEN 1 
            ELSE 0 
        END
    ) AS sufficient_beds,
    
    SUM(
        CASE 
            WHEN f.patients_admitted_yesterday > (e.functional_beds + e.functional_maternity_beds) 
            THEN 1 
            ELSE 0 
        END
    ) AS insufficient_beds
FROM silver_facility f
JOIN silver_equipment e 
    ON f.facility_id = e.facility_id
GROUP BY f.rural_urban;

-- Which authorities have facilities missing beds, maternity beds and incubators?
CREATE VIEW gold_facility_equipment_summary AS
SELECT 
    f.managing_authority,
    COUNT(*) AS total_facilities,
    
    -- Functional beds sufficiency
    SUM(IF(e.functional_beds >= 1, 1, 0)) AS facilities_with_beds,
    SUM(IF(e.functional_beds = 0, 1, 0)) AS facilities_without_beds,
    
    -- Functional maternity beds
    SUM(IF(e.functional_maternity_beds >= 1, 1, 0)) AS facilities_with_maternity_beds,
    SUM(IF(e.functional_maternity_beds = 0, 1, 0)) AS facilities_without_maternity_beds,
    
    -- Functional incubators
    SUM(IF(e.functional_incubators >= 1, 1, 0)) AS facilities_with_incubators,
    SUM(IF(e.functional_incubators = 0, 1, 0)) AS facilities_without_incubators,
    
    -- Functional baby cots
    SUM(IF(e.functional_baby_cots >= 1, 1, 0)) AS facilities_with_baby_cots,
    SUM(IF(e.functional_baby_cots = 0, 1, 0)) AS facilities_without_baby_cots,
    
    -- Fan possession
    SUM(IF(e.fan_possession = 'Yes', 1, 0)) AS facilities_with_fans,
    SUM(IF(e.fan_possession = 'No', 1, 0)) AS facilities_without_fans

FROM silver_equipment e
JOIN silver_facility f 
    ON e.facility_id = f.facility_id

GROUP BY f.managing_authority;

