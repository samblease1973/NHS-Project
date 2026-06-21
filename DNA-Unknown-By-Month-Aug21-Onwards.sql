WITH ar AS 
	(
	SELECT icb_ons_code, appointment_mode, appointment_status, count_of_appointments, appointment_month, appointment_year
	FROM appointments_regional
	WHERE appointment_year = CASE WHEN appointment_month > 7 THEN 2021 ELSE 2022 END
	),
	appt_data AS 
	(
	SELECT icb_ons_code, appointment_mode, SUM(count_of_appointments) AS total_appointments, appointment_month, appointment_year
	FROM appointments_regional
	GROUP BY icb_ons_code, appointment_mode, appointment_month, appointment_year
	)
	
SELECT ar.icb_ons_code, 
	   ar.appointment_mode, 
	   ar.appointment_status, 
	   SUM(CAST(ar.count_of_appointments AS DECIMAL(10,2))) / CAST(total_appointments AS DECIMAL(10,2)) * 100.00 AS percent_dna_appts,
	   CONCAT_WS('-', ar.appointment_year, ar.appointment_month) AS appointment_month
FROM ar
	INNER JOIN appt_data
		ON ar.icb_ons_code = appt_data.icb_ons_code AND
		   ar.appointment_mode = appt_data.appointment_mode AND
		   ar.appointment_month = appt_data.appointment_month AND
		   ar.appointment_year = appt_data.appointment_year
GROUP BY ar.icb_ons_code, ar.appointment_mode, ar.appointment_status, total_appointments, ar.appointment_month, ar.appointment_year
HAVING ar.appointment_status IN ('DNA', 'Unknown')
ORDER BY percent_dna_appts DESC