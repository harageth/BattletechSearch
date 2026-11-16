-- Combat vehicles' transport bays (Copilot on PR #26; user, 2026-11-15). The reader stored a vehicle's first
-- <transporters> line as an Infantry Bay, whatever it was, and dropped the other lines; it now stores each line
-- as its own bay with its tons (TransportBay). V3_22 renamed the stored bays Infantry Compartment (troop space,
-- MegaMek's name) and added the support vehicles with the right bays; this fixes the combat vehicles.
--
-- Generated like V3_22, from the vehicles re-imported with the new reader (mm-data at
-- d195e171b3c87801c8dbc5ffcb5f763e5da57483) compared with the database before. 131 vehicles (113 Tank, 18 Vtol)
-- change:
--   - 67 had only the battle armor handles every combat vehicle has, which MegaMek doesn't load as a bay, and
--     lose their Infantry Compartment
--   - the others get one item per bay: 89 Cargo Bays and 5 Insulated Cargo Bays that were stored as an
--     infantry bay or dropped, next to their Infantry Compartments
-- No other item or unit changes. A vehicle is only changed while its stored bays differ from these, so a
-- database that already re-imported the vehicles keeps its rows.
--
-- The unit data comes from MegaMek (https://megamek.org), licensed CC BY-NC-SA 4.0.
-- Data migrations after V3_8 update what's stored; see the importers skill.

CREATE TEMPORARY TABLE v3_25_vehicle (megamek_uuid uuid);
CREATE TEMPORARY TABLE v3_25_bay (megamek_uuid uuid, name varchar(255), tech varchar(255), omni_pod boolean,
    tonnage double precision);

-- the vehicles whose bays change
COPY v3_25_vehicle (megamek_uuid) FROM stdin;
019f583e-e26a-73f7-8c4d-f127e7c31821
019f583e-e26c-74a3-940a-2d94c48f64b5
019f583e-e26d-7725-80b1-4a6750459beb
019f583e-e280-7fca-bdb8-a0613c781a62
019f583e-e2a0-75c8-8389-1d9f13f7576d
019f583e-e2a8-751c-80a0-fddf718c8945
019f583e-e2a9-7c03-b86f-77b9fde5ffc6
019f583e-e2aa-7bd7-8fd2-8438c1749840
019f583e-e2ac-7c60-b90c-c2d02d14e88b
019f583e-e2c9-7b65-a6da-bf1e629851d5
019f583e-e2ce-7330-a8ac-401e2f40caf2
019f583e-e2f0-7781-a4e5-f065768eb9a4
019f583e-e30b-7fef-920f-25157baa62d0
019f583e-e31d-7e62-a38a-0d1550c410f8
019f583e-e31f-7493-af24-01170d11cbc9
019f583e-e322-7d62-b21b-2fda10c3e9c3
019f583e-e376-78d2-b501-d577ae4e87e1
019f583e-e3da-7164-98b2-e8724bdcb2ed
019f583e-e417-7904-a8fe-15dbe8834a55
019f583e-e458-7750-88d8-191c484693d1
019f583e-e475-7031-8ec2-2882045f2b28
019f583e-e4c3-7964-a1b5-397675cbed34
019f583e-e4d7-71dd-869c-4edb92211530
019f583e-e4d9-75ec-8603-fb2bbb918f7b
019f583e-e4db-771b-beed-469057b40890
019f583e-e4dd-7542-9f03-a8396e206572
019f583e-e4df-74e1-9b9a-bde3711c7391
019f583e-e4e2-7e2f-9598-34f3a57c066b
019f583e-e4e4-7537-b85b-39c0e34e7270
019f583e-e4e8-786b-a240-b4a2033173e9
019f583e-e4e9-74e5-b0a2-7d724710657c
019f583e-e4f8-7b4e-8095-41386d4add8f
019f583e-e544-78f3-8969-4f9904b87afd
019f583e-e546-7b4c-821c-0073733de2c5
019f583e-e547-7d51-aded-d83fd4e8bad5
019f583e-e54a-758b-868b-384a2136cf06
019f583e-e54c-7fa6-8ff8-8fb95d92f6b9
019f583e-e54e-729d-a83b-04bd1602aec3
019f583e-e54f-7f74-941f-88a1f91391ba
019f583e-e55e-7f1e-b3d0-55c70dab2df5
019f583e-e561-700f-91ef-c8f67f1304df
019f583e-e575-7ab1-810d-c36b5df460fd
019f583e-e577-71d6-8f4c-524307e777b6
019f583e-e579-7661-a7be-72d66859a0a8
019f583e-e588-7365-8b5b-1b1d13526a0a
019f583e-e58a-77fd-8b46-28e5f5e7e1a2
019f583e-e58d-7317-83bd-fe98af5e09ef
019f583e-e5a4-72ec-a0e3-7c131ddb2d44
019f583e-e5a5-75fe-b446-025cbf2a7bbc
019f583e-e5ae-72a0-bd69-d66acd0d60a5
019f583e-e5b0-7011-8788-76ab4bbd1af9
019f583e-e5ba-7671-96e2-26e7ec292071
019f583e-e5bc-7dc4-8bfe-04f58f4501cf
019f583e-e5cc-7172-bd84-6c88374d3c5d
019f583e-e5cd-7db8-9d5b-40f0e758763e
019f583e-e5ce-7dc1-8022-0194107cf600
019f583e-e5e9-765c-a2e5-7159829cd952
019f583e-e5eb-7780-83f8-b460a261464f
019f583e-e5ec-7c9b-9562-779612721829
019f583e-e5ef-767f-8341-b70be6267a06
019f583e-e5f1-7e1e-9c7c-ba6864d5cfd4
019f583e-e5f4-7c93-ac53-e3167abcf54b
019f583e-e611-7ae3-b68c-f881b36648c6
019f583e-e617-721c-81d0-49102a3d6fff
019f583e-e61d-7d66-96d9-c2be7956d4fb
019f583e-e68c-7e03-91b2-82e3b7d69409
019f583e-e693-7d3f-a5a3-93c4aacfe86e
019f583e-e70d-79f0-afba-ede259b27f43
019f583e-e711-7f78-b02f-06a7851871f7
019f583e-e712-7421-adce-e3237b5172d7
019f583e-e717-7159-8d75-1c8479267860
019f583e-e72d-7c97-8533-361a8ee2926a
019f583e-e75f-716d-8a83-89bfd00a8724
019f583e-e78e-73e7-a4cf-c9fac8b7e5cd
019f583e-e797-7d1c-af4d-f859f223fc85
019f583e-e7bd-72fa-a2ef-b2524f0a1308
019f583e-e7bf-7403-8d4a-c34a169f6aad
019f583e-e7c0-7eed-917e-d88b11a1a3ce
019f583e-e7c2-71ad-8b48-ebf334e9e98c
019f583e-e7c5-7126-b7d7-f5af77be0c25
019f583e-e802-7747-a3f5-dfe8beeee72c
019f583e-e839-7350-b7b5-1e9e5f528e64
019f583e-e841-7121-9b5d-9eb9a164e358
019f583e-e877-72af-829d-f47fdbc2db8f
019f583e-e878-7782-ba9b-62298da65ebf
019f583e-e87a-7efc-85fc-1cfcc84d9296
019f583e-e87b-7c9b-b199-57b8af1137ff
019f583e-e87d-7072-b94d-9cc95b6b8013
019f583e-e87f-7bbb-b8fa-c1a991769ea8
019f583e-e880-72a9-8cb5-ca25a3bb9e1e
019f583e-e882-79ba-872d-a5d40891a63f
019f583e-e885-7f47-a157-f42cb62a48d3
019f583e-e887-7289-85c2-e7e606d408a2
019f583e-e889-73ec-b645-5b916dfe38c2
019f583e-e896-7166-977d-2d26817bffe6
019f583e-e898-7099-93ac-eff1684533e0
019f583e-e89b-7612-b846-ac86fd362ddf
019f583e-e8e9-78ee-8a08-fcd478a79fab
019f583e-e9a0-7c5f-a833-c28d7f84e8e5
019f583e-e9ae-7f9a-b943-8ba60675187d
019f583e-e9af-7be5-87fd-adfb9ba0d434
019f583e-e9b0-7a39-9467-301a32894be5
019f583e-e9b3-7bfd-bc96-26a81db8a726
019f583e-e9b4-7121-9f1b-2fb899d0cb02
019f583e-e9bc-7604-8b01-53383093b165
019f583e-e9bd-7e50-85a5-99fb0c456d79
019f583e-e9d5-7c58-8157-8a9860654987
019f583e-e9dd-7b81-b940-c65ecff062fc
019f583e-e9e0-7d12-885c-631247a86191
019f583e-e9e1-7470-9400-14732edc3430
019f583e-e9e3-7d33-8334-8dfbe99642ef
019f583e-e9e4-7481-bb5c-b3a53a931ff0
019f583e-e9ec-7b7e-b5cc-626405b56fba
019f583e-e9ed-7451-9763-a72536f99834
019f583e-e9ef-7c60-8a1b-ac0bd706bf5b
019f583e-e9f0-76c2-81e7-da784e6aa2b9
019f583e-e9f1-7885-baf3-4d50f79fb6c0
019f583e-e9f3-7fca-88fc-32a681ac80f5
019f583e-ea5a-7d24-9cd6-edd3414eb4ea
019f583e-ea88-7399-8bfd-a0dda617c17a
019f583e-eba0-7e85-96b0-0120ca9be2cc
019f583e-eba2-7c45-adb4-373d242b5950
019f583e-ebd0-7d5d-b967-89609fb4de53
019f583e-ebfa-7f3a-b14f-4d595f39441f
019f583e-ebff-7bd6-ae28-038f8e1c20d4
019f583e-ec12-75a0-9e3a-3a743e475dfa
019f583e-ec16-7fdc-bb4f-2503ddbfe431
019f583e-ec66-74a5-be46-512ab4154ab1
019f583e-ec68-7175-806b-fe28fc8cb55d
019f583e-ec69-7574-8aaf-d4382fadfbeb
019f583e-ec6c-76d8-820b-88d91b669155
\.

-- and their bays (none for those that only have battle armor handles)
COPY v3_25_bay (megamek_uuid, name, tech, omni_pod, tonnage) FROM stdin;
019f583e-e26a-73f7-8c4d-f127e7c31821	insulatedcargobay	INNER_SPHERE	f	4.35
019f583e-e26c-74a3-940a-2d94c48f64b5	insulatedcargobay	INNER_SPHERE	f	1.74
019f583e-e26c-74a3-940a-2d94c48f64b5	insulatedcargobay	INNER_SPHERE	f	4.35
019f583e-e26d-7725-80b1-4a6750459beb	insulatedcargobay	INNER_SPHERE	f	2.175
019f583e-e26d-7725-80b1-4a6750459beb	insulatedcargobay	INNER_SPHERE	f	5.655
019f583e-e280-7fca-bdb8-a0613c781a62	cargobay	INNER_SPHERE	f	2.5
019f583e-e2a0-75c8-8389-1d9f13f7576d	cargobay	INNER_SPHERE	f	15.5
019f583e-e2a8-751c-80a0-fddf718c8945	cargobay	INNER_SPHERE	f	3
019f583e-e2a9-7c03-b86f-77b9fde5ffc6	cargobay	INNER_SPHERE	f	3
019f583e-e2aa-7bd7-8fd2-8438c1749840	cargobay	INNER_SPHERE	f	8
019f583e-e2ac-7c60-b90c-c2d02d14e88b	cargobay	INNER_SPHERE	f	3
019f583e-e2c9-7b65-a6da-bf1e629851d5	cargobay	INNER_SPHERE	f	0.5
019f583e-e2ce-7330-a8ac-401e2f40caf2	cargobay	INNER_SPHERE	f	0.5
019f583e-e2f0-7781-a4e5-f065768eb9a4	cargobay	INNER_SPHERE	f	12
019f583e-e30b-7fef-920f-25157baa62d0	cargobay	INNER_SPHERE	f	1
019f583e-e31d-7e62-a38a-0d1550c410f8	cargobay	INNER_SPHERE	f	3
019f583e-e31f-7493-af24-01170d11cbc9	cargobay	INNER_SPHERE	f	2
019f583e-e322-7d62-b21b-2fda10c3e9c3	cargobay	INNER_SPHERE	f	0.5
019f583e-e376-78d2-b501-d577ae4e87e1	cargobay	INNER_SPHERE	f	0.5
019f583e-e3da-7164-98b2-e8724bdcb2ed	infantrycompartment	INNER_SPHERE	t	4
019f583e-e3da-7164-98b2-e8724bdcb2ed	infantrycompartment	INNER_SPHERE	f	4
019f583e-e417-7904-a8fe-15dbe8834a55	cargobay	INNER_SPHERE	f	0.5
019f583e-e458-7750-88d8-191c484693d1	cargobay	INNER_SPHERE	f	1
019f583e-e458-7750-88d8-191c484693d1	cargobay	INNER_SPHERE	f	1
019f583e-e458-7750-88d8-191c484693d1	cargobay	INNER_SPHERE	f	1
019f583e-e458-7750-88d8-191c484693d1	cargobay	INNER_SPHERE	f	1
019f583e-e458-7750-88d8-191c484693d1	cargobay	INNER_SPHERE	f	1
019f583e-e458-7750-88d8-191c484693d1	cargobay	INNER_SPHERE	f	1
019f583e-e458-7750-88d8-191c484693d1	cargobay	INNER_SPHERE	f	1
019f583e-e475-7031-8ec2-2882045f2b28	cargobay	CLAN	f	17
019f583e-e4c3-7964-a1b5-397675cbed34	cargobay	INNER_SPHERE	f	10
019f583e-e4e4-7537-b85b-39c0e34e7270	cargobay	INNER_SPHERE	f	1
019f583e-e4e4-7537-b85b-39c0e34e7270	cargobay	INNER_SPHERE	f	1
019f583e-e4e4-7537-b85b-39c0e34e7270	cargobay	INNER_SPHERE	f	1
019f583e-e4e4-7537-b85b-39c0e34e7270	cargobay	INNER_SPHERE	f	1
019f583e-e4e8-786b-a240-b4a2033173e9	cargobay	INNER_SPHERE	f	1
019f583e-e4e8-786b-a240-b4a2033173e9	cargobay	INNER_SPHERE	f	1
019f583e-e4e8-786b-a240-b4a2033173e9	cargobay	INNER_SPHERE	f	1
019f583e-e4e8-786b-a240-b4a2033173e9	cargobay	INNER_SPHERE	f	1
019f583e-e4e9-74e5-b0a2-7d724710657c	cargobay	INNER_SPHERE	f	6
019f583e-e4f8-7b4e-8095-41386d4add8f	cargobay	INNER_SPHERE	f	30
019f583e-e5b0-7011-8788-76ab4bbd1af9	cargobay	INNER_SPHERE	t	8
019f583e-e5b0-7011-8788-76ab4bbd1af9	infantrycompartment	INNER_SPHERE	t	4
019f583e-e5bc-7dc4-8bfe-04f58f4501cf	infantrycompartment	INNER_SPHERE	t	8
019f583e-e5cc-7172-bd84-6c88374d3c5d	cargobay	INNER_SPHERE	f	9
019f583e-e5cd-7db8-9d5b-40f0e758763e	cargobay	INNER_SPHERE	f	14
019f583e-e5ce-7dc1-8022-0194107cf600	cargobay	INNER_SPHERE	f	10
019f583e-e5e9-765c-a2e5-7159829cd952	cargobay	INNER_SPHERE	f	1.5
019f583e-e5eb-7780-83f8-b460a261464f	cargobay	INNER_SPHERE	f	2
019f583e-e5ec-7c9b-9562-779612721829	cargobay	INNER_SPHERE	f	1.5
019f583e-e5ef-767f-8341-b70be6267a06	cargobay	INNER_SPHERE	f	1.5
019f583e-e5f1-7e1e-9c7c-ba6864d5cfd4	cargobay	INNER_SPHERE	f	1
019f583e-e5f4-7c93-ac53-e3167abcf54b	cargobay	INNER_SPHERE	f	3
019f583e-e611-7ae3-b68c-f881b36648c6	cargobay	INNER_SPHERE	f	8
019f583e-e617-721c-81d0-49102a3d6fff	cargobay	INNER_SPHERE	f	8
019f583e-e61d-7d66-96d9-c2be7956d4fb	cargobay	INNER_SPHERE	f	0.5
019f583e-e68c-7e03-91b2-82e3b7d69409	cargobay	INNER_SPHERE	f	0.5
019f583e-e693-7d3f-a5a3-93c4aacfe86e	cargobay	CLAN	f	0.5
019f583e-e70d-79f0-afba-ede259b27f43	cargobay	INNER_SPHERE	f	0.5
019f583e-e70d-79f0-afba-ede259b27f43	cargobay	INNER_SPHERE	f	1
019f583e-e70d-79f0-afba-ede259b27f43	cargobay	INNER_SPHERE	f	1
019f583e-e70d-79f0-afba-ede259b27f43	cargobay	INNER_SPHERE	f	1
019f583e-e70d-79f0-afba-ede259b27f43	cargobay	INNER_SPHERE	f	1
019f583e-e711-7f78-b02f-06a7851871f7	cargobay	INNER_SPHERE	f	0.5
019f583e-e711-7f78-b02f-06a7851871f7	cargobay	INNER_SPHERE	f	1
019f583e-e711-7f78-b02f-06a7851871f7	cargobay	INNER_SPHERE	f	1
019f583e-e711-7f78-b02f-06a7851871f7	cargobay	INNER_SPHERE	f	1
019f583e-e711-7f78-b02f-06a7851871f7	cargobay	INNER_SPHERE	f	1
019f583e-e712-7421-adce-e3237b5172d7	cargobay	INNER_SPHERE	f	1
019f583e-e712-7421-adce-e3237b5172d7	cargobay	INNER_SPHERE	f	1
019f583e-e712-7421-adce-e3237b5172d7	cargobay	INNER_SPHERE	f	1
019f583e-e712-7421-adce-e3237b5172d7	cargobay	INNER_SPHERE	f	1
019f583e-e712-7421-adce-e3237b5172d7	cargobay	INNER_SPHERE	f	1
019f583e-e712-7421-adce-e3237b5172d7	cargobay	INNER_SPHERE	f	1
019f583e-e712-7421-adce-e3237b5172d7	cargobay	INNER_SPHERE	f	1
019f583e-e712-7421-adce-e3237b5172d7	cargobay	INNER_SPHERE	f	1
019f583e-e717-7159-8d75-1c8479267860	cargobay	INNER_SPHERE	f	0.5
019f583e-e717-7159-8d75-1c8479267860	cargobay	INNER_SPHERE	f	1
019f583e-e717-7159-8d75-1c8479267860	cargobay	INNER_SPHERE	f	1
019f583e-e717-7159-8d75-1c8479267860	cargobay	INNER_SPHERE	f	1
019f583e-e717-7159-8d75-1c8479267860	cargobay	INNER_SPHERE	f	1
019f583e-e72d-7c97-8533-361a8ee2926a	cargobay	INNER_SPHERE	f	33
019f583e-e75f-716d-8a83-89bfd00a8724	cargobay	INNER_SPHERE	f	0.5
019f583e-e78e-73e7-a4cf-c9fac8b7e5cd	cargobay	INNER_SPHERE	f	18
019f583e-e78e-73e7-a4cf-c9fac8b7e5cd	infantrycompartment	INNER_SPHERE	f	4
019f583e-e797-7d1c-af4d-f859f223fc85	cargobay	INNER_SPHERE	f	5
019f583e-e797-7d1c-af4d-f859f223fc85	infantrycompartment	INNER_SPHERE	f	8
019f583e-e802-7747-a3f5-dfe8beeee72c	infantrycompartment	INNER_SPHERE	f	4
019f583e-e802-7747-a3f5-dfe8beeee72c	infantrycompartment	INNER_SPHERE	t	8
019f583e-e8e9-78ee-8a08-fcd478a79fab	cargobay	INNER_SPHERE	f	1
019f583e-e9a0-7c5f-a833-c28d7f84e8e5	cargobay	INNER_SPHERE	f	0.5
019f583e-e9bc-7604-8b01-53383093b165	cargobay	INNER_SPHERE	f	3
019f583e-e9bd-7e50-85a5-99fb0c456d79	cargobay	INNER_SPHERE	f	1.5
019f583e-e9d5-7c58-8157-8a9860654987	cargobay	INNER_SPHERE	f	0.5
019f583e-ea88-7399-8bfd-a0dda617c17a	cargobay	INNER_SPHERE	f	0.5
019f583e-eba0-7e85-96b0-0120ca9be2cc	cargobay	INNER_SPHERE	f	5.5
019f583e-eba2-7c45-adb4-373d242b5950	cargobay	INNER_SPHERE	f	0.5
019f583e-ebd0-7d5d-b967-89609fb4de53	cargobay	INNER_SPHERE	f	4
019f583e-ebfa-7f3a-b14f-4d595f39441f	cargobay	INNER_SPHERE	f	10
019f583e-ebff-7bd6-ae28-038f8e1c20d4	cargobay	INNER_SPHERE	f	14
019f583e-ebff-7bd6-ae28-038f8e1c20d4	infantrycompartment	INNER_SPHERE	f	4
019f583e-ec12-75a0-9e3a-3a743e475dfa	cargobay	INNER_SPHERE	f	13.5
019f583e-ec16-7fdc-bb4f-2503ddbfe431	cargobay	CLAN	f	5.5
\.

-- the bay items stored now (an "infantrybay" too, where V3_22 couldn't rename it)
CREATE TEMPORARY TABLE v3_25_stored AS
SELECT u.megamek_uuid, ue.id AS item_id, e.name, e.tech, ue.omni_pod, ue.tonnage
FROM v3_25_vehicle v
JOIN unit u ON u.megamek_uuid = v.megamek_uuid
JOIN unit_mech_equipment um ON um.unit_id = u.id
JOIN unit_equipment ue ON ue.id = um.mech_equipment_id
JOIN equipment e ON e.id = ue.equipment_id
WHERE e.name IN ('infantrybay', 'infantrycompartment', 'cargobay', 'liquidcargobay', 'insulatedcargobay',
    'refrigeratedcargobay', 'livestockcargobay', 'crewquarters', 'steeragequarters', 'secondclassquarters',
    'firstclassquarters', 'standardseating', 'pillionseating', 'ejectionseating', 'lightvehiclebay');

CREATE TEMPORARY TABLE v3_25_wrong AS
SELECT DISTINCT megamek_uuid FROM (
    (SELECT megamek_uuid, name, tech, omni_pod, tonnage FROM v3_25_stored
     EXCEPT ALL SELECT megamek_uuid, name, tech, omni_pod, tonnage FROM v3_25_bay)
    UNION ALL
    (SELECT megamek_uuid, name, tech, omni_pod, tonnage FROM v3_25_bay
     EXCEPT ALL SELECT megamek_uuid, name, tech, omni_pod, tonnage FROM v3_25_stored)
) d;

DELETE FROM unit_mech_equipment
WHERE mech_equipment_id IN (SELECT item_id FROM v3_25_stored WHERE megamek_uuid IN (SELECT megamek_uuid FROM v3_25_wrong));
DELETE FROM unit_equipment
WHERE id IN (SELECT item_id FROM v3_25_stored WHERE megamek_uuid IN (SELECT megamek_uuid FROM v3_25_wrong));

CREATE TEMPORARY TABLE v3_25_new AS
SELECT gen_random_uuid() AS id, u.id AS unit_id, e.id AS equipment_id, b.omni_pod, b.tonnage
FROM v3_25_bay b
JOIN v3_25_wrong w ON w.megamek_uuid = b.megamek_uuid
JOIN unit u ON u.megamek_uuid = b.megamek_uuid
JOIN equipment e ON e.name = b.name AND e.tech IS NOT DISTINCT FROM b.tech;

INSERT INTO unit_equipment (id, location, omni_pod, rear_facing, tonnage, turret_equipped, equipment_id)
SELECT id, 'BODY', omni_pod, false, tonnage, false, equipment_id FROM v3_25_new;

INSERT INTO unit_mech_equipment (unit_id, mech_equipment_id)
SELECT unit_id, id FROM v3_25_new;

DROP TABLE v3_25_vehicle, v3_25_bay, v3_25_stored, v3_25_wrong, v3_25_new;
