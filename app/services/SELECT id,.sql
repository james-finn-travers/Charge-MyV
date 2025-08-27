SELECT id,
       name,
       address,
       latitude,
       longitude,
       connector_types,
       power_output,
       is_operational,
       created_at,
       updated_at
FROM public.charging_stations
LIMIT 1000;