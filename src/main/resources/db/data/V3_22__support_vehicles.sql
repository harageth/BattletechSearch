-- Support vehicles (importers skill, bug 13; user, 2026-11-15): MegaMek's SupportTank, LargeSupportTank and
-- SupportVTOL files, stored as the SupportTank and SupportVtol unit types. Fixed-wing support aircraft wait for
-- an aircraft unit type.
--
-- Generated from a database V3_8 to V3_21 loaded and the vehicles then re-imported with the new reader
-- (mm-data at d195e171b3c87801c8dbc5ffcb5f763e5da57483), by comparing it with the database before:
--   1. 49 equipment no unit had before (chassis mods, infantry weapons, fire control, ...). MegaMek's
--      "Machine Gun (Light)" and "Flamer (Heavy)" are stored as the Light Machine Gun and Heavy Flamer (user,
--      2026-11-15), so they add none.
--   2. 226 units (202 SupportTank, 24 SupportVtol; one more file has no MUL id, importers skill bug 25)
--   3. their 1,481 items
--   4. 139 MegaMek alias terms for the new equipment, and their 143 links
--   5. the Condor Heavy Hover Tank (Fission)'s two sponson flamers: "Flamer (Vehicle)(ST)" was cut at its
--      first bracket and stored as a Flamer; the reader now only takes the mounting note off the end
-- Nothing else changed. Rows are loaded into temporary tables and only what isn't stored yet is added, so a
-- database that already imported support vehicles keeps its own rows. Group memberships are V3_23.
--
-- The unit data comes from MegaMek (https://megamek.org), licensed CC BY-NC-SA 4.0.
-- Data migrations after V3_8 update what's stored; see the importers skill.

CREATE TEMPORARY TABLE v3_22_equipment (LIKE equipment);
CREATE TEMPORARY TABLE v3_22_unit (LIKE unit);
CREATE TEMPORARY TABLE v3_22_item (megamek_uuid uuid, id uuid, location varchar(255), omni_pod boolean,
    rear_facing boolean, tonnage double precision, turret_equipped boolean, name varchar(255), tech varchar(255),
    fire_control varchar(255), jump_boost integer, drones integer, mash_theaters integer);
CREATE TEMPORARY TABLE v3_22_slang (id uuid, term varchar(255), lookup varchar(255), kind varchar(255));
CREATE TEMPORARY TABLE v3_22_link (lookup varchar(255), name varchar(255), tech varchar(255));

-- 1.
COPY v3_22_equipment (id, crit_slots, damage, heat, long_range, medium_range, min_range, name, short_range, tech, tonnage, display_name) FROM stdin;
7bf498c0-a2c1-4b79-8085-39e45d8d87f6	0	\N	0	0	0	0	advancedfirecontrol	0	CLAN	0	Advanced Fire Control
a962053c-25c2-48af-85e8-74c35f526527	0	\N	0	0	0	0	autocannon(bearhuntersuperheavy)	0	CLAN	0	Autocannon (Bearhunter Superheavy)
63d2fb62-c2fe-4f94-9fe9-a6af152f0399	0	\N	0	0	0	0	autocannon(semi-portable)	0	INNER_SPHERE	0	Autocannon (Semi-Portable)
f5f49db9-fe77-40bc-a305-fde9234f1d6e	0	\N	0	0	0	0	auto-rifle(modern,generic)	0	INNER_SPHERE	0	Auto-Rifle (Modern, Generic)
80bad38b-27f4-4ea4-ad4a-b1363ec60121	0	\N	0	0	0	0	basicfirecontrol	0	INNER_SPHERE	0	Basic Fire Control
b24eea47-4be2-41ef-aa52-cbb0e5a9678e	0	\N	0	0	0	0	bridgelayer(heavy)	0	INNER_SPHERE	0	Bridge Layer (Heavy)
229b68d2-017a-4b54-8514-a0f91bac9f06	0	\N	0	0	0	0	cargocontainer(10tons)	0	INNER_SPHERE	0	Cargo Container (10 tons)
88ea0158-29ff-4080-b8ab-d3c288c46d0c	0	\N	0	0	0	0	environmentalsealing	0	INNER_SPHERE	0	Environmental Sealing
20f8b3cb-5240-4daa-b3ce-d16c5a2609dc	0	\N	0	0	0	0	fieldkitchen	0	INNER_SPHERE	0	Field Kitchen
9145e8cc-8653-4deb-9e9d-6199e573e37b	0	\N	0	0	0	0	fluidsuctionsystem(standard)	0	INNER_SPHERE	0	Fluid Suction System (Standard)
62d3eebc-a5cf-490f-85bd-0c4adae9f7c6	0	\N	0	0	0	0	gaussrifle,light(kingdavid)	0	INNER_SPHERE	0	Gauss Rifle, Light (King David)
c410ace5-6fa9-4fdb-ab35-acb0815f49d4	0	\N	0	0	0	0	grenadelauncher(auto)	0	INNER_SPHERE	0	Grenade Launcher (Auto)
18464460-7e8c-4767-9237-03e55f15d2c2	0	\N	0	0	0	0	grenadelauncher(heavy)	0	INNER_SPHERE	0	Grenade Launcher (Heavy)
25d54f09-df3e-4472-b1ff-e4f8f3928944	0	\N	0	0	0	0	ladder	0	INNER_SPHERE	0	Ladder
843f0d3c-b2f6-4bc1-b031-eaa21938d9b0	0	\N	0	0	0	0	laserrifle(mauseriicias)	0	CLAN	0	Laser Rifle (Mauser IIC IAS)
ba103eb7-935d-436a-ab5a-eb4215ccd541	0	\N	0	0	0	0	lifeboat(maritime)	0	INNER_SPHERE	0	Lifeboat (Maritime)
2fbda0f1-da7c-4698-bcbe-1b1672f38f22	0	\N	0	0	0	0	machinegun(semi-portable)	0	INNER_SPHERE	0	Machine Gun (Semi-Portable)
e6968008-4f77-4d98-a97d-3a0b9655a1c6	0	\N	0	0	0	0	machinegun(support)	0	INNER_SPHERE	0	Machine Gun (Support)
1e57c49a-2af7-4c65-97c3-8eace9a834a9	0	\N	0	0	0	0	manipulator(non-mech/non-battlearmor)	0	INNER_SPHERE	0	Manipulator (Non-Mech/Non-BattleArmor)
48bb3bd9-4fd0-44be-9773-487bf5cb4a78	0	\N	0	0	0	0	pintlemount	0	INNER_SPHERE	0	Pintle Mount
dcf015bf-cb2d-470b-ade0-471890f870d9	0	\N	0	0	0	0	plasmarifle(man-portable)	0	INNER_SPHERE	0	Plasma Rifle (Man-Portable)
a8b0918d-aba1-4f39-a1a9-c8b1f838c7a3	0	\N	0	0	0	0	primitiveprototypeautocannon/20	0	INNER_SPHERE	0	Primitive Prototype Autocannon/20
7c6ddb3e-b05c-413c-8b57-7701ea19e7f7	0	\N	0	0	0	0	primitiveprototypeautocannon/20ammo	0	INNER_SPHERE	0	Primitive Prototype Autocannon/20 Ammo
92571437-d757-4884-9c6f-142e7015f70a	0	\N	0	0	0	0	recoillessrifle(heavy)	0	INNER_SPHERE	0	Recoilless Rifle (Heavy)
9cc7a982-6afd-40df-a28d-3cd70c615e17	0	\N	0	0	0	0	satelliteimager(high-resolutionimager)	0	INNER_SPHERE	0	Satellite Imager (High-Resolution Imager)
07b11d6b-7438-4d71-afcf-69dfe2c32162	0	\N	0	0	0	0	satelliteimager(infraredimager)	0	INNER_SPHERE	0	Satellite Imager (Infrared Imager)
8b5389b0-7290-4173-82c7-472bec833d76	0	\N	0	0	0	0	searchlight(handheld)	0	INNER_SPHERE	0	Searchlight (Handheld)
4d14a6b2-f244-4cb3-88d2-b2b7dafe6efb	0	\N	0	0	0	0	sprayer(vehicular)	0	INNER_SPHERE	0	Sprayer (Vehicular)
93dd0cc5-2763-4482-9bd3-a30cc508cb00	0	\N	0	0	0	0	srmlauncher(light)	0	INNER_SPHERE	0	SRM Launcher (Light)
6d159c06-2d55-4d83-b446-01f39a7434e1	0	\N	0	0	0	0	srmlauncher(std,two-shot)	0	INNER_SPHERE	0	SRM Launcher (Std, Two-Shot)
b5215b69-fb61-4f1b-a43e-13c57e4a5a8f	0	\N	0	0	0	0	supportlaser	0	INNER_SPHERE	0	Support Laser
36639265-fe26-4eaa-81ae-78f7c52f7017	0	\N	0	0	0	0	supportlaser(heavy)	0	INNER_SPHERE	0	Support Laser (Heavy)
73e6a5ef-9a30-4f1a-9973-7524fe91fe48	0	\N	0	0	0	0	supportlaser(semi-portable)	0	CLAN	0	Support Laser (Semi-Portable)
7ca751dd-425b-4055-9728-2d7cea48ebba	0	\N	0	0	0	0	svchassismod[amphibious]	0	INNER_SPHERE	0	SV Chassis Mod [Amphibious]
f190d681-20cb-497b-9757-1956ce7bf66d	0	\N	0	0	0	0	svchassismod[bicycle]	0	CLAN	0	SV Chassis Mod [Bicycle]
19b41511-d655-4de1-ba97-108024bbd02d	0	\N	0	0	0	0	svchassismod[bicycle]	0	INNER_SPHERE	0	SV Chassis Mod [Bicycle]
949512c4-9669-481e-adf0-205790be8ae1	0	\N	0	0	0	0	svchassismod[convertible]	0	INNER_SPHERE	0	SV Chassis Mod [Convertible]
4274f63d-2f5c-4e1f-9b04-743a2d1d3a46	0	\N	0	0	0	0	svchassismod[dunebuggy]	0	INNER_SPHERE	0	SV Chassis Mod [Dune Buggy]
d3b8a80e-d77d-40b3-9f27-2d75a2847af7	0	\N	0	0	0	0	svchassismod[hydrofoil]	0	INNER_SPHERE	0	SV Chassis Mod [HydroFoil]
53908e41-b32b-4469-bfca-a071a8ef09c1	0	\N	0	0	0	0	svchassismod[monocycle]	0	INNER_SPHERE	0	SV Chassis Mod [Monocycle]
b7e04872-d798-4096-aab7-b362c2e86b87	0	\N	0	0	0	0	svchassismod[omni]	0	CLAN	0	SV Chassis Mod [Omni]
7acae8d1-d079-49a4-b7be-e37a983ad745	0	\N	0	0	0	0	svchassismod[omni]	0	INNER_SPHERE	0	SV Chassis Mod [Omni]
e4eecf2a-033f-4ab8-bffa-7c52c419155b	0	\N	0	0	0	0	svchassismod[snowmobile]	0	INNER_SPHERE	0	SV Chassis Mod [Snowmobile]
c623272b-a3d1-4198-b556-f487310e0c20	0	\N	0	0	0	0	svchassismod[submersible]	0	INNER_SPHERE	0	SV Chassis Mod [Submersible]
c052bbda-1fb1-49d6-ab64-14305fa4f178	0	\N	0	0	0	0	svchassismod[tractor]	0	INNER_SPHERE	0	SV Chassis Mod [Tractor]
22627664-36b4-404d-9dc4-98ab76cbae5d	0	\N	0	0	0	0	svchassismod[trailer]	0	INNER_SPHERE	0	SV Chassis Mod [Trailer]
904b33fd-ce3a-46c2-9756-e7a64cafe289	0	\N	0	0	0	0	svchassismod[ultra-light]	0	INNER_SPHERE	0	SV Chassis Mod [Ultra-Light]
92736ede-e6ac-48c7-86ca-4ffaba7328dc	0	\N	0	0	0	0	tag(light,man-portable)	0	INNER_SPHERE	0	TAG (Light, Man-Portable)
b295dd4b-40f9-42be-96c8-eb882915ca82	0	\N	0	0	0	0	wire-guidedmissilelauncher	0	INNER_SPHERE	0	Wire-Guided Missile Launcher
\.

INSERT INTO equipment
SELECT v.* FROM v3_22_equipment v
WHERE NOT EXISTS (SELECT 1 FROM equipment e WHERE e.name = v.name AND e.tech IS NOT DISTINCT FROM v.tech);

-- 2.
COPY v3_22_unit (dtype, id, designation, era, bonus_jump, jump, potential_run, potential_walk, run, walk, name, omni, rules_level, tech, weight, weight_class, ejection, heatsink_quantity, tech_type, type, locomotion, myomer, megamek_uuid, mul_id, motive_system, engine_type, engine_tech, engine_rating, armor_type, armor_tech, structure_type, structure_tech, gyro, cockpit, lam_type, quad_vee_motive) FROM stdin;
SupportTank	0caab7a5-73f8-4293-b565-5ab03b764982		\N	0	0	0	0	0	11	Air Car	f	0	INNER_SPHERE	40	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e231-73a2-9055-f7d8459e4f09	3684	Hover	ICE	INNER_SPHERE	440	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	af87b72f-42aa-41df-a7de-817c4731cafa	(NapFind)	\N	0	0	0	0	0	15	Hi-Scout Drone	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e29c-762f-9274-753bb6064e76	1530	Hover	FUEL_CELL	INNER_SPHERE	38	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	aabbb8e6-3483-4d65-840e-e7ea1eb24672	(PathTrak)	\N	0	0	0	0	0	8	Hi-Scout Drone	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e29d-70e8-b0f6-cd3ba2e9a13f	1531	Tracked	ICE	INNER_SPHERE	24	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	cb589512-b610-4585-b95d-357b64e7f607	(Cargo)	\N	0	0	0	0	0	3	Büffel Engineering Support Vehicle VII	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e649-77d4-ab78-f95b76a11762	5475	Tracked	ICE	INNER_SPHERE	210	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	62a49c36-72ca-407c-8d73-e53df0bbabb2	(Reverse)	\N	0	0	0	0	0	3	Büffel Engineering Support Vehicle VII	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e64b-79ec-a027-ca5b2431f0d9	5476	Tracked	ICE	INNER_SPHERE	210	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7b0fd904-61fd-4486-833b-de1f0372e926		\N	0	0	0	0	0	3	Büffel Engineering Support Vehicle VII	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e64d-79ff-af8b-7dd38cde63fd	5477	Tracked	ICE	INNER_SPHERE	210	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9b05bb88-fdb8-4520-a019-2200b741900f		\N	0	0	0	0	0	3	Büffel Engineering Support Vehicle VIII	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e650-7bd6-a664-8080fffc751a	5478	Tracked	ICE	INNER_SPHERE	210	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	fb3f25b5-2f9c-4600-81ea-2b143dc6307d		\N	0	0	0	0	0	2	Dromedary Water Transport	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e653-7a8c-a667-4b6b66b73922	4099	Wheeled	ICE	INNER_SPHERE	300	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ab84545b-8645-4c7d-979b-4c1d189887d2	DeConAid Trailer	\N	0	0	0	0	0	0	HMRV (Hazardous Materials Recovery Vehicle)	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e654-7265-b77a-515a1e7450b2	6961	Tracked	NONE	INNER_SPHERE	0	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c0faa46c-fca5-4939-8faa-e5516d24763b	'Oppie' O-65	\N	0	0	0	0	0	2	HMRV (Hazardous Materials Recovery Vehicle)	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e656-7f3e-8c83-5133b1d91814	4739	Tracked	FUSION	INNER_SPHERE	300	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c6d2950a-e060-4cca-bf39-a3dc5007cdf5	'Oppie' O-66	\N	0	0	0	0	0	2	HMRV (Hazardous Materials Recovery Vehicle)	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e659-75cf-af7e-617b624a12ff	4740	Tracked	FUSION	INNER_SPHERE	300	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c9e951c9-ca23-49c0-a797-937ef769ada3	Salvage Bed	\N	0	0	0	0	0	0	HMRV (Hazardous Materials Recovery Vehicle)	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e65c-7589-805d-1f76e53fc17c	6960	Tracked	NONE	INNER_SPHERE	0	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5f20bd66-3571-457d-8755-0dc5571c2500	JI-50 (Hoist)	\N	0	0	0	0	0	4	Jifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e66a-7f62-809c-937110fabc1b	4405	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	af2829b6-f9ed-4956-9fc2-b6cec6c6ea1c	JI-50 (MG)	\N	0	0	0	0	0	4	Jifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e66e-7939-9125-398d08c4c0f2	4404	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	f71eca1a-89e0-4343-9d5b-6d9e05e2c126	JI-50 (ML)	\N	0	0	0	0	0	4	Jifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e670-7c82-aa18-a995e6e33753	4406	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c8437d2d-eeb8-4b45-80e5-b96aa21bce7e	JI-50 (Q-Vehicle)	\N	0	0	0	0	0	4	Jifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e671-7d35-b57b-ba79e8093ccc	4407	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a9adbd4d-60ab-47a4-8de7-fd1b125ff517	JI-50	\N	0	0	0	0	0	4	Jifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e674-72a3-b6e4-69c5b17f3a1e	4403	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7f18844e-52c6-4dee-93a6-136bf8901807	Mk VII	\N	0	0	0	0	0	3	Merkava Heavy Tank	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e67a-754c-87ea-c8e670768c1e	4628	Tracked	FUSION	INNER_SPHERE	225	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0ad1b363-6411-4d7e-9b26-7c2b5cdad394	(MFB)	\N	0	0	0	0	0	4	Paramour Mobile Repair Vehicle	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e67b-784c-9db5-d6ce76f2fd2c	4788	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4da5dfa3-1620-4885-9eb9-37d9b2ad392b		\N	0	0	0	0	0	4	Paramour Mobile Repair Vehicle	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e67e-781a-8912-e1f77ce45fac	4789	Tracked	FUSION	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ac3800d0-435f-41a6-bc8d-2e16e9ac5bf0		\N	0	0	0	0	0	3	Prometheus Combat Support Bridgelayer	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e688-7bca-a9c5-5ca6c628192e	4872	Tracked	FUSION	INNER_SPHERE	225	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	f46cd2de-89db-4627-84c1-f164ecf20ce0		\N	0	0	0	0	0	3	Nifty Transportable Field Repair Unit	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e68b-75cf-a396-5b8b997fd55f	4716	Tracked	ICE	INNER_SPHERE	180	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ea07774b-3753-4d5c-8ab2-4bb7c3e840ba	A3	\N	0	0	0	0	0	3	Augustus MBT	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e690-77ea-9b93-91c5ffe79fac	154	Tracked	ICE	INNER_SPHERE	225	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	f8329d8d-cfbf-4ffb-8f11-5e46b3b72592	(Original)	\N	0	0	0	0	0	5	J-37 Ordnance Transport	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e6e0-7b06-a615-2b2abbb88cd6	1648	Wheeled	FUSION	INNER_SPHERE	250	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	76237aa2-473c-4738-a9d9-5f80adefa7f1		\N	0	0	0	0	0	5	J-37 Ordnance Transport	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e6e2-7e3e-99a0-16496db45d28	1649	Wheeled	FUSION	INNER_SPHERE	250	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	5203c929-37b7-4f8b-bb4d-736b3e151c33		\N	0	0	0	0	0	6	Tonbo Superheavy Transport	f	0	INNER_SPHERE	56	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e727-7a8f-9e84-a4b0c69276a5	3275	\N	FUSION	INNER_SPHERE	336	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	6b23cf77-daed-4463-b2d7-1245950bba83	(CS)	\N	0	0	0	0	0	7	Trireme Infantry Transport	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e72f-707b-a00a-560fe7270860	3308	\N	FUSION	INNER_SPHERE	420	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	4eb76e99-9b55-4fcf-8269-081db5d4c81b		\N	0	0	0	0	0	6	Trireme Infantry Transport	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e731-7888-8c39-b99da4acf787	3309	\N	FUSION	INNER_SPHERE	360	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	f7a99902-ea67-4b7b-aedd-f726bbcb66cd		\N	0	0	0	0	0	7	Bishop Transport VTOL	f	0	INNER_SPHERE	45	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e806-7a90-a05e-960ee185f5a1	6545	\N	FUEL_CELL	INNER_SPHERE	315	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7c91ce67-fc2a-477a-aa8e-d646975b0fa3		\N	0	0	0	0	0	4	Savior Repair Vehicle	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e813-7306-bd3b-30e5dfae7622	6546	Tracked	FUSION	INNER_SPHERE	240	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c9fab07d-b0fc-4848-82c6-74e900f3436b	A	\N	0	0	0	0	0	14	Boreas Cavalry Hovercraft	t	0	CLAN	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8c7-75f1-8d54-551bf09a0730	9218	Hover	FUEL_CELL	INNER_SPHERE	11	BAR_8	CLAN	STANDARD	CLAN	\N	\N	\N	\N
SupportTank	b75e9bde-36f4-441d-8db0-0f6a7ff5dd7d	B	\N	0	0	0	0	0	14	Boreas Cavalry Hovercraft	t	0	CLAN	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8c9-7cbe-a88f-62c6e42329ad	9219	Hover	FUEL_CELL	INNER_SPHERE	11	BAR_8	CLAN	STANDARD	CLAN	\N	\N	\N	\N
SupportTank	edb47f23-a6c6-4016-89f9-6c9d65bd17b1	(Prime)	\N	0	0	0	0	0	14	Boreas Cavalry Hovercraft	t	0	CLAN	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8cb-7c3a-9c9e-7a217b4325d3	9217	Hover	FUEL_CELL	INNER_SPHERE	11	BAR_8	CLAN	STANDARD	CLAN	\N	\N	\N	\N
SupportTank	f627801e-f9cd-4f99-bd9a-d5a615421034		\N	0	0	0	0	0	9	Hoodling Sensor HoverJeep	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8cd-79f5-ac82-f89dfc20dbee	9220	Hover	FUSION	INNER_SPHERE	45	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	21dde55e-1ed8-41a0-8dca-a6792b09c112		\N	0	0	0	0	0	5	HoverPod	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8cf-7c27-b0c7-b3c22c44e45a	9221	Hover	BATTERY	INNER_SPHERE	1	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	65a8999d-863d-4c8f-8144-9aa0835163ab		\N	0	0	0	0	0	10	JI-002 HoverBike	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d0-7cae-9e0c-25c7f6e835bf	9222	Hover	BATTERY	INNER_SPHERE	7	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c9d79c71-5b95-4e7a-8d09-61eb389fae50		\N	0	0	0	0	0	3	Harpoon ParaSub	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d2-7000-a8c2-9e2a44f5ae51	9230	Submarine	FUEL_CELL	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a6046567-05d7-4d24-bc92-e49ff10f837a		\N	0	0	0	0	0	2	Small Steamer	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d4-7f7c-9235-fa32872c784e	9231	Naval	STEAM	INNER_SPHERE	5	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	c528f72a-0ad8-48e0-801e-d2c126a595dc		\N	0	0	0	0	0	5	HTE Micro-Copter	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d6-7df9-8874-e3dab445ead1	9229	\N	ICE	INNER_SPHERE	0	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	481f822e-42d6-4a1c-937f-7ceb82365994		\N	0	0	0	0	0	6	Assuan Armored Bike	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d8-7171-9fd0-4da83cb95ff1	9223	Wheeled	ICE	INNER_SPHERE	6	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4def1b64-8f7a-4329-a097-a05f17ecf93e		\N	0	0	0	0	0	3	Beast Riot Car	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8d9-715d-abd9-9da2e9f5bc2f	9224	Wheeled	FUSION	INNER_SPHERE	12	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a30fc259-8c82-4c37-b118-00d18f82d1e3		\N	0	0	0	0	0	10	Death Trike	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8da-7f95-b3ef-20609635092b	9225	Wheeled	ICE	INNER_SPHERE	6	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b741cd9a-167f-46de-86ba-90c46f82abb5		\N	0	0	0	0	0	8	Dune Buggy	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8dc-72eb-906e-b0b726970333	9226	Wheeled	ICE	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d668ae40-286c-4041-8d8a-1c0258688a90		\N	0	0	0	0	0	5	Eagre Firefighting ATV	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8dd-766f-9b54-3ee51394b3f1	9227	Wheeled	BATTERY	INNER_SPHERE	4	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c14eed42-0b4f-4177-87cd-f1a60213ee88		\N	0	0	0	0	0	4	Tracked Quad	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8df-7489-87be-783213e374a7	9228	Tracked	ICE	INNER_SPHERE	9	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4b52fbf1-81dc-4460-8352-7c5877d93282		\N	0	0	0	0	0	4	Shackleton AESV	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-e8e0-7156-b045-bfaa36119249	5800	Wheeled	FUSION	INNER_SPHERE	200	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	cc61b632-8977-46b5-91df-e861271aa32e	(Anti-Aircraft)	\N	0	0	0	0	0	3	Estevez MBT	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e8e1-7dce-aea0-a3d6b48c0c03	4138	Tracked	ICE	INNER_SPHERE	240	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9331b15d-ef60-44b5-893e-f0abdd370ff6		\N	0	0	0	0	0	3	Estevez MBT	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e8e5-7b3c-add5-107849771830	4139	Tracked	ICE	INNER_SPHERE	240	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c4d3073a-31a3-4138-b13b-bd6187ccce87	I	\N	0	0	0	0	0	3	Marsden MBT	f	0	INNER_SPHERE	65	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	4602	Tracked	ICE	INNER_SPHERE	195	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	72f6a189-014e-480d-930e-b53b52ccdb9b		\N	0	0	0	0	0	4	Apocalypse World Rover	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8f4-7564-9283-eef7d59681c3	3705	Wheeled	ICE	INNER_SPHERE	8	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1056eded-bc05-44df-b3dc-75f6e1261321	(Command Post)	\N	0	0	0	0	0	6	Generic Expandable Services Vehicle	t	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8f6-7734-b7fd-8bec3772bda2	9582	Wheeled	FUEL_CELL	INNER_SPHERE	180	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	fa3336e5-b8f1-4d9d-9e4b-b03d348c802b	(Field Kitchen)	\N	0	0	0	0	0	6	Generic Expandable Services Vehicle	t	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8f7-7f4d-b7a0-d300976b8c70	9583	Wheeled	FUEL_CELL	INNER_SPHERE	180	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b7e3e2ae-4a5f-4b8b-adf6-78c65981c2a8	(MASH)	\N	0	0	0	0	0	6	Generic Expandable Services Vehicle	t	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8f9-7e9f-8ef5-1ba56493b1fe	9585	Wheeled	FUEL_CELL	INNER_SPHERE	180	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	31819806-7da0-43fa-91b8-0c5c0c79a6ae	(Bunk)	\N	0	0	0	0	0	0	Generic Expandable Services Vehicle Trailer	t	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8fa-705c-a86e-641d91a256aa	9586	Wheeled	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a9895cec-9b03-429c-bb9e-1678c3ea6c90	(Cargo)	\N	0	0	0	0	0	0	Generic Expandable Services Vehicle Trailer	t	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8fc-7622-afeb-8df8291b40c6	9587	Wheeled	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	dafa9344-7b1c-4c0b-936f-77f01155bebd		\N	0	0	0	0	0	4	Heavy Combat ATV	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8fd-7e7e-a398-e9a547d14830	4831	Wheeled	ICE	INNER_SPHERE	2	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	3873b5d5-82f7-46b1-934c-d0a79aee8bea		\N	0	0	0	0	0	5	Obuzaabaa Tactical Vehicle	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e8ff-7c25-89b0-57a8dae3ae7d	7771	Wheeled	FUEL_CELL	INNER_SPHERE	125	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4e3671a2-bc4c-4881-bf9e-288ce4ec2536		\N	0	0	0	0	0	5	Sasayaku Control Transport	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e900-7dd6-97b8-dcea7bba7a3e	7772	Wheeled	FUEL_CELL	INNER_SPHERE	125	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	974a32b2-0a62-43ed-a086-95c93789e0ba		\N	0	0	0	0	0	7	Apple-Churchill Surveillance VTOL	f	0	INNER_SPHERE	20	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e902-71ce-9cc5-05cb327cd5c8	3708	\N	ICE	INNER_SPHERE	140	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	fd26cc32-de24-4509-9da9-5209a04eac7d		\N	0	0	0	0	0	11	C-85 Sprinter Delivery Vehicle	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e904-79eb-b552-460ed6242c3c	3931	Wheeled	BATTERY	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ac4ad626-1a9a-4dd8-b15d-4ff9db55e7de		\N	0	0	0	0	0	4	Hector Road Train Tractor	f	0	INNER_SPHERE	160	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e906-700d-b94b-51df5ac8b568	4285	Wheeled	ICE	INNER_SPHERE	500	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	63caf0a1-d6fb-4c7a-8943-7cc96f7232a0	(Liquid)	\N	0	0	0	0	0	0	Hector Road Train Trailer Module	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e907-7d40-b85a-70a5c8b4fc5f	4287	Wheeled	NONE	INNER_SPHERE	0	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0cc70700-ff96-4698-b9ed-ec951240a704	(Livestock)	\N	0	0	0	0	0	0	Hector Road Train Trailer Module	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e90a-7725-ae3b-6fd6beb2e32d	4288	Wheeled	NONE	INNER_SPHERE	0	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	32ebc5e8-0fb7-41db-8a95-4039afef4438	(Passenger)	\N	0	0	0	0	0	0	Hector Road Train Trailer Module	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e90d-750f-82f4-4ae3cd916c2a	4289	Wheeled	NONE	INNER_SPHERE	0	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b27616ab-3298-4ab5-abd8-6f5336cc6aeb	(Refrigerated)	\N	0	0	0	0	0	0	Hector Road Train Trailer Module	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e90f-72ae-873e-3d4014ac2ff3	4290	Wheeled	NONE	INNER_SPHERE	0	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b6f72dfb-0bc9-4974-b980-5dcbf68f5ac7		\N	0	0	0	0	0	0	Hector Road Train Trailer Module	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-e910-7643-8852-814c6e90b4f0	4286	Wheeled	NONE	INNER_SPHERE	0	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	f9a12e16-a8fd-4ea5-8628-5fe0034669fb	(Militarized:Gauss)	\N	0	0	0	0	0	5	Ibex RV	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e913-7389-a648-0624c05f2f44	4355	Wheeled	ICE	INNER_SPHERE	10	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	3454b820-f310-4b67-947b-8294144ccaa9	(Militarized:MG)	\N	0	0	0	0	0	5	Ibex RV	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e914-7693-8724-943128800a78	4356	Wheeled	ICE	INNER_SPHERE	10	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	150ff9ed-0a64-4346-b42d-e94e34b052c0		\N	0	0	0	0	0	5	Ibex RV	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e915-7783-b5dc-1e16b1dfac0c	4357	Wheeled	ICE	INNER_SPHERE	10	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	3195fe76-4797-4510-b8c4-5d57a91a7e01		\N	0	0	0	0	0	3	Wayland Mobile Base	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e92c-7ea8-8f09-e39bc182cda4	5396	Tracked	FUSION	INNER_SPHERE	450	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	aac5b0e8-a0f4-44bc-af51-11c6838bff58	(AC)	\N	0	0	0	0	0	3	Brunel Dump Truck	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e935-70b2-ba3e-07e18e7145bf	3864	Wheeled	ICE	INNER_SPHERE	450	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	67c87d2b-ebe5-4eca-8488-397df89a8c27	(LRM)	\N	0	0	0	0	0	3	Brunel Dump Truck	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e937-74b5-b408-3a549695a9ad	3865	Wheeled	ICE	INNER_SPHERE	450	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	28ffac03-e2ef-434d-bc9a-a1dd51856120	(Production)	\N	0	0	0	0	0	12	Lexan Surveillance VTOL	f	0	INNER_SPHERE	17	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-e962-7b51-a87b-cc6ad71000e3	4506	\N	FUSION	INNER_SPHERE	204	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a46968ee-479b-4886-84b2-247f486f4687	Koi	\N	0	0	0	0	0	5	Nishikigoi Support Aircraft	f	0	INNER_SPHERE	240	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-e965-724d-8c86-a8e46210b74e	4728	WiGE	FUSION	INNER_SPHERE	500	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d3de9c69-9ec8-455c-a724-6ca031599d73	ADT-1	\N	0	0	0	0	0	3	Auxiliary Defense Tank	f	0	INNER_SPHERE	28	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea5f-7925-92e7-611ca0aba32a	8302	Tracked	ICE	INNER_SPHERE	84	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	89344471-0968-4bdd-afaf-a2efe3aa3e28	ADT-2	\N	0	0	0	0	0	3	Auxiliary Defense Tank	f	0	INNER_SPHERE	28	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea61-7566-870b-5ed3a47568d4	8303	Tracked	ICE	INNER_SPHERE	84	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	969e60bd-46ed-4755-aac0-74d8327b37c9	'The Warcrime Wagon'	\N	0	0	0	0	0	2	Debbie	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ea62-7318-978c-0befea421dfe	7630	Tracked	ICE	INNER_SPHERE	160	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c6bbab77-0853-44e0-b99c-bbee80905fd2		\N	0	0	0	0	0	5	Outrider	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea64-7933-93eb-c6be11ec1aee	7631	Wheeled	ICE	INNER_SPHERE	8	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	01eb70f9-75aa-4b7e-944f-d534f2680114	(Laser)	\N	0	0	0	0	0	12	Hoverbike	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea65-73df-9d60-09bb7587ad94	7808	Hover	FUEL_CELL	INNER_SPHERE	14	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	bb70f73d-16cf-4739-aab8-48c5d8e56de5	(MG)	\N	0	0	0	0	0	12	Hoverbike	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea67-7d08-ac7f-4b1ab3191905	7809	Hover	FUEL_CELL	INNER_SPHERE	14	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	bd1edfe9-f404-4445-8e53-087f8949b824		\N	0	0	0	0	0	12	Hoverbike	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea68-7726-b719-e46c85a620fb	7807	Hover	FUEL_CELL	INNER_SPHERE	14	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b3f8daac-0fa8-4974-a2be-ff484adc828e	(SRM)	\N	0	0	0	0	0	7	Minigun Cycle	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea69-7bcf-a185-c649f8b45549	7806	Wheeled	ICE	INNER_SPHERE	2	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	20af8eb4-9593-4636-81bf-e649af8a0dc4		\N	0	0	0	0	0	7	Minigun Cycle	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea6b-782e-86af-f4cc09cc6486	7805	Wheeled	ICE	INNER_SPHERE	2	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	2792b36a-3b14-4812-9078-495bd83d9eb7		\N	0	0	0	0	0	8	Monocycle	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea6c-766b-981f-bb4533825ff3	7804	Wheeled	ICE	INNER_SPHERE	6	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5a5e8e3f-0c61-49c0-b9e3-5b13259b8bfe		\N	0	0	0	0	0	9	Scout ATV	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea6e-73c2-b2b0-abe409e92816	7812	Wheeled	ICE	INNER_SPHERE	9	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	f4b079f3-7d15-405f-bbce-120422e4fe75		\N	0	0	0	0	0	7	TrackBike	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea6f-75d3-bc85-8bf53c79276b	7811	Tracked	ICE	INNER_SPHERE	14	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	06414d98-c9c3-428c-8bb0-245cca65e515		\N	0	0	0	0	0	6	Trike	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea70-7299-ac6b-32f4589a1a2b	7810	Wheeled	ICE	INNER_SPHERE	3	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c3cbd07f-6d9a-4522-9345-3942fda5d046	(Original)	\N	0	0	0	0	0	5	Prime Mover	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ea72-7df4-ae4c-b8f07fdc593c	7817	Wheeled	FUSION	INNER_SPHERE	300	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6d023977-748b-4328-bc90-42799997ae2b	(Succession Wars)	\N	0	0	0	0	0	5	Prime Mover	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ea73-773c-bc0b-7353d654d9bd	9512	Wheeled	FUSION	INNER_SPHERE	300	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b710ffe5-65f5-4c06-ab3c-8f4438d33a05	(LRM)	\N	0	0	0	0	0	5	Prime Mover	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ea75-7bc0-9f24-7cec82d88f2b	7818	Wheeled	FUSION	INNER_SPHERE	300	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ceb16cf2-06e1-4255-9d38-bd27357973e5	WiGE	\N	0	0	0	0	0	8	Sturmvogel Gunship	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea77-752e-ad84-382cf20495b3	7816	WiGE	FUSION	INNER_SPHERE	400	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0584e074-b6d4-4fff-9ceb-44025861cddc	(LB-10X)	\N	0	0	0	0	0	8	Sturmvogel Maritime Patrol WiGE	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea7b-7248-939c-265f761f0fb2	7815	WiGE	FUSION	INNER_SPHERE	400	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1596233a-3a3f-46c5-8182-70893d743d63	(LB-2X)	\N	0	0	0	0	0	8	Sturmvogel Maritime Patrol WiGE	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea7e-7b02-a9cc-19f319098488	7814	WiGE	FUSION	INNER_SPHERE	400	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	f33b0227-74f0-4136-8fea-4a606dbe213b		\N	0	0	0	0	0	8	Sturmvogel Maritime Patrol WiGE	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea80-7b1e-928e-5ed05d07c074	7813	WiGE	FUSION	INNER_SPHERE	400	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	04f1b486-9ec8-4829-9fb5-f69954dd2973		\N	0	0	0	0	0	12	Bayamo Hoverbike	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea89-74fd-bbf9-2c328cd2bafd	3810	Hover	BATTERY	INNER_SPHERE	7	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d2805856-eb83-4051-8e46-eff8179bef69	BFFL Hovertruck	\N	0	0	0	0	0	5	Buffalo	f	0	INNER_SPHERE	100	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ea8d-71ba-ada3-c4e412cb9fd2	3819	Hover	FUEL_CELL	INNER_SPHERE	500	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	e989d36e-53fb-4649-bad6-b7233ce58ffa		\N	0	0	0	0	0	15	Champion Hoversports CS535 Hover Car	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea8f-7da6-8321-6f2f6dbbbc80	3942	Hover	ICE	INNER_SPHERE	45	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	00bea256-a4e2-41cb-b386-fc49419d75c4		\N	0	0	0	0	0	17	Champion Hoversports Crimson Streak Hover Racer	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea91-7849-8b93-ca87e63a1f10	3941	Hover	FUEL_CELL	INNER_SPHERE	60	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	178fc777-bb17-4835-9bc1-5b11f95b3b64		\N	0	0	0	0	0	7	Deusenberg VIP Luxury Hovercar	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea94-79a8-a982-ec2a2a88d9d6	4074	Hover	FUSION	INNER_SPHERE	350	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	e3dc418c-69e9-496d-b992-bf88546ff838	(Original)	\N	0	0	0	0	0	7	Deusenberg VIP Luxury Hovercar	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea97-7e69-b5a0-da6c266d4fb4	4073	Hover	FUSION	INNER_SPHERE	350	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d6eea296-52e4-483f-8f4a-3b4e772221ed		\N	0	0	0	0	0	7	Dillinger Police Vehicle	f	0	INNER_SPHERE	40	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ea9a-76d8-8101-7d4068cefc55	4464	Hover	FUSION	INNER_SPHERE	280	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	180ee65f-b80d-482d-9fb3-a15422af01dd		\N	0	0	0	0	0	10	Freedom 900 Hover Jeep	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea9d-76b7-99cd-2165b9e79aab	4187	Hover	ICE	INNER_SPHERE	30	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4ec94d63-3caf-4103-9540-3d88169c1a4c		\N	0	0	0	0	0	9	Ina-du Swamp Skimmer	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ea9f-756b-a692-9527ec3fc049	4361	Hover	FUEL_CELL	INNER_SPHERE	90	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ef8a2a4b-8d68-4bf2-8b45-29ce8889b09e		\N	0	0	0	0	0	6	Lewis Skimmer Bus	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-eaa2-7bd2-93a2-4c8ebd3527eb	4503	Hover	FUEL_CELL	INNER_SPHERE	480	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a2c93fa1-c742-4d45-b5b8-4cd3f909194b		\N	0	0	0	0	0	9	Routemaster Hover Shuttle	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eaa3-7d11-b1a0-aec3057334d2	4944	Hover	ICE	INNER_SPHERE	34	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1a12d5ab-bede-4933-a85a-8d3ca137df5f		\N	0	0	0	0	0	15	Slipper Hovercar LX-Series	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eaa5-7454-8517-0af434784a6e	5080	Hover	FUEL_CELL	INNER_SPHERE	23	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	64462513-9cd5-43e0-8e24-05caad797588		\N	0	0	0	0	0	3	Baleena Passenger Submarine	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaa8-7004-b1f7-cfbb94817579	3778	Submarine	FUSION	INNER_SPHERE	500	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ab854843-25c7-471a-809e-88090236b4be	JN-002	\N	0	0	0	0	0	4	Jonah Submarine	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eaaa-76f7-b7e6-989e6480a13e	4408	Submarine	FUSION	INNER_SPHERE	8	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5f720dfc-48b7-46c6-8096-ed210a310f6d		\N	0	0	0	0	0	4	Seahorse Cargo Sub	f	0	INNER_SPHERE	250	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaac-74d2-9629-c1f2eb661366	5011	Submarine	ICE	INNER_SPHERE	500	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b1cab913-536c-4065-b058-87727870b59b		\N	0	0	0	0	0	3	Atlantia Luxury Yacht	f	0	INNER_SPHERE	190	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaaf-7c92-b5ff-4b6f4765efb3	3748	Naval	ICE	INNER_SPHERE	500	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d88533b5-7e45-4deb-8c0c-02c2310630fa		\N	0	0	0	0	0	6	Silverback Coastal Cutter	f	0	INNER_SPHERE	40	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eab1-7d75-8413-9dce41e11ead	5062	Hydrofoil	ICE	INNER_SPHERE	240	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	14cd5052-c937-4044-b6ee-da8ffa8a0860		\N	0	0	0	0	0	6	Silverfin Coastal Cutter	f	0	INNER_SPHERE	40	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eab4-7121-a296-3d6a5868bf90	5063	Hydrofoil	ICE	INNER_SPHERE	240	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	85f30d01-4270-41fc-85f6-7f3b287edc1e		\N	0	0	0	0	0	7	Whitestreak Jetski	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eab7-7393-aaa2-212bbb5a8a3a	5407	Naval	FUEL_CELL	INNER_SPHERE	1	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	abb52c3f-7bb0-477b-b53c-582dc7257e71		\N	0	0	0	0	0	12	Whitestreak Speedboat	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eab9-7eb7-92ce-33119b5fd7a6	5408	Naval	FUEL_CELL	INNER_SPHERE	3	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	50094973-e05f-4c6f-bd9b-da84e864e815		\N	0	0	0	0	0	12	Adelante Passenger/Cargo Train	f	0	INNER_SPHERE	600	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaba-77cc-bbc6-e0ce02cb8ced	3669	Rail	FUSION	INNER_SPHERE	500	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b8600f48-6889-4242-aa6d-8de0de5f8f0b	A (Passengers)	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eabe-7fb3-a5fd-7786e7c0c045	5214	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	8bab6b31-006d-49e6-b6f6-a2efd66541d3	B (Military Support)	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eac1-7290-a30c-99fa10f3558c	5214	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b584f990-33a8-4520-af64-80075cb0c123	C (Cargo)	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eac4-72c9-be12-f0862f962a4e	5215	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	3faa8765-ea7c-441d-9df9-6da8ccc06a4b	D (MASH)	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eac8-7be2-a548-c275acaa1e23	5216	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	dc7daef2-644d-49a2-890c-ab3ac8e74e4a	Primary (Luxury)	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ead9-788f-9051-cd4db6b63371	5217	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a3a7441d-9e7d-4579-9fcd-b097e3976d0a	Primary Configuration	\N	0	0	0	0	0	0	TGV Omni Railcar	t	0	INNER_SPHERE	120	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eadc-75eb-992c-2dc58ce46ff1	5217	Rail	NONE	INNER_SPHERE	0	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	fc4c69d5-7436-43e3-a201-288564343f5a	UPU-3000	\N	0	0	0	0	0	3	Cellco Ranger	f	0	INNER_SPHERE	17	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eadf-700b-aece-62f18cdb6b58	3915	Tracked	ICE	INNER_SPHERE	51	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	9b3dca74-0377-4625-b23d-6d2c7a67fd21		\N	0	0	0	0	0	1	Corx Mobile Tunnel Miner	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eae4-7240-bf52-9ce4d3d2aec0	4011	Tracked	FISSION	INNER_SPHERE	200	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	2437a67f-714a-430d-9e2e-3e88c216f4a0		\N	0	0	0	0	0	2	Croyle Systems Cortez Series N	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eae7-73ca-8e85-fe2aba846ce5	4027	Tracked	FUSION	INNER_SPHERE	150	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d3742f37-9e7d-418c-b0e5-a92b4790dc57		\N	0	0	0	0	0	0	Galaport Ground Trailer	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaec-7b17-9b33-5c0e62d441c3	4196	Tracked	NONE	INNER_SPHERE	0	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	275cd25e-73b8-4275-bd88-1a94862321fa		\N	0	0	0	0	0	2	Galaport Ground Tug	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaee-7a62-b46b-a0cfb832b36d	4195	Tracked	FUSION	INNER_SPHERE	400	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	147f2b3c-c1dc-4db0-873a-e8eaaeaead68	(Tractor) Series 3	\N	0	0	0	0	0	4	Gienah-Durapaq Elite Land Train	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eaf1-7d35-86c5-5791aa3d7f1b	4211	Tracked	FUSION	INNER_SPHERE	500	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	1095e332-06bd-4ce7-9f8c-4283939a1a42	(Trailer) Series 3T	\N	0	0	0	0	0	0	Gienah-Durapaq Elite Land Train	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eaf4-7edb-81b9-282313c635d6	4212	Tracked	NONE	INNER_SPHERE	0	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	194291af-15b0-4c44-bb92-9cad0806ec45	B (Bulldozer)	\N	0	0	0	0	0	4	Hesiod Utility Vehicle	t	0	INNER_SPHERE	7	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eaf7-7245-bcb6-562f0f692e6b	4322	Wheeled	ICE	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7d60295f-1648-47e4-95c7-c262d4e4e310	Prime (Cargo)	\N	0	0	0	0	0	4	Hesiod Utility Vehicle	t	0	INNER_SPHERE	7	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eafa-7f5e-9b91-9392b84cb84b	4322	Wheeled	ICE	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	e6d77d22-c1e4-4338-8098-7adb07701113	C (Crane)	\N	0	0	0	0	0	4	Hesiod Utility Vehicle	t	0	INNER_SPHERE	7	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eafd-7785-87d2-d7d036befb00	4322	Wheeled	ICE	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7ad762e9-3d6c-4119-bd7d-430035573246	A (Harvester)	\N	0	0	0	0	0	4	Hesiod Utility Vehicle	t	0	INNER_SPHERE	7	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eaff-7230-9148-e755ed804af8	4322	Wheeled	ICE	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	de5a3256-637a-46a4-82f0-b0c69d7d1d34	UL-10 'Backhoe'	\N	0	0	0	0	0	1	Kallon UL-series Construction Vehicle	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb03-725e-a7ac-16ddedab3c01	4423	Tracked	ICE	INNER_SPHERE	10	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	89ea125a-718a-4970-b660-cc81ffe5c51d	UL-11 'Rock Cutter'	\N	0	0	0	0	0	1	Kallon UL-series Construction Vehicle	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb05-765f-aa7d-dab58755008d	4424	Tracked	ICE	INNER_SPHERE	10	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	f6c3ba05-fd88-459e-98ce-03a786f5b9c0	UL-12 'Chainsaw'	\N	0	0	0	0	0	1	Kallon UL-series Construction Vehicle	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb08-735e-97aa-af93f7f2e9dc	4425	Tracked	ICE	INNER_SPHERE	10	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	3c01780c-b1ed-4517-8eed-8995bbd51eb5	UL-14 'Dual Bulldozer'	\N	0	0	0	0	0	1	Kallon UL-series Construction Vehicle	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb0a-7c22-b52d-cb72caf6e6af	4426	Tracked	ICE	INNER_SPHERE	10	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4c804849-a57f-4b16-8756-4ed76d97574e		\N	0	0	0	0	0	2	Limpet Half-Track	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb0e-7b5f-afa0-b120634189cc	3869	Tracked	FUEL_CELL	INNER_SPHERE	8	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	41d817b9-e317-485c-80d9-74f038b30d04		\N	0	0	0	0	0	4	Luciano White Wolverine	f	0	INNER_SPHERE	8	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb12-74db-b53b-5eef739e6955	4540	Tracked	ICE	INNER_SPHERE	32	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	da34e30a-8abd-4841-a1fb-d6d2cf8f8df4		\N	0	0	0	0	0	2	Magellan Series Four	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb16-7869-91f5-649ee5124434	4088	Tracked	FUEL_CELL	INNER_SPHERE	150	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0cc5c203-ac99-4d6b-96d8-93a62fdcda5b		\N	0	0	0	0	0	4	Raptor RRV	f	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb19-70e7-944f-06e94c2fb2b5	4900	Tracked	FUEL_CELL	INNER_SPHERE	60	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	331d1a61-5263-42f6-b686-5173d6c69af0	RRV	\N	0	0	0	0	0	2	Rock Rover Half-Track	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb1c-7f90-b0d5-d9443332c6d7	4946	Tracked	FUEL_CELL	INNER_SPHERE	8	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5802027b-8952-4914-b900-493e051c7d56	RRV (Speed)	\N	0	0	0	0	0	3	Rock Rover Half-Track	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb1f-703a-830f-682569c85ac8	4945	Tracked	FUEL_CELL	INNER_SPHERE	12	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	e1c4a64e-9ea0-42dd-80cb-545afa95d222		\N	0	0	0	0	0	2	Rumbler-HT	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb24-79d8-92d8-73b427772b18	4210	Tracked	FUEL_CELL	INNER_SPHERE	6	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	cb337045-3d55-43f0-93b1-6e83f1ff80e9		\N	0	0	0	0	0	2	Saturn Harvester	f	0	INNER_SPHERE	175	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb28-7e35-923c-431fd9d1c460	4977	Tracked	FUSION	INNER_SPHERE	350	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6e050534-dc5f-465e-94b8-100ef5602139	(MASH)	\N	0	0	0	0	0	4	Sherpa Armored Truck	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb2c-7dd0-b55a-dbea0e342200	5047	Tracked	ICE	INNER_SPHERE	140	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6a362a94-fc98-4014-a3ed-7c7d5b092b07	(Mobile Canteen)	\N	0	0	0	0	0	4	Sherpa Armored Truck	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb30-759d-95a9-e212f7dc9c00	5049	Tracked	ICE	INNER_SPHERE	140	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0fc88d11-d6c4-4867-95a5-5ec98d08b862		\N	0	0	0	0	0	4	Sherpa Armored Truck	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb33-74f7-b789-45c38ab4bd89	5050	Tracked	ICE	INNER_SPHERE	140	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	146296f1-673e-48c3-b8bc-138830961de7		\N	0	0	0	0	0	8	Blackstone Baronet Passenger VTOL	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb36-7f04-b382-7da6a3064956	3832	\N	FUEL_CELL	INNER_SPHERE	400	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	a83df6dc-0c7f-4d9d-83f9-c7dd74f3687f		\N	0	0	0	0	0	8	Blackstone Pegasus Passenger VTOL	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb38-7c8e-9913-22a6dd885e82	3833	\N	FUEL_CELL	INNER_SPHERE	240	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	8745008b-fcc6-4698-8d72-370be927f780		\N	0	0	0	0	0	6	Cascatelle Firefighting VTOL	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb3a-748f-a3dc-0eab4dba3cbe	4833	\N	ICE	INNER_SPHERE	360	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	8cda40d6-cea7-4b9f-a1c6-c596e7e7d010	Series VI	\N	0	0	0	0	0	5	Lexan Oceanic Luxury VTOL	f	0	INNER_SPHERE	60	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb3f-7e01-a045-dbf4fd922f5d	4504	\N	FUSION	INNER_SPHERE	300	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	d2cd7149-9e6d-4189-8bb9-938832ee9932	Series II	\N	0	0	0	0	0	15	Lexan Oceanic Personal VTOL	f	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb42-7c1d-a49d-982cbe3e7171	4505	\N	FUSION	INNER_SPHERE	225	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	1c2615ee-2f0f-48e5-9b84-d9d8001c751e		\N	0	0	0	0	0	7	Peacekeeper SWAT Carrier	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb45-7948-a8bc-23d7e8efdfbc	4796	\N	FUSION	INNER_SPHERE	350	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	8c0ef70c-ef6b-48cb-bdd9-8ca2dc2befe9		\N	0	0	0	0	0	6	Lama-Deux Firefighting VTOL	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb49-7f19-82fd-0f70ff69960f	4834	\N	ICE	INNER_SPHERE	180	BAR_3	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	819c5380-c26c-4fa9-86a4-7e4e0644ce1d		\N	0	0	0	0	0	8	SOAR VTOL	f	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb4c-7cc1-b8eb-864536f75e2a	5095	\N	FUEL_CELL	INNER_SPHERE	120	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	f70fe690-439a-40aa-bbd9-3514a2c69a7c		\N	0	0	0	0	0	7	Sky Eye News Helicopter	f	0	INNER_SPHERE	20	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb4f-7ba8-8c4b-3f0b22b576ef	5072	\N	ICE	INNER_SPHERE	140	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	89fd2b1c-9278-4ec7-a7d2-bfcf0e6de10d	C1	\N	0	0	0	0	0	8	St. Christopher Cargo Transport	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb52-7363-9406-1098aa6d4964	5116	\N	FUEL_CELL	INNER_SPHERE	200	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	605059f8-8031-414b-b21e-d96f89f162ca	C2	\N	0	0	0	0	0	8	St. Christopher Cargo Transport	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb55-7c2a-8bff-ac2a239a9f9d	5117	\N	FUEL_CELL	INNER_SPHERE	200	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	6f872608-86b6-40f2-9d3a-657654744daf		\N	0	0	0	0	0	11	Swiftran RTC-215M	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb58-7aaf-9e06-f4553e702d0d	3889	\N	ICE	INNER_SPHERE	275	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c6ea5878-fe8a-4e50-bb79-ebb53baeb78d		\N	0	0	0	0	0	12	Aston-Martin Fiver Roadster	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb5b-7ae1-8f12-cd59cc2cccda	3740	Wheeled	BATTERY	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ebc7e842-23ab-4716-acae-3acd7ee684e7		\N	0	0	0	0	0	11	Aston-Martin Fiver Traveler	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb5d-7850-8b3f-6c542e769a19	3741	Wheeled	BATTERY	INNER_SPHERE	28	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	e7ab620e-f85e-412f-9e5b-70c039ba8810		\N	0	0	0	0	0	6	Bailey Armored Car	f	0	INNER_SPHERE	27	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb5f-7f03-9138-cd650b4afc60	3777	Wheeled	FUSION	INNER_SPHERE	162	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	05d0d7f5-5d6a-40b5-9656-59b003aabd0e		\N	0	0	0	0	0	3	Bombduster	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb64-700a-baa3-813adac7ab4f	3847	Wheeled	FUSION	INNER_SPHERE	150	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7fd32a1c-f96f-4eae-b47e-34d0bd38f741		\N	0	0	0	0	0	3	Brunel Dump Truck	f	0	INNER_SPHERE	150	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb66-7072-abab-abb8edaeafd2	3866	Wheeled	ICE	INNER_SPHERE	450	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	2728a5db-4d4c-4f0b-9ce8-c3fb4a431e78		\N	0	0	0	0	0	4	Bulldog Medium Truck	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb69-796c-849e-36897a7a2290	4827	Wheeled	ICE	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	3012c313-93a6-4aeb-9a53-04625646fcaa		\N	0	0	0	0	0	6	Burro Heavy Support Truck	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb6c-7733-96f6-360657593341	4381	Wheeled	FUSION	INNER_SPHERE	15	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	2055d892-c6ad-485b-ae9a-2302d3dbc8e5		\N	0	0	0	0	0	3	Burro II Super Heavy Cargo Truck	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb6e-745b-9387-8e136d828309	4382	Wheeled	FUSION	INNER_SPHERE	150	BAR_9	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	158de7cf-d567-454b-ba8b-91a4b2106b75	ZZ10000	\N	0	0	0	0	0	10	Ceres-Bikes Flashbang	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb71-7be5-8895-b1a314f2b79b	3933	Wheeled	ICE	INNER_SPHERE	2	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	efdf88e9-bc43-43ad-9a11-bf2a26b6f348		\N	0	0	0	0	0	8	Durandel-British 'Blue Nova' Convertible	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb74-74ff-b99b-0639ffdd1412	4104	Wheeled	ICE	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	e5224de3-e019-4b06-a097-998362cd7dc8		\N	0	0	0	0	0	5	Knox Armored Car	f	0	INNER_SPHERE	12	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	4453	Wheeled	ICE	INNER_SPHERE	60	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d31c1098-d8bc-4a16-a318-642501325826		\N	0	0	0	0	0	3	Lesseps Dump Truck	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb79-7c2d-acd0-aee5587b12c5	4499	Wheeled	BATTERY	INNER_SPHERE	150	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	3aadfa03-cf37-4496-a7c8-8605dddea77e	(Original)	\N	0	0	0	0	0	6	Mao-Heng Charioteer	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb7a-751a-8bb2-1e31e1941b58	4588	Wheeled	ICE	INNER_SPHERE	60	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ec50c47e-f827-43d2-b76e-a23664be23fd		\N	0	0	0	0	0	12	Mótuö Chë Shang No.2	f	0	INNER_SPHERE	0	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb7d-7a0e-8c54-ca0a6f56b117	4680	Wheeled	ICE	INNER_SPHERE	4	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	357c7abb-b994-4332-8ab3-0a9419fa889c		\N	0	0	0	0	0	4	Pit Bull Medium Truck	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb7e-7909-b38f-56cc78308a5a	4828	Wheeled	ICE	INNER_SPHERE	12	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b6b9ad23-d114-4d2c-a104-eee205560864		\N	0	0	0	0	0	4	Prairie Schooner Land Train	f	0	INNER_SPHERE	90	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-eb81-779a-91c5-b60821553625	7334	Wheeled	FUSION	INNER_SPHERE	360	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	050508c9-c4de-4404-98b5-ae00fa877c40		\N	0	0	0	0	0	0	Prairie Schooner Module	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb84-7391-9229-28fc3cc437ef	7335	Wheeled	NONE	INNER_SPHERE	0	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	7cf9db9d-c6f4-492f-a6c3-c26aa2a3e77f		\N	0	0	0	0	0	13	Saturnus V Grande Circuit Racer	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb87-7c93-89bf-8b7de4a95ca8	4978	Wheeled	ICE	INNER_SPHERE	20	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	64fc4351-77c4-422b-be6f-1517912bc965	TLF-LL6500	\N	0	0	0	0	0	6	Saurer-Bucher Fire Engine	f	0	INNER_SPHERE	44	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-eb89-7bd0-b58b-e50ada6fec4c	4980	Wheeled	ICE	INNER_SPHERE	264	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	db8d52c0-9bf0-4166-a89e-cfc499f613e0		\N	0	0	0	0	0	7	Simca Ambulance	f	0	INNER_SPHERE	2	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb8b-70e8-877b-15354dc10ae1	5064	Wheeled	ICE	INNER_SPHERE	18	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	50183c99-4f05-425c-bcdf-aad9dc6a0f1d		\N	0	0	0	0	0	6	Skoda 'Growler' Service Utility Truck	f	0	INNER_SPHERE	1	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb8e-7f30-9caf-e4773869eac1	5066	Wheeled	ICE	INNER_SPHERE	6	BAR_2	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b8b10738-509e-4e81-a370-0403968d2fee		\N	0	0	0	0	0	11	Coanda Personal Sports Craft	f	0	INNER_SPHERE	3	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb90-7b4d-bfac-cb63d60e73fa	3970	WiGE	ICE	INNER_SPHERE	39	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	58dabf21-14cf-4f28-87cc-9081f432d39b	(Cargo)	\N	0	0	0	0	0	5	Cormorant Medium Cargo Craft	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb92-75af-8aec-4c4ff2992fd9	4003	WiGE	ICE	INNER_SPHERE	350	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d6f50b4c-389f-48d5-859c-7092475c8565		\N	0	0	0	0	0	5	Cormorant Medium Cargo Craft	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb94-7a82-aec4-b489542e4575	4004	WiGE	ICE	INNER_SPHERE	350	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	834c713e-7a6e-4ab3-9109-d48395a94872	(Original)	\N	0	0	0	0	0	7	Fulmar Patrol Craft	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb96-7662-a5ed-bfd1a33b7fac	4189	WiGE	ICE	INNER_SPHERE	490	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	8b593785-773a-4046-b9d4-28698583c23a		\N	0	0	0	0	0	7	Fulmar Patrol Craft	f	0	INNER_SPHERE	70	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb98-7b10-8427-7d5fff189c62	4190	WiGE	ICE	INNER_SPHERE	490	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0f6dd711-4a16-4c7e-a936-eb27c8bd75af		\N	0	0	0	0	0	5	Koi Heavy Transport	f	0	INNER_SPHERE	240	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb9b-7ae6-84c7-e2da71753968	4460	WiGE	FUSION	INNER_SPHERE	500	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	014e26f1-170f-4602-a02d-82153e26c6a1		\N	0	0	0	0	0	12	Quicksilver Personal Sports Craft	f	0	INNER_SPHERE	4	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-eb9c-75b7-8d26-ea4f6b8e6c81	4889	WiGE	ICE	INNER_SPHERE	54	BAR_4	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d3abda25-3a33-466d-a98f-62b84592e2b0		\N	0	0	0	0	0	5	Ryu Heavy Transport	f	0	INNER_SPHERE	240	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-eb9f-7b84-a031-8f75c5f879ea	4956	WiGE	FUSION	INNER_SPHERE	500	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	8b920a33-b4b2-4dc1-b462-49d269f99444		\N	0	0	0	0	0	15	Lexan Surveillance Helo	f	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ebc1-78f3-82b4-1446276cb2d3	1868	\N	FUSION	INNER_SPHERE	225	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5e201932-9064-4820-b995-a684f2db3ead		\N	0	0	0	0	0	5	Nishikigoi Support Aircraft	f	0	INNER_SPHERE	240	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ebc3-74fb-9232-24f9b1cb39d4	2288	WiGE	FUSION	INNER_SPHERE	500	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6451138b-3370-46be-82b2-9f6f0af01e6e	Configuration #1	\N	0	0	0	0	0	0	Dreadnought Mk II Land Trailer	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec04-78a7-99c8-2e2cd5ab7b15	5571	Tracked	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	56ccc05c-1c13-4137-91aa-4813066479a8	Configuration #2	\N	0	0	0	0	0	0	Dreadnought Mk II Land Trailer	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec05-7443-ad84-66d9c73936fa	5572	Tracked	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4d50238d-2584-4e46-8cbf-d6cad130fe5f	Configuration #3	\N	0	0	0	0	0	0	Dreadnought Mk II Land Trailer	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec07-7895-a9cc-fee8727e7a9a	5573	Tracked	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	a0741c29-743a-472e-b3b9-da5d16e0758c	Configuration #4	\N	0	0	0	0	0	0	Dreadnought Mk II Land Trailer	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec09-7466-9949-cf9e91650d70	5574	Tracked	NONE	INNER_SPHERE	0	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	775029c3-7429-4119-aaa8-53dd68b977e5		\N	0	0	0	0	0	3	Dreadnought Mk II Land Train	f	0	INNER_SPHERE	200	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ec0a-7340-a6c3-f2700c3efca1	5570	Tracked	FUSION	INNER_SPHERE	500	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5ca3aaf6-bac1-43f9-86e5-8950ceb958ff	(Hover Primitive)	\N	0	0	0	0	0	7	Armored Personnel Carrier	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec1d-7022-b8e3-21b683ba510f	113	Hover	ICE	INNER_SPHERE	70	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	91711733-c77e-432c-a592-5b177a1e3971	(Tracked Primitive)	\N	0	0	0	0	0	3	Armored Personnel Carrier	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec1f-7629-b7f5-095c9748cfbb	118	Tracked	ICE	INNER_SPHERE	30	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	337aad41-4a5f-4448-92f7-53a2df645f6e	(Wheeled Primitive)	\N	0	0	0	0	0	4	Armored Personnel Carrier	f	0	INNER_SPHERE	10	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec20-7319-9741-d48a52da23d2	123	Wheeled	ICE	INNER_SPHERE	40	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	5c789f8f-6db9-40c3-aadf-5325407a8cef	Mk VI	\N	0	0	0	0	0	3	Merkava Heavy Tank	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ec23-7b21-9c77-d12e9659c093	2175	Tracked	ICE	INNER_SPHERE	225	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	f05ec332-473b-4c50-a2ac-55d482307260		\N	0	0	0	0	0	8	Sand Devil Hover Tank	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec24-747e-8eb7-35e3a54106f4	2793	Hover	ICE	INNER_SPHERE	400	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	114e2b35-3ebf-474e-88b5-a72598f80450		\N	0	0	0	0	0	5	Stoat Scout Car	f	0	INNER_SPHERE	15	ULTRA_LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec25-78fe-9971-587d9dbe9be9	3075	Wheeled	FUSION	INNER_SPHERE	75	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	af7bffa4-1275-4dd4-a52a-bddec9434885	(Primitive)	\N	0	0	0	0	0	3	AC/2 Carrier	f	0	INNER_SPHERE	55	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec27-7c5f-83b1-dda0d2dad2d4	5588	Tracked	ICE	INNER_SPHERE	165	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ca918b10-e870-40bc-a6d1-c9aefd00d6fc	(Primitive)	\N	0	0	0	0	0	3	LRM Carrier	f	0	INNER_SPHERE	55	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec2a-7682-bd35-0ff30fe06d81	5589	Tracked	ICE	INNER_SPHERE	165	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	18fafc65-31cd-4c40-9e47-007beb8a5a2d		\N	0	0	0	0	0	4	Randolph Support Vehicle	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec2d-7ab0-a75d-5253f2863a4b	5586	Tracked	ICE	INNER_SPHERE	140	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	50570d61-015b-401e-b696-7039458c7184	(Primitive)	\N	0	0	0	0	0	3	SRM Carrier	f	0	INNER_SPHERE	55	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec2e-7d66-812c-e49ba2b9acb6	5590	Tracked	ICE	INNER_SPHERE	165	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	6cc64beb-e2be-4b0b-bf9e-3a9f9d934582		\N	0	0	0	0	0	7	Strike Falcon Attack VTOL	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec30-7a43-8727-98b32f4c02d5	5585	\N	ICE	INNER_SPHERE	210	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	cad59ded-f5bb-4c90-b474-9b4c0772cec3		\N	0	0	0	0	0	5	Carter Medical Emergency Response Vehicle	f	0	INNER_SPHERE	25	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec37-7f5e-b29e-160141dfcb8d	5620	Wheeled	ICE	INNER_SPHERE	125	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	dba98755-a6b0-41fb-9cdc-bfbd376c067f	KRV-2	\N	0	0	0	0	0	5	Korvin Tank	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec3a-7dab-a42d-b0c60710239b	1816	Tracked	FUSION	INNER_SPHERE	250	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	c18a4467-f09e-4c5d-bbba-c9490a7cb1e6	(Original)	\N	0	0	0	0	0	3	Chi-Ha Infantry Combat Vehicle	f	0	INNER_SPHERE	22	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec3c-7b20-848d-ef876a429829	7188	Tracked	ICE	INNER_SPHERE	66	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	bba98077-8aeb-4c93-88f1-9081b7a9d555		\N	0	0	0	0	0	4	Chi-Ha Infantry Combat Vehicle	f	0	INNER_SPHERE	22	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec3f-7a7c-9852-18a6a3ce05a4	7187	Tracked	ICE	INNER_SPHERE	88	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	2eb58e2a-48fd-4dc7-987f-9f127e86dccc	(Fusion)	\N	0	0	0	0	0	10	Cobra VTOL Transport	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec42-78fe-8163-1c465907ceb6	7190	\N	FUSION	INNER_SPHERE	300	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	8b82ae1b-acdc-414d-ba31-95d11bd526b1		\N	0	0	0	0	0	8	Cobra VTOL Transport	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec43-77c3-9837-427bd3b5f580	7189	\N	ICE	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	53fdc0af-6799-45d8-ae0e-d5828ad0e046		\N	0	0	0	0	0	4	Sturmblitz Assault Gun	f	0	INNER_SPHERE	75	HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ec46-70f9-b001-8c48763f9513	7191	Tracked	ICE	INNER_SPHERE	300	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	0dbd5aed-5ebb-4b6e-8bae-3365ce9b53e8		\N	0	0	0	0	0	3	Apostle Self-Propelled Artillery	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ec48-7c24-9448-12f9f7a3db2e	7414	Tracked	ICE	INNER_SPHERE	240	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	b525da04-2827-42e6-a850-54ad0edb69b2		\N	0	0	0	0	0	8	Asher Hover Scout	f	0	INNER_SPHERE	45	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec4d-798f-84ad-eecdcc54759d	7410	Hover	ICE	INNER_SPHERE	360	BAR_7	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	464855c2-99b2-43f4-8e1a-e71b1ff7512e		\N	0	0	0	0	0	5	Dunning Mobile Tactical Command Post	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec4f-7522-895b-66f3e0e40f6e	7409	Wheeled	ICE	INNER_SPHERE	150	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	d47a1547-d2a0-4707-9536-6a181bc57984		\N	0	0	0	0	0	3	RR-3 Recovery Vehicle	f	0	INNER_SPHERE	55	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec51-731c-94b5-a5c494fdd6d1	7411	Wheeled	ICE	INNER_SPHERE	165	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	94541280-c942-4d5f-97ed-fce828631cba		\N	0	0	0	0	0	3	Reaper Self-Propelled Artillery	f	0	INNER_SPHERE	55	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec53-79c4-be1e-77db6ca4932f	7413	Tracked	ICE	INNER_SPHERE	165	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	86092205-f1ef-4b21-b474-6d9649949892		\N	0	0	0	0	0	4	UTR-588 Recovery Vehicle	f	0	INNER_SPHERE	90	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ec54-7008-ba53-94c900e2263f	7412	Tracked	FUSION	INNER_SPHERE	360	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	2417cd94-6a52-4569-be0d-b61b393a47de		\N	0	0	0	0	0	7	Barouche Military Transport	f	0	INNER_SPHERE	80	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ec6e-7bb0-8a34-4b08f83b9763	3793	Hover	FUSION	INNER_SPHERE	500	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	ac87dea8-1773-497d-a507-81ab95cfc018	HW1	\N	0	0	0	0	0	3	Hwacha Urban Combat Vehicle	f	0	INNER_SPHERE	50	MEDIUM	\N	\N	\N	\N	\N	\N	019f583e-ec70-76c7-a26a-3b560de8e435	4350	Wheeled	FUEL_CELL	INNER_SPHERE	150	BAR_6	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportVtol	6ca8e2ae-a760-4e60-b2d3-b9e267e522f8	(Rescue)	\N	0	0	0	0	0	11	Humming Bird VTOL	f	0	INNER_SPHERE	30	LIGHT	\N	\N	\N	\N	\N	\N	019f583e-ec72-79eb-ad16-cee49f243461	4336	\N	FUEL_CELL	INNER_SPHERE	330	BAR_5	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	6c50cf39-4a92-4008-b475-1aa1e0cd0a92		\N	0	0	0	0	0	3	White Tip Submarine	f	0	INNER_SPHERE	250	ULTRA_HEAVY	\N	\N	\N	\N	\N	\N	019f583e-ec75-7cd8-8032-f2d83d9a0544	5406	Submarine	FUSION	INNER_SPHERE	500	BAR_8	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	37f434ed-bc1c-4357-b990-51e23bf6a3a4	BFFL Drone Bomb	\N	0	0	0	0	0	5	Buffalo	f	0	INNER_SPHERE	100	ASSAULT	\N	\N	\N	\N	\N	\N	019f583e-ec7c-7f1d-b79a-8290b0bb8b37	5777	Hover	FUEL_CELL	INNER_SPHERE	500	STANDARD	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	4162ed61-5054-44e8-b90b-68104267a0a7	(Fuel Tanker)	\N	0	0	0	0	0	4	Sherpa Armored Truck	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	01a0bb4b-3acf-740c-a575-80954010f2a7	5050	Tracked	ICE	INNER_SPHERE	140	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
SupportTank	cece7971-fb00-4b3d-92f7-9eba1f75c652	(Mobile Headquarters)	\N	0	0	0	0	0	4	Sherpa Armored Truck	f	0	INNER_SPHERE	35	LIGHT	\N	\N	\N	\N	\N	\N	01a0bb4c-6e83-721d-992c-a9dc9c849827	5050	Tracked	ICE	INNER_SPHERE	140	BAR_10	INNER_SPHERE	STANDARD	INNER_SPHERE	\N	\N	\N	\N
\.

INSERT INTO unit
SELECT v.* FROM v3_22_unit v
WHERE NOT EXISTS (SELECT 1 FROM unit u WHERE u.megamek_uuid = v.megamek_uuid);

-- 3. only on the units added above (a unit already stored has its own items)
COPY v3_22_item (megamek_uuid, id, location, omni_pod, rear_facing, tonnage, turret_equipped, name, tech, fire_control, jump_boost, drones, mash_theaters) FROM stdin;
019f583e-e29c-762f-9274-753bb6064e76	4d8147c7-8970-45c5-a48a-4a470a2139af	BODY	f	f	0	f	drone(remote)operatingsystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29c-762f-9274-753bb6064e76	a8a2d75f-8dff-4090-9106-594197c5bd5b	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29c-762f-9274-753bb6064e76	237fbe40-b877-4f19-99e1-a2a1622a2046	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29c-762f-9274-753bb6064e76	e1d2a2b3-cb3c-4c3b-aba1-1f87e7c89054	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29c-762f-9274-753bb6064e76	290097a4-ae6f-4ce6-bff0-48e55a9e10f1	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29d-70e8-b0f6-cd3ba2e9a13f	7c811ff0-858b-4999-b027-410be6e4b84a	BODY	f	f	0	f	drone(remote)operatingsystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29d-70e8-b0f6-cd3ba2e9a13f	f37d1a3e-8881-49f7-ab19-cf14b64bd1c6	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e29d-70e8-b0f6-cd3ba2e9a13f	b243431e-092f-4d8c-8eec-1c6795f0ac9a	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	462fd34e-2a5e-4cda-b3f3-606caec89f46	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	344748e8-0899-4008-8091-01f97102a671	BODY	f	f	3.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	1467971f-736e-4f8b-b4b9-6be17de91943	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	a4a02df9-2b53-4540-9f3c-e955f23cb8ed	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	34552db7-6698-49b3-a2e7-e70e069072d6	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	0adc235d-e5dd-463c-ac07-bf6f901b9ae9	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	c8401c4e-ca3c-4ebb-a1eb-9e7b470bff81	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	918026b7-25e7-44f5-a396-e2b49bd57dea	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	c129e77c-a5fb-404b-a847-fd9ab5a1ab3e	REAR	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	2aac862d-52f2-4d55-826d-d1e499adc549	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e649-77d4-ab78-f95b76a11762	d412ad26-7191-4733-9d9e-a450a70f3c85	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	4d13ccf3-b57c-4c0f-85ca-babbdf60fd9b	REAR	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	48b2c04b-0b87-4e27-a14b-ba7880c36693	BODY	f	f	2.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	7f0ca3da-365e-40fc-9872-23215185ca3e	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	ac29bdf9-572e-4002-8a21-dd3e627ac684	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	1d8f3c95-50e9-4ca3-8b47-ff2275f0e40a	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	84950d1e-e2e2-4d12-a179-c2ebe1902e90	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	dd48c7d3-861c-4756-abba-d2ede3524b99	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	d9208bed-1d68-473f-8ec7-db787dd41fde	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	9a350565-d6e7-43e9-9427-8a0544a60ca5	FRONT	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	ccc58e28-7135-49e7-9f75-07d04db0acb6	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	506ec7f4-cc68-4d1d-9e81-4e5492de88f7	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	8cbf26c8-b102-4d86-9fbe-0cd4dcf05c82	REAR	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64b-79ec-a027-ca5b2431f0d9	b77db993-b5f8-44db-8e83-c80e6ae80705	REAR	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	68312b06-96ee-406a-861e-d744e5e2e43b	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	22ef16a0-8f11-434b-9a77-c8a856da1807	BODY	f	f	2.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	14b4d634-7705-48d8-8e3a-a320d4b8395c	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	4084ff40-cfd4-4217-85d9-3969416d69ae	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	4fddcb8f-42fe-4bc1-91d8-594066f4d5c2	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	3af7ea5c-ecb3-4296-9b87-8696d5e9376c	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	db1c3822-2408-4c2a-b58b-ede58c9d8ace	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	df94e9b0-ec34-4074-b08d-45282257cc24	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	b3cf039d-6ebc-4e92-a76b-ac3f6b285ddd	REAR	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	d575106d-3b23-4370-b139-f32dfd3e1c2e	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	22cc9d7b-933d-42b6-968f-d9a0626d1e61	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	247e42e4-5514-4236-a013-145c5fb273b3	REAR	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e64d-79ff-af8b-7dd38cde63fd	3e773182-62ac-4cf8-8d99-7c91cbea97ff	REAR	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	563e556f-5e0d-4815-8b05-f29576cec790	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	55bde111-c32d-4fe9-b264-c76302345627	BODY	f	f	4	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	616547f5-6b92-4a4f-9052-9ee36a3e57ad	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	f226e85b-f235-499e-83d5-18a0c5ada528	FRONTTURRET	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	22f3cee9-79cd-44aa-ba4f-50105fb88cd8	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	f8dd5326-f4bf-4ad7-b237-9fd65686ac95	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	5728642c-3263-48a2-a1fd-be3a751b73eb	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	4e77091e-bda9-484f-a4a6-b67fd23bec87	REAR	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	6e0359d7-51cd-4c3d-8c40-f9ae08094aa9	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e650-7bd6-a664-8080fffc751a	8d890b3f-a07d-4aad-812a-c677135bb614	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e653-7a8c-a667-4b6b66b73922	7f1b7e6a-aad7-4634-b85a-4b4b0d0ae6c0	BODY	f	f	4	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e653-7a8c-a667-4b6b66b73922	842b011e-6cb2-46b9-bd09-579b05eff7f8	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e653-7a8c-a667-4b6b66b73922	1fedc266-c836-41b6-99d0-da50bc211db4	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e653-7a8c-a667-4b6b66b73922	a4f4205c-e460-44bb-a039-06d1d399500d	BODY	f	f	0	f	svchassismod[dunebuggy]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	4e8743fe-090b-4094-9ed2-f0b5748be4a2	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	48c82fb2-afb1-4bdf-9f9f-63dcc1748c49	BODY	f	f	18	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	085c4d2b-524c-4f7a-8a33-7ce214463740	BODY	f	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	11
019f583e-e654-7265-b77a-515a1e7450b2	53257dba-4e81-4282-83bd-7c925cd9d153	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	701431a6-b5af-4564-b2a7-64dd474f60fb	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	dcc6dcf2-ffe0-45d4-8bc1-3610405abda1	LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	807e2379-31a0-4021-ae16-8096375f54ff	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	df4f62ec-d5b5-4002-9314-0cbcb4e54083	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	f52696e6-e2af-4554-af07-c6ea39450b44	RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	f6778402-fb94-42dc-bec6-8577ac5c52f9	LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	d2380b47-a0de-460c-86f6-8c93f04c16f2	RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e654-7265-b77a-515a1e7450b2	b9e281d6-6c8a-4c6f-93ef-c494e073f7cc	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	0af2b638-060a-415e-9b7a-a1673c92b148	REAR	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	186808b7-2fca-42b7-af19-dbf8ecfa5c42	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	1837d85c-c336-42ea-8827-1d8dd49014b8	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	ba9b27df-79dc-4e3a-bfe2-7af4b1b07964	BODY	f	f	22.91	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	8646ed83-bda3-433a-9f1b-c60a1571fa1e	FRONT_LEFT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	29af9671-d5f3-48c9-881d-46c66177ad76	FRONT_RIGHT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	d22b054d-bcae-400f-bdbe-86960a1e5c50	REAR_LEFT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	8d3427a4-2b8c-4109-b397-493bc6e27ce7	REAR_RIGHT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	f97ff703-c4ee-4e6f-bd97-24e26bf29088	FRONT	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	8ef47edb-c3c3-425a-8ca5-7a3b421c9ac9	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	c95014e8-0343-4e27-95b9-464e26cce225	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	8142bb5d-d09b-4584-a45e-a2838c2d1692	FRONT_LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	399dad6d-7814-46cb-a5ff-d0af6b2eda88	FRONT_RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	696ef2f4-1209-46bc-b610-640da64707cf	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	06c666d9-1081-47d8-9822-27f1c66f3e60	REAR_LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	f43ba10d-abc4-4547-85b8-2ff64d47e8c9	REAR_RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e656-7f3e-8c83-5133b1d91814	09aba937-ed1a-46cc-af9e-c0df17051124	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	52d1c18a-bea3-40e2-ae0d-166d8e172afc	REAR	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	1d5bf923-d465-43ea-807b-4a56ea60d460	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	33bb6504-1007-442c-90fd-6c1a2b30acde	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	163df940-2d0f-4a4c-b2bc-1dedf81ffce1	BODY	f	f	18	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	ae087d1f-350f-4c63-8a27-59c012b05452	FRONT_LEFT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	3cb109ce-d9b2-4d34-855d-fd180030ccb0	FRONT_RIGHT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	8bb83fef-7b02-4357-8877-3bf7d5bca0f9	REAR_LEFT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	0109cabe-1358-4579-a80c-56bdf87e20ac	REAR_RIGHT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	e4083878-a7f8-41c0-aaae-c9e4051a66cc	FRONT	f	f	0	f	minesweeper	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	945f7995-6c8f-4bcc-93aa-b02e88eaac00	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	6cb29344-e76c-4862-b6f2-eed3ae250a04	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	fc690f2b-73f8-4f86-a82f-337dfddbd175	FRONT_LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	9ee147f7-0870-43c4-bd3f-6d62bf5e2cb7	FRONT_RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	294dc41e-502d-4836-bb7d-5e5fbe9c75fc	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	af98bfbd-e3ba-4c66-b454-831566ec22af	REAR_LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	cbe70374-dc31-4a9b-a0fb-b54f5026ff48	REAR_RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e659-75cf-af7e-617b624a12ff	4c24a9ac-2bf2-4828-9256-48803b95a265	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	b64b0ee8-232c-4050-a063-932f96b72a23	REAR	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	e37d5845-0d7f-47a4-b5a3-1d5388246f04	BODY	f	f	100	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	81529fdc-c3f5-41e7-b77e-b6e4a02da62f	FRONT_LEFT	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	613bc75e-07cb-4fcb-b786-cda00fd32356	FRONT_RIGHT	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	cf5226b5-cae8-44c8-83ff-43bfc54985fc	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	0a4f7121-75ec-44d2-8aeb-6890edf38de1	FRONT_LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	b26292d0-7afe-4921-b058-67f4401ba6fb	FRONT_RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	3336f8b2-17f9-4ce5-a013-bf667f24f771	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	aedc62eb-004a-4f76-9bf2-93095b874984	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e65c-7589-805d-1f76e53fc17c	b2a8f8c0-9c4d-46c3-8edf-f3c9e8b303a8	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	7f453700-bd66-46cb-9cef-362734dbe324	BODY	f	f	16.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	000e9da6-ee88-4e3d-8698-22ea6de0e786	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	0d5a6c8c-901f-4fc2-8b64-0c6d94b1b259	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	0e8a70ab-42c2-4a5c-b72b-fc5ff6ded510	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	15626634-f012-454c-bd4a-3ad820a18910	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	41222cf0-9df3-469e-bc2d-86a4c1d7e451	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	5c0c808d-2e61-48aa-967d-1c8a4f86c665	BODY	f	f	0	f	lightmachinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66a-7f62-809c-937110fabc1b	e3e870a1-465e-495d-92ea-c89f18619266	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	f7ac39d3-94fb-40f9-9989-a1ed19f5c088	BODY	f	f	19.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	180d9db0-c724-4dc3-9992-de3e2db2c2df	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	58c5fc05-d7c8-4b95-9948-863e17d30787	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	113482bc-4ab3-408d-8d3f-998c92b7cbcf	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	31b279aa-fa01-4d1d-8906-60bd308c1f76	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	82f5458d-e74e-4acd-8703-6c9961a514df	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e66e-7939-9125-398d08c4c0f2	9b0a25ae-1298-4c64-84bd-82bb48b5a489	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	393ab3f8-8d81-4b61-a0ff-d8e6b2fc8005	BODY	f	f	13	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	89e05fa9-3ff7-43ff-a4fc-5d9e286cfe8c	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	b5bce4d0-3655-4ec4-abfd-0df59d25f009	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	bcb464fd-b66b-4ff0-854b-4c071b8cdc26	FRONT	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	e9835446-03bf-464b-b166-b6f78c37b8bc	FRONT	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e670-7c82-aa18-a995e6e33753	f33c2d29-d47c-49a7-8f1f-b232e98a43fe	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	09d94459-6f87-4d89-bb50-0579b777188a	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	169e1f99-f936-4452-b044-d584dd8b16a5	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	0eb418a9-e72a-40ed-ae5c-d42c5c8c14df	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	1799dd76-281f-40ca-92f6-ba68ea9074bd	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	2161aaf6-3881-4ee7-b917-e7aaa93cfddf	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	5f376fbb-db1f-46e7-9833-88de529327f3	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	bd42c72a-6d92-443a-9991-4c5bf91068b6	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	c4713e39-fe33-48c2-bce7-a8a2ece9c93e	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	eaf4093a-0c59-403a-9821-31ff16dd23f2	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	f76749c1-de4c-4c4b-83b5-d96dd0cbd8b1	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	06cb74dc-a27c-46aa-8868-0bdf3111736a	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	493f3fa9-6d8a-46b3-a5f4-d8bd4595fd35	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	95788231-cc49-4420-8933-e5ea88e17e16	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	985b632a-4b59-4448-aaf4-8bccb9063b04	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	bc7b2620-7468-4cda-9f3e-b12a73e90d14	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e671-7d35-b57b-ba79e8093ccc	ef1c5ad3-16ba-4765-8619-d0b56dd339a6	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	7a060d46-de20-49d4-9000-14a27cf34737	BODY	f	f	19.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	71e2492a-b22d-4ead-8ae4-e4229ac7f276	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	ec1f18b0-82ed-451d-b622-4226d25bbba6	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	11388c8e-101f-49d8-a98c-0b646e6c9c35	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	5338c79b-4a59-4720-a41a-5b7277365be8	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	7f80b386-5490-4b75-b23f-5f7fd7519626	BODY	f	f	0	f	lightmachinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e674-72a3-b6e4-69c5b17f3a1e	c91ddf5d-2566-415a-a1aa-d61c0dc3c9fe	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	dcc75bee-3c87-466b-9667-ff10750cf736	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	eea6aa3a-32d4-42ea-a7c0-f036a44faa8e	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	5f8249db-d47d-442b-89d1-85b05650fabc	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	2b755e8a-d9dc-4efa-921f-954cbb25f487	FRONTTURRET	f	f	0	f	lrm10	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	df90e49f-467a-4ffc-af2c-5c1215af8d6e	BODY	f	f	0	f	lrm10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	e5cf3398-065e-479f-a72c-e2876928b708	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	3ce18ef3-ff22-412f-8f2c-047d929c252b	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	51da1bf8-a3d6-4e23-8565-c02fcf17d618	FRONTTURRET	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	ec9ffe2f-7c81-4196-881a-f89abd7fe0de	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	7f07700c-979c-42f0-aebe-913e4d383b0d	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67a-754c-87ea-c8e670768c1e	bfd5d00d-be94-4bcc-9d68-ebf1082f27ff	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	9781c76f-e1f2-46c2-8e62-62c21829fe79	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	b246e585-5c68-4bfd-afa9-af32ec31abc9	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	ae4b74fe-4786-4fff-b3cb-d13678247efb	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	dfd45b7d-72e0-4012-8889-0bd52e48cf21	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	8f4eb418-7bc8-4a86-a2ff-765850b5c9f7	BODY	f	f	0	f	mobilefieldbase	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67b-784c-9db5-d6ce76f2fd2c	d65f91a6-b2e7-4d78-b890-9883c3af797d	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	ae9dc9c2-58c9-4284-bd2b-c7268e42ff85	BODY	f	f	15	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	1611e604-f73e-4f38-83d2-9f744a16cb94	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	539671b7-a464-422d-9ea8-0c7904116416	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	dbdbd2ae-fbfa-4614-aba6-deffddaa2586	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	21f51821-c4ad-4f08-a4ea-ed49dde11493	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e67e-781a-8912-e1f77ce45fac	29b46f8a-860b-4cf4-8682-96d211a2b1d8	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	0a80c0bd-f3ea-4afb-be79-db36a92e2e05	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	8afaa532-4a39-46ea-a9cb-0c44cf072f8d	LEFT	f	f	0	f	bridgelayer(heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	a86cb60b-a8d1-4729-9ce2-37d85b10cf82	RIGHT	f	f	0	f	bridgelayer(heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	ec7d910e-b8a8-4c99-9ee9-1162ba45bcd1	BODY	f	f	5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	8c3c0d28-b6ba-40f1-a72e-85cfd0208c6f	FRONT	f	f	0	f	lrm15	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	ad43b792-b623-47e3-80fa-afea7f7df3d9	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	beaaeecc-894b-4a6d-b35e-930c65bd9cde	FRONT	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e688-7bca-a9c5-5ca6c628192e	5e5dcc5a-261e-43f2-a504-a2f601c8a415	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	33ce2ed4-3d9b-4615-bac0-8b8f33eacde0	BODY	f	f	19.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	09e6b85f-18ef-49a0-a5ed-69b34c2ff6dc	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	ff8ca72f-a232-41c7-8739-097f68e1fd19	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	51b4473d-87ed-4608-8054-6c78e65728b1	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	9a0b61ee-0da1-436d-a99c-0d1b1af22ca6	FRONT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	f1ce477e-2d7e-4331-8127-bcf1c4b666e0	BODY	f	f	0	f	lightmachinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e68b-75cf-a396-5b8b997fd55f	bc8969fc-3ffa-4e99-867e-a7bf5e055ac2	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	456b12a4-ae9d-466f-b06a-0b15478a7f7b	FRONTTURRET	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	e7d05a3c-4b9f-43d8-9e9a-d6fe5a165adf	FRONTTURRET	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	29ed24b0-b8f8-4da8-82ed-47142f978e72	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	0af41361-c706-4e12-8ce3-dcb653d589db	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	e283aedc-85d1-4531-b881-6fe1c32f574d	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	c7c368c6-e102-44e7-bf66-da00e85dc287	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	f506b251-a65a-4381-8b37-6db06232f8f9	BODY	f	f	1	f	cargo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	c91fb099-b63e-4f05-9e18-ae335dca8f99	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	0f763888-b09f-424f-bfab-0ed88c3cb3eb	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e690-77ea-9b93-91c5ffe79fac	56720303-732b-4144-bc88-fcd0bb04d8a3	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e0-7b06-a615-2b2abbb88cd6	5528c722-8c44-4c28-8138-742d866ac8e9	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e0-7b06-a615-2b2abbb88cd6	1f489ef8-4d97-46ad-a9d0-c0a647246206	BODY	f	f	21	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e0-7b06-a615-2b2abbb88cd6	4a2008c6-c6cb-494e-af3d-674b361fa848	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e0-7b06-a615-2b2abbb88cd6	425b1aaf-5222-4b51-bd70-d7d764dfe021	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e2-7e3e-99a0-16496db45d28	673b5fbe-131f-45a5-9bc0-3423419783fa	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e2-7e3e-99a0-16496db45d28	9df5ebf4-7f3d-4683-83c2-a1367965f3c4	FRONTTURRET	f	f	0	f	ersmalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e2-7e3e-99a0-16496db45d28	499a443b-3ce9-4fc5-b194-d2dcdf7f91f1	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e2-7e3e-99a0-16496db45d28	a1752483-1b14-4769-8e36-b64a0987d6bf	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e6e2-7e3e-99a0-16496db45d28	ecfc86f2-66af-4819-acc5-b423a27ee04e	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	52a7b595-d326-49c1-820b-ccd4af5a24e3	BODY	f	f	7	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	b20cf1ed-5782-42f8-9042-d8f21cf3f960	BODY	f	f	12	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	1d7bd875-e223-4fc1-91e0-c2a37067a438	BODY	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	9768c0b2-51e9-4611-86d7-4e1fdfa3e761	BODY	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	9b051ff6-4339-4a9c-8099-598f8835356d	BODY	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	e84568dc-4c7e-41f4-9618-58e4a244178b	BODY	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	12783295-d6c1-4224-b837-62dfc351735f	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e727-7a8f-9e84-a4b0c69276a5	2562cf9c-15ff-4bdb-9f0d-f3199755b7cf	REAR	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	b2ae8b5a-669a-4b25-a438-64dd8c9f8e0e	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	22e77d69-0098-4f1e-918c-2cef26841203	BODY	f	f	0	f	ecmsuite(guardian)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	627dc454-0964-4f06-beae-6bb9d82b1b41	BODY	f	f	16	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	55f73ba1-e801-41ce-a9c1-dbaa387c6870	FRONT	f	f	0	f	srm2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	b423e657-179d-49b4-a0cc-b3c131e24a58	FRONT	f	f	0	f	srm2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	32399f76-646a-4c1a-87f0-a4ae23daac05	BODY	f	f	0	f	srm2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	da480318-5558-4ccb-9372-9fee957033bd	BODY	f	f	0	f	srm2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e72f-707b-a00a-560fe7270860	54509e66-8e88-4024-a400-fa3ae27c1015	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e731-7888-8c39-b99da4acf787	4b615eb0-dd79-451b-9410-fbf51f890586	BODY	f	f	4.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e806-7a90-a05e-960ee185f5a1	c532257e-02eb-486a-9b8c-d3d589514b6f	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e806-7a90-a05e-960ee185f5a1	950279d7-ff98-4350-a683-5642fdb51596	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e813-7306-bd3b-30e5dfae7622	9aaa2b75-972b-4141-b643-f239ea7c11a5	BODY	f	f	0	f	case	INNER_SPHERE	\N	\N	\N	\N
019f583e-e813-7306-bd3b-30e5dfae7622	27d3b5c9-1374-459c-8ad6-c14fcd096e39	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e813-7306-bd3b-30e5dfae7622	c4256163-27eb-4765-a7ed-f531cad29e63	BODY	f	f	0	f	mobilefieldbase	INNER_SPHERE	\N	\N	\N	\N
019f583e-e813-7306-bd3b-30e5dfae7622	2f2a95d9-6efa-48ee-8a9d-d5436cb5886a	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e813-7306-bd3b-30e5dfae7622	0b4d51f2-7a0e-4c26-930c-03cd2b43a185	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8c7-75f1-8d54-551bf09a0730	1369b869-68d5-4607-84a6-4ea8b1b76b9d	BODY	f	f	0	f	advancedfirecontrol	CLAN	\N	\N	\N	\N
019f583e-e8c7-75f1-8d54-551bf09a0730	6a068668-c025-47eb-a4a9-4cbcef8a4bd3	BODY	f	f	1	f	infantrybay	CLAN	\N	\N	\N	\N
019f583e-e8c7-75f1-8d54-551bf09a0730	6a115190-2a50-46e3-bc1f-d4e98e05d94e	FRONT	t	f	0	f	supportlaser(semi-portable)	CLAN	\N	\N	\N	\N
019f583e-e8c7-75f1-8d54-551bf09a0730	2dd35ea0-6774-4ea0-9a38-ff530eddbfa0	BODY	f	f	0	f	svchassismod[bicycle]	CLAN	\N	\N	\N	\N
019f583e-e8c7-75f1-8d54-551bf09a0730	c3b507e1-31cd-471d-900a-86459b961470	BODY	f	f	0	f	svchassismod[omni]	CLAN	\N	\N	\N	\N
019f583e-e8c9-7cbe-a88f-62c6e42329ad	f8f4d7eb-1928-4048-946d-f031923c6c6a	BODY	f	f	0	f	advancedfirecontrol	CLAN	\N	\N	\N	\N
019f583e-e8c9-7cbe-a88f-62c6e42329ad	7d49177a-5e79-4b84-a407-4984252acc3e	FRONT	t	f	0	f	autocannon(bearhuntersuperheavy)	CLAN	\N	\N	\N	\N
019f583e-e8c9-7cbe-a88f-62c6e42329ad	86234092-4a3a-4a3b-988a-e80112ce85f5	BODY	f	f	1	f	infantrybay	CLAN	\N	\N	\N	\N
019f583e-e8c9-7cbe-a88f-62c6e42329ad	2a6db452-ffa6-4eb9-8f2f-a43ca022a7a9	BODY	f	f	0	f	svchassismod[bicycle]	CLAN	\N	\N	\N	\N
019f583e-e8c9-7cbe-a88f-62c6e42329ad	5ecf7bf7-0d35-4afe-818b-967883f0dd17	BODY	f	f	0	f	svchassismod[omni]	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	6f2b5638-ee1e-4a88-83d6-0712ee072f43	BODY	f	f	0	f	advancedfirecontrol	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	cd6e864b-4d09-4c63-8c49-76188980d326	BODY	f	f	1	f	infantrybay	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	55f8a64b-2907-4a78-af9e-b19d69301ec4	FRONT	t	f	0	f	laserrifle(mauseriicias)	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	95c27817-41cb-46b4-a9dd-b67f3491ced2	FRONT	t	f	0	f	laserrifle(mauseriicias)	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	520d7fe9-d186-4391-91bf-d8028fccd02b	BODY	f	f	0	f	svchassismod[bicycle]	CLAN	\N	\N	\N	\N
019f583e-e8cb-7c3a-9c9e-7a217b4325d3	98a6196d-0b7d-4805-aa3c-5135568d0387	BODY	f	f	0	f	svchassismod[omni]	CLAN	\N	\N	\N	\N
019f583e-e8cd-79f5-ac82-f89dfc20dbee	8b4ca88c-99c1-4df5-949e-2a0ddbfa20b8	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cd-79f5-ac82-f89dfc20dbee	992c2062-7fbc-451d-a9d3-a8e5367f8cb5	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cd-79f5-ac82-f89dfc20dbee	f838ec54-0522-4d55-bcc2-d675df169554	BODY	f	f	2	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cd-79f5-ac82-f89dfc20dbee	44731834-e6e8-4dfb-a650-65f810e458fd	REAR	f	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cf-7c27-b0c7-b3c22c44e45a	43e75b42-7f60-4252-b0fe-ecabfc303ebb	BODY	f	f	0.04	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8cf-7c27-b0c7-b3c22c44e45a	9d56c5b2-1f4f-4106-9afd-78c7df00da8d	BODY	f	f	0	f	svchassismod[monocycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d0-7cae-9e0c-25c7f6e835bf	9ba58f04-de58-49ae-b355-a7deb61b0555	BODY	f	f	0.02	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d0-7cae-9e0c-25c7f6e835bf	89b0a5bf-2e25-40e9-b4af-3d43739a5327	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d0-7cae-9e0c-25c7f6e835bf	446e6cb7-c702-4fda-96ed-6b7022936929	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	29eee9a0-9ecd-4182-af2f-2f81ec1a7e5a	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	1dbcdbc4-471b-4eac-852d-249aa3909afe	BODY	f	f	0.2	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	68d50db9-a7e7-4499-b9b4-9d07c275cd97	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	b2903d27-7fad-450a-9186-2aa3c016b69d	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	fa14a6c6-32a3-414d-a0db-5307482b9adb	FRONT	f	f	0	f	srmlauncher(std,two-shot)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	521bbea0-6706-47da-afb2-9cd1f2c89b17	FRONT	f	f	0	f	supportlaser(heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d2-7000-a8c2-9e2a44f5ae51	7a5a6029-4ef4-43b3-bb87-f6bce52314f3	BODY	f	f	0	f	svchassismod[submersible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d4-7f7c-9235-fa32872c784e	be1a7346-3c66-499d-9c39-e5d00a3a2dbe	BODY	f	f	0.7	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d6-7df9-8874-e3dab445ead1	4f38d459-8058-457d-9dca-c7c717d3c601	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d6-7df9-8874-e3dab445ead1	4a913a71-9dc6-40fe-8cf6-a64f509e99b9	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	088becaf-25bd-4bf5-83c8-5983578ac05c	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	1a2e3d69-31c5-4097-9c38-88f5a8b04d73	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	3ffbddd9-bd22-42b5-8d13-5f706ea1599f	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	f67ce695-3e03-41bc-b8a9-6aef9a25c2fe	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	b6fbf7dd-dcdb-493e-b699-364ea9baafb6	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d8-7171-9fd0-4da83cb95ff1	3177ca28-83a7-4345-b20b-336d02aae76f	FRONT	f	f	0	f	tag(light,man-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	8baa8d49-fc4a-42f7-8647-4fc97b25383e	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	0d58988e-36c5-4a5c-a216-555da3cc5f0a	FRONT	f	f	0	f	grenadelauncher(auto)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	814d1617-6daf-46b0-9b56-235a53598743	FRONTTURRET	f	f	0	f	heavyflamer	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	8939a252-766b-42eb-8364-874fe08eaf89	BODY	f	f	2	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8d9-715d-abd9-9da2e9f5bc2f	c71661b3-13e3-40dc-a1e4-38f22e3bd979	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	6406fa5c-fc67-42cc-a20f-e21e2d0564fb	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	fc769f7e-1a6b-41dc-a903-29f291dbe6d9	BODY	f	f	0.04	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	68e3b187-3573-43ef-b106-330a3923ac2a	FRONT	f	f	0	f	srmlauncher(std,two-shot)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	6436d502-0c32-4c36-a14a-0d321af309a6	BODY	f	f	0	f	supercharger	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	8b04ca37-8136-4d60-95d2-c98448d5eafa	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8da-7f95-b3ef-20609635092b	bcf1c80c-b86d-47bd-88e6-d0b622df6181	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dc-72eb-906e-b0b726970333	7e682d84-4553-4628-ade9-8f6badbef6e6	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dc-72eb-906e-b0b726970333	a0d3994d-a442-474d-9338-7c5a4e3aa84f	BODY	f	f	0.2	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dc-72eb-906e-b0b726970333	2d4976ed-da19-4eb2-95b1-50956022837f	FRONT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dc-72eb-906e-b0b726970333	c1c06b40-24ed-4cd1-939e-490a1be132a6	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dc-72eb-906e-b0b726970333	01db4f5a-6421-4306-896b-bb5e37dddbec	FRONT	f	f	0	f	wire-guidedmissilelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dd-766f-9b54-3ee51394b3f1	697d4d31-4ec1-4596-910c-c601bf4945c9	BODY	f	f	0.3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dd-766f-9b54-3ee51394b3f1	bf92fb99-43a5-4d0a-ac35-06c128d68ff0	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dd-766f-9b54-3ee51394b3f1	d574e3e0-bf50-4a22-a14d-cbaf6b7236a4	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dd-766f-9b54-3ee51394b3f1	0f66402a-562f-4455-b473-aba1514286a6	REAR	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8dd-766f-9b54-3ee51394b3f1	3b8e7282-dae1-42d9-83f7-a71862b8d75e	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	6a9a52ec-a776-4d9b-a09b-cb1857ae96ce	BODY	f	f	0.7	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	648b43ce-225c-4530-9ee3-32192cb4e0d7	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	72143f4a-efa6-4d30-8641-ecfd677acaa8	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	825f2305-1334-4292-a269-f4cea38803c6	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8df-7489-87be-783213e374a7	e96702c9-e652-4139-9a72-85d1429c57d4	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	18f9bc77-47c7-4c6a-b346-41657427c88c	FRONT	f	f	0	f	activeprobe(beagle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	f73aaaca-ee3e-4d94-9fee-1cf097062782	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	8bf3221b-64c5-41e6-9976-7a9134bb3df9	BODY	f	f	0	f	armoredmotivesystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	dc81e01c-b35c-4b9e-aa15-db4d4bbe8daa	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	bdca5ce3-e4a1-44a7-978b-dbaa37cb606c	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	595a2b41-ccd5-4fb4-8d18-3876c87cbd99	BODY	f	f	0	f	jumpjet	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	6432ea46-c918-43f1-9ac4-e0558aa84e87	BODY	f	f	0	f	jumpjet	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	9816ea7a-c523-468e-ad13-50e75363b213	BODY	f	f	0	f	jumpjet	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	f9530eaf-b1ba-42f1-b221-d55ebea6e998	BODY	f	f	0	f	jumpjet	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	215b7b09-7256-4fc5-bdab-39ae2749f0a9	FRONT	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	6a2f1886-e00d-4c50-9b42-9dfff3817025	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	c2bd512e-4f19-4be2-829f-3f171b401d11	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	3ce19b6e-9786-4e98-969a-3ca87e0683fc	FRONT	f	f	0	f	miningdrill	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	9122dfa6-cb11-48bf-9fe8-a1a816152ccf	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e0-7156-b045-bfaa36119249	7dc8c985-56a3-46fd-94c2-6e24dfd826ec	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	a0150c7a-ab71-45eb-bf61-5c7789c85913	FRONTTURRET	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	e7492971-4ceb-43c9-8fc0-cb5f8ecd9b9f	FRONTTURRET	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	7757dc2a-b68e-4ce9-ad89-15bfc2e35d17	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	92a518c8-19fa-428a-91c2-057535d4095f	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	aea23939-5ced-4ed7-8547-f87d531f9d21	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	52b66498-aad6-4423-86f7-59b57e8cb7ce	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	fcb037e0-7764-4666-a36a-26d3426e476b	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	d410ecce-e848-4f83-82ac-b6ba600e0e71	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	5064f35d-daaf-4c66-acdc-3944df4aa5de	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	6bebe2a7-ebb5-4cb6-87a2-1795b16738fb	LEFT	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e1-7dce-aea0-a3d6b48c0c03	30303a0f-4704-4412-bd93-eb83979085f8	RIGHT	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	b1ccb844-3caa-423f-ab6f-bd7adefbf946	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	3bb6b4de-44fb-4494-91c7-684397703f79	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	536f1444-e2f2-484a-9b31-0c4619f3d04d	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	5862631d-196b-4d9a-b851-beb4df08d4f0	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	6d51cc9a-a14c-4b99-8ac6-3028b35b85b3	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	959ebc45-9615-4872-b36f-4ada4a45bc24	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	b2d87d8e-27b2-485c-ad62-80d02753b810	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	df3cce3c-82cd-4872-8700-3dcacc0a16fe	BODY	f	f	0	f	heavyrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	2fbcb238-4a5e-4ac1-9ef4-fc4f36172684	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	6aca650b-c6b8-46d4-9005-487ebdf4f107	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	c5d197de-ad9e-4087-92c3-31c183d60361	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	ad0dce7a-d127-4e33-baf8-c10f74567584	FRONTTURRET	f	f	0	f	rifle(cannon,heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	12e932cd-7ba7-404e-85c4-0fb0961be023	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	2860f4c6-00c1-4759-94b5-99ef790fc914	LEFT	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e5-7b3c-add5-107849771830	2540098a-3263-4515-b9bb-e298aca511aa	RIGHT	f	f	0	f	vehiculargrenadelauncher	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	a65052c9-cd2d-4700-bdbc-b9f6b60d269f	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	09e13c22-5f9a-4e03-9b8e-7be1acd31103	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	44e22b83-7655-433a-bd5c-142577167caa	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	edd9f237-fbd3-4de9-9ab6-34cf46d5fb11	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	802500ab-2867-41ab-91cf-d55e64ef2df2	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	5a10c8aa-cd69-4e37-b83a-7dc7b6e35a6c	FRONT	f	f	0	f	srm6	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	baada254-c220-4602-9644-dc4d4b2e9b91	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	cc848f7d-75d5-4281-89d5-99e20538af90	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8e6-70c9-91b1-d2f2a0ef4fe7	85880c35-1b9d-4836-acc4-cb870e1a10d9	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f4-7564-9283-eef7d59681c3	29f24579-f294-43ba-83e6-7f4aded3a637	BODY	f	f	7	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f4-7564-9283-eef7d59681c3	8fd62bef-7421-4a6f-8682-f36c5c35aefd	FRONT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f4-7564-9283-eef7d59681c3	74c700ae-4fbb-433a-9f81-eeded91a3e89	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	3c18ab48-00f4-474f-a9a5-132e50258907	BODY	t	f	7	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	7f82e694-70b6-4260-97d7-05eff7a46b77	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	0eee35ef-c14e-445c-a482-06f48bb41b70	REAR	t	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	b5429c9a-882f-4126-8066-5c3092d8ebe7	REAR	t	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	281a0fe2-5e68-491a-8f9b-3229a36ca3fa	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f6-7734-b7fd-8bec3772bda2	4390c6dd-f5f9-4e3e-b3f0-2e1eaf6fb2d0	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f7-7f4d-b7a0-d300976b8c70	6f950a4d-5573-4ca6-a845-0a384997f334	BODY	t	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f7-7f4d-b7a0-d300976b8c70	e59f7647-d431-49d4-8e87-f91731a5ef94	BODY	t	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f7-7f4d-b7a0-d300976b8c70	cc067ee1-07b7-4f21-8fe5-b42c1a95e24c	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f7-7f4d-b7a0-d300976b8c70	7db9b38c-93e9-4000-b647-c506f9028f6a	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f7-7f4d-b7a0-d300976b8c70	43486950-42a6-4482-8061-e6ea8d2f3679	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f9-7e9f-8ef5-1ba56493b1fe	9d303ffb-8798-41b5-9481-375f2077ad06	BODY	f	f	2.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f9-7e9f-8ef5-1ba56493b1fe	ce628c47-9fa6-431e-abc1-9eea8e8f7a80	BODY	t	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	6
019f583e-e8f9-7e9f-8ef5-1ba56493b1fe	1e7681cc-5ac6-4d76-8019-ae8b4db22f77	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8f9-7e9f-8ef5-1ba56493b1fe	667359d5-db7a-42a8-9e7e-eb408fe8ec4f	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fa-705c-a86e-641d91a256aa	f1400321-a000-4186-abf5-f54c72da685f	BODY	f	f	1.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fa-705c-a86e-641d91a256aa	30a700ba-cc8b-4618-9413-77d25f24d4e6	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fa-705c-a86e-641d91a256aa	67c60d6a-e2cc-46b4-b49e-3ccd273f0c2f	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fa-705c-a86e-641d91a256aa	abcd3d5a-da2a-4f56-aeff-222c193686a0	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fc-7622-afeb-8df8291b40c6	c926cd78-1601-46c8-a007-1102c6cc4d78	BODY	f	f	11.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fc-7622-afeb-8df8291b40c6	c1641435-9c07-484a-bffa-944e97b384d5	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fc-7622-afeb-8df8291b40c6	073d1664-fd31-4811-9ec1-cb8afdf673ed	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fc-7622-afeb-8df8291b40c6	5f6a0336-0c12-4dbe-a1c1-8d261e2ffe5a	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	a151dc01-7cd8-43fb-bad1-74eda9231481	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	72f6b55d-a912-4ed8-ad25-b152a5660272	FRONT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	cca47185-99e7-4ba3-888c-e55556be5a90	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	ed1488ed-c39a-4a9d-af2e-201db0596978	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8fd-7e7e-a398-e9a547d14830	75cda64a-2326-40b9-95a9-d11aa5143263	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8ff-7c25-89b0-57a8dae3ae7d	50178ebd-8902-4db1-a075-3d586558e73c	BODY	f	f	2	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8ff-7c25-89b0-57a8dae3ae7d	3e44b7cf-5d44-4d3f-bdea-9a8107baea86	BODY	f	f	4	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e8ff-7c25-89b0-57a8dae3ae7d	0d9d31fa-3411-402d-9de5-8c5c0e9f0ccd	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e900-7dd6-97b8-dcea7bba7a3e	6800b484-504a-49fe-a0b3-c5e5a5eaba99	BODY	f	f	2	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e900-7dd6-97b8-dcea7bba7a3e	c4963a00-f14a-4f50-bbfc-14b5ba489a26	BODY	f	f	0	f	drone(remote)carriercontrolsystem	INNER_SPHERE	\N	\N	1	\N
019f583e-e900-7dd6-97b8-dcea7bba7a3e	dce23a9e-65c5-4a36-8d20-a62f941e212d	BODY	f	f	5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e900-7dd6-97b8-dcea7bba7a3e	b96695ae-a1cf-43eb-98c8-554aec0961e1	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e902-71ce-9cc5-05cb327cd5c8	a2895d7a-800b-4b5e-b7ce-9960b196bc80	BODY	f	f	0	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e902-71ce-9cc5-05cb327cd5c8	4c8a5f1a-98f3-44a2-8eef-42db546b6c10	BODY	f	f	0.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e902-71ce-9cc5-05cb327cd5c8	3ecf543a-b370-410f-afc3-cdd1a0bf0422	BODY	f	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e902-71ce-9cc5-05cb327cd5c8	7306386f-b44f-41be-892f-0d50f176fd64	FRONT	f	f	0	f	satelliteimager(high-resolutionimager)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e902-71ce-9cc5-05cb327cd5c8	98582fa1-c7af-4d5a-a1de-e776d489b4a2	FRONT	f	f	0	f	satelliteimager(infraredimager)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e904-79eb-b552-460ed6242c3c	5746bfbc-84e9-4e5b-97d4-8ccd17054fd7	BODY	f	f	0.81	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e906-700d-b94b-51df5ac8b568	981b161f-dcaf-4b4a-8a3f-6d26e0dc96fa	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e906-700d-b94b-51df5ac8b568	c8bd434c-5309-447f-b078-a84afc6f4771	BODY	f	f	14	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e906-700d-b94b-51df5ac8b568	d000ee66-d5ec-4d9b-a1c8-d975ab596260	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e906-700d-b94b-51df5ac8b568	6a588368-525d-4bcc-bcbc-f8b7a31c3df4	FRONT	f	f	0	f	satelliteimager(infraredimager)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e906-700d-b94b-51df5ac8b568	d1b2743c-ea90-45d1-a3f8-e4d2f89a221e	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e907-7d40-b85a-70a5c8b4fc5f	2d4a112a-5da2-4681-9a85-d3697e08a8a4	BODY	f	f	60.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e907-7d40-b85a-70a5c8b4fc5f	5b3e42eb-c055-4177-bf62-801cc2f0a31c	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e907-7d40-b85a-70a5c8b4fc5f	703b6381-86ae-4a14-b764-e5beac4c432f	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90a-7725-ae3b-6fd6beb2e32d	059edff4-9265-43e7-a9e0-a14a2c527794	BODY	f	f	55.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90a-7725-ae3b-6fd6beb2e32d	ab8725e6-40b0-4441-8e58-e17848441072	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90a-7725-ae3b-6fd6beb2e32d	300d235d-1a1e-44db-8135-1a082c284a6e	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90d-750f-82f4-4ae3cd916c2a	4fe29f29-e622-489b-bb39-1b0edc1f7a2a	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90d-750f-82f4-4ae3cd916c2a	62581baf-8f63-48e6-a072-3554effa9dd3	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90d-750f-82f4-4ae3cd916c2a	e6627cbf-9fd8-45fc-a603-aadebe8fffe2	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90d-750f-82f4-4ae3cd916c2a	8f8114ae-0011-4df2-91d5-d16c1f5cb7c6	BODY	f	f	11	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90d-750f-82f4-4ae3cd916c2a	ff73f5e6-3c55-4243-8ea3-1a4cd64522e9	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90f-72ae-873e-3d4014ac2ff3	ceadd61f-3445-45cf-8f32-6f25ae55be29	BODY	f	f	58	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90f-72ae-873e-3d4014ac2ff3	d8534170-4743-4f9d-a198-dbf95d6ed2c5	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e90f-72ae-873e-3d4014ac2ff3	7356033a-970c-4470-8fa1-21935a50d1ff	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e910-7643-8852-814c6e90b4f0	00ec339c-04dd-4e25-91ef-3edb87bce531	BODY	f	f	67	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e910-7643-8852-814c6e90b4f0	02be9373-feda-4f3e-860d-14b050adeb99	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e910-7643-8852-814c6e90b4f0	cee041a1-fa7a-40b6-b9c5-3e365ea8a20b	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	0cd0d573-8424-48b1-bc38-73a0f50679f0	LEFT	f	f	0	f	gaussrifle,light(kingdavid)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	0342ce14-dc67-40e2-89b3-07eac6805446	RIGHT	f	f	0	f	gaussrifle,light(kingdavid)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	d1045de1-f73a-4d18-8691-6af85a3195c4	BODY	f	f	8	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	04d8bdbd-2861-4a17-914d-5379ba88f5f8	LEFT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	56d3cd2b-8e8e-4e54-bba4-cb4319c3d3f1	RIGHT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e913-7389-a648-0624c05f2f44	b70f9d53-8f94-42c5-b0f3-d37b3328881a	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	34e13cdc-d2b9-47a1-a979-7e3daff6e12a	BODY	f	f	8	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	87cfec87-1c4d-4c93-93b6-95c6fb3aeb4c	LEFT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	df1dc2ce-5f84-4ba4-a36d-b5cbf8e3de33	RIGHT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	f79a52ad-915f-4bff-8b37-9f194390927d	LEFT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	3d9fde7b-9e8a-459f-a6b7-bcd2beb53736	RIGHT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-e914-7693-8724-943128800a78	c5ab7900-49b4-4db6-b0e2-8b2f33869b77	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e915-7783-b5dc-1e16b1dfac0c	6dfb7b16-4d85-4df7-be3b-e53777af4a9f	BODY	f	f	0.601	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e915-7783-b5dc-1e16b1dfac0c	839a398a-f928-43e0-b51c-aed8fa08f42c	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	6a6de285-64f1-4572-888a-7c9793244ae9	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	252a1453-1be7-418f-979b-6372d345dba4	BODY	f	f	11	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	95bdb1a7-5695-400e-858b-a7b0b410ff41	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	0d410b9e-92d9-4502-abe5-fd1047300f74	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	5996cc90-fa53-4cd8-b183-136b74c125ba	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	f732f4c5-f988-4d9c-9994-3ce0598ced00	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	f898f806-a9b2-4878-91e7-26b16fd844f4	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e92c-7ea8-8f09-e39bc182cda4	52959d85-b921-4744-807e-9f6a69a22332	FRONT	f	f	0	f	mobilefieldbase	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	02868e51-b62e-48fc-97d0-fc989d6cc22f	REAR	f	f	0	f	ac/20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	8e9bcadf-b28e-4295-9f13-aa05eb0c887d	REAR	f	f	0	f	ac/20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	c99b1aa0-ad54-4c2f-b105-8324dfc93a97	REAR	f	f	0	f	ac/20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	8a42b4cf-1778-4c48-b762-66b6a1f7d28f	BODY	f	f	0	f	ac/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	b0d7ca8e-e0e6-4a9f-8971-d66ad13c8080	BODY	f	f	0	f	ac/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	fd72dfbd-74f1-41ff-b4d4-fd3552928e0e	BODY	f	f	0	f	ac/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	532b1ed1-d183-4271-b88e-96475249ec4f	REAR	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	4820fbb0-7463-4d21-93a0-977e04f7bd71	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	7aaca08a-213b-4ed8-8802-059f501b40fb	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	6d0e1f30-2aa2-407b-8334-daef357f8c5d	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e935-70b2-ba3e-07e18e7145bf	c2267389-2cdf-400a-b583-caf6c4ac6685	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	a436e5bc-3de6-4815-acdf-b32440ae70aa	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	3ac1cdd7-e6a4-44fc-b84e-084a750fa1f4	REAR	f	f	0	f	lrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	3f22d6e8-ba0d-4263-abea-c6a3b2089e7f	REAR	f	f	0	f	lrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	6a33d073-9589-4d98-a031-befc455a2227	REAR	f	f	0	f	lrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	700d1f55-ddaa-4afb-91d9-5ef0f11c2858	REAR	f	f	0	f	lrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	0ab7d36d-9258-43cb-992a-a185c765d350	BODY	f	f	0	f	lrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	0db2e418-b438-4918-a55a-950a607a2866	BODY	f	f	0	f	lrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	6670adc9-346c-461e-a206-7d24daba8c9b	BODY	f	f	0	f	lrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	9d619265-4289-4031-b6fc-399c8701ae08	BODY	f	f	0	f	lrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	d60a9eed-6985-45d1-8e2d-b82386390c0e	BODY	f	f	0	f	lrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	011adec9-0cf6-4054-93d7-f8f26d714ec9	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	3edb47df-a5f1-49a4-bd99-1fb738dbfe34	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	3ec54188-869d-45d6-82d4-8d9215616240	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e937-74b5-b408-3a549695a9ad	028b7079-c10b-4339-aec3-fecde1d0bcf5	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e962-7b51-a87b-cc6ad71000e3	132753f7-822e-40a9-bc17-4609e85e876d	BODY	f	f	0	f	ecmsuite(guardian)	INNER_SPHERE	\N	\N	\N	\N
019f583e-e962-7b51-a87b-cc6ad71000e3	9e9fc542-edba-481d-801f-526a78dabc00	FRONTTURRET	f	f	0	f	reconcamera	INNER_SPHERE	\N	\N	\N	\N
019f583e-e962-7b51-a87b-cc6ad71000e3	5aba4c7a-2076-4e50-8285-6ceb9911b8f3	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e962-7b51-a87b-cc6ad71000e3	67553187-ea94-46ae-b2f0-0ea8a190b0bd	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-e962-7b51-a87b-cc6ad71000e3	c2c7916d-abd2-431b-a160-32692790c773	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	9c481acc-8919-4960-b7a7-1c72d57a534f	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	5b986bdd-234d-42f7-976e-88c4581485c7	REAR_LEFT	f	f	0	f	anti-missilesystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	c2972447-f9c1-4079-a6a1-fbbbb3cb56cf	REAR_RIGHT	f	f	0	f	anti-missilesystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	574c9b75-1f9d-49a4-aba1-51cc479b8b74	BODY	f	f	0	f	anti-missilesystemammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	be13bb94-71ad-4b18-84a0-c7ed39027b6d	BODY	f	f	8	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	9cfa313b-7aa7-4594-8f10-b6f7484cf0bc	BODY	f	f	52.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	a4a555ac-3041-4ad8-9141-8eb5b34a36c7	BODY	f	f	0	f	supercharger	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	3dd24a0a-1a27-4fc1-a6d5-d3ebd53a5fb1	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	0c14e7e3-d400-4fd6-8416-ba23303b7b91	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	391fd11b-db3b-4b62-9783-3cb70ad0446a	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	829d02ba-3310-455f-9ae8-8b712e3d8a05	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	f5977962-3108-42ad-9654-196b3a33f4e7	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	fd9aeb0d-2126-4647-9bbc-c275b51bfe1b	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	21039ec3-6624-44a6-ae76-d55d31cda18b	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	5434604a-260f-4258-9047-bf9bd584dde4	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	566c73ff-3e79-4f52-ae1b-f3e597164b67	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	6cc7b5b9-e3ab-4659-a83c-d49314968608	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	6e859571-65c9-48a2-8e99-fe85b303877a	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	7ece576b-bb00-4cbf-bbf6-a1733caff790	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	989c8350-4319-4402-9c4c-6f162ebd5af1	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	c28fa856-3772-4288-9ea5-3666c4f4b5ad	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	e5391c25-bdde-4d3a-9bbb-f62555faaac8	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-e965-724d-8c86-a8e46210b74e	ed189451-61a0-4c68-81d2-308efd0a4173	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	28198702-9676-492f-a3e0-4578435868b4	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	e61d63ea-8b2a-4527-a0b0-0955199f25b7	BODY	f	f	5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	1ca794ac-8979-4bbb-97ae-fa445da4404c	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	57df0549-e07a-436a-968d-edbae6a5a6c8	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	7842e60b-c08e-4c1e-860f-33f28e770151	BODY	f	f	0	f	mediumrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	8c4786df-db0e-4ffb-9f0d-934c3eab2f6e	BODY	f	f	0	f	mediumrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea5f-7925-92e7-611ca0aba32a	29d6271a-c286-4679-b7a6-51b09799bd58	FRONTTURRET	f	f	0	f	rifle(cannon,medium)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	1096c515-ecf0-437c-b5dc-77fd1c68cf2d	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	4aa4f23c-eada-42e8-a257-2a520bcccc74	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	c04dd194-ee3d-40eb-b8a9-bd1b47afba64	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	0ce86b5c-36d3-47a4-887f-c90c1601fee2	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	ce0ed628-fd13-45f4-87a5-8739386c98e9	BODY	f	f	5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	dee10ac0-cc12-43a6-a92f-f379214ea5f8	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea61-7566-870b-5ed3a47568d4	10661677-f69b-4db5-b787-ee83ccf75034	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	c05e6cf5-9fa1-4e8b-b2c6-759258bf499c	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	9350a501-624a-4b09-96c5-3eb41e90a3ba	FRONT	f	f	0	f	combine	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	d5c631b5-55a1-4a34-b506-842ea2798745	FRONT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	7a88e953-7c4e-4074-94d7-69e7067b5510	LEFT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	9df77246-3977-4587-bfeb-448186a183fb	LEFT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	ea6b2948-5d60-472f-8472-c7582c02b36d	LEFT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	0a723d7c-4367-47f0-a53b-53f50eb1cfb8	REAR	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	0dc717da-c77c-4ee9-99ef-20d00aba38ab	REAR	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	2656532f-868b-4b0f-a921-e365e56081c9	RIGHT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	3d02224d-d455-48cd-aead-647d9220398b	RIGHT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	98b1ddbb-819a-4d1d-8576-14fe9b3aa96f	RIGHT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	672e5186-5a0a-4dec-bbd0-19b61b1db5cf	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	f65a684d-ea1a-4d39-99b9-95338232d882	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	19236e93-3dd9-4168-8996-e7c2b2058f34	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	284a309a-e93e-4b9b-b01a-dfae9c43a555	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	8a9e8e9e-dab3-4869-a144-8c0b9cf2ed99	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	13d3d6a5-80e9-42c0-86bd-0626426ac6d5	REAR	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	2a83ed51-afdf-45e9-a84b-febf0852568c	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	5ea3eb70-2ce8-4522-894f-589598bbe25e	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	5ef1dc50-be8b-4319-8a19-fe1f76d3f357	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	1e36251f-51cc-42af-80e1-30f3e7dddf6c	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	249dee87-e717-4d54-a1f1-5ade75a6abe6	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	5374f5ce-673d-468a-8f32-ad3f6bb7470a	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	5409e964-5f79-4415-ba09-43412434d1ef	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	6804349f-6c4b-446f-8b1f-47885b5ee791	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	6ff52536-66d9-4f3e-9ea1-8632d43a7131	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	713b2c97-366e-4572-8aec-731cfd0bc5c7	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	80ba801d-197b-4619-9b77-ee4c7c8dab08	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	a0a58666-5c35-4a43-ad07-fc33f1452ecb	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	9f19e36f-7b5a-46fa-b762-c85243e6b093	FRONT	f	f	0	f	srm2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	1f4fec68-00c3-4bbf-8b54-62a1d673e613	BODY	f	f	0	f	srm2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	7a8b7d4d-aebd-413f-8c43-144b01b59403	BODY	f	f	0	f	srm2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	b33e4a0a-2f5e-45c7-88b7-5ad5c24b7aad	BODY	f	f	0	f	srm2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	248e93d0-961d-4ffd-b99a-a7c32fbf8d50	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	4054ef60-a266-473c-97e5-73e41d7ba466	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	92472002-6c43-4475-bccf-9abd29a55b9d	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	984a81db-4016-4297-bdc6-728c0edb8d26	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	ba9fdb95-7052-4119-93db-4c6cd324680b	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	bca9001f-fbe2-47c3-b5a5-e1d48ea55164	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	cdf27ea2-ee00-4749-9268-aaa00f742bf0	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	d219cf98-d8d5-4785-9ac5-38dfe3542d0a	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea62-7318-978c-0befea421dfe	dc16fbff-55c7-4c57-a766-83a0ee66e1c3	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea64-7933-93eb-c6be11ec1aee	81514a3a-f6d0-411d-820c-8d9efe8501f9	BODY	f	f	0.234	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea64-7933-93eb-c6be11ec1aee	fe4f10db-fa12-4155-8c21-722c7a8da810	RIGHT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea64-7933-93eb-c6be11ec1aee	c05c2f6f-cfcb-41c6-b3ec-dd47372c9dfd	LEFT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea64-7933-93eb-c6be11ec1aee	6ccb8df8-8cfb-4681-b0a8-9c12f261fe8b	RIGHT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea64-7933-93eb-c6be11ec1aee	905e5396-1ae1-4ead-8e14-259283afa146	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea65-73df-9d60-09bb7587ad94	3e100286-9d5a-4dc4-adc8-aa950601e187	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea65-73df-9d60-09bb7587ad94	fc9529e5-faae-4043-a156-b5804e7a868a	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea65-73df-9d60-09bb7587ad94	25d54950-3ae5-4d2a-87d8-35d10981c5f5	FRONT	f	f	0	f	supportlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea65-73df-9d60-09bb7587ad94	c3efd159-c2e1-4ac8-9d08-88c607555dee	FRONT	f	f	0	f	supportlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea65-73df-9d60-09bb7587ad94	4357a700-d767-4480-9848-1736ae426036	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea67-7d08-ac7f-4b1ab3191905	cf273cb5-10f0-4f99-ba8a-6bf7782babed	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea67-7d08-ac7f-4b1ab3191905	622d23a0-420c-43c0-87dc-567dd79be397	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea67-7d08-ac7f-4b1ab3191905	8af3428e-0e4c-49f9-bc95-f8c6ffa89e7f	FRONT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea67-7d08-ac7f-4b1ab3191905	e88dda6f-fa32-4e16-93b0-8959c761d8c1	FRONT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea67-7d08-ac7f-4b1ab3191905	0817cb5e-d0d3-4289-ad4d-af51054154d1	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea68-7726-b719-e46c85a620fb	bceee1d4-0577-4347-aef5-4ec019c8cb69	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea68-7726-b719-e46c85a620fb	549a3b0f-9201-403f-a4ee-70f322c6bfab	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea68-7726-b719-e46c85a620fb	187f6204-4f49-43fd-ab3f-e96693864ee5	FRONT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea68-7726-b719-e46c85a620fb	f226d2f1-be89-47e0-8bcf-d8cff198cb53	FRONT	f	f	0	f	supportlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea68-7726-b719-e46c85a620fb	718a8138-b4f7-4f69-aaf4-2f73577366c1	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	840e17e4-11f8-4123-acf5-47f6e1c57236	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	ea68ad37-9372-4bc8-b1cd-823d7114cfd7	BODY	f	f	0.021	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	58753938-bc5e-4011-9610-3551f91ed67e	FRONT	f	f	0	f	srmlauncher(light)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	72a9da52-e903-4152-8da8-cae8a085ed84	FRONT	f	f	0	f	srmlauncher(light)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	7745e0ac-3831-4026-8970-f03e6a713d63	FRONT	f	f	0	f	srmlauncher(light)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	944a385d-6409-4a5d-87b8-31f87c342a00	FRONT	f	f	0	f	srmlauncher(light)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	180dfb6e-bdfd-4392-b1ae-58b0093d1a24	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea69-7bcf-a185-c649f8b45549	6603a6f4-3dce-4c19-af4a-fb223847b209	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6b-782e-86af-f4cc09cc6486	2a47d9d4-aad1-4254-a9fd-6bede34c0b7a	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6b-782e-86af-f4cc09cc6486	d213d500-f1d7-4c2b-8a13-b025376ad597	BODY	f	f	0.02	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6b-782e-86af-f4cc09cc6486	6bf8479f-6003-41aa-a176-897021eb0220	FRONT	f	f	0	f	machinegun(support)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6b-782e-86af-f4cc09cc6486	531ae236-dd59-4e31-a8f8-a0abbdce87a6	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6b-782e-86af-f4cc09cc6486	cb661b17-96a9-4305-81ca-b41352fdad19	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	40d63c5c-62b3-40a6-8eb6-a27aecd5b7d6	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	6f797c5b-f8f9-4923-b80e-749182c1afa3	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	166c48c7-eb0e-43df-8d0e-4eb1c9f2782d	FRONT	f	f	0	f	plasmarifle(man-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	1e4ebdbe-6dee-4530-a278-671a3eb4b8a6	FRONT	f	f	0	f	plasmarifle(man-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	7717aa16-dde7-4320-b20b-bf47ca12d29c	FRONT	f	f	0	f	plasmarifle(man-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	9e5ec4b2-54a1-4068-847f-f9df02eb894a	FRONT	f	f	0	f	plasmarifle(man-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	e7e7f231-e352-4b97-b18a-296fcf0be27a	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	f9c89194-ac25-4e02-9604-7a497a4156b6	BODY	f	f	0	f	svchassismod[monocycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6c-766b-981f-bb4533825ff3	9ad8409f-ae00-447b-920e-4cffe6bba4a6	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6e-73c2-b2b0-abe409e92816	654ec8a7-0793-4e45-a99b-ef0747e174b0	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6e-73c2-b2b0-abe409e92816	1955fd3e-b7cd-412a-8233-b80f5fcf8aed	FRONT	f	f	0	f	grenadelauncher(heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6e-73c2-b2b0-abe409e92816	1132f2ab-2f0a-4c03-a741-e159549550fc	BODY	f	f	0.15	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6e-73c2-b2b0-abe409e92816	97eea343-59a1-4887-a71d-a8339dc041eb	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6f-75d3-bc85-8bf53c79276b	5f1c858c-7d1c-4539-b19a-afe8a513be5e	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6f-75d3-bc85-8bf53c79276b	5bbc3be1-df04-414c-890c-88c23fa30383	FRONT	f	f	0	f	autocannon(semi-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea6f-75d3-bc85-8bf53c79276b	e3c25ad6-de82-4c4b-8935-682565c10374	BODY	f	f	0.405	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea70-7299-ac6b-32f4589a1a2b	7e18e179-a480-416b-8092-26261eab67c2	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea70-7299-ac6b-32f4589a1a2b	0d6152fd-6d74-4c87-b9cf-8fd95798eed7	FRONT	f	f	0	f	heavyflamer	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea70-7299-ac6b-32f4589a1a2b	bd1661ed-4edb-41f4-844e-69e242ab7877	BODY	f	f	0.06	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea70-7299-ac6b-32f4589a1a2b	8cbdff22-a68f-4b54-b771-a279464f7e2c	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea70-7299-ac6b-32f4589a1a2b	2866d836-974f-4f62-844d-9e9caf61d5e9	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	3e2f1987-5e36-4539-b568-7f5227bb66ea	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	4fd5f70b-ccfa-44a6-a535-48a3dc85de43	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	91c28793-01a3-457d-a471-5f2920042b1e	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	4cf98315-17ec-470d-b35b-514f8273adca	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	d50c3a1c-c231-45d5-8943-0a12e38c7f09	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	d63048f0-627d-443a-8bb5-597a7a985358	FRONTTURRET	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	13761d95-3882-4799-97f2-dd11a45e400e	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea72-7df4-ae4c-b8f07fdc593c	b46e801d-16ea-4e63-bafc-de2a689e995a	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	61294fa9-1fb7-4225-926f-8ea25d3c7ef9	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	52b48c83-5f87-42c9-8351-3df7d89903dd	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	d295be29-ba13-4301-b70a-32642779aa72	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	19f94f0a-09f6-4a6e-b429-18e3b186993a	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	2717a14c-58d0-4a79-81c7-3a36f6be8c48	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	9a441456-c284-4412-989f-bd51470ad2f9	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	e6a4368b-5f56-427c-8acf-a3d2916d5606	FRONTTURRET	f	f	0	f	srm6	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	3bede5c6-be2a-4bef-9512-aef1b090c945	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea73-773c-bc0b-7353d654d9bd	787e9161-b284-464b-a171-b85205944d5d	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	304864e5-3e95-4b24-ade0-25d5cd613c0d	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	1137982a-2ffb-4f02-a450-0e97c50419cf	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	91e81bdf-b557-4146-ad84-a471b328ec16	BODY	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	29a987c9-98cf-460d-b132-93abf253daf8	FRONTTURRET	f	f	0	f	lrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	64300496-7359-4296-8a68-d3e8c5f89c38	BODY	f	f	0	f	lrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	0317e168-5cb0-4330-a6e1-801ee7e1acc5	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	dac6deef-71d5-4fad-9313-a1c4f4532c74	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	4c50a216-ca6c-4aac-85a7-496519b243db	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	2a7c372e-e93f-4571-82cd-22874d40d956	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea75-7bc0-9f24-7cec82d88f2b	fcb62204-8e17-4f9c-bd21-81e82182df60	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	6f94fa6c-ddae-42f0-a69b-3ab3a01226fa	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	ffc552dd-c248-47a5-acac-9afdffd43329	FRONT	f	f	0	f	lightgaussrifle	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	9e2edff7-6a7b-4a00-944a-8bbd4ef36404	BODY	f	f	0	f	lightgaussrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	d54ec0db-dbe9-4150-a585-275a5c96b216	BODY	f	f	0	f	lightgaussrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	d60e6358-9bcc-40e8-952b-5326a3ceac00	BODY	f	f	0	f	lightgaussrifleammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	0899832c-a2e9-4d58-93b3-fe16e404816c	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	ff63b25c-b809-4221-bdd3-6587cdca413f	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	597483d8-65df-4b63-bc95-c6646cd473c6	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	7e4aae45-721b-476b-90db-e93ed713c5d4	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea77-752e-ad84-382cf20495b3	dbbd0a89-b5a2-4499-8c80-a30c2f224f0b	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	127bfb39-2af5-4c12-930e-987028ae9ab8	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	c0cec8ea-9280-4e7f-baae-e9ccce49e875	FRONT	f	f	0	f	lb10-xac	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	c2a7dee0-4869-4f68-aa03-f0420e4f75b5	BODY	f	f	0	f	lb10-xacammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	e04f6466-5a8d-453b-a02f-038bd4bf83df	BODY	f	f	0	f	lb10-xacammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	5baf7d55-6b67-4e15-9737-ffdf02950703	BODY	f	f	0	f	lb10-xclusterammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	841dabf7-4bd0-40dc-a610-f598dbadf109	BODY	f	f	0	f	lb10-xclusterammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	be52c4a5-f683-47ca-9231-5df6a1697aab	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	6bc12dc0-d78f-4323-9d46-9880dd71cc04	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	32175a0d-fd56-463e-92c3-7299e2faa83f	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	5303682c-c376-46d7-b8d0-ffa3b43ea439	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7b-7248-939c-265f761f0fb2	79a2bd18-44ab-4525-8b59-eb9d3faf6d23	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	5ffa218c-9791-4567-9f98-924770407d9d	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	86e244fe-3101-4156-ad0c-c4f658c420a5	BODY	f	f	6	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	e17ce695-e694-45dd-a923-db50906da1c0	FRONT	f	f	0	f	lb2-xac	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	46fad432-5bf3-47a1-8023-2bda79f93746	BODY	f	f	0	f	lb2-xacammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	f98a32a4-a1e4-4bab-ac69-7c344c6035a1	BODY	f	f	0	f	lb2-xacammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	0a880f5f-c2fb-440b-bae3-4e7f3e447e96	BODY	f	f	0	f	lb2-xclusterammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	3671c6e4-27dd-4e2d-ad97-20e66d983e9b	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	b67ff780-8150-4dfd-8221-72af59c2c623	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	15f348a2-c0b3-4354-b384-2540f2496cf7	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	be19f8a5-d6ce-46ff-9368-2cc9f96d4c09	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	c3d1889b-9992-4c2e-b1c9-d9c6d601b0c6	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea7e-7b02-a9cc-19f319098488	d8884884-a88a-4cf8-b1ca-17618b96af27	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	42edead6-b8b3-452e-8afe-3c3cc8f99c2f	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	91ef59ed-aa95-4778-96dc-3e76c4992c89	BODY	f	f	3.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	91aee81f-fa66-41d9-9cb0-04060274dd2c	REAR	f	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	a69b1996-8329-4b5b-8c42-6eb7825d5f62	FRONT	f	f	0	f	rotaryac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	a5144b19-53be-40b6-ab81-e4c7b365d8da	BODY	f	f	0	f	rotaryac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	e2c8264f-5a80-4c3c-b2fb-a9367ee2f414	BODY	f	f	0	f	rotaryac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	ee3cdca1-3a6e-4f43-affc-d81b290b991b	BODY	f	f	0	f	rotaryac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	bbeeaaaf-4a6f-4a97-872e-5fc4686c0d56	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	46bacde0-1ab2-417f-b02c-b78f5497c3c4	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	9e17264a-cfd0-467e-b569-90d570968528	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	a97b581f-8970-407d-a45f-835464984a3a	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	be7bc34e-ca2f-407b-860f-a1c9797fa379	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea80-7b1e-928e-5ed05d07c074	d2657117-e651-4733-b2d3-83045a8c2102	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea89-74fd-bbf9-2c328cd2bafd	9b6eb6be-4b36-435b-91d6-aa5e676ed8aa	BODY	f	f	0.068	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea89-74fd-bbf9-2c328cd2bafd	74206a69-80ce-410c-8dd7-033421891bb8	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea89-74fd-bbf9-2c328cd2bafd	2bdde8de-dcbf-4a89-a3c1-4d3536b180bb	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8d-71ba-ada3-c4e412cb9fd2	7bcc9729-ebec-4040-98c5-b3ec729bb506	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8d-71ba-ada3-c4e412cb9fd2	999b8adb-5662-4592-98b6-45f62dcba18c	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8d-71ba-ada3-c4e412cb9fd2	b435e57c-673a-4638-926b-2c65b2ccd489	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8d-71ba-ada3-c4e412cb9fd2	ca2aa253-3bb5-4878-85d6-8644f2448623	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8f-7da6-8321-6f2f6dbbbc80	3c0d41bf-b38a-4ff6-9370-25f50e443b3c	BODY	f	f	0.214	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea8f-7da6-8321-6f2f6dbbbc80	aab3aedb-7d24-4ae9-8d82-7e514aa0e165	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea91-7849-8b93-ca87e63a1f10	174d697b-148e-46e5-9663-509b699370a3	BODY	f	f	0.053	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea91-7849-8b93-ca87e63a1f10	2aa71403-606d-47f9-9794-21f213199994	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	296b6af6-f9a5-47b6-b7cd-63a3a098caab	FRONT	f	f	0	f	activeprobe(beagle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	a1c5db78-8849-4a46-8fb1-547d7bede15f	FRONT	f	f	0	f	anti-personnelpods(a-pods)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	708f6cc9-dd18-4b1d-8b0c-e9ce9f8af9b3	LEFT	f	f	0	f	anti-personnelpods(a-pods)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	5a4dfcd1-f9eb-4346-a77c-8ac2d7873213	RIGHT	f	f	0	f	anti-personnelpods(a-pods)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	e17d50b6-b9b8-4fa8-9e18-7055e9d3a6ba	RIGHT	f	f	0	f	ecmsuite(guardian)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	caa3904a-c0a6-4885-8b23-bdb96e7d618e	BODY	f	f	10	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea94-79a8-a982-ec2a2a88d9d6	1260b86b-2dae-4f35-bf0f-91612c860bf1	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea97-7e69-b5a0-da6c266d4fb4	19cb6fc3-bf67-4e23-99b6-65c0df7d18e0	BODY	f	f	10	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea97-7e69-b5a0-da6c266d4fb4	d9508297-4e4c-43d1-ab1d-282b5fcca759	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	60c4e328-5d36-4fe6-88a8-98ea89a614a7	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	7ecc422b-ba26-4d00-aec1-d8e2e2d0b180	BODY	f	f	0	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	4e39140d-2c9c-4dd0-a8cb-10b8cae5a73b	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	aa737c2f-0b3b-4172-8678-a486f05f1d55	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	0e1151d4-3727-4ec6-a383-5b5bf650fa8d	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	9d81c859-d393-4fea-ab8d-e3b11eeab8e1	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	4dc9d2b3-6a4e-4d0c-9228-702ddda4ba77	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	76c940e1-b30c-42b2-93d5-e10fbe9fc18e	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	cee727a5-41f5-4835-8971-b1f3a8729238	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9a-76d8-8101-7d4068cefc55	a8e1d6af-8e60-4595-9a66-04084b61403e	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9d-76b7-99cd-2165b9e79aab	e7287bbc-ae03-4f79-9db8-9719e5a98f6c	BODY	f	f	0.304	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9d-76b7-99cd-2165b9e79aab	5f4220ba-e00f-4f1f-af23-4f4ab163c589	BODY	f	f	0	f	svchassismod[convertible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9f-756b-a692-9527ec3fc049	06abe5ef-810a-46ee-ab33-f5d28ec33746	BODY	f	f	0.2	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ea9f-756b-a692-9527ec3fc049	90ffa6b5-cd70-4144-9e25-3991e565c31b	BODY	f	f	0	f	svchassismod[convertible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa2-7bd2-93a2-4c8ebd3527eb	e8a11362-c78d-4a07-8ddc-a9d45620b9f0	BODY	f	f	18.05	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa3-7d11-b1a0-aec3057334d2	f8a185f7-198c-492a-ae8c-74d54f32a17f	BODY	f	f	0.085	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa5-7454-8517-0af434784a6e	3c3442a5-6a0a-4d05-9624-5e7e728a0981	BODY	f	f	4	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa5-7454-8517-0af434784a6e	f1c24aa4-c7ae-4d0a-b504-3b1a7f911271	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	e35c36cf-2bf5-48a7-bebf-8e5e750a9d58	LEFT	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	f4ad9724-841e-447b-978b-0bc6299dcf39	LEFT	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	7433615d-1cd5-470b-8df8-05ed4f4ab491	RIGHT	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	a138dbf4-bae0-4c7d-baa5-38f69668ae11	RIGHT	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	e9e50527-8f54-4d61-addf-1159e9f1222e	BODY	f	f	10	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	0c261df5-b6d7-4c04-9c63-240137068ef1	BODY	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	5e2682e6-5036-4681-b6ca-8848e25211d6	BODY	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	7786321c-0796-40a0-b738-ea5a10620fd2	BODY	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	18ceb225-05cc-488f-bb93-3b6a5b16573d	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	c7516742-7607-4e24-b236-6ef35d46dad5	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaa8-7004-b1f7-cfbb94817579	1a11631e-1b18-4de4-b8ee-745ec7c8f45a	BODY	f	f	0	f	svchassismod[submersible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	9119b431-081c-41d2-961b-c0079d4b95f3	BODY	f	f	0.194	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	66383a6c-09dc-44a3-92a7-a40b6bb9ed4b	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	aca71544-0c00-44a0-b252-8e7b61037bd9	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	bd6eabdc-7098-4d7c-8d28-d4f1f694a1c7	REAR	f	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	2df9a1b2-ea6b-4b0b-9b3d-60dbf7749acd	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	0c0ded5c-3987-41ef-88d1-c40e700762d4	BODY	f	f	0	f	svchassismod[submersible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaa-76f7-b7e6-989e6480a13e	6a236025-7778-416d-8074-bb8eba471f05	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	d4b51639-d88d-41b9-aecf-270728ca75e5	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	f385a4d8-b500-4ac4-b987-73d9785cc982	BODY	f	f	84.55	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	44849248-279d-401a-9869-dfd169ec15c1	BODY	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	717c22b4-8fdd-40d8-ae9b-ee81e15919b0	BODY	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	d075a274-0eee-4ae5-992a-a7470419e903	LEFT	f	f	0	f	lrt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	5cc42bd8-def6-4884-9abe-9a1790456176	RIGHT	f	f	0	f	lrt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	7ee0dfdb-da9d-49d2-91ec-8605a62f59d3	BODY	f	f	0	f	lrt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	8bbedf78-b2e1-4a1a-a7d9-395dff826f9f	BODY	f	f	0	f	lrt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaac-74d2-9629-c1f2eb661366	e74cbc49-665c-4a70-bbab-2cf33997838c	BODY	f	f	0	f	svchassismod[submersible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaf-7c92-b5ff-4b6f4765efb3	8acd6cb8-3591-4eb2-a145-35a1d4cc68db	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaf-7c92-b5ff-4b6f4765efb3	f2cc3b2d-51dc-4568-9c15-00f85d5ea3f0	BODY	f	f	7	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaf-7c92-b5ff-4b6f4765efb3	2a1f4d44-de08-41e1-b075-6c2920e171a7	LEFT	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaaf-7c92-b5ff-4b6f4765efb3	1bd4e368-daab-4a40-8c91-d917e9062068	RIGHT	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	f12d4db8-4cee-4fdb-a899-ae08d16941b8	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	85b8c6b0-651d-496b-a881-0740b6b55669	BODY	f	f	0	f	ecmsuite(guardian)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	e6419bac-66c8-4495-a215-7af034010a25	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	b3076e9c-885b-4285-871d-8487b11dfd83	REAR	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	0bcb9167-a198-407c-a681-e847451de353	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	b6b90afe-1034-4632-a47a-956415c9691e	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	dbe31778-103b-46de-a495-6958f0332fee	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	cc8ea7e6-f861-41b4-9cb3-3ea6eb74668f	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	5a07e591-e24c-432e-82fb-753575ddfca1	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	88b7ff34-0a4f-4850-aadf-f66df9905f56	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab1-7d75-8413-9dce41e11ead	fc6362ea-9bbe-4e2c-9997-f544fed2a5c2	BODY	f	f	0	f	svchassismod[hydrofoil]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	969704f0-b81b-44df-942d-11df84cd9e80	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	0215dd5d-199b-4ab1-8e8c-ba6da0a13c00	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	01bd6d52-99c3-4f94-b445-7534d917170b	REAR	f	f	0	f	lifeboat(maritime)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	70dbe646-9fd5-4a93-8b62-a44d71d232b7	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	4d0568af-0c78-4d15-b271-6e580f967435	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	cfd3a0b2-5184-419f-abed-5776266f36b0	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	58b2f42b-cc62-49ca-bfc0-68cd0d9b6c80	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	85702425-12dd-473b-8adb-95a0a8cf38da	FRONT	f	f	0	f	srt2	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	aa28a874-122f-4712-bf30-0ed49d761a8a	FRONT	f	f	0	f	srt2	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	caf9682c-c099-406c-ac3f-37d71f9c58e8	BODY	f	f	0	f	srt2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab4-7121-a296-3d6a5868bf90	7462f22f-3709-47f7-b9a0-23d4b3401385	BODY	f	f	0	f	svchassismod[hydrofoil]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab7-7393-aaa2-212bbb5a8a3a	560f1f2a-af8d-4043-9bc2-932fb1940e46	BODY	f	f	2	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab9-7eb7-92ce-33119b5fd7a6	d4b81c3d-910d-48f0-b569-43ccea945381	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eab9-7eb7-92ce-33119b5fd7a6	1a40b41b-7a5e-4c12-9212-500684bbb776	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaba-77cc-bbc6-e0ce02cb8ced	10cc846e-a80f-4a45-821e-d74ac35d015b	BODY	f	f	7	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaba-77cc-bbc6-e0ce02cb8ced	2d858f38-d652-4693-a311-569be286c88c	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eabe-7fb3-a5fd-7786e7c0c045	de1f09b9-f234-4325-98a1-33f467db2b2b	BODY	f	f	70	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eabe-7fb3-a5fd-7786e7c0c045	2c55c7cf-0d73-4a1e-8a7d-f19caaffe668	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eabe-7fb3-a5fd-7786e7c0c045	d96ccdb6-14ee-4f88-a736-f9b80f6599cd	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eabe-7fb3-a5fd-7786e7c0c045	b7932b5d-7ef0-425a-b1e4-39a8972e5b74	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	083fd20f-e584-40bd-8e15-844893e45a76	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	fcc340fa-a804-42fe-a557-6d2417a518cf	BODY	t	f	0	f	mobilefieldbase	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	336d0c04-2040-4a06-9fd1-ebb0bcf666fe	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	9344528c-61a8-4c88-b0c7-797403cc0807	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac1-7290-a30c-99fa10f3558c	504124a3-7d53-42e8-9d33-d6b024a2c9ec	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	8d762407-cb79-4547-87a5-5b1455a794a7	RIGHT	t	f	0	f	dumper	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	c141148c-9ee8-48e3-bcc4-f809b994018d	BODY	f	f	8	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	28e83471-d7e0-4269-9a39-9de783636f9b	RIGHT	t	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	3b874bd3-3fa4-42ae-93fb-7a02d278fc33	RIGHT	t	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	45e9dc26-b623-4bd8-91f5-54ca4af262a6	RIGHT	t	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	88857ff0-1666-457b-9e55-269577d2629f	RIGHT	t	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	5d6b565e-0ca5-4700-a0f9-54ebcbdb193a	LEFT	t	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	3dfc2eae-92b9-4ac7-aa88-617aeec2d85a	RIGHT	t	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	ce1b0d8d-bc15-4e04-aaea-67d82de64a78	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	9eb269c7-ca17-4017-bb4d-71112e3b48e2	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac4-72c9-be12-f0862f962a4e	c4fdd084-02f5-438c-b13c-068b0f8e4746	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	10255cb8-86c3-4eac-bbe6-1d268df5c8e3	BODY	t	f	3	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	78e63100-549f-4537-bd4c-56356d8fa6be	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	ac08e639-daf0-49a3-8701-50e6a5fbd3f8	BODY	t	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	5
019f583e-eac8-7be2-a548-c275acaa1e23	021bbf46-8974-4ba1-8bc7-2515b9eae971	BODY	t	f	0	f	mobilefieldbase	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	22970084-f173-43d1-adcb-f670ba85385d	LEFT	t	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	194135bd-837f-49e8-ba56-aefad576cf21	RIGHT	t	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	0130d827-4ae5-4233-be4d-c5086ccf2404	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	e8ee3c41-f464-49f4-9af2-46cd6d538cc9	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eac8-7be2-a548-c275acaa1e23	097ce38e-df5f-4355-b475-6b8e4d0256bf	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ead9-788f-9051-cd4db6b63371	68ccbf6e-bbbe-4ea0-a2f2-5a8d92f7f478	BODY	f	f	90	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ead9-788f-9051-cd4db6b63371	695d1b05-849b-4456-ac19-b4b5e5bc7eb6	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ead9-788f-9051-cd4db6b63371	28606ba5-bdb3-45d8-8f1e-ff836de8bdb3	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ead9-788f-9051-cd4db6b63371	514f67c5-0f6e-46a8-825d-645ffdd36ea5	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadc-75eb-992c-2dc58ce46ff1	ccd06898-1574-4b91-a8ad-f4807986cc55	BODY	f	f	90	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadc-75eb-992c-2dc58ce46ff1	ab26c662-0e40-4343-abff-15e9989805e8	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadc-75eb-992c-2dc58ce46ff1	9e91b5b2-f864-4afa-826a-536ad965796d	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadc-75eb-992c-2dc58ce46ff1	ca69c3e3-c9dc-49e3-a105-7c18c169c6d9	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	f0998e72-84c3-4ad8-ab82-ee7ce0122216	BODY	f	f	0.869	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	16850e7f-d305-45b8-bce5-8f6a265552d2	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	c999de01-ae93-4b11-9562-f92c2efac681	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	9619dfeb-f9d6-4294-9cdf-a4a36a90e8ae	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	c8495f50-5721-4e73-838b-21b70779ed33	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	6876a551-1b54-42f6-a745-361d5a17bd99	FRONTTURRET	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	4871cf2c-e521-41fd-ba91-6cfe87e0660e	FRONT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	4b1781f8-5c3b-4758-ad8e-be238cd5ec02	REAR	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eadf-700b-aece-62f18cdb6b58	2b1ebcd3-b338-42b1-ad78-2f24b568d4fb	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	43496a12-16ce-44e8-9f92-8355d02a257d	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	38865eaf-25ed-432b-97da-ce9ddcd7a725	BODY	f	f	23.591	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	049d4849-1f19-4437-af47-be3ca45d092a	FRONTTURRET	f	f	0	f	miningdrill	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	9e23dffc-c37d-4566-b39a-27d386a4371c	FRONT	f	f	0	f	rockcutter	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	7bb99397-98a1-469d-abdd-7d648bed1dc4	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	eb1a6cd1-a93c-4c75-85f9-0bbf8d28d0ce	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	89d5bb83-5b7d-4e80-9c7c-7354bdf1bf5f	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	8ff7741c-848e-4810-bb1e-6e290216a685	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	908eea1a-0114-4900-8cba-4bebe67fa2f3	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	96869766-9867-4ca1-83dc-1036fb40d010	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	2ebae87c-dab7-45ce-99d5-cfbd201eeec2	FRONT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	e1f22f26-1f1b-4d19-aa37-39f16e7789c5	FRONT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	fbda745b-cc1b-43a1-bd4a-2fc3c05c7a48	FRONT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	6d07522b-0d17-42ba-a9a0-382ddac54f49	FRONT_LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae4-7240-bf52-9ce4d3d2aec0	e192fc76-ccc5-411c-90a5-61c0155e4a69	FRONT_RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	f77cf09c-c350-4699-8fb4-28a3b504958f	FRONT	f	f	0	f	activeprobe(beagle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	75c1cdbd-0a3c-4092-838f-bcf870192c0c	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	49110bcd-58de-4c18-b9e2-2a97d3cfeed6	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	b5217735-ad15-429d-9059-7dfd27edd748	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	c4d69dee-f038-4494-ac01-d41f6ac9d0b5	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	1629a88b-45c8-4808-adb2-8dfc8224734c	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	f93b26ae-fc44-4f09-a4ea-763aa4aa3f5c	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	8d80fbfb-f75a-420a-a4ef-7d607011698a	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	3c6e4ecf-5fad-4284-aa53-f30a88e5aef6	REAR	f	f	0	f	remotesensors/dispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	478b8dca-d600-4a15-a7a6-e1ffc84aa0f9	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	6671ff43-d2a3-404b-a626-f61474b63c05	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	af5e6480-afaf-4195-a463-1610fc69b6ff	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	05910a33-9013-427e-a269-4c0938ecc8b7	LEFT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	270f8188-73a4-4e60-9b37-94a38324c48b	LEFT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	2c698e27-1ed5-4073-86bc-a48b032d1b06	LEFT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	5aa91d04-d275-46e3-867b-13acd6133311	REAR	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	7619dba1-28da-4558-a54d-186525f79056	REAR	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	9774b87a-86b0-4ed2-a7e9-2be69e3f18e7	REAR	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	426c79e7-5efa-4679-8a4a-74e2373c3b11	RIGHT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	7c52006f-97c8-42ba-b845-5d9315226506	RIGHT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	f10cf62b-2eb4-4617-888c-0b82fc7636ec	RIGHT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	6a8e1310-e87d-419d-b782-c6538d8f9a35	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eae7-73ca-8e85-fe2aba846ce5	23af5de1-dc17-40d4-913e-2691a6a38ddc	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaec-7b17-9b33-5c0e62d441c3	c331ccf1-1c12-4cdb-8c1e-29a0d32595fe	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaec-7b17-9b33-5c0e62d441c3	b97b5b37-2a16-43bc-980a-79b07fa843b2	BODY	f	f	88	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaec-7b17-9b33-5c0e62d441c3	e871ffd9-865f-4101-afc6-be48a8b119cb	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaee-7a62-b46b-a0cfb832b36d	c7f9e1bb-0dd4-4f49-ab84-ed7399ebbf1c	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaee-7a62-b46b-a0cfb832b36d	196ab665-8074-44af-8a07-63e05ad32cd2	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaee-7a62-b46b-a0cfb832b36d	9d649339-3724-4b91-bb0b-b3597b81e622	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	97413a68-c839-4804-84fd-dd307b01c2d0	BODY	f	f	7	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	d851e1bf-ea30-47d0-a229-afe886a9c41d	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	dedd5c57-be89-4cad-8444-91dc3c6e2160	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	f4b613e8-49c6-4362-a3d3-a2594d6e2cc7	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	5ef7a8d0-061f-4239-b20f-a990ef046096	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	96b9efad-c95f-4b34-aa83-6c11902c28d3	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf1-7d35-86c5-5791aa3d7f1b	b3cb06bd-ab80-40eb-89bb-ee88053f9ef8	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf4-7edb-81b9-282313c635d6	ee926e07-ddb7-4e53-ba23-73f8877543d9	BODY	f	f	39.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf4-7edb-81b9-282313c635d6	1a9fa6e5-1876-4b31-9031-38dbfadd174d	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf4-7edb-81b9-282313c635d6	0682d7f0-7ceb-41ad-ac2a-683f20b54387	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf7-7245-bcb6-562f0f692e6b	a63758f0-a145-4193-9a23-7dfdf5c0899c	FRONT	t	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf7-7245-bcb6-562f0f692e6b	0d1388d4-6f64-4a26-a2e1-64fceaf72241	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf7-7245-bcb6-562f0f692e6b	4dc1fda0-e956-4c94-82b0-22b1bb8268a5	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaf7-7245-bcb6-562f0f692e6b	bacc3c0e-8bbf-4263-a9f4-197af49af8f0	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafa-7f5e-9b91-9392b84cb84b	964b55b3-5253-4afe-a4da-bd706084f1a3	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafa-7f5e-9b91-9392b84cb84b	a6023b7b-f1be-4cdd-98a7-0213fcca9113	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafa-7f5e-9b91-9392b84cb84b	61c90f55-39fc-4c5a-b768-a9f247392b9a	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafd-7785-87d2-d7d036befb00	c6f8b829-741d-4388-a2a1-5565fb981baf	BODY	f	f	-1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafd-7785-87d2-d7d036befb00	4ce54a4a-cf72-4900-b1af-0d5090541fcf	FRONT	t	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafd-7785-87d2-d7d036befb00	0d176b12-a2e7-4703-afc6-a7a6d75214a8	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eafd-7785-87d2-d7d036befb00	1f1f8185-f669-44e7-8788-850e4c0f810f	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaff-7230-9148-e755ed804af8	7231b8fd-1a40-40b8-bddc-1bee019dc9d7	FRONT	t	f	0	f	combine	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaff-7230-9148-e755ed804af8	e41da211-932a-4321-aac3-92d2fc5db60c	BODY	f	f	0.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaff-7230-9148-e755ed804af8	f2066e63-3779-470d-a8b5-cc98765cf3e3	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eaff-7230-9148-e755ed804af8	e3dc2f18-2902-412d-84e9-7d8401b2255b	BODY	f	f	0	f	svchassismod[omni]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb03-725e-a7ac-16ddedab3c01	a1b40116-1356-4f00-ad88-ad1a219a99e8	FRONT	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb03-725e-a7ac-16ddedab3c01	94e42852-553a-4cd5-9b65-68f56bac9b86	BODY	f	f	0.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb05-765f-aa7d-dab58755008d	c702a9d6-103c-42eb-a5ce-e99c00f1d372	BODY	f	f	0.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb05-765f-aa7d-dab58755008d	96d205e2-3523-468e-bdbe-cbf37818534a	FRONT	f	f	0	f	rockcutter	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb08-735e-97aa-af93f7f2e9dc	cd352784-5dff-4ba8-8b5a-6fb900e8283f	FRONT	f	f	0	f	chainsaw	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb08-735e-97aa-af93f7f2e9dc	dbebffde-23a3-4bad-b5d8-02e976d001f3	BODY	f	f	0.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0a-7c22-b52d-cb72caf6e6af	fd7ed895-2867-49f9-93c7-1299310487b9	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0a-7c22-b52d-cb72caf6e6af	6afca4f7-ab60-4a54-9463-cc19c9cf2bed	REAR	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0a-7c22-b52d-cb72caf6e6af	c10324c0-221f-4459-b464-71e019d77fee	BODY	f	f	1.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	0bb69ebb-1904-4f42-b228-bb3429a97aa3	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	9444635b-b144-4b1b-98ce-3b21b0fcbbb6	LEFT	f	f	0	f	auto-rifle(modern,generic)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	9c2f2d84-ef3b-42ee-bbb2-77f3f43c336a	RIGHT	f	f	0	f	auto-rifle(modern,generic)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	7e8eacd0-080a-421d-99ac-9cb8abad1911	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	f01504e9-2e01-4fbd-a0e9-71fe0de3e707	LEFT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	7e7a0250-6dca-476c-a65d-b4f6c1c0598e	RIGHT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	e29f66fc-5e69-45cc-aa45-c2f4452a13d4	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	1d8fa19e-9cac-46bc-8988-956fe3410df9	FRONTTURRET	f	f	0	f	srmlauncher(std,two-shot)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb0e-7b5f-afa0-b120634189cc	00c80ffd-4e65-49b7-a7cb-3db2527f01cd	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb12-74db-b53b-5eef739e6955	a4796280-fdc7-4cf9-b907-a42e47f458ee	BODY	f	f	0.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb12-74db-b53b-5eef739e6955	c6d11bd8-9c7c-41a6-b70d-b8d3811ea109	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb12-74db-b53b-5eef739e6955	b0e406c0-ab01-4743-8ba0-be0d84b8c407	BODY	f	f	0	f	svchassismod[snowmobile]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	fd8df1ed-1175-45a5-9e0b-5e92df13ae4e	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	7299074c-d1ac-495f-9e55-7e48204a5984	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	a7a43074-5a43-49b9-8540-96bc6912e4dd	BODY	f	f	5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	4bf50221-10b0-49b9-be05-d665a6163c94	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	29e98f29-ba99-43a2-ae55-f9281c6444f0	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	c67a6a96-3ea6-4e9f-9943-c909b5e469fc	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	a58a9473-e5d0-4d5e-b2cd-93b0454530e6	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	16e3db52-ad71-46b5-aec5-a85ff9ab24d1	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	379d4140-6202-4c06-bdcb-79e37f21d304	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	7eb5a1fe-37c0-4541-a07d-f5c434c61261	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	d303be60-f8e8-40cb-892b-65d65dee9286	FRONTTURRET	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	004c0dc6-8530-40dc-ba15-9bc8ced266d2	LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	5ee2e050-ba1f-4590-8a4d-36f1fb858393	RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb16-7869-91f5-649ee5124434	399922c6-e17f-4b88-8607-ec12da1cf5d6	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb19-70e7-944f-06e94c2fb2b5	b7b55e2b-42c7-44b3-97b0-8d96002194ea	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb19-70e7-944f-06e94c2fb2b5	c4aa2613-0e8c-4a68-9c21-ba56e26d8470	FRONTTURRET	f	f	0	f	ersmalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb19-70e7-944f-06e94c2fb2b5	f4fef0c0-9d67-4822-bdcb-f9bc1e6d28e0	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	aba719aa-4b24-4ca8-b066-0880ab9d65bf	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	d85f290a-b2d8-41b9-bbe1-840618e1d283	LEFT	f	f	0	f	auto-rifle(modern,generic)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	746aa761-7fb4-4dec-9b51-c1efff439d51	RIGHT	f	f	0	f	auto-rifle(modern,generic)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	725b996e-ef59-4182-aa4a-139b1b7721ae	BODY	f	f	1.054	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	4c317ab4-c4a0-4720-bdb6-2804c04df92b	LEFT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	451dacc1-30cc-493e-9075-9c155ebd6a00	RIGHT	f	f	0	f	pintlemount	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	8597da7a-957e-4c67-a209-456ead22787f	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	33af7dba-6c81-41cc-b41d-bb68932caecb	FRONTTURRET	f	f	0	f	supportlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1c-7f90-b0d5-d9443332c6d7	8d23852f-6eaa-43a9-af88-cab4ffaf22f0	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	c9cfff95-3538-43d6-a356-0b9302d22b0a	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	2ed783f4-b36a-4f49-917e-307e0c1d5639	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	30eaad4c-5d5f-41f9-b4e5-0987724b5f04	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	37429015-a5f1-4327-a89b-bb37b63c4a3b	FRONTTURRET	f	f	0	f	supportlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb1f-703a-830f-682569c85ac8	a9b09de4-c993-4718-875e-9d983b87e4a6	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	c833af42-f019-4c1b-a65d-31ea81102d4e	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	a57d0ee7-1429-45cd-9baa-1cc7733bc0fc	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	b2be381d-3f39-4e00-896a-6522e7a1d81c	FRONTTURRET	f	f	0	f	machinegun(semi-portable)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	1a1ff580-49b1-43a2-ae54-374a8eff68ce	FRONTTURRET	f	f	0	f	recoillessrifle(heavy)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	30a2a01c-297c-4625-9682-5b61fd1a3e58	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb24-79d8-92d8-73b427772b18	c5bea96c-ba7f-46df-b6e0-25c33ed57dd8	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb28-7e35-923c-431fd9d1c460	e7682452-8897-48c8-a706-9d2117f32548	FRONT	f	f	0	f	combine	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb28-7e35-923c-431fd9d1c460	402cb090-c421-4003-9ed0-a6125912fc37	BODY	f	f	21	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb28-7e35-923c-431fd9d1c460	13ba0573-676f-4a67-8df5-a1836e5bfd60	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb28-7e35-923c-431fd9d1c460	4a4d337a-d1a8-4796-891f-1b6983d9dc3c	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb2c-7dd0-b55a-dbea0e342200	0dc9e2ad-ba44-44ad-a701-6274f999b7f1	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb2c-7dd0-b55a-dbea0e342200	fc735ae0-e743-41b7-951b-8c8100d7a389	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb2c-7dd0-b55a-dbea0e342200	ed985bce-689f-4802-befd-56b65f908394	BODY	f	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	5
019f583e-eb2c-7dd0-b55a-dbea0e342200	8511053d-d8b9-4cc6-8b98-651b9c72ed30	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	01ecaad4-f0ff-4308-8f78-ef94b69395f6	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	58ecc5cc-fa7a-4e04-bf97-1a9202239199	LEFT	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	49964505-5b59-4d08-8403-b752df36a67a	RIGHT	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	c5aef464-3896-4f49-977a-f56fe1484b90	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	26ab9d28-e56d-4421-bbeb-a55a6232b521	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	139f12c0-720c-4be0-8a44-9b3a869b8b31	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	fc1280f3-4a24-4707-a039-963ede075942	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb30-759d-95a9-e212f7dc9c00	ce1f33c3-e71e-47bc-856f-1efb44b46804	REAR	f	f	0	f	trailerhitch	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb33-74f7-b789-45c38ab4bd89	e5fa6b7a-3ef7-45b1-8cdf-9198db068dbf	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb33-74f7-b789-45c38ab4bd89	e9c7d966-88bb-45a0-9d8b-68f8a51834d3	BODY	f	f	7	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb33-74f7-b789-45c38ab4bd89	b6537470-8d25-4d19-8a3a-c58e2d5c76a4	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb33-74f7-b789-45c38ab4bd89	46bcf021-fac0-43c8-ad72-8f57ca082b04	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb33-74f7-b789-45c38ab4bd89	1b24ad63-f4ce-4a39-8f93-4150b1087b29	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb36-7f04-b382-7da6a3064956	6c282589-9bb1-477e-ae1b-7df83f98afac	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb38-7c8e-9913-22a6dd885e82	097820f8-de02-4568-96aa-bd7d37b4e182	BODY	f	f	5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3a-748f-a3dc-0eab4dba3cbe	4ed3c176-9ac9-4af4-94be-4d750ffc30e3	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3a-748f-a3dc-0eab4dba3cbe	72d7008b-fd46-42c1-88ba-9e2339caeb36	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3a-748f-a3dc-0eab4dba3cbe	6328ec50-713b-4e9a-8333-ac7a17f9fa05	BODY	f	f	0	f	fluidsuctionsystem(standard)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3a-748f-a3dc-0eab4dba3cbe	5276fff4-7b33-4050-91d8-a8919573317a	BODY	f	f	0.1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3f-7e01-a045-dbf4fd922f5d	a049055c-22e6-489e-87fa-c5bde61540a8	BODY	f	f	10	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3f-7e01-a045-dbf4fd922f5d	99f38ec3-1570-4e4c-9d9a-7a92c2701adc	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb3f-7e01-a045-dbf4fd922f5d	33d7d350-1114-4d80-bdfa-a1783673582e	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb42-7c1d-a49d-982cbe3e7171	19fd78e9-d70b-4840-860d-3429c2703e9b	BODY	f	f	0	f	ecmsuite(guardian)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb42-7c1d-a49d-982cbe3e7171	c64c51d1-d40b-4456-ac5f-55af4d109c26	BODY	f	f	0.55	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb42-7c1d-a49d-982cbe3e7171	5ffa1394-9e44-4d2f-bd6a-e1528b5ceb50	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	7085250f-dfd8-40cd-8ad0-ff6a66275a28	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	f8e81bdd-88e5-4cf2-842d-9ade14e01983	BODY	f	f	4	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	673ffb69-4276-4f57-9e98-a5b31fb0f049	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	b02a027f-ed6c-4377-b5ea-4da063fd7460	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	be873018-4e3f-4d30-aa52-461178beb843	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	0b9287b7-42fe-4e5f-90b1-180b2c66d188	LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	b29498f6-f3eb-4b53-8266-1f1c574a3902	RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	41967ee3-33d7-4593-b591-1d0fffbdfd7a	FRONT	f	f	0	f	srm6	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	4d61ea8a-5ced-4313-b634-136371b0039f	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb45-7948-a8bc-23d7e8efdfbc	2cb368b2-46f1-4975-ba8a-558ca332c530	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb49-7f19-82fd-0f70ff69960f	6e0d3739-9316-46ac-a225-7aefd7faf67a	BODY	f	f	0.45	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb49-7f19-82fd-0f70ff69960f	c90d3c74-34ff-42fa-943e-9a67b616bfd0	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb49-7f19-82fd-0f70ff69960f	da43e034-d72b-46a6-9228-91fed6444aa8	LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb49-7f19-82fd-0f70ff69960f	3c063375-e968-4441-9120-73ac349488df	RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	05d41461-ef10-483e-a29b-ad145af41089	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	451d7099-5a50-4395-b0c2-18c8c39d98a2	BODY	f	f	0.05	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	73b92354-338f-4a6b-851e-21f72d2e6c13	LEFT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	95c2b7a1-1cd3-4e25-9ef5-d9f34146d524	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	ef4ab15e-d06d-49c9-a5fb-90664ae359e1	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4c-7cc1-b8eb-864536f75e2a	7b37d618-da1e-4b27-9dc4-d61034622da4	RIGHT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4f-7ba8-8c4b-3f0b22b576ef	4cd92d7c-52f5-49a2-8753-6799be166d7f	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4f-7ba8-8c4b-3f0b22b576ef	46b26f25-230b-4e0f-9ccb-328e924c1186	BODY	f	f	1.2	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4f-7ba8-8c4b-3f0b22b576ef	e2563dce-2d49-44a3-b044-5ee29bc5ef74	FRONT	f	f	0	f	satelliteimager(high-resolutionimager)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb4f-7ba8-8c4b-3f0b22b576ef	334f30f7-4771-4936-802c-98886b0825ce	FRONT	f	f	0	f	satelliteimager(infraredimager)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb52-7363-9406-1098aa6d4964	cd9697de-c1de-41d7-a332-351d66321943	BODY	f	f	8.55	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb52-7363-9406-1098aa6d4964	889c8bec-0f40-482a-ab7b-882afe148fba	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb55-7c2a-8bff-ac2a239a9f9d	f5da28d3-4123-4e34-bae4-661f3e54f0d3	BODY	f	f	12.55	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	d56d6e8b-3838-49e0-a5d0-33f99405dacc	BODY	f	f	0.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	75d3384c-88b1-4532-af6a-cd1092d59094	LEFT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	84923392-3255-471e-8cb5-6baf40f884e5	LEFT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	86cccf54-215f-4c60-a413-a61fea06a93c	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	ff807530-fb95-4346-ad4a-123f739e05b3	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	db80253d-acc5-4f52-8285-910bcbc57750	RIGHT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	db937013-a01e-4af4-87d8-793349e4bffb	RIGHT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb58-7aaf-9e06-f4553e702d0d	908426e0-d725-420c-ae0b-a490103f9e28	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5b-7ae1-8f12-cd59cc2cccda	2ccce50e-2be8-42e9-8883-a3684f611767	BODY	f	f	2	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5b-7ae1-8f12-cd59cc2cccda	dba9c33f-7e8f-4d52-abca-b67b303820cf	BODY	f	f	0	f	svchassismod[convertible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5d-7850-8b3f-6c542e769a19	bac10a1e-b377-4c97-8edd-392fffb571b5	BODY	f	f	8	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	fa6f2b97-7b6d-49aa-b059-771061bb2fdb	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	041a3efc-a6a0-441b-a78a-4c407e010d81	FRONTTURRET	f	f	0	f	anti-missilesystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	1fe45630-1250-4057-a69c-d88e665eaf11	BODY	f	f	0	f	anti-missilesystemammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	392da9aa-2371-4c36-86c1-d1f30bd6a245	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	7c8fefda-6967-40fe-ae23-6d6b7d6fbdb7	FRONTTURRET	f	f	0	f	smallpulselaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	de93efcb-5524-41ad-b345-c074519055c8	FRONTTURRET	f	f	0	f	smallpulselaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb5f-7f03-9138-cd650b4afc60	6b8cc3fd-1a13-42a6-becb-d99b21ce9174	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	0e219478-8708-4691-a196-996b05f24f16	FRONT	f	f	0	f	bulldozer	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	dbb93859-a14f-4fe5-b8f2-fa33eb6fd401	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	12d42fc3-0cb1-47b3-a506-6b8ba9de92f6	BODY	f	f	4	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	e0ba32a0-2da0-4010-aad9-30af472fc335	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	b73c93f3-79f2-45ce-b4fd-003b82f06597	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb64-700a-baa3-813adac7ab4f	7c3b4809-7398-456b-a2f2-0f69368008c2	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb66-7072-abab-abb8edaeafd2	224963df-daaa-4e76-9712-f9f7efbd0c9f	FRONT	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb66-7072-abab-abb8edaeafd2	38c4f462-1bf9-455f-ba9c-2c7620123b77	REAR	f	f	50	f	cargo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb66-7072-abab-abb8edaeafd2	2c97a716-c53d-4d86-85ec-5ee2d84c9aff	REAR	f	t	0	f	dumper	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb66-7072-abab-abb8edaeafd2	6fc040c5-9c2d-43f7-8f55-170ffa1d1a54	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb69-796c-849e-36897a7a2290	5a36d8f1-59bd-44a6-9d12-66a03288a4f9	BODY	f	f	1.617	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb69-796c-849e-36897a7a2290	3e81a202-12e5-4d08-b1c8-a2010d895947	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb69-796c-849e-36897a7a2290	99cb9146-7f69-4084-bd56-cd855cf0b3e5	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb69-796c-849e-36897a7a2290	e5bf6c82-e7c0-46d0-bbcd-c1989539a32b	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb69-796c-849e-36897a7a2290	f73dcda6-c6aa-423a-8080-ecc79f37057d	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	73e40aaf-755b-4752-9f37-51c09d0c834b	BODY	f	f	0.739	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	30e56723-1b0f-4d5a-a56c-300312c04c4d	FRONT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	15672a58-f1b1-4dd7-8992-8f47f9dae7d2	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	ec490fb8-218e-4c60-8983-d8496c57d65c	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	bcb64803-5585-4609-9143-839c5ed9e517	LEFT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	2adb1110-3827-429b-a527-4b855f20fc79	REAR	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	fca60fc8-bae3-404c-b9e0-df040369ca2f	RIGHT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	698aec46-47e4-4548-b2f9-a80d92e904fa	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	0b700201-5e7a-4f9c-9fc9-6a4f3874b86f	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6c-7733-96f6-360657593341	78a49322-1400-4d2f-81bf-3414d95dbb3b	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6e-745b-9387-8e136d828309	336fd15e-2b6a-4246-97e8-4ef56fe51a86	BODY	f	f	0	f	environmentalsealing	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6e-745b-9387-8e136d828309	228097b5-3746-401c-80ee-b6629fde1f4a	BODY	f	f	12.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6e-745b-9387-8e136d828309	95ed8166-1b90-4bff-b241-a0f5c91d66c5	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6e-745b-9387-8e136d828309	d8bb0040-4e4b-4879-b7e9-fabab987795c	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb6e-745b-9387-8e136d828309	d9a96798-5b2c-44c5-83e7-69aa616b89ce	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb71-7be5-8895-b1a314f2b79b	2f08b367-15c8-4786-ba67-14b32fb1e1a1	BODY	f	f	0.021	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb71-7be5-8895-b1a314f2b79b	305b7556-2491-4c59-8e75-6ea2546e5305	BODY	f	f	0	f	svchassismod[bicycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb74-74ff-b99b-0639ffdd1412	82276545-d466-422a-8420-6d10c93d3ade	BODY	f	f	0.198	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb74-74ff-b99b-0639ffdd1412	0a610325-059b-4c0f-a4c8-cd4f11943373	BODY	f	f	0	f	svchassismod[convertible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	41a0ae03-8afe-4ccb-94e2-b94ff75dfe7a	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	e8a07d73-0236-45c2-b096-f5db5c0fafb1	BODY	f	f	1.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	d56287ce-2cc8-4e29-84d3-0bc77911b51d	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	41fd3863-768d-4a0b-8ce3-b2cade51fcf4	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb77-7a56-b5bf-f0fe2fbe02c6	4d1b9f42-30bb-4cc8-876b-0000d511ac0a	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb79-7c2d-acd0-aee5587b12c5	c20fecb5-9f04-47b5-b294-b35ccfbf66a4	FRONT	f	f	0	f	backhoe	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb79-7c2d-acd0-aee5587b12c5	f753a7cc-57e4-4764-a1d7-799d6e84a873	REAR	f	f	20	f	cargo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb79-7c2d-acd0-aee5587b12c5	d3b1663e-b4e3-4a84-b2a4-ca6a9caee92e	REAR	f	t	0	f	dumper	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb79-7c2d-acd0-aee5587b12c5	5120fee0-e7f3-4555-8568-2a975d229073	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7a-751a-8bb2-1e31e1941b58	c19e8924-718d-44d1-b9b1-e7187c203550	BODY	f	f	0.4	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7d-7a0e-8c54-ca0a6f56b117	41cba060-0fac-4f39-911c-22b6caaf0e57	BODY	f	f	0.025	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7d-7a0e-8c54-ca0a6f56b117	231597a3-1292-40ef-b22a-8c5616f2b407	BODY	f	f	0	f	svchassismod[monocycle]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	e8c56fe1-c349-449a-8250-2b01b305c075	BODY	f	f	4	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	0e88987b-09cd-4f26-bcee-8cccaae107e1	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	453dfb93-533d-4c00-a0c3-5b367f329141	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	66015e4c-64b3-43e6-922c-ef109ed428a2	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	76030782-f7f4-4755-9c4b-81e8b53601f3	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb7e-7909-b38f-56cc78308a5a	71f997cf-8919-4f25-91ed-e6c5f5c53dc7	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb81-779a-91c5-b60821553625	0df3e0de-1300-4990-8fc8-2348e759ac5e	BODY	f	f	17	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb81-779a-91c5-b60821553625	68320245-3e43-4152-a203-a0b81c0c735f	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb81-779a-91c5-b60821553625	337e720c-63a6-4891-915b-a49552ad5aae	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb84-7391-9229-28fc3cc437ef	65d6fc1f-9ad2-40b9-9f83-9ae13602a69a	BODY	f	f	21.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb84-7391-9229-28fc3cc437ef	84d161e3-a302-4c64-9395-00356587636d	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb84-7391-9229-28fc3cc437ef	16a60cac-45ea-491a-9870-d1687ab73f91	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb84-7391-9229-28fc3cc437ef	d92a62a6-7b34-4b03-a10f-ba21dd43698e	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb87-7c93-89bf-8b7de4a95ca8	731c7965-4007-4801-9eb6-a0546c2044ef	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb87-7c93-89bf-8b7de4a95ca8	b61c6900-9749-44a7-8a41-abc25e869084	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	1540f669-12e6-4855-ace7-4639835d4f78	BODY	f	f	4	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	d3a3c57f-325d-46ce-8796-04e4945e9627	LEFT	f	f	0	f	ladder	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	cf711923-4d41-4178-8903-384588f3dd60	RIGHT	f	f	0	f	ladder	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	f3cadcfc-bf3e-4d59-80b0-e2eb39a35712	LEFT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	4ca18839-52f2-46d5-baa7-8b28c41b6a9d	RIGHT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	57e37f16-414c-43f4-864b-2430e62de6b2	LEFT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb89-7bd0-b58b-e50ada6fec4c	7b0853bc-37d8-47db-ba2a-2942c08358a0	RIGHT	f	f	0	f	sprayer(vehicular)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8b-70e8-877b-15354dc10ae1	70aaeeb4-3447-4b3e-bd4c-6a781704cf19	BODY	f	f	0.136	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8b-70e8-877b-15354dc10ae1	ee033f5a-e111-40f7-9afc-8ec6a24ffe5f	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8b-70e8-877b-15354dc10ae1	a40909c7-b4c6-48dd-90e7-793ceae865ac	LEFT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8b-70e8-877b-15354dc10ae1	7546f806-eb09-49e9-a3c7-ea1a9084ee43	REAR	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8b-70e8-877b-15354dc10ae1	44e0f6df-8c19-4d94-aae6-70f03d612352	RIGHT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	8c132d50-b1b3-4867-8e4f-bb4f6050c2af	BODY	f	f	0.128	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	fdd9ffed-1323-4578-aa6b-6a902bb49c4f	RIGHT	f	f	0	f	ladder	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	bd6ee470-5531-497e-9af7-8492a61599bf	RIGHT	f	f	0	f	manipulator(non-mech/non-battlearmor)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	3f74ca50-de3a-4d3c-8ee3-9e7a6e5b1bd0	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	5ad93847-668f-4c8c-a6a2-032de51e1ea3	FRONT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	6612fd2c-eeae-43b4-95bc-c579b803f129	LEFT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	4faced47-8063-4970-b10f-4070547faaa7	RIGHT	f	f	0	f	searchlight(handheld)	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	f618b29a-f84e-41e4-a8e4-693ad3edd895	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	cb3aa13c-240e-4cc1-a5e8-67b76512bc6e	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb8e-7f30-9caf-e4773869eac1	0f1d473a-aff1-45e3-88af-f27de6ef6342	BODY	f	f	0	f	svchassismod[ultra-light]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb90-7b4d-bfac-cb63d60e73fa	db7d9fcc-e55d-4385-b9e3-616cc1f9abd6	BODY	f	f	0.019	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb90-7b4d-bfac-cb63d60e73fa	6df6b6da-1b3c-4469-a554-129f96307e1c	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb92-75af-8aec-4c4ff2992fd9	f92d7b24-3a43-4bf9-bb7d-48066d2e8db9	BODY	f	f	30.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb92-75af-8aec-4c4ff2992fd9	cca33f5e-430f-4126-8827-d7b13ffd799a	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb94-7a82-aec4-b489542e4575	2d7d9a8b-a9bf-4446-9280-a5693eb69cf1	BODY	f	f	29	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb94-7a82-aec4-b489542e4575	9bfa713f-adf4-4146-9f4f-1005633b7554	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb94-7a82-aec4-b489542e4575	e05d4801-e811-40ab-901e-8e22a092a901	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb94-7a82-aec4-b489542e4575	c4d9835b-4055-4dc3-ac97-f25b45db0676	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb94-7a82-aec4-b489542e4575	4833fc7f-6ed8-428c-81de-29b1ecce8973	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	3ca032b0-3460-49b6-a236-66e00d490e95	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	e7deb5d9-1ce3-4436-a40b-1e1288c455af	BODY	f	f	16.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	622b94c0-050a-45f8-9ca1-601d5ddebd72	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	b96397a0-0fc8-4dc1-8acb-42a1243de0fc	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	1e6550b2-772f-4012-a168-b8d2827c22a7	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	9cf708c2-5240-46ed-9120-a792768ddbeb	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	14965d91-50a0-4cc7-80e0-6cf6c2a0fe73	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	51a7318e-3036-4915-8051-45942da272d3	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	9cd8cd7a-ad45-496b-b9ed-e922c0702a08	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb96-7662-a5ed-bfd1a33b7fac	c569e908-efef-4862-9b54-58335b8d581b	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	96537261-b374-46a3-8ea4-adadebd46012	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	023ec09e-29c6-4fb0-97df-c664b40b7055	BODY	f	f	8.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	6084669c-63a3-4674-ba62-ed162f910f44	LEFT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	0b27d05f-1d61-4575-82f7-b08860476335	RIGHT	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	46b70b6a-8e51-4e9f-a0f9-fba5be873643	BODY	f	f	0	f	lightmachinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	b5f1a70f-2ac0-4283-b325-504606501397	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	6288eb77-84f9-4b5a-9b7a-663ec3338f37	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	7b3509bf-0896-481d-8e22-a181329a1465	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	b0008d0e-fb98-4352-b8fc-072f31ab7876	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb98-7b10-8427-7d5fff189c62	dd14e33a-f407-4d11-86d9-a25e5c986e79	REAR	f	f	0	f	vehicularminedispenser	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9b-7ae6-84c7-e2da71753968	c46fba0d-72c4-4695-9164-eabcc8eb4435	BODY	f	f	123.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9b-7ae6-84c7-e2da71753968	8d82c7b0-7213-4b9b-a44d-b819424e00aa	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9c-75b7-8d26-ea4f6b8e6c81	b21aa94f-9b9c-4c86-aab4-576433a84d94	BODY	f	f	0.019	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9c-75b7-8d26-ea4f6b8e6c81	9520d9c8-9787-4d38-982c-3a4c6c6520e9	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	5dee4da9-1430-49c5-97fb-81cc3c99218f	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	b72395b9-be5b-4971-8100-8730f2b9b31c	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	f9cb1806-4fb7-41c4-b2d8-b6a938f1faac	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	af130c10-fe4f-4677-a192-25bb9cdd3314	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	60e4cf6d-e8e8-4ca0-b14e-0d8cb05838fe	BODY	f	f	108	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	13661f05-5cbb-4178-a65f-07f469712bac	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	3fb72110-c44d-4ff0-a871-af26ca415d2e	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	952de87d-5d64-4282-a747-8ca1fc230cb6	FRONT_LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	599d4196-0cd6-4c99-9015-7ac5a61f41ba	FRONT_RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	80d95ec8-1545-4551-827e-31fe0c69e830	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-eb9f-7b84-a031-8f75c5f879ea	8b15eb25-7fcc-4280-a0a5-d9936c6a1aa0	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc1-78f3-82b4-1446276cb2d3	5a72687e-1122-4e8b-97a9-e97baa45a15c	BODY	f	f	0	f	angelecmsuite	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc1-78f3-82b4-1446276cb2d3	0a0716c0-3bc3-4972-8c9a-da81c4ec3d94	FRONT	f	f	0	f	reconcamera	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc1-78f3-82b4-1446276cb2d3	039ab6ba-ebb2-4e8a-930b-59e2fb7b9fe1	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc1-78f3-82b4-1446276cb2d3	d453d71f-76f1-400a-bbbb-9267df64c94c	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc1-78f3-82b4-1446276cb2d3	d551dcdd-69b8-4d32-af27-7fd18cf75823	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	26db6250-cc4b-4f0e-92a2-4e70de6d8ee1	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	5101f9d3-392c-41e1-be49-2f2aac33f80b	REAR_LEFT	f	f	0	f	chaffpod	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	67bea0e2-5e25-4b59-a905-73502c31647f	REAR_LEFT	f	f	0	f	chaffpod	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	240a1b75-f952-47ff-8f73-948ead2098ef	REAR_RIGHT	f	f	0	f	chaffpod	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	77e87381-93e3-47bf-9f85-9b863520d8fb	REAR_RIGHT	f	f	0	f	chaffpod	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	9f02c15b-4990-4134-bffb-a90130fac8e5	BODY	f	f	8	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	80a45a94-57e5-45e1-b94e-6ca806378177	BODY	f	f	8	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	e708a3ac-4b36-446e-ac9c-995b2d3fe238	BODY	f	f	0	f	supercharger	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	dc7aff64-3834-48a9-935e-a617fa78bdf0	BODY	f	f	0	f	svchassismod[amphibious]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	12ee80f7-3949-4b3f-967d-a03abad40f0d	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	60236455-3d1c-4869-aa74-1b272aa5113c	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	98046ac7-fc34-4a9c-80ff-300c8a1e6b46	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	e00c4d4b-2607-41a0-ac2f-6dbd9fbb04f7	FRONTTURRET	f	f	0	f	thunderbolt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	3a022900-acdc-4966-9450-89dffa5280da	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	646687e1-458a-4d19-aeb4-31ea8ac284b8	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	6d16d928-7c04-430c-af73-409cff2f15cd	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	830063b2-d452-483e-941e-5b0757b531b8	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	86f665e4-3139-4c16-97a2-fbd643442284	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	880cbb18-3366-4753-b7a6-6cc169a36075	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	a523b7d4-28d7-417e-a4e1-470ac8d279d2	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	b64ac6fb-96ee-4937-beb6-55e189931327	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	d6aba235-33cf-4170-9914-0d72c1f9095f	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ebc3-74fb-9232-24f9b1cb39d4	f6cec8cb-0652-4e25-b864-c9cad2537f60	BODY	f	f	0	f	thunderbolt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	54de6700-00c4-4a38-8c30-e20bfc99fe37	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	3a91e979-d1b8-4192-bcc9-ff5b16ea1664	BODY	f	f	0	f	ammomml-5lrmartemis-capable	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	c30a5ae5-a2ea-4b9d-ac70-48be6887931f	BODY	f	f	0	f	ammomml-5srmartemis-capable	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	1277c5e9-475b-4200-b418-ef44060ddb51	FRONTTURRET	f	f	0	f	hvac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	44fb060e-9a26-47b2-b27f-77ddccb44713	BODY	f	f	0	f	hvac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	6aa3a7b5-186f-4198-aaa8-081ced7162d8	BODY	f	f	20	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	d46a7f80-1477-4b2d-a899-a32cddfc7996	FRONTTURRET	f	f	0	f	mml5	INNER_SPHERE	ARTEMIS_IV	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	3a7a5eaf-389c-42d6-9f8d-b903bf55e174	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec04-78a7-99c8-2e2cd5ab7b15	8a75e933-ac65-4a75-994f-70aa1247cca5	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	bc9c4e02-88a7-4e34-b8d6-b2ff73ef2ccf	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	e1bcf146-e173-44cd-a87a-0a5a3b001947	FRONTTURRET	f	f	0	f	extendedlrm10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	8d252694-f7ef-4b1b-a32b-d1f561552349	BODY	f	f	0	f	extendedlrm10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	acbc29ac-24ca-45f3-9254-c46e19fa065e	BODY	f	f	0	f	extendedlrm10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	c97c4b4a-fb93-4658-a29c-7ab32888b014	BODY	f	f	18.2	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	4bfb3018-31e9-41f9-bfd1-23f4d4cca25c	FRONTTURRET	f	f	0	f	srm6	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	5ddd4fc9-519e-4873-a98a-3d64ff6275e2	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	a50c8b12-76cd-4020-8c1b-506a628f7047	BODY	f	f	0	f	srm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	13a11d22-6779-4e2a-80a3-cad0b13d8f25	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec05-7443-ad84-66d9c73936fa	4192ef12-bff2-451f-be04-e2863979e974	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	a685c66e-0398-47af-872a-273535e63e91	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	0524acaa-41f3-451e-ae2e-4c46e64cf27d	FRONTTURRET	f	f	0	f	extendedlrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	7a0f3b75-5d0e-4329-b38d-764c7a681678	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	83af29aa-2f9b-4193-b7e5-7e27dd1b4641	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	f9836bcf-771c-439f-8bc7-7f9ee2b9bdb3	BODY	f	f	17.4	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	01d91c43-cf5c-4ff2-ad12-43a6ba4b438a	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	e7cecbf8-64ce-4755-ad06-7452c0a5b814	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	f2ee3b5e-7317-4d4c-bd79-9c88a5ef0b00	FRONTTURRET	f	f	0	f	streaksrm6	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	b73c432d-b431-4e1f-86ef-e02f97207392	BODY	f	f	0	f	streaksrm6ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	1c6a011e-b4c0-4954-bb6b-483a8424a13c	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec07-7895-a9cc-fee8727e7a9a	4066ff88-78b1-4f1c-ae36-84927b9c0b2e	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	29e06f49-5ed2-4b4b-8a8b-9152fdbff7ff	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	02194e1a-6c9d-49bb-8e32-c0ccc2dfebb9	FRONTTURRET	f	f	0	f	hvac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	07446211-1b1d-499a-b972-4f1eea7aef11	BODY	f	f	0	f	hvac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	b153e83d-9480-47d3-8db4-9243d19cfe12	BODY	f	f	0	f	hvac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	922450a7-8a44-40aa-835a-1b9277bcd6e5	BODY	f	f	16.6	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	271c345e-648b-4ffa-8d15-5fa0e382c12e	FRONTTURRET	f	f	0	f	rocketlauncher15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	ad500390-c261-40b6-91f8-5d9012deb429	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec09-7466-9949-cf9e91650d70	cc8a90f6-6120-42c4-9cfa-f78995de65da	BODY	f	f	0	f	svchassismod[trailer]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	31a33798-d865-4642-84d2-2c6a3bcbbf54	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	75694fd3-dd06-477a-b4fb-93e4fcf5ba5d	FRONTTURRET	f	f	0	f	extendedlrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	925b7a05-8050-41b4-ad7c-7d54ea3ec4b4	FRONTTURRET	f	f	0	f	extendedlrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	2233ae9a-caca-484d-9bd7-5c58ed89cc03	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	2b8fdc43-6838-477d-96b3-f3469c8aaca3	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	2bdb9cf5-dc58-4560-abb3-673ac10f10db	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	85614765-cae3-421d-af7f-74f7ad384afb	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	91c03b47-39d8-4416-8910-6e0ca2bbc941	BODY	f	f	0	f	extendedlrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	fce8aa4d-1d9c-4b89-924f-59ba904ac1b6	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	28574304-f3e1-4b1b-b7c6-01bcbe88ec2f	FRONTTURRET	f	f	0	f	hvac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	dbb12b0c-24d5-4418-8138-f572473a0db7	FRONTTURRET	f	f	0	f	hvac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	8692e750-ce8b-4a26-a264-10f453fcc20c	BODY	f	f	0	f	hvac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	9739a057-fed6-497a-9b87-39e80e80aa97	BODY	f	f	0	f	hvac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	f0309b90-cd55-488a-91d9-1617e160f74d	BODY	f	f	0	f	hvac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	e088ae14-434c-425f-9ee7-1e351c7b4747	BODY	f	f	4	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	facd2503-acb1-4c26-851c-453c88734a53	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	01b45e25-5314-447d-bbfc-b5d61e5fde07	FRONT_LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	1592a664-158d-4a73-83c1-7d4878119bbb	FRONT_LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	71f88e54-4f89-4f23-9859-cbb2b83c7b46	FRONT_LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	2631ec97-9db9-484a-9e3e-45cd9702e44e	FRONT_RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	7b88cdef-79ac-4fd2-81d4-c509a2ce94a1	FRONT_RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	d7f683a9-9e7c-4e43-b103-6ba8c44a3a07	FRONT_RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	a309d2df-148c-4099-a64e-77a4f82e331b	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	9a8ff3e4-ea4a-4bf6-a46b-53a2c8b4ceec	FRONT_LEFT	f	f	0	f	machinegunarray	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	f20cebd7-f1b7-4a2d-b330-f4fe42a9c14d	FRONT_RIGHT	f	f	0	f	machinegunarray	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	56166509-1724-43e2-a270-2d9f9e72a444	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	71d24645-40f5-4338-a9c2-9ab65ed01eab	FRONT_LEFT	f	f	0	f	vehicularsponsonturret	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec0a-7340-a6c3-f2700c3efca1	6e7206bb-b36a-4a36-82b2-ca3cad54dbd7	FRONT_RIGHT	f	f	0	f	vehicularsponsonturret	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1d-7022-b8e3-21b683ba510f	62031325-a634-49f3-9ba4-79fb2c91422e	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1d-7022-b8e3-21b683ba510f	0106d558-9ae6-452d-9626-9d1d555e50c1	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1d-7022-b8e3-21b683ba510f	dd373ad3-39fa-43cb-a1a7-9490c4ea042a	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1d-7022-b8e3-21b683ba510f	434dae07-3fc8-4b82-904e-35f105d2a2fa	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1f-7629-b7f5-095c9748cfbb	2004e671-3cae-4f41-a9e8-3cfa2ea93793	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1f-7629-b7f5-095c9748cfbb	f3a6752b-2f10-4de0-9ef1-3fb173dd2f1c	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1f-7629-b7f5-095c9748cfbb	367a9f24-2167-456b-86d4-a347a36e3783	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1f-7629-b7f5-095c9748cfbb	fd0682de-9a78-4e4c-9119-6d8fa26d246c	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec1f-7629-b7f5-095c9748cfbb	eba72851-95ed-4ea0-af73-8e20295fc837	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	f3f590a0-0116-4a37-8d87-91f04e411229	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	ec78a11e-6fe2-467b-86ef-c55d8e0a8074	BODY	f	f	1	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	e576f7f3-31d5-4113-b8cc-6cc7f0387da4	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	f72fd833-9daf-484e-830a-7fc4e41a5f74	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	76e1812a-3970-4cbc-9855-3d963dc57a1e	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec20-7319-9741-d48a52da23d2	f65fe489-df63-4a0c-b24e-7ce3832101ee	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	be235758-f9cf-4d2d-98af-f22db4a8d9b3	FRONTTURRET	f	f	0	f	ac/5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	a1515eaa-76ca-4b0f-9790-2fc82bfcc4b3	BODY	f	f	0	f	ac/5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	640c85c1-e795-453f-b4db-ea838ae34b76	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	abd2c703-d03b-412b-b399-cfcafa0f9cab	FRONTTURRET	f	f	0	f	lrm10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	c8d0b6e8-4701-4b8a-ac8b-54bbf704ff25	BODY	f	f	0	f	lrm10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	b74f9840-db53-4d63-bc66-e48ec84e1cf5	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	e38750cc-da4c-4922-bb19-e6bcb8027b25	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	6d5c51e0-9c46-4f6e-ada3-0a0e39454664	FRONTTURRET	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	bb56bb9e-3f46-424f-8610-457ccf93cb14	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec23-7b21-9c77-d12e9659c093	0b44b976-892f-447a-895b-3a34afb0e870	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec24-747e-8eb7-35e3a54106f4	2c4af280-3d72-4dec-b62a-52c94e74cf94	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec24-747e-8eb7-35e3a54106f4	18dd44c1-36b3-44bd-9c39-ceb88440242f	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec24-747e-8eb7-35e3a54106f4	9702b662-1fe9-42fc-80a8-23dfe92d8597	FRONTTURRET	f	f	0	f	mediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec24-747e-8eb7-35e3a54106f4	492cea7b-3c21-4aed-9e37-9d48b66ac926	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec24-747e-8eb7-35e3a54106f4	d2bbf5fa-1b5f-42e0-b28c-08b6b76908b1	FRONTTURRET	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	7822ee61-9e50-4d93-8cd5-e1198ed1900c	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	20afec48-3f6c-4c1c-a2e4-4266f73af7b4	BODY	f	f	1	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	7473f39b-c0f0-4106-b2e8-5f583d1e0f21	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	54a805b1-38c2-48be-a8a6-be8ea0ca92e3	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	cfd1e98e-c998-4a17-9b7d-3508b00a1021	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec25-78fe-9971-587d9dbe9be9	2f6753ff-c581-45f9-99a4-663a3a3c6937	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	a96113be-20c5-4aeb-b6e8-21f9725b19a7	FRONT	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	bd5c4e7a-3a85-4f94-a9e2-59afb84f26f2	FRONT	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	fcfea103-f77d-4d46-833d-4bdbc751f666	FRONT	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	fed9aa79-6139-48f0-b5ce-91850d39dd14	FRONT	f	f	0	f	ac/2	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	8624bf9c-292b-4439-acbd-d24453d070b1	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	d0623e00-f25e-4899-b40b-98bf29b6b8ca	BODY	f	f	0	f	ac/2ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec27-7c5f-83b1-dda0d2dad2d4	98adf826-e6ab-4e4a-89a6-a487720f905a	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	b1f1bbf8-0c12-48d4-b7b2-3e074c81db67	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	01072f18-386e-4b74-848b-0b1059d121a4	FRONT	f	f	0	f	lrm15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	4b9569d1-b521-42a3-bda9-846338d0daaf	FRONT	f	f	0	f	lrm15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	88fcdef8-5818-4c6a-9cc4-641458b99d21	FRONT	f	f	0	f	lrm15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	15d7c1a9-9e66-4191-9923-8e4be53b2d57	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	ca86b381-b4d1-47c8-9782-8e4b9e1b490c	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	e001f5ed-3be0-4fc6-bb9d-a62553266fd7	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	effba1d4-2bfa-4975-8c25-6e3334b9dd12	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2a-7682-bd35-0ff30fe06d81	fcc3a415-6976-4a95-ab33-5d343d528d0a	BODY	f	f	0	f	lrm15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	75e7a4ed-342a-48fb-a567-c8fac50b72bd	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	765c14fb-4e6e-410e-951f-35681f3df1b0	BODY	f	f	9	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	11ae4ad2-c126-487a-98d5-08e9840e9d05	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	6d71d507-85b8-414b-9929-2186d9e1891f	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	b06160cd-7e17-43dd-8228-58aa08096597	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	a020f200-951f-4c4d-917a-8ada7b20f2cf	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2d-7ab0-a75d-5253f2863a4b	9034c8dc-7656-4104-88f2-94f4451bcb27	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	2d31991f-101b-4656-bc46-f22e1e7e7465	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	06c81abc-7310-423d-8212-50c4d1b1af12	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	1fbe3a4e-0ddc-45af-b4ad-f81aa6fc1c3b	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	3e8f97b5-8ff1-492b-92e6-51c564067d4d	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	667472e6-d836-4df2-862c-f6962c9ed4bb	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	99376a41-025d-4fd4-a19c-c48d1c969e55	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	9b1b313b-1de4-4a38-ba25-7f1d803431b2	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	d0529854-77e0-486e-8530-bf51262e2875	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	e64787b0-eca9-4994-b359-20f103b1be07	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	ee1ffaf0-0816-4669-94e7-9f0c17fb2774	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	12138ac0-16e9-4b97-9c82-f9c98d596a8b	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	37574c64-f1a9-4c4a-806d-91fe0677a3b2	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	7999ec09-5237-4e47-ad1f-1f9ee208c69c	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	9bbe7893-6ab0-4ecb-8708-d00ab8c111a3	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	c0355216-b9f6-4ee2-8631-a8bbc7bca5a8	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	c8a4bacc-2a23-4cf8-b3f1-d097890b18f6	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	e1d94737-fd8d-418a-b1d9-0b25cad442c7	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec2e-7d66-812c-e49ba2b9acb6	e7b19596-d6e9-42eb-80ed-5dd338797ee0	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	f70b0bee-69b5-40a1-a4de-e7dc47d97c89	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	eeb61198-b932-4d61-9237-c52c25077e7f	BODY	f	f	6	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	46324d9a-7543-4d78-ad23-bd9018d345eb	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	d1423787-12ea-40b7-85f5-feafe888b959	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	d0845f74-9cc4-4162-92b4-287210eb2259	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	49a4fa8a-b61c-4b91-b622-e60dd3470f6b	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	abe6abce-c017-46b4-8c17-40926ee782c2	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	f68f8bc9-f057-4a33-8ffc-5ebc63db91ce	FRONT	f	f	0	f	srm4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec30-7a43-8727-98b32f4c02d5	53ed5c30-13c8-45d5-94b5-13fe5fedd471	BODY	f	f	0	f	srm4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	7f3e6eaa-e629-4f2c-a1ac-e1a525672ecb	BODY	f	f	2	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	e51712e1-19b8-4dff-a5a9-2401c748c200	BODY	f	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	2
019f583e-ec37-7f5e-b29e-160141dfcb8d	fb96779a-06dd-48f4-a1e7-821d58933fd0	BODY	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	d84bf3cf-e43a-4b98-aefd-d4aef9cddb11	FRONT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	c55edb2f-072f-4ac4-b9cb-52e235d5a07a	LEFT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	3ac38924-8aa8-4fc7-acde-6eb8e3d84708	RIGHT	f	f	0	f	paramedicequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec37-7f5e-b29e-160141dfcb8d	e2895f72-4834-4061-a462-10e0e97de2f7	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	9d17c750-4131-437b-9ea8-cc7820eeecef	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	67e63351-a8ab-4350-96c6-a256405d1b4a	FRONTTURRET	f	f	0	f	largelaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	f2037533-1560-417c-8d44-a49c8f82a5be	FRONTTURRET	f	f	0	f	lrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	1e514a1e-7b62-4171-b797-b4815e2e2f1b	BODY	f	f	0	f	lrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	62860a28-7c4b-4d80-af44-809ccb722655	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3a-7dab-a42d-b0c60710239b	57cb81c0-3d59-44c1-88c2-c77546b24905	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	2776da76-7249-4105-9253-bb1a9c2cc124	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	6666d16e-0d08-4a61-8df5-f9632fefb1d4	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	7e3e2928-9e39-4a1f-a94a-3dcdcfc72a35	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	49f6819e-3c34-4e0a-b98c-0fb1cff14fa4	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	fe52997a-753c-4e4c-8761-5e669a552fc1	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	d69d7035-86fb-4d3b-80aa-800cf53f99e0	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3c-7b20-848d-ef876a429829	65ac40be-1a4b-4b10-aa65-cfb9efd4f455	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	59f09eaa-f2fc-4e82-aeda-c6a0590d1a1a	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	5f1a8ad5-51b0-4d2b-a028-2d270eecc701	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	88a83b64-c468-41f1-b66d-ec8d5e98b622	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	5220bd08-e30d-46a4-8e8f-b4ebf4e15e32	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	acf6460f-6bbc-4575-896c-f60670326f50	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	b2f9c09d-6819-420f-863e-01395115bf0e	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec3f-7a7c-9852-18a6a3ce05a4	69b54c4a-22ca-4e56-a242-15473b63b499	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	4ea33995-f558-45d4-911b-7cce6bdf361e	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	0316576a-6528-446c-b3db-72d059f56319	BODY	f	f	9.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	7a856ba3-6d10-4dc1-bd21-ddc75610deb2	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	99943aac-6128-40d6-9021-12078612ad5a	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	c3695d81-8737-47a8-84b8-0531b405ebb4	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	66cebe80-c998-4a4b-897f-d7254ff511c5	REAR	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	c614e380-477c-435f-bc50-85f1715678ce	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec42-78fe-8163-1c465907ceb6	37b9a623-95b3-45a5-b4d1-341dd775c693	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	bb58b13e-7fb0-4470-a4af-84a86ae55c5b	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	362b07df-9531-4f33-8e3d-b2bfeec65cc1	BODY	f	f	9	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	7488df6c-ced5-4c0a-9cc3-91466b4d9bab	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	c7f587bd-1b4a-44ea-b56a-45bd8225778c	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	b032e53f-7157-44f8-b20d-50dd8dce16c8	LEFT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	c9bf0cc9-cb3c-43a7-b63b-7cae93a19090	REAR	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	5ad0a849-f695-4a84-9335-8208bd44d5e3	RIGHT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec43-77c3-9837-427bd3b5f580	0d48cc51-71c9-41a6-86c3-e563a44d6c06	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	9c911e30-621f-4a3a-99c8-88bb86e9735d	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	42486374-9ee1-4abd-809b-ee200e759b0a	FRONT	f	f	0	f	primitiveprototypeautocannon/20	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	02382265-d6b9-4403-abf8-74c4e49f02c3	BODY	f	f	0	f	primitiveprototypeautocannon/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	30c13ece-d2b2-4453-a3cd-36dc4f5d250a	BODY	f	f	0	f	primitiveprototypeautocannon/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	34788b11-cc23-4327-a185-f169f2dafd02	BODY	f	f	0	f	primitiveprototypeautocannon/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	a579c51a-37c7-492c-a0c5-4f105e73ea0f	BODY	f	f	0	f	primitiveprototypeautocannon/20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec46-70f9-b001-8c48763f9513	be655f3a-ff5e-4c5a-9453-f32225c7b13c	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	bcd13549-0068-46ae-8f62-0a84878e3d1a	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	8ba90c04-e511-40e1-8e08-a6641d6f49ba	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	18481a3e-bc79-4986-8a2d-eae95e214482	FRONT	f	f	0	f	sniper	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	116799ee-b189-4116-bebf-2c28edf26da8	BODY	f	f	0	f	sniperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	43f55619-587f-456f-8ddd-0910f12fdec9	BODY	f	f	0	f	sniperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	89fbeaeb-394c-4a32-ae24-6dbd9529a760	BODY	f	f	0	f	sniperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec48-7c24-9448-12f9f7a3db2e	9caa7177-c9c4-43e6-b8ac-ef0dca3b66b8	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	854fceb8-40f0-4daf-83a7-a753238066c5	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	905164a3-0e37-4243-a0e5-eb101e7a6ddb	FRONT	f	f	0	f	flamer(vehicle)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	3ff0bab6-977d-44e2-b415-6c89c471e41e	FRONTTURRET	f	f	0	f	lrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	ed64a5a7-6c6e-405f-88f5-c99873c9cc6d	FRONTTURRET	f	f	0	f	lrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	a59059ac-c40b-46e2-84f7-dcd0b5f170f5	BODY	f	f	0	f	lrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	d65ef32c-238d-485d-b1f5-933c3f645fcf	FRONT	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	a0902172-eae3-4bbb-97be-1646c493262c	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	d78ea6d7-68f6-452b-828a-5a4ad92361a5	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	94ebcaea-78d7-4a88-913f-30c7311c710d	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4d-798f-84ad-eecdcc54759d	6e017720-dc0a-4176-a2d0-c64a7d6c6f33	BODY	f	f	0	f	vehicleflamerammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4f-7522-895b-66f3e0e40f6e	a70355cf-3ae2-443c-a1c4-952394f3d8d3	BODY	f	f	7	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4f-7522-895b-66f3e0e40f6e	90bdf6ab-15f1-436d-b20b-7fae942c9343	BODY	f	f	3	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec4f-7522-895b-66f3e0e40f6e	b20daa2a-0851-4b6a-b3eb-bfe6eb131ef5	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec51-731c-94b5-a5c494fdd6d1	def6e144-b25c-490f-9fc5-76614c94ecc9	BODY	f	f	20	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec51-731c-94b5-a5c494fdd6d1	44b899ec-6695-4f63-9338-114967e77552	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec51-731c-94b5-a5c494fdd6d1	80e74ce0-6bf1-438d-898c-39c352104acb	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec51-731c-94b5-a5c494fdd6d1	ed8b8e82-a9fe-4c5d-80f1-318a4c8b43d3	BODY	f	f	0	f	svchassismod[off-road]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec51-731c-94b5-a5c494fdd6d1	c479c3fb-6457-4fcb-9ed0-6c64822b5e51	BODY	f	f	0	f	svchassismod[tractor]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	a9995dea-9315-44f7-8935-006c2c7f2936	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	6f0c76ae-0e29-4135-8eac-b9b0d9a74c4a	FRONT	f	f	0	f	smalllaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	71c0a980-dca0-4f92-a8e1-ed03317dac42	FRONT	f	f	0	f	thumper	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	114249d1-7dca-4920-9506-959875ab63cf	BODY	f	f	0	f	thumperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	47e6e8f9-1d38-4ffd-9a28-dfe81a31b8d7	BODY	f	f	0	f	thumperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec53-79c4-be1e-77db6ca4932f	dc0c9c3d-55fc-4e81-ae95-e4bd85fc1c76	BODY	f	f	0	f	thumperammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec54-7008-ba53-94c900e2263f	05603e26-07d3-4b3e-bf3a-c984ce20aa14	BODY	f	f	40	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec54-7008-ba53-94c900e2263f	6227fe72-25ba-46f9-9e84-58112fcb6475	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec54-7008-ba53-94c900e2263f	957e3400-6bc1-4224-af0b-fe6fd56ab196	REAR	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	b36cfc3f-f7f3-47d4-b706-d15a24e14fcb	BODY	f	f	24.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	74ad71a0-6b08-43c9-896b-a76b0fec42ed	FRONTTURRET	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	bbfe4937-4768-48c6-8960-9b42007f3d19	FRONTTURRET	f	f	0	f	lightmachinegun	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	c302c652-511d-4f89-933b-dfc14dfba273	BODY	f	f	0	f	lightmachinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	8e53345d-61fe-46e2-89bb-7581ce776e7d	FRONTTURRET	f	f	0	f	lrm5	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec6e-7bb0-8a34-4b08f83b9763	0768de8c-1298-4af2-becb-cc8e4cadcb83	BODY	f	f	0	f	lrm5ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	fcc5a5ec-b420-4446-9418-1c641915960f	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	01ae5857-3aa7-411d-b488-a40ea35a664f	FRONTTURRET	f	f	0	f	mrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	62719ba1-4612-4484-9501-eda54c120224	FRONTTURRET	f	f	0	f	mrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	fa11ecb0-33ef-454a-bffe-c54273481f2d	FRONTTURRET	f	f	0	f	mrm20	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	11991b58-0b30-4395-93e3-2b20c47ef632	BODY	f	f	0	f	mrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	5ef59aae-3f8b-4997-9947-6aabceaa7d84	BODY	f	f	0	f	mrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	9253b624-1d1f-4d56-9e6b-7997d6e136d1	BODY	f	f	0	f	mrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	defbe4e9-3537-4912-a9c9-d4e78fdbcb56	BODY	f	f	0	f	mrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec70-76c7-a26a-3b560de8e435	ecdd42ea-4da2-4962-8944-8a40d11a61d8	BODY	f	f	0	f	mrm20ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec72-79eb-ad16-cee49f243461	bc981635-a22a-4f33-81ab-572c059f9d56	FRONT	f	f	0	f	bloodhoundactiveprobe	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec72-79eb-ad16-cee49f243461	4a3bd87d-18e6-43b1-a9fb-17b7cbc4af52	BODY	f	f	2.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec72-79eb-ad16-cee49f243461	7a11394b-61d3-4659-a4ed-a0d925d05c84	RIGHT	f	f	0	f	lifthoist/arrestinghoist	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec72-79eb-ad16-cee49f243461	5fbe58db-fc98-45a3-886d-440155420c0c	FRONT	f	f	0	f	searchlight(mounted)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	d42abc68-6f56-45b4-a6bb-621702a3c1ec	BODY	f	f	0	f	advancedfirecontrol	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	e83b9122-f33f-48ae-9703-fe4c5da5bbfd	BODY	f	f	7	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	d2c1731d-4591-4830-abde-bb3820ffcb1b	FRONTTURRET	f	f	0	f	ermediumlaser	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	188bdd7a-564f-4bcd-ba28-a4f8abde6a8e	BODY	f	f	0	f	fieldkitchen	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	a5db747c-9bd1-4732-bdb1-4c03f58a2751	BODY	f	f	10	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	bb2d02e0-6642-4957-9039-5fafb927f5e1	FRONTTURRET	f	f	0	f	lrt10	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	5b3a27fc-b517-4e36-a64f-80fc60d2fb8e	BODY	f	f	0	f	lrt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	f63f4ec8-d359-4fca-abf2-775bf989651b	BODY	f	f	0	f	lrt10ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	38f0cdb2-5739-4730-9e93-96e0a1d40164	FRONT	f	f	0	f	lrt15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	25fd2f09-6a0e-4145-99f8-ed238c30d1d1	REAR	f	f	0	f	lrt15	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	3c9aa359-b31d-4435-89fc-ffa7496e005a	BODY	f	f	0	f	lrt15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	41fd71ed-ebeb-43c4-8550-9187691a872b	BODY	f	f	0	f	lrt15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	82a209f7-6f85-46df-b09b-fd329751f565	BODY	f	f	0	f	lrt15ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	e4d670e4-9011-4385-92b3-cc8632be8490	BODY	f	f	0	f	mashequipment	INNER_SPHERE	\N	\N	\N	1
019f583e-ec75-7cd8-8032-f2d83d9a0544	d9be1ac7-479e-42e3-8e99-4e4782e663b9	FRONT	f	f	0	f	srt4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	9e98c232-c757-43e1-afe9-640d8dd3b1db	FRONTTURRET	f	f	0	f	srt4	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	394658cf-4513-4c71-90af-75c294a4edc7	BODY	f	f	0	f	srt4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	61b93927-5305-480e-b1ac-0af5b3ffa46c	BODY	f	f	0	f	srt4ammo	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec75-7cd8-8032-f2d83d9a0544	ecdc23b0-98ed-471f-ab2a-85ad222205f2	BODY	f	f	0	f	svchassismod[submersible]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	9a747dea-0bc7-4c71-8226-e83178f5bcb2	BODY	f	f	0	f	boobytrap	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	e4d660e4-47ba-419d-9be2-ab7f1a3c20bf	REAR	f	f	0	f	cargocontainer(10tons)	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	3ce29b75-9763-42cb-b6a6-5f73fbc6a64a	FRONT	f	f	0	f	drone(remote)operatingsystem	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	087affec-4d1a-44da-8095-afa70c3990fd	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	162d0419-e7ad-4238-ad03-0b016fda27ba	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	491c8d40-3045-4d71-863c-935c6713a549	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	5fd51c04-d583-4286-bf0d-6caed4aecd01	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	64a329f0-f06e-4069-b198-1129990646fc	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	8c3a4050-1d48-48d9-9c1d-84df701e4f10	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	9ca65ac7-fca3-4071-a1f2-576b4d82c684	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	a23bf1be-1681-47cc-8b1c-cb51111a6e7d	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	c2e2130d-899c-465c-842e-53dc4476b746	BODY	f	f	0	f	machinegunammo[half]	INNER_SPHERE	\N	\N	\N	\N
019f583e-ec7c-7f1d-b79a-8290b0bb8b37	714fb87e-29f7-4758-abd4-1d53e7a461de	BODY	f	f	0	f	supercharger	INNER_SPHERE	\N	\N	\N	\N
01a0bb4b-3acf-740c-a575-80954010f2a7	3e10967e-b06c-486a-9f13-8b885cfb9fba	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
01a0bb4b-3acf-740c-a575-80954010f2a7	4a6b5079-6e98-4d60-9a1c-d7ac8350835d	BODY	f	f	6.46	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
01a0bb4b-3acf-740c-a575-80954010f2a7	75d853b8-c108-4ef7-be85-cd0fd436d458	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
01a0bb4b-3acf-740c-a575-80954010f2a7	c6c16550-4708-40f5-9ebe-c4750eed83b3	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
01a0bb4b-3acf-740c-a575-80954010f2a7	8d625182-fdd8-43dd-bb31-d966c3cf0d56	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	93ed8567-4fe6-4ab0-9cef-de2cd2d8b570	BODY	f	f	0	f	basicfirecontrol	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	ffd507f4-63ab-4503-89ea-392b3723d214	BODY	f	f	7	f	communicationsequipment	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	2bc1a036-7fa1-480a-9b36-43df81a3d725	BODY	f	f	0.5	f	infantrybay	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	96da28f8-76c4-459f-a80e-42152b7cbd0b	FRONTTURRET	f	f	0	f	machinegun	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	6f3152cc-e055-40e7-bc6a-461d132f3c02	BODY	f	f	0	f	machinegunammo[full]	INNER_SPHERE	\N	\N	\N	\N
01a0bb4c-6e83-721d-992c-a9dc9c849827	b1c36829-3ca7-468e-9511-ddf9aa63301f	BODY	f	f	0	f	svchassismod[armoredchassis]	INNER_SPHERE	\N	\N	\N	\N
\.

CREATE TEMPORARY TABLE v3_22_new_item AS
SELECT i.*, u.id AS unit_id, e.id AS equipment_id
FROM v3_22_item i
JOIN v3_22_unit vu ON vu.megamek_uuid = i.megamek_uuid
JOIN unit u ON u.id = vu.id
JOIN equipment e ON e.name = i.name AND e.tech IS NOT DISTINCT FROM i.tech
WHERE NOT EXISTS (SELECT 1 FROM unit_equipment ue WHERE ue.id = i.id);

INSERT INTO unit_equipment (id, location, omni_pod, rear_facing, tonnage, turret_equipped, equipment_id, fire_control,
    jump_boost, drones, mash_theaters)
SELECT id, location, omni_pod, rear_facing, tonnage, turret_equipped, equipment_id, fire_control, jump_boost, drones,
    mash_theaters
FROM v3_22_new_item;

INSERT INTO unit_mech_equipment (unit_id, mech_equipment_id)
SELECT unit_id, id FROM v3_22_new_item;

-- 4.
COPY v3_22_slang (id, term, lookup, kind) FROM stdin;
6c868ee6-a6ba-450c-b47c-5f5b584d5796	AC20p	ac20p	ALIAS
0a63adb0-3790-426a-9548-3670ed3eb89c	AC20p Ammo	ac20pammo	ALIAS
ffbaf8ba-bb91-4039-9a77-719fc921029c	Ammo AC/20 Primitive	ammoac20primitive	ALIAS
7b7ecffa-8cb6-4c44-91ca-a6251f2339b8	AmphibiousChassis	amphibiouschassis	ALIAS
001221d7-eec0-4405-8f36-a099bd2c0534	AmphibiousChassisMod	amphibiouschassismod	ALIAS
cea11b66-8f0f-4586-9556-19cb95f11835	Auto Cannon/20 Primitive	autocannon20primitive	ALIAS
beb03d9f-7086-4f2d-b276-35d1c959fc55	Autocannon/20 Primitive Ammo	autocannon20primitiveammo	ALIAS
6cc369a8-0575-460f-9f94-a47f447dd866	Autocannon (Bearhunter Superheavy)	autocannonbearhuntersuperheavy	ALIAS
c9d74c0a-acf4-4eb6-aef5-7c8bbf42dbaf	Autocannon (Semi-Portable)	autocannonsemiportable	ALIAS
39bf2c7d-68fc-43af-92fe-ca712d74bac4	Auto Rifle	autorifle	ALIAS
cf7211f4-bfa9-4c68-abb4-5aef08806831	Auto-Rifle (Modern, Generic)	autoriflemoderngeneric	ALIAS
930ac4e4-4e76-4669-b58b-b3cf8106b157	BAAutoGL	baautogl	ALIAS
88a59bed-9123-4e6a-b330-b6ea5d65a487	BA Grenade Launcher	bagrenadelauncher	ALIAS
ebc821c2-fb34-4f64-b260-9c7971551420	BAHeavyGL	baheavygl	ALIAS
9b4d9d7e-55e2-4ecc-b43b-5d74969a8a40	BA Heavy Grenade Launcher	baheavygrenadelauncher	ALIAS
743bb49e-9967-400e-9659-68090af44e22	BA Plasma Rifle	baplasmarifle	ALIAS
c7d592a2-b6e1-4ce2-86ca-a55f7751756b	BicycleChassisMod	bicyclechassismod	ALIAS
89b29054-ae33-4518-959a-aa2a26fc7de4	Bridge Layer (Heavy)	bridgelayerheavy	ALIAS
7d0e5c37-b4bd-47bd-aad6-7269a59ad1f9	ConvertibleChassisMod	convertiblechassismod	ALIAS
09bdb03b-f753-4391-9932-acd1054054eb	DuneBuggyChassisMod	dunebuggychassismod	ALIAS
297d7918-716f-4ab6-81f6-fbfd41648a1a	Field Kitchen	fieldkitchen	ALIAS
8582ef42-8633-45d0-b01e-9237eee6cf0e	Fluid Suction System	fluidsuctionsystem	ALIAS
c44ff1a1-5651-427f-b4ae-55da0093f3d0	Fluid Suction System (Standard)	fluidsuctionsystemstandard	ALIAS
6e865d00-f989-4df6-baab-cf2152d0983a	Gauss Rifle, Light (King David)	gaussriflelightkingdavid	ALIAS
747be1ee-7330-475f-9b7c-5c580b36ab89	Grenade Launcher (Auto)	grenadelauncherauto	ALIAS
e10599d7-1486-4dd9-ac5e-348a52d75c33	Grenade Launcher (Heavy)	grenadelauncherheavy	ALIAS
01f6e913-6eca-4248-bb23-1f848cc61ff7	Heavy BA Grenade Launcher	heavybagrenadelauncher	ALIAS
6c17457e-f4f0-4111-8d00-35a5014aca61	HeavyBridgeLayer	heavybridgelayer	ALIAS
038dbd71-368b-45ef-9e37-b8be4995f821	HHSearchlight	hhsearchlight	ALIAS
84a9b8e8-7d5b-4a38-950c-ef903bb1cef3	HighResImager	highresimager	ALIAS
a7e00bd0-f2d3-433c-94ee-8977ce190f59	HydroFoilChassisMod	hydrofoilchassismod	ALIAS
def244d5-9ad0-45e9-8d1c-66fba5a1b71c	Infantry2ShotSRM	infantry2shotsrm	ALIAS
37296d78-d9e9-4a29-bdde-ed04c9edf4c4	InfantryAssaultRifle	infantryassaultrifle	ALIAS
08d7f06c-3c7c-4463-b9cb-b5073bdd9dab	InfantryAutoGL	infantryautogl	ALIAS
87100a1a-d6a7-444d-89da-8b3adb8cb730	Infantry Auto Grenade Launcher	infantryautogrenadelauncher	ALIAS
523aefb4-cd1a-4af7-877c-725c3dcaab1e	Infantry Automatic Rifle	infantryautomaticrifle	ALIAS
2d44c3a7-2e27-40d1-868e-7a605877c0ac	Infantry Auto Rifle	infantryautorifle	ALIAS
baa58560-1390-4a5b-af7c-9706269c8c0e	InfantryBearhunter	infantrybearhunter	ALIAS
48c979b8-c97e-42e9-a6cc-ef112c6ac855	InfantryBearhunterAutocannon	infantrybearhunterautocannon	ALIAS
8e13b9b6-6524-4408-82c2-d1615db5e05e	Infantry Bearhunter Super-Heavy Autocannon	infantrybearhuntersuperheavyautocannon	ALIAS
3558e760-f049-41fd-aab0-a94f9babb95d	Infantry Clan Mauser IIC	infantryclanmauseriic	ALIAS
369a06c7-2525-48de-bc1f-66c57b47f89f	InfantryClanMauserIICIAS	infantryclanmauseriicias	ALIAS
83ac1b67-1f24-47eb-99bd-ff60d476df4e	Infantry Heavy Grenade Launcher	infantryheavygrenadelauncher	ALIAS
0e051802-ba5d-4944-864e-92597bca3fed	Infantry Heavy Laser	infantryheavylaser	ALIAS
a19f68be-adb1-48a6-b0e4-5d67c39fcf39	Infantry Heavy Recoilless Rifle	infantryheavyrecoillessrifle	ALIAS
e3e384d1-4d07-4294-b20b-0b31529c9313	InfantryHMG	infantryhmg	ALIAS
4a2c1a68-6196-45ab-b87b-796e870f4f91	InfantryHRR	infantryhrr	ALIAS
0cf24c52-de70-450b-8405-e28d004484fd	InfantryKingDavid	infantrykingdavid	ALIAS
9b99e0c4-a24c-4c6d-b125-e707f876a40d	Infantry King David Light Gauss Rifle	infantrykingdavidlightgaussrifle	ALIAS
120254fc-82a4-40aa-8abb-c24d57019403	InfantryMediumLaser	infantrymediumlaser	ALIAS
ffea0f21-2c8d-4e62-b550-63a45cfb32d9	Infantry MG Semi Portable	infantrymgsemiportable	ALIAS
89bd0ffd-ae5d-46cd-adbf-4cedf5e27fdc	InfantryMPPR	infantrymppr	ALIAS
e40e66f3-8f9b-41c1-b1fc-27539e8d219e	InfantryPlasmaPortable	infantryplasmaportable	ALIAS
48aff24b-e7da-450f-a930-a1680186d4f9	InfantryPlasmaRifle	infantryplasmarifle	ALIAS
84e6dd32-6611-4469-8675-0d5222ec19ad	InfantryPortableAutocannon	infantryportableautocannon	ALIAS
032ecada-8e97-4222-b583-f09f955d333b	InfantrySemiMG	infantrysemimg	ALIAS
b7dc334c-225b-431c-a964-441228a9d7ae	Infantry Semi Portable Autocannon	infantrysemiportableautocannon	ALIAS
66f8a258-4daf-4f16-9ec1-ee122cc33eeb	Infantry Semi Portable Laser	infantrysemiportablelaser	ALIAS
0c2ebc6d-dfb6-41e9-800e-cb81b888fd49	InfantrySmallLaser	infantrysmalllaser	ALIAS
3c108583-3cf4-442c-8e58-38ae282d80c8	InfantrySRM	infantrysrm	ALIAS
4a188a9e-ecea-44de-9ecf-e2944c7196bf	InfantrySRMLight	infantrysrmlight	ALIAS
cd9a8892-f904-4ecc-b171-cefb6a81781a	InfantryStandardSRM	infantrystandardsrm	ALIAS
de53e644-1924-43d0-82ac-7f117ee66a2e	Infantry Support Laser	infantrysupportlaser	ALIAS
8c5395ee-2373-459a-a655-e07f2ba89a35	InfantrySupportMachineGun	infantrysupportmachinegun	ALIAS
7c619359-d08b-4cb1-94d7-e327d72572e0	InfantrySupportMG	infantrysupportmg	ALIAS
789e58e9-5864-4e50-aba3-d4e0de9c80d2	Infantry TAG	infantrytag	ALIAS
5f69053a-b42b-4674-8846-ede6c2a408f9	Infantry Two-Shot SRM Launcher	infantrytwoshotsrmlauncher	ALIAS
22e26acd-e283-4097-be04-e05af59f02c5	InfantryWireGuidedMissileLauncher	infantrywireguidedmissilelauncher	ALIAS
e3ee750d-0bbb-437e-b69b-de33d6ea76b3	InfraredImager	infraredimager	ALIAS
ea9e77d2-c21b-465c-b6b7-fe99acbd5320	ISAC20p	isac20p	ALIAS
2ac90ca7-6e93-44ee-899d-76375ba6f583	ISAC20p Ammo	isac20pammo	ALIAS
c635cf34-b79f-4b80-9d79-69934270e1fe	IS Ammo AC/20 Primitive	isammoac20primitive	ALIAS
31d7ecfe-5d9c-47e8-ae9e-3b2893630ca1	IS Auto Cannon/20 Primitive	isautocannon20primitive	ALIAS
e99ebffd-b9eb-46a7-8946-b7d27fd2a50d	IS Autocannon/20 Primitive Ammo	isautocannon20primitiveammo	ALIAS
8f26b849-0948-40c9-8e1e-cfbafbf58a88	ISBAAutoGL	isbaautogl	ALIAS
84c5d466-ea17-44a4-8a1d-f531f751e812	IS BA Grenade Launcher	isbagrenadelauncher	ALIAS
b096da70-5eb3-4a46-8b91-59e402085b28	ISBAHeavyGL	isbaheavygl	ALIAS
ce38850f-456f-47bc-88de-ce2a08925a69	ISBAHeavyGrenadeLauncher	isbaheavygrenadelauncher	ALIAS
8f7ffcab-7ab5-4fb8-8e37-fe7a9c56d2b0	IS BA Plasma Rifle	isbaplasmarifle	ALIAS
ff51b084-ed9d-4c32-9eb0-1a20e0943e3e	ISHighResImager	ishighresimager	ALIAS
c3267df2-3a9a-43e8-8219-31f8eada3b66	ISInfraredImager	isinfraredimager	ALIAS
3d300fff-fe24-4264-89d3-b5d0c6a186ab	ISSVDuneBuggy	issvdunebuggy	ALIAS
becc4dde-34d1-4694-90ae-1293c660baa0	ISSVDuneBuggyChassis	issvdunebuggychassis	ALIAS
e97b3574-1130-4caf-8991-0990e2f6d943	Ladder	ladder	ALIAS
08817307-108b-4f6a-bc25-232c31edc200	Ladder (100m)	ladder100m	ALIAS
01b14f29-60c0-4dce-aaa0-432d53effb09	Ladder (20m)	ladder20m	ALIAS
110459c4-63bf-4864-aabc-5762f05c4012	Ladder (40m)	ladder40m	ALIAS
1f1d626f-6f7a-43e7-ab6c-75aa6debe60b	Ladder (60m)	ladder60m	ALIAS
403e9a58-99be-49c1-9af2-709e0634916c	Ladder (80m)	ladder80m	ALIAS
b96865c0-c568-4baa-bfc9-fb3843418c29	Laser Rifle (Mauser IIC IAS)	laserriflemauseriicias	ALIAS
b8ad403c-e6d1-40c5-84f5-b327ed23a888	Light SRM Launcher	lightsrmlauncher	ALIAS
3236cd7f-9cff-4cb6-862b-1e18ffbaa599	Machine Gun (Semi-Portable)	machinegunsemiportable	ALIAS
60f2999c-8409-41e2-93fd-e5c3db071e5b	Machine Gun (Support)	machinegunsupport	ALIAS
deacdfa0-1ad2-4015-8e80-febf1070f69b	Manipulator	manipulator	ALIAS
c698f980-6b4c-4b74-bb80-861aca27e946	Manipulator (Non-Mech/Non-BattleArmor)	manipulatornonmechnonbattlearmor	ALIAS
1b0faa63-adc9-4f14-83da-8f4b2231bfea	MonocycleChassisMod	monocyclechassismod	ALIAS
86aa2a53-e41b-4e86-adcd-fc2864411506	OmniChassisMod	omnichassismod	ALIAS
63bfaed7-8735-470b-bc61-f7d1ec1e76cb	Pintle Mount	pintlemount	ALIAS
a1321dd8-5384-4fd9-8c3e-705e4bc46451	PintleTurret	pintleturret	ALIAS
6fd48c9f-82a4-49f0-8581-0617c96e7740	Plasma Rifle (Man-Portable)	plasmariflemanportable	ALIAS
1c97aad7-1110-4f21-b06c-b16a9a5f803f	Portable Plasma Rifle	portableplasmarifle	ALIAS
f128f8b7-ba07-402a-810a-079b9aabb030	Primitive Prototype Autocannon/20	primitiveprototypeautocannon20	ALIAS
4651d7db-0720-4b59-89cb-b8f49bac0e47	Primitive Prototype Autocannon/20 Ammo	primitiveprototypeautocannon20ammo	ALIAS
96642954-8346-46ff-95af-111fc6ea043b	Recoilless Rifle (Heavy)	recoillessrifleheavy	ALIAS
79b7717b-ed86-4bcb-90d0-f70c9bc24931	Satellite Imager [High-Resolution (Hi-Res) Imager]	satelliteimagerhighresolutionhiresimager	ALIAS
fe751458-4649-4dfc-bcdd-483dbab72027	Satellite Imager (High-Resolution Imager)	satelliteimagerhighresolutionimager	ALIAS
37fbc8b7-f58d-40b4-855d-b9b4ff5a6287	Satellite Imager (Infrared Imager)	satelliteimagerinfraredimager	ALIAS
682b1625-0128-4478-9e3e-e06f4e1c8984	Searchlight (Handheld)	searchlighthandheld	ALIAS
f3ecf98d-0d5e-4e1b-b547-4ec01eb17d67	SnowmobileChassis	snowmobilechassis	ALIAS
8aed3613-f3bc-438b-844f-bd9e908d165b	SnowmobileChassisMod	snowmobilechassismod	ALIAS
70ffcf73-2e5a-4c6c-9e24-ac0393f783c7	Sprayer (Vehicular)	sprayervehicular	ALIAS
68d39f03-6298-4a3b-9574-4ec3cc6ae661	SRM Launcher (Light)	srmlauncherlight	ALIAS
0d434169-df4e-4bae-8449-8458df64f2ec	SRM Launcher (Std, Two-Shot)	srmlauncherstdtwoshot	ALIAS
d5ebc041-6a12-480f-b6bb-c3f2385f0ae3	SubmersibleChassisMod	submersiblechassismod	ALIAS
74f25fdc-88f6-4bc8-afc5-eaf438f0a4b4	Support Laser	supportlaser	ALIAS
65f1bd83-f98b-4390-9ce0-fd930d6943d3	Support Laser (Heavy)	supportlaserheavy	ALIAS
d44262ad-8317-40c3-a985-1bd560569701	Support Laser (Semi-Portable)	supportlasersemiportable	ALIAS
5828b914-4a93-44fe-b326-833e6dcd5eb2	SV Chassis Mod [Amphibious]	svchassismodamphibious	ALIAS
973947f6-d408-4e47-9cde-9860c1cb19c0	SV Chassis Mod [Bicycle]	svchassismodbicycle	ALIAS
1c563c19-64de-4c17-8b9f-236aa4fbc97d	SV Chassis Mod [Convertible]	svchassismodconvertible	ALIAS
bfb00452-566d-403a-a79b-a0375bd15d8b	SV Chassis Mod [Dune Buggy]	svchassismoddunebuggy	ALIAS
b5b8a21b-bc0b-4f12-9706-fe35698317e1	SV Chassis Mod [HydroFoil]	svchassismodhydrofoil	ALIAS
7e3b7b77-9774-4ebb-84ee-b757e1724075	SV Chassis Mod [Monocycle]	svchassismodmonocycle	ALIAS
5d202852-e038-43bc-b35e-74dc8444470b	SV Chassis Mod [Omni]	svchassismodomni	ALIAS
755b7450-ae05-4d47-ab5a-8cb0d9ffce55	SV Chassis Mod [Snowmobile]	svchassismodsnowmobile	ALIAS
7fbcb1ff-ab26-4dcf-bc80-eaf04ce06f0e	SV Chassis Mod [Submersible]	svchassismodsubmersible	ALIAS
44c06974-8d1f-4122-a9da-48710a5d92f1	SV Chassis Mod [Tractor]	svchassismodtractor	ALIAS
494431d0-87e9-4ad4-8924-1bdbb84d7292	SV Chassis Mod [Trailer]	svchassismodtrailer	ALIAS
be4f38bc-dc29-419b-813a-761081f24c77	SV Chassis Mod [Ultra-Light]	svchassismodultralight	ALIAS
e3ddf0c3-2d99-43e5-8cb9-15bdff61788c	SVDuneBuggy	svdunebuggy	ALIAS
b165a7c3-d23f-4d1a-9082-e0bd2704ad8d	SVDuneBuggyChassis	svdunebuggychassis	ALIAS
21709ed6-84ce-4a12-bbb6-5159500871ce	TAG (Light, Man-Portable)	taglightmanportable	ALIAS
adff33e1-e41d-4840-bace-c375a83af1cb	Tank Sprayer	tanksprayer	ALIAS
0c4fbfc1-3ecf-49d5-96c6-312f2f0b1084	Tractor	tractor	ALIAS
1c792f98-528b-4e9b-937f-d42feb086da4	TractorChassisMod	tractorchassismod	ALIAS
0eb1fe39-9507-4c13-90d8-e98577ccc931	Trailer	trailer	ALIAS
4a87d15c-5d78-4a65-bc84-69aba8da0224	TrailerChassisMod	trailerchassismod	ALIAS
12fd35aa-8499-4ae7-bb78-0b022e5ab766	UltraLightChassisMod	ultralightchassismod	ALIAS
33400917-bdf0-4780-bdf5-9d556c4c8954	Wire-Guided Missile Launcher	wireguidedmissilelauncher	ALIAS
\.

INSERT INTO slang (id, term, lookup, kind)
SELECT v.id, v.term, v.lookup, v.kind FROM v3_22_slang v
WHERE NOT EXISTS (SELECT 1 FROM slang s WHERE s.lookup = v.lookup);

COPY v3_22_link (lookup, name, tech) FROM stdin;
ac20p	primitiveprototypeautocannon/20	INNER_SPHERE
ac20pammo	primitiveprototypeautocannon/20ammo	INNER_SPHERE
ammoac20primitive	primitiveprototypeautocannon/20ammo	INNER_SPHERE
amphibiouschassis	svchassismod[amphibious]	INNER_SPHERE
amphibiouschassismod	svchassismod[amphibious]	INNER_SPHERE
autocannon20primitive	primitiveprototypeautocannon/20	INNER_SPHERE
autocannon20primitiveammo	primitiveprototypeautocannon/20ammo	INNER_SPHERE
autocannonbearhuntersuperheavy	autocannon(bearhuntersuperheavy)	CLAN
autocannonsemiportable	autocannon(semi-portable)	INNER_SPHERE
autorifle	auto-rifle(modern,generic)	INNER_SPHERE
autoriflemoderngeneric	auto-rifle(modern,generic)	INNER_SPHERE
baautogl	grenadelauncher(heavy)	INNER_SPHERE
bagrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
baheavygl	grenadelauncher(heavy)	INNER_SPHERE
baheavygrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
baplasmarifle	plasmarifle(man-portable)	INNER_SPHERE
bicyclechassismod	svchassismod[bicycle]	CLAN
bicyclechassismod	svchassismod[bicycle]	INNER_SPHERE
bridgelayerheavy	bridgelayer(heavy)	INNER_SPHERE
convertiblechassismod	svchassismod[convertible]	INNER_SPHERE
dunebuggychassismod	svchassismod[dunebuggy]	INNER_SPHERE
fieldkitchen	fieldkitchen	INNER_SPHERE
fluidsuctionsystem	fluidsuctionsystem(standard)	INNER_SPHERE
fluidsuctionsystemstandard	fluidsuctionsystem(standard)	INNER_SPHERE
gaussriflelightkingdavid	gaussrifle,light(kingdavid)	INNER_SPHERE
grenadelauncherauto	grenadelauncher(auto)	INNER_SPHERE
grenadelauncherheavy	grenadelauncher(heavy)	INNER_SPHERE
heavybagrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
heavybridgelayer	bridgelayer(heavy)	INNER_SPHERE
hhsearchlight	searchlight(handheld)	INNER_SPHERE
highresimager	satelliteimager(high-resolutionimager)	INNER_SPHERE
hydrofoilchassismod	svchassismod[hydrofoil]	INNER_SPHERE
infantry2shotsrm	srmlauncher(std,two-shot)	INNER_SPHERE
infantryassaultrifle	auto-rifle(modern,generic)	INNER_SPHERE
infantryautogl	grenadelauncher(auto)	INNER_SPHERE
infantryautogrenadelauncher	grenadelauncher(auto)	INNER_SPHERE
infantryautomaticrifle	auto-rifle(modern,generic)	INNER_SPHERE
infantryautorifle	auto-rifle(modern,generic)	INNER_SPHERE
infantrybearhunter	autocannon(bearhuntersuperheavy)	CLAN
infantrybearhunterautocannon	autocannon(bearhuntersuperheavy)	CLAN
infantrybearhuntersuperheavyautocannon	autocannon(bearhuntersuperheavy)	CLAN
infantryclanmauseriic	laserrifle(mauseriicias)	CLAN
infantryclanmauseriicias	laserrifle(mauseriicias)	CLAN
infantryheavygrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
infantryheavylaser	supportlaser(heavy)	INNER_SPHERE
infantryheavyrecoillessrifle	recoillessrifle(heavy)	INNER_SPHERE
infantryhmg	machinegun(support)	INNER_SPHERE
infantryhrr	recoillessrifle(heavy)	INNER_SPHERE
infantrykingdavid	gaussrifle,light(kingdavid)	INNER_SPHERE
infantrykingdavidlightgaussrifle	gaussrifle,light(kingdavid)	INNER_SPHERE
infantrymediumlaser	supportlaser(heavy)	INNER_SPHERE
infantrymgsemiportable	machinegun(semi-portable)	INNER_SPHERE
infantrymppr	plasmarifle(man-portable)	INNER_SPHERE
infantryplasmaportable	plasmarifle(man-portable)	INNER_SPHERE
infantryplasmarifle	plasmarifle(man-portable)	INNER_SPHERE
infantryportableautocannon	autocannon(semi-portable)	INNER_SPHERE
infantrysemimg	machinegun(semi-portable)	INNER_SPHERE
infantrysemiportableautocannon	autocannon(semi-portable)	INNER_SPHERE
infantrysemiportablelaser	supportlaser(semi-portable)	CLAN
infantrysmalllaser	supportlaser	INNER_SPHERE
infantrysrm	srmlauncher(light)	INNER_SPHERE
infantrysrmlight	srmlauncher(light)	INNER_SPHERE
infantrystandardsrm	srmlauncher(std,two-shot)	INNER_SPHERE
infantrysupportlaser	supportlaser	INNER_SPHERE
infantrysupportmachinegun	machinegun(support)	INNER_SPHERE
infantrysupportmg	machinegun(support)	INNER_SPHERE
infantrytag	tag(light,man-portable)	INNER_SPHERE
infantrytwoshotsrmlauncher	srmlauncher(std,two-shot)	INNER_SPHERE
infantrywireguidedmissilelauncher	wire-guidedmissilelauncher	INNER_SPHERE
infraredimager	satelliteimager(infraredimager)	INNER_SPHERE
isac20p	primitiveprototypeautocannon/20	INNER_SPHERE
isac20pammo	primitiveprototypeautocannon/20ammo	INNER_SPHERE
isammoac20primitive	primitiveprototypeautocannon/20ammo	INNER_SPHERE
isautocannon20primitive	primitiveprototypeautocannon/20	INNER_SPHERE
isautocannon20primitiveammo	primitiveprototypeautocannon/20ammo	INNER_SPHERE
isbaautogl	grenadelauncher(heavy)	INNER_SPHERE
isbagrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
isbaheavygl	grenadelauncher(heavy)	INNER_SPHERE
isbaheavygrenadelauncher	grenadelauncher(heavy)	INNER_SPHERE
isbaplasmarifle	plasmarifle(man-portable)	INNER_SPHERE
ishighresimager	satelliteimager(high-resolutionimager)	INNER_SPHERE
isinfraredimager	satelliteimager(infraredimager)	INNER_SPHERE
issvdunebuggy	svchassismod[dunebuggy]	INNER_SPHERE
issvdunebuggychassis	svchassismod[dunebuggy]	INNER_SPHERE
ladder	ladder	INNER_SPHERE
ladder100m	ladder	INNER_SPHERE
ladder20m	ladder	INNER_SPHERE
ladder40m	ladder	INNER_SPHERE
ladder60m	ladder	INNER_SPHERE
ladder80m	ladder	INNER_SPHERE
laserriflemauseriicias	laserrifle(mauseriicias)	CLAN
lightsrmlauncher	srmlauncher(light)	INNER_SPHERE
machinegunsemiportable	machinegun(semi-portable)	INNER_SPHERE
machinegunsupport	machinegun(support)	INNER_SPHERE
manipulator	manipulator(non-mech/non-battlearmor)	INNER_SPHERE
manipulatornonmechnonbattlearmor	manipulator(non-mech/non-battlearmor)	INNER_SPHERE
monocyclechassismod	svchassismod[monocycle]	INNER_SPHERE
omnichassismod	svchassismod[omni]	CLAN
omnichassismod	svchassismod[omni]	INNER_SPHERE
pintlemount	pintlemount	INNER_SPHERE
pintleturret	pintlemount	INNER_SPHERE
plasmariflemanportable	plasmarifle(man-portable)	INNER_SPHERE
portableplasmarifle	plasmarifle(man-portable)	INNER_SPHERE
primitiveprototypeautocannon20	primitiveprototypeautocannon/20	INNER_SPHERE
primitiveprototypeautocannon20ammo	primitiveprototypeautocannon/20ammo	INNER_SPHERE
recoillessrifleheavy	recoillessrifle(heavy)	INNER_SPHERE
satelliteimagerhighresolutionhiresimager	satelliteimager(high-resolutionimager)	INNER_SPHERE
satelliteimagerhighresolutionimager	satelliteimager(high-resolutionimager)	INNER_SPHERE
satelliteimagerinfraredimager	satelliteimager(infraredimager)	INNER_SPHERE
searchlighthandheld	searchlight(handheld)	INNER_SPHERE
snowmobilechassis	svchassismod[snowmobile]	INNER_SPHERE
snowmobilechassismod	svchassismod[snowmobile]	INNER_SPHERE
sprayervehicular	sprayer(vehicular)	INNER_SPHERE
srmlauncherlight	srmlauncher(light)	INNER_SPHERE
srmlauncherstdtwoshot	srmlauncher(std,two-shot)	INNER_SPHERE
submersiblechassismod	svchassismod[submersible]	INNER_SPHERE
supportlaser	supportlaser	INNER_SPHERE
supportlaserheavy	supportlaser(heavy)	INNER_SPHERE
supportlasersemiportable	supportlaser(semi-portable)	CLAN
svchassismodamphibious	svchassismod[amphibious]	INNER_SPHERE
svchassismodbicycle	svchassismod[bicycle]	CLAN
svchassismodbicycle	svchassismod[bicycle]	INNER_SPHERE
svchassismodconvertible	svchassismod[convertible]	INNER_SPHERE
svchassismoddunebuggy	svchassismod[dunebuggy]	INNER_SPHERE
svchassismodhydrofoil	svchassismod[hydrofoil]	INNER_SPHERE
svchassismodmonocycle	svchassismod[monocycle]	INNER_SPHERE
svchassismodomni	svchassismod[omni]	CLAN
svchassismodomni	svchassismod[omni]	INNER_SPHERE
svchassismodsnowmobile	svchassismod[snowmobile]	INNER_SPHERE
svchassismodsubmersible	svchassismod[submersible]	INNER_SPHERE
svchassismodtractor	svchassismod[tractor]	INNER_SPHERE
svchassismodtrailer	svchassismod[trailer]	INNER_SPHERE
svchassismodultralight	svchassismod[ultra-light]	INNER_SPHERE
svdunebuggy	svchassismod[dunebuggy]	INNER_SPHERE
svdunebuggychassis	svchassismod[dunebuggy]	INNER_SPHERE
taglightmanportable	tag(light,man-portable)	INNER_SPHERE
tanksprayer	sprayer(vehicular)	INNER_SPHERE
tractor	svchassismod[tractor]	INNER_SPHERE
tractorchassismod	svchassismod[tractor]	INNER_SPHERE
trailer	svchassismod[trailer]	INNER_SPHERE
trailerchassismod	svchassismod[trailer]	INNER_SPHERE
ultralightchassismod	svchassismod[ultra-light]	INNER_SPHERE
wireguidedmissilelauncher	wire-guidedmissilelauncher	INNER_SPHERE
\.

INSERT INTO slang_equipment (slang_id, equipment_id)
SELECT s.id, e.id
FROM v3_22_link l
JOIN slang s ON s.lookup = l.lookup
JOIN equipment e ON e.name = l.name AND e.tech IS NOT DISTINCT FROM l.tech
WHERE NOT EXISTS (SELECT 1 FROM slang_equipment x WHERE x.slang_id = s.id AND x.equipment_id = e.id);

-- 5.
UPDATE unit_equipment ue SET equipment_id = vf.id
FROM unit u, unit_mech_equipment um, equipment f, equipment vf
WHERE u.megamek_uuid = '019f583e-ec7e-7b9b-b6bb-40be930a143f'
  AND um.unit_id = u.id AND um.mech_equipment_id = ue.id
  AND ue.location IN ('LEFT', 'RIGHT')
  AND ue.equipment_id = f.id AND f.name = 'flamer' AND f.tech = 'INNER_SPHERE'
  AND vf.name = 'flamer(vehicle)' AND vf.tech = 'INNER_SPHERE';

DROP TABLE v3_22_equipment, v3_22_unit, v3_22_item, v3_22_new_item, v3_22_slang, v3_22_link;
