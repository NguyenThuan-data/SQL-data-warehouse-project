-- =============================================================================
-- Function: fn_parse_human_readable
-- =============================================================================
-- Purpose: 
--     Converts human-readable business numbers (e.g., $1.2B, $500M, 221,000) 
--     into standard DECIMAL values for analytical processing.
-- =============================================================================

CREATE OR REPLACE FUNCTION silver.fn_parse_human_readable(p_str TEXT)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
DECLARE
    v_clean_str TEXT;
    v_multiplier DECIMAL := 1;
    v_num_str TEXT;
BEGIN
    -- Return NULL for N/A or empty strings
    IF p_str IS NULL OR p_str = '' OR p_str = 'N/A' THEN
        RETURN NULL;
    END IF;

    -- 1. Remove currency symbols, commas, spaces, and extra text (like "(Adobe)")
    v_clean_str := REGEXP_REPLACE(p_str, '[$, ]', '', 'g');
    v_clean_str := REGEXP_REPLACE(v_clean_str, '\(.*?\)', '', 'g'); -- Remove parentheses content

    -- 2. Determine multiplier based on suffix
    IF v_clean_str ~* 'T$' THEN
        v_multiplier := 1000000000000;
        v_num_str := SUBSTRING(v_clean_str FROM 1 FOR LENGTH(v_clean_str) - 1);
    ELSIF v_clean_str ~* 'B$' THEN
        v_multiplier := 1000000000;
        v_num_str := SUBSTRING(v_clean_str FROM 1 FOR LENGTH(v_clean_str) - 1);
    ELSIF v_clean_str ~* 'M$' THEN
        v_multiplier := 1000000;
        v_num_str := SUBSTRING(v_clean_str FROM 1 FOR LENGTH(v_clean_str) - 1);
    ELSIF v_clean_str ~* 'K$' THEN
        v_multiplier := 1000;
        v_num_str := SUBSTRING(v_clean_str FROM 1 FOR LENGTH(v_clean_str) - 1);
    ELSE
        v_num_str := v_clean_str;
    END IF;

    -- 3. Final Conversion
    BEGIN
        RETURN v_num_str::DECIMAL * v_multiplier;
    EXCEPTION WHEN OTHERS THEN
        RETURN NULL; -- Safety fallback if conversion fails
    END;
END;
$$;
