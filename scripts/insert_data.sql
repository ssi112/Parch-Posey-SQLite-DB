/*
 * insert_data.sql
 * tried importing other data files into tables directly using
 * SQLite Studio but too buggy to be worth the effort
 *  - other files have their own scripts -
 */

INSERT INTO region (id, name)
VALUES (1, 'Northeast'),
       (2, 'Midwest'),
       (3, 'Southeast'),
       (4, 'West');

INSERT INTO sales_reps (id, name, region_id)
VALUES
(321500,  'Samuel Racine',  1),
(321510,  'Eugena Esser',   1),
(321520,  'Michel Averette',  1),
(321530,  'Renetta Carew',  1),
(321540,  'Cara Clarke',  1),
(321550,  'Lavera Oles',  1),
(321560,  'Elba Felder',  1),
(321570,  'Shawanda Selke',   1),
(321580,  'Sibyl Lauria',   1),
(321590,  'Necole Victory',   1),
(321600,  'Ernestine Pickron',  1),
(321610,  'Ayesha Monica',  1),
(321620,  'Retha Sears',  1),
(321630,  'Julia Behrman',  1),
(321640,  'Tia Amato',  1),
(321650,  'Akilah Drinkard',  1),
(321660,  'Silvana Virden',   1),
(321670,  'Nakesha Renn',   1),
(321680,  'Elna Condello',  1),
(321690,  'Gianna Dossey',  1),
(321700,  'Debroah Wardle',   1),
(321710,  'Sherlene Wetherington',  2),
(321720,  'Chau Rowles',  2),
(321730,  'Carletta Kosinski',  2),
(321740,  'Charles Bidwell',  2),
(321750,  'Cliff Meints',   2),
(321760,  'Delilah Krum',   2),
(321770,  'Kathleen Lalonde',   2),
(321780,  'Julie Starr',  2),
(321790,  'Cordell Rieder',   2),
(321800,  'Earlie Schleusner',  3),
(321810,  'Moon Torian',  3),
(321820,  'Dorotha Seawell',  3),
(321830,  'Maren Musto',  3),
(321840,  'Vernita Plump',  3),
(321850,  'Calvin Ollison',   3),
(321860,  'Saran Ram',  3),
(321870,  'Derrick Boggess',  3),
(321880,  'Babette Soukup',   3),
(321890,  'Nelle Meaux',  3),
(321900,  'Soraya Fulton',  4),
(321910,  'Brandie Riva',   4),
(321920,  'Marquetta Laycock',  4),
(321930,  'Hilma Busick',   4),
(321940,  'Arica Stoltzfus',  4),
(321950,  'Elwood Shutt',   4),
(321960,  'Maryanna Fiorentino',  4),
(321970,  'Georgianna Chisholm',  4),
(321980,  'Micha Woodford',   4),
(321990,  'Dawna Agnew',  4);