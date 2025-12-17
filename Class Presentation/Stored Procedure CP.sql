-- Drop the procedure if it already exists
DROP PROCEDURE IF EXISTS load_silver_to_warehouse;

DELIMITER $$

CREATE PROCEDURE load_silver_to_warehouse()
BEGIN
    -- Disable foreign key checks to allow truncation
    SET FOREIGN_KEY_CHECKS = 0;

    -- Truncate warehouse tables to refresh data
    TRUNCATE TABLE equipment;
    TRUNCATE TABLE infrastructure;
    TRUNCATE TABLE facility;

    -- Re-enable foreign key checks
    SET FOREIGN_KEY_CHECKS = 1;

    -- ===== FACILITY TABLE =====
    CREATE TABLE IF NOT EXISTS facility (
        facility_id INT PRIMARY KEY,
        facility_name VARCHAR(255),
        facility_address VARCHAR(255),
        facility_type VARCHAR(100),
        managing_authority VARCHAR(100),
        respondent_role VARCHAR(100),
        rural_urban VARCHAR(50),
        available_healthcare_workers VARCHAR(150),
        daily_hours INT,
        days_open_in_week VARCHAR(150),
        patients_admitted_3_months INT,
        patients_admitted_yesterday INT,
        no_patients_3_months INT
    );

    INSERT INTO facility
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

    -- ===== INFRASTRUCTURE TABLE =====
    CREATE TABLE IF NOT EXISTS infrastructure (
        infrastructure_id INT NOT NULL PRIMARY KEY,
        facility_id INT NOT NULL,
        generator_available VARCHAR(10),
        solar_available VARCHAR(10),
        electricity_available VARCHAR(10),
        toilet_available VARCHAR(10),
        facility_signpost VARCHAR(10),
        water_source VARCHAR(100),
        is_facility_fenced VARCHAR(50),
        functional_toilet_numbers INT,
        toilet_numbers INT,
        access_to_national_grid VARCHAR(10),
        room_numbers INT,
        staff_accommodation VARCHAR(10),
        telecom_presence VARCHAR(10),
        FOREIGN KEY (facility_id) REFERENCES facility(facility_id)
    );

    INSERT INTO infrastructure
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

    -- ===== EQUIPMENT TABLE =====
    CREATE TABLE IF NOT EXISTS equipment (
        equipment_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
        facility_id INT NOT NULL,
        functional_baby_cots INT,
        functional_beds INT,
        functional_delivery_couches INT,
        functional_incubators INT,
        functional_maternity_beds INT,
        fan_possession VARCHAR(10),
        FOREIGN KEY (facility_id) REFERENCES facility(facility_id)
    );

    INSERT INTO equipment
    SELECT
        `facility id`,
        `no fun baby cots`,
        `no of funct bed`,
        `no of fuct delv couches`,
        `Number of functional incubators`,
        `Number of functional maternity beds`,
        `Possession of fan by health facility`
    FROM silver_layer;

END$$

DELIMITER ;
