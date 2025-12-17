-- Create a new database called all_data_set
CREATE DATABASE all_data_set;

-- create bronze table from imported data, and view the bronze table
SELECT *
FROM bronze_layer;

-- create silver table from imported data, and view the silver table
SELECT *
FROM silver_layer;

-- create the facility table
CREATE TABLE `silver_facility` (
  `facility_id` INT,
  `facility_name` VARCHAR(255),
  `facility_address` VARCHAR(255),
  `facility_type` VARCHAR(100),
  `managing_authority` VARCHAR(100),
  `respondent_role` VARCHAR(100),
  `rural_urban` VARCHAR(50),
  `available_healthcare_workers` VARCHAR(150),
  `daily_hours` INT,
  `days_open_in_week` VARCHAR(150),
  `patients_admitted_3_months` INT,
  `patients_admitted_yesterday` INT,
  `no_patients_3_months` INT,
  PRIMARY KEY (`facility_id`)
);


-- insert selected columns into the silver_facility table
INSERT INTO silver_facility
SELECT
`facility id`,
`Facility name`,
`Facility address`,
`facility type`,
`managing authority`,
`respondent role`,
`ï»¿Rural/urban`,
`Available healthcare workers`,
`daily hours`,
`days open in week`,
`patients admitted 3 months`,
`patients ad yesterday`,
`no patients 3 mos`
FROM silver_layer;

-- view silver_facility table
SELECT *
FROM silver_facility;

-- create silver infastructure table
CREATE TABLE `silver_infrastructure` (
    `infrastructure_id` INT NOT NULL PRIMARY KEY,
    `facility_id` INT NOT NULL,
    `generator_available` VARCHAR(10),
    `solar_available` VARCHAR(10),
    `electricity_available` VARCHAR(10),
    `toilet_available` VARCHAR(10),
    `facility_signpost` VARCHAR(10),
    `water_source` VARCHAR(100),
    `is_facility_fenced` VARCHAR(50),
    `functional_toilet_numbers` INT,
    `toilet_numbers` INT,
    `access_to_national_grid` VARCHAR(10),
    `room_numbers` INT,
    `staff_accommodation` VARCHAR(10),
    `telecom_presence` VARCHAR(10),
    FOREIGN KEY (`facility_id`) REFERENCES `silver_facility`(`facility_id`)
);

-- insert our columns into silver infastructure table
INSERT INTO silver_infrastructure
SELECT
    `infastructure_id`,
    `facility id`,
    `generator available?`,
    `solar available?`,
    `electricity available?`,
    `Toilet available?`,
    `facility signpost?`,
    `water soucre`,
    `Is facility fenced?`,
    `functional toilet numbers`,
    `Toilet numbers`,
    `access to national grid`,
    `room numbers`,
    `staff accom`,
    `telecom presence`
FROM silver_layer;

-- veiw the silver infrastructure
SELECT *
FROM silver_infrastructure;

-- create silver equipment table
CREATE TABLE silver_equipment (
    facility_id INT NOT NULL,
    functional_baby_cots INT,
    functional_beds INT,
    functional_delivery_couches INT,
    functional_incubators INT,
    functional_maternity_beds INT,
    fan_possession VARCHAR(10),
    FOREIGN KEY (facility_id) REFERENCES silver_facility(facility_id)
);

-- insert our column into silver equipment table
INSERT INTO silver_equipment
SELECT
    `facility id`,
    `no fun baby cots`,
    `no of funct bed`,
    `no of fuct delv couches`,
    `Number of functional incubators`,
    `Number of functional maternity beds`,
    `Possession of fan by health facility`
FROM silver_layer;

-- to call our saved procedure for silver to warehouse
CALL load_silver_to_warehouse();

-- review view_bed_analysis
SELECT * 
FROM view_bed_analysis;

-- review view_equipment_capacity_analysis
SELECT * 
FROM view_equipment_capacity_analysis;

-- review view_rural_urban_performance
SELECT *
FROM view_rural_urban_performance;

-- review gold_facility_equipment_summary
SELECT * 
FROM gold_facility_equipment_summary;

SELECT *  
FROM gold_facility_equipment_summary        
WHERE managing_authority = 'Private';

SELECT *
FROM gold_facility_equipment_summary
WHERE managing_authority = 'Government - Public';

SELECT *
FROM gold_facility_equipment_summary
WHERE managing_authority = 'Faith Based Organisation';

SELECT *
FROM gold_facility_equipment_summary
WHERE managing_authority = 'Government - Not Public (Military, etc)';

SELECT *
FROM gold_facility_equipment_summary
WHERE managing_authority = 'NGO';

SELECT *
FROM gold_facility_equipment_summary
WHERE managing_authority = 'Community';
