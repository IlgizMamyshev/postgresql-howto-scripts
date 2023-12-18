# Эксперимент по дельта-кодированию числовых массивов в PostgreSQL

```sql
drop table if exists test.delta;

create table test.delta as
with t (t) as (
    -- sorted array, total 343 numbers
    select array[
        2239,41143,43680,46924,49167,105104,109897,112415,115395,122158,148423,172843,174614,190826,194347,196216,212020,
        216878,218739,231989,235215,239120,251962,259141,266870,267111,293828,328461,347700,360731,445181,449105,451722,
        468346,507372,507439,514136,523122,540308,574048,608075,608501,624823,655194,673104,697552,725126,758057,778539,
        799410,800058,808395,825529,838576,893155,900709,910738,960362,967123,973357,985869,986775,993856,998668,1001212,
        1015859,1018501,1026646,1041880,1055876,1069487,1071779,1093113,1102665,1108141,1133656,1191504,1198641,1206195,
        1207352,1215040,1218661,1222112,1223301,1245404,1260137,1268337,1277306,1282015,1283143,1283337,1284715,1302693,
        1335639,1335783,1413998,1416792,1418906,1424272,1426175,1431187,1451974,1457238,1463259,1465193,1468820,1473061,
        1476395,1481640,1486118,1493907,1506640,1523283,1523648,1529316,1533814,1549233,1549655,1555135,1582042,1582430,
        1591238,1591961,1596041,1599835,1607545,1608793,1627732,1628151,1628668,1629622,1630586,1634579,1638847,1639255,
        1656994,1658571,1665138,1671182,1671453,1671760,1676399,1680804,1697482,1705580,1711466,1717020,1718666,1719635,
        1726216,1730900,1731591,1736760,1739926,1744268,1746952,1752044,1757517,1763223,1787537,1802303,1806085,1891049,
        1907172,1911092,1993128,2037791,2038208,2048351,2049630,2094606,2109838,2125609,2141451,2309262,2624088,2647382,
        2771607,2788384,2790848,2814353,2835258,2905416,2930218,2951028,3011300,3073974,3083528,3091224,3101806,3138087,
        3138208,3145823,3150760,3155656,3182615,3192463,3216956,3221593,3224076,3246325,3249113,3281720,3281981,3302396,
        3308804,3323207,3332980,3340524,3383591,3396832,3406748,3414327,3414351,3419535,3420443,3422900,3435395,3436274,
        3443678,3445843,3449080,3449274,3459132,3462558,3470909,3489239,3492043,3498624,3502018,3505700,3508738,3509896,
        3522448,3559049,3562702,3572998,3578771,3579934,3592441,3594351,3596793,3617815,3621520,3630742,3634255,3637422,
        3638327,3639271,3640614,3640668,3642355,3643344,3644263,3644510,3644541,3646778,3648552,3655369,3669775,3670230,
        3671447,3675956,3681473,3684425,3686136,3686551,3687135,3688226,3690596,3691413,3691501,3693492,3694055,3694183,
        3694554,3695411,3696421,3697566,3698336,3699462,3700685,3701211,3703435,3703611,3705073,3706212,3708268,3708585,
        3709014,3709097,3709824,3710373,3710442,3711455,3712649,3712963,3713212,3713996,3714362,3715181,3715960,3717910,
        3718062,3721958,3722553,3722741,3723196,3723283,3724045,3724664,3726072,3726147,3729398,3731129,3732116,3732258,
        3734708,3734871,3734884,3734994,3737495,3737644,3738703,3738771,3738882,3739134,3740457,3741793,3741856,3741917,
        3742105,3742664,3742944,3743140,3743926,3744223,3744693,3745066,3746248,3746818,3755984,3757454
    ]
)
, a (a) as (
    select t --|| t || t
    from t
)
, b as (
    select a,                           ad,
           to_json(a) as a_json,        to_json(ad) as ad_json,
           to_jsonb(a) as a_jsonb,      to_jsonb(ad) as ad_jsonb,
           public.fib_pack(a) as a_fib, public.fib_pack(ad) as ad_fib
    from a
    cross join public.delta_encode(a) as ad
)
select * from b;

select 'fibonacci_bytea' as storage_type,
       pg_column_size(a_fib) as orig_compressed_size,
       pg_column_size(ad_fib) as delta_compressed_size,
       pg_column_size(a_fib::text::bytea) as orig_uncompressed_size,
       pg_column_size(ad_fib::text::bytea) as delta_uncompressed_size
from test.delta
union all
select 'pg_int_array',
       pg_column_size(a),
       pg_column_size(ad),
       pg_column_size(a::text::int[]),
       pg_column_size(ad::text::int[])
from test.delta
union all
select 'json_int_array',
       pg_column_size(a_json),
       pg_column_size(ad_json),
       pg_column_size(a_json::text::json),
       pg_column_size(ad_json::text::json)
from test.delta
union all
select 'jsonb_int_array',
       pg_column_size(a_jsonb),
       pg_column_size(ad_jsonb),
       pg_column_size(a_jsonb::text::jsonb),
       pg_column_size(ad_jsonb::text::jsonb)
from test.delta;
```

| storage\_type     | orig\_compressed\_size | delta\_compressed\_size | orig\_uncompressed\_size | delta\_uncompressed\_size |
|:------------------|-----------------------:|------------------------:|-------------------------:|--------------------------:|
| fibonacci\_bytea  |                    887 |                     773 |                      887 |                       773 |
| pg\_int\_array    |                   1392 |                    1392 |                     1396 |                      1396 |
| json\_int\_array  |                   2376 |                    1578 |                     2679 |                      1717 |
| jsonb\_int\_array |                   2130 |                    2044 |                     5490 |                      4496 |

Отсортированный список чисел (например список идентификаторов) с дельта + Фибоначчи кодированием 
и хранением в `bytea` занимает почти 2 раза меньше места, чем в обычном массиве `int[]`.   