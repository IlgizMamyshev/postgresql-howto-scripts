--https://habr.com/ru/company/hflabs/blog/333736/

/*
Структура кода
    СС РРР ГГГ ППП АА — 13 цифр
    СС РРР ГГГ ППП УУУУ АА — 17 цифр
    СС РРР ГГГ ППП УУУУ ДДДД — 19 цифр
где
    СС – код субъекта Российской Федерации (региона), коды регионов представлены в Приложении 2 к описанию КЛАДР
    РРР – код района
    ГГГ – код города
    ППП – код населенного пункта
    УУУУ – код улицы
    АА – признак актуальности адресного объекта
*/

CREATE DOMAIN kladr AS text CHECK(octet_length(VALUE) IN (13, 17, 19) AND VALUE ~ '^\d+$');

COMMENT ON DOMAIN kladr IS 'Идентификатор КЛАДР';

--TEST
select '1234567890123'::kladr; --ok
select '78000000000172700'::kladr; --ok
select '1234567890123456789'::kladr; --ok

select '1234567890'::kladr; --error
