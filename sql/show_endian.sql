SELECT t.endian_format
FROM v$transportable_platform t, v$database d
WHERE t.platform_name = d.platform_name;
