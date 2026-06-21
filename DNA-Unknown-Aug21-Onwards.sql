WITH ar AS 
	(
	SELECT icb_ons_code, appointment_mode, appointment_status, count_of_appointments
	FROM appointments_regional
	WHERE appointment_year = CASE WHEN appointment_month > 7 THEN 2021 ELSE 2022 END
	),
	appt_data AS 
	(
	SELECT icb_ons_code, appointment_mode, SUM(count_of_appointments) AS total_appointments
	FROM appointments_regional
	GROUP BY icb_ons_code, appointment_mode
	)
	
SELECT ar.icb_ons_code, 
	   ar.appointment_mode, 
	   ar.appointment_status, 
	   SUM(CAST(ar.count_of_appointments AS DECIMAL(10,2))) / CAST(total_appointments AS DECIMAL(10,2)) * 100.00 AS percent_dna_appts   
FROM ar
	INNER JOIN appt_data
		ON ar.icb_ons_code = appt_data.icb_ons_code AND
		   ar.appointment_mode = appt_data.appointment_mode
GROUP BY ar.icb_ons_code, ar.appointment_mode, ar.appointment_status, total_appointments
HAVING ar.appointment_status IN ('DNA', 'Unknown')
ORDER BY percent_dna_appts DESC